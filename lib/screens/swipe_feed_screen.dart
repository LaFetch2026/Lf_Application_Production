// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/lf_loader_widget.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../core/constant/constants.dart';
import '../core/utils/share_link_generator.dart';
import '../models/recommendation_event.dart';
import '../screens/bottomnavscreen.dart';
import '../screens/cartscreen.dart';
import '../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import '../screens/wishlistscreen.dart';
import '../services/event_tracking_service.dart';
import '../services/swipe_feed_service.dart';
import '../widgets/swipe_product_card.dart';

// ─── SharedPreferences key for first-time tutorial ───────────────────────────
const _kSwipeTutorialSeen = 'swipe_tutorial_seen';

// ─── "LF Swipes" board name ───────────────────────────────────────────────────
const _kSwipeBoardName = 'LF Swipes';

class SwipeFeedScreen extends StatefulWidget {
  const SwipeFeedScreen({super.key});

  @override
  State<SwipeFeedScreen> createState() => _SwipeFeedScreenState();
}

class _SwipeFeedScreenState extends State<SwipeFeedScreen>
    with TickerProviderStateMixin {
  // ── Feed state ───────────────────────────────────────────────────────────
  List<RecommendationProduct> _cards = [];
  bool _isFetching = false;
  bool _hasError = false;

  // ── Gender filter: 0=All, 1=Men, 2=Women ────────────────────────────────
  int _genderFilter = 0;

  // ── Undo / rewind ────────────────────────────────────────────────────────
  RecommendationProduct? _lastSwiped;
  SwipeAction? _lastAction;

  // ── Tutorial overlay ─────────────────────────────────────────────────────
  bool _showTutorial = false;

  // ── Cart flash animation ─────────────────────────────────────────────────
  late final AnimationController _cartFlashController;
  late final Animation<double> _cartFlashAnim;
  bool _showCartFlash = false;

  // ── Wishlist flash ────────────────────────────────────────────────────────
  bool _showWishlistFlash = false;

  // ── Controllers ──────────────────────────────────────────────────────────
  late final WishlistController _wishlistCtrl;
  late final CartController _cartCtrl;

  @override
  void initState() {
    super.initState();
    _wishlistCtrl = Get.find<WishlistController>();
    _cartCtrl = Get.find<CartController>();

    _cartFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cartFlashAnim = CurvedAnimation(
      parent: _cartFlashController,
      curve: Curves.easeOut,
    );
    _cartFlashController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _cartFlashController.reverse();
      }
      if (s == AnimationStatus.dismissed) {
        if (mounted) setState(() => _showCartFlash = false);
      }
    });

    _fetchBatch();
    _checkTutorial();
  }

  @override
  void dispose() {
    _cartFlashController.dispose();
    super.dispose();
  }

  // ── Tutorial ─────────────────────────────────────────────────────────────

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_kSwipeTutorialSeen) ?? false;
    if (!seen && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSwipeTutorialSeen, true);
    if (mounted) setState(() => _showTutorial = false);
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchBatch() async {
    if (_isFetching) return;
    final wasEmpty = _cards.isEmpty;
    setState(() {
      _isFetching = true;
      _hasError = false;
    });

    try {
      final results = await SwipeFeedService.instance.fetchBatch(
        genderFilter: _genderFilter,
      );
      if (mounted) {
        setState(() {
          _cards = [..._cards, ...results];
          _isFetching = false;
          if (wasEmpty && results.isEmpty) _hasError = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _hasError = true;
          _isFetching = false;
        });
    }
  }

  void _maybePrefetch() {
    if (_cards.length <= 3 && !_isFetching) _fetchBatch();
  }

  // ── Swipe actions ─────────────────────────────────────────────────────────

  Future<void> _onCardSwiped(
      SwipeAction action, RecommendationProduct product) async {
    _lastSwiped = product;
    _lastAction = action;

    EventTrackingService.instance.trackSwipe(action, product.id);

    switch (action) {
      case SwipeAction.likeProduct:
        // Like → add to "LF Swipes" wishlist board + lavender flash
        setState(() {
          _showWishlistFlash = true;
          _cards.removeAt(0);
        });
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _showWishlistFlash = false);
        });
        _addToSwipesBoard(product);
        break;

      case SwipeAction.dislikeProduct:
        setState(() => _cards.removeAt(0));
        break;

      case SwipeAction.swipeUp:
        // Swipe up → add to cart directly (navigate to PDP to pick size if needed)
        // Show black flash, remove card, open PDP for size selection → add to cart
        setState(() {
          _showCartFlash = true;
          _cards.removeAt(0);
        });
        _cartFlashController.forward(from: 0);
        // Open PDP so user can select size and add to cart
        _openPdp(product);
        break;

      case SwipeAction.swipeDown:
        // Swipe down → open PDP, card stays in stack
        _openPdp(product);
        return;
    }

    _maybePrefetch();
  }

  void _openPdp(RecommendationProduct product) {
    Get.to(
      () => ProductDetailsScreenV2(
        productId: product.id,
        brandName: product.brandName,
        type: 'add',
        Slug: product.slug,
      ),
    );
  }

  Future<void> _addToSwipesBoard(RecommendationProduct product) async {
    try {
      // Ensure boards are loaded
      if (_wishlistCtrl.wishlistList.isEmpty) {
        await _wishlistCtrl.fetchBoards();
      }

      // Find or create "LF Swipes" board
      final existing = _wishlistCtrl.wishlistList.firstWhereOrNull(
        (b) =>
            (b['name'] as String?)?.toLowerCase() ==
            _kSwipeBoardName.toLowerCase(),
      );

      int boardId;
      if (existing != null) {
        boardId = existing['id'] as int;
      } else {
        // Create the board silently
        await _wishlistCtrl.createBoard(_kSwipeBoardName);
        await _wishlistCtrl.fetchBoards();
        final created = _wishlistCtrl.wishlistList.firstWhereOrNull(
          (b) =>
              (b['name'] as String?)?.toLowerCase() ==
              _kSwipeBoardName.toLowerCase(),
        );
        if (created == null) return;
        boardId = created['id'] as int;
      }

      await _wishlistCtrl.addProductToBoard(boardId, product.id,
          price: product.sellingPrice);
    } catch (e) {
      debugPrint('[SwipeFeed] addToSwipesBoard error: $e');
    }
  }

  Future<void> _shareProduct(RecommendationProduct product) async {
    final link = await ShareLinkGenerator.generateProductShareLink(
      productId: product.id,
      slug: product.slug,
      brandName: product.brandName,
      type: 'add',
    );
    Share.share('Check out ${product.productName} on LaFetch!\n$link');
  }

  // ── Rewind ────────────────────────────────────────────────────────────────

  void _rewind() {
    if (_lastSwiped == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _cards.insert(0, _lastSwiped!);
      _lastSwiped = null;
      _lastAction = null;
    });
  }

  // ── Gender filter ─────────────────────────────────────────────────────────

  void _setGenderFilter(int gender) {
    if (_genderFilter == gender) return;
    setState(() {
      _genderFilter = gender;
      _cards.clear();
      _hasError = false;
    });
    _fetchBatch();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildGenderTabs(),
              Expanded(child: _buildBody()),
            ],
          ),
          // Cart flash overlay
          if (_showCartFlash) _CartFlashOverlay(animation: _cartFlashAnim),
          // Wishlist flash overlay
          if (_showWishlistFlash) _WishlistFlashOverlay(),
          // Tutorial overlay (on top of everything)
          if (_showTutorial) _TutorialOverlay(onDismiss: _dismissTutorial),
        ],
      ),
      bottomNavigationBar: _buildHintBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18.sp, color: homeAppBarColor),
        onPressed: () {
          // Pop back; if nothing in stack, go to BottomNavScreen (home)
          if (Get.previousRoute.isNotEmpty) {
            Get.back();
          } else {
            Get.offAll(() => const BottomNavScreen());
          }
        },
      ),
      title: Text(
        'LF Swipe',
        style: TextStyle(
          fontFamily: 'Clash Display Semibold',
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: homeAppBarColor,
        ),
      ),
      centerTitle: true,
      actions: [
        // Wishlist
        Obx(() {
          final count = _wishlistCtrl.wishlistCount.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border_rounded,
                    size: 20.sp, color: homeAppBarColor),
                onPressed: () => Get.to(() => const WishlistScreen()),
              ),
              if (count > 0)
                Positioned(
                  right: 6.sp,
                  top: 6.sp,
                  child: Container(
                    padding: EdgeInsets.all(2.sp),
                    constraints:
                        BoxConstraints(minWidth: 14.sp, minHeight: 14.sp),
                    decoration: const BoxDecoration(
                        color: lightPurpleColor, shape: BoxShape.circle),
                    child: Text(
                      '$count',
                      style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontFamily: 'Clash Display Regular'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
        // Cart
        Obx(() {
          final count = _cartCtrl.cartTotalValue.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined,
                    size: 20.sp, color: homeAppBarColor),
                onPressed: () =>
                    Get.to(() => CartScreen(backgroundcolor: homeAppBarColor)),
              ),
              if (count > 0)
                Positioned(
                  right: 6.sp,
                  top: 6.sp,
                  child: Container(
                    padding: EdgeInsets.all(2.sp),
                    constraints:
                        BoxConstraints(minWidth: 14.sp, minHeight: 14.sp),
                    decoration: const BoxDecoration(
                        color: homeAppBarColor, shape: BoxShape.circle),
                    child: Text(
                      '$count',
                      style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontFamily: 'Clash Display Regular'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
        SizedBox(width: 4.sp),
      ],
    );
  }

  Widget _buildGenderTabs() {
    const labels = ['All', 'Men', 'Women'];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Row(
        children: [
          ...List.generate(3, (i) {
            final selected = _genderFilter == i;
            return GestureDetector(
              onTap: () => _setGenderFilter(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.sp),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: selected ? homeAppBarColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.sp),
                  border: Border.all(
                      color: selected ? homeAppBarColor : Colors.grey[300]!),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontFamily: 'Clash Display',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: selected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            );
          }),
          // Rewind + Retry live on the right of the tabs row
          if (_lastSwiped != null || (_hasError && _cards.isEmpty)) ...[
            const Spacer(),
            // Rewind (undo last swipe)
            if (_lastSwiped != null)
              GestureDetector(
                onTap: _rewind,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay_rounded, color: homeAppBarColor, size: 14.sp),
                      SizedBox(width: 4.sp),
                      Text('Undo',
                          style: TextStyle(
                              fontFamily: 'Clash Display',
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: homeAppBarColor)),
                    ],
                  ),
                ),
              ),
            // Retry (when error)
            if (_hasError && _cards.isEmpty) ...[
              if (_lastSwiped != null) SizedBox(width: 8.sp),
              GestureDetector(
                onTap: _fetchBatch,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
                  decoration: BoxDecoration(
                    color: homeAppBarColor,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.sp),
                      Text('Retry',
                          style: TextStyle(
                              fontFamily: 'Clash Display',
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cards.isEmpty && _isFetching) {
      return Center(
        child: LfLogoLoader(
            size: 48, brandColor: Colors.grey[200]!, showGlow: false),
      );
    }

    if (_cards.isEmpty && _hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LfLogoLoader(
                  size: 48, brandColor: Colors.grey[200]!, showGlow: false),
              SizedBox(height: 20.sp),
              Text('Could not load feed',
                  style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: homeAppBarColor)),
              SizedBox(height: 6.sp),
              Text('Tap Retry above to try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Clash Display Regular',
                      fontSize: 13.sp,
                      color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    if (_cards.isEmpty && !_isFetching && !_hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You've seen it all! 🎉",
                  style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontWeight: FontWeight.w600,
                      fontSize: 22.sp,
                      color: homeAppBarColor),
                  textAlign: TextAlign.center),
              SizedBox(height: 8.sp),
              Text('Check back later for new arrivals',
                  style: TextStyle(
                      fontFamily: 'Clash Display Regular',
                      fontSize: 14.sp,
                      color: Colors.grey[500]),
                  textAlign: TextAlign.center),
              SizedBox(height: 28.sp),
              _PillButton(label: 'Refresh', onTap: _fetchBatch),
            ],
          ),
        ),
      );
    }

    final visibleCards = _cards.take(3).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: Stack(
        children: [
          for (int i = visibleCards.length - 1; i >= 0; i--)
            _buildCardAtIndex(i, visibleCards[i]),
          // Share button (top-right of top card)
          if (visibleCards.isNotEmpty)
            Positioned(
              right: 12.sp,
              bottom: 80.sp,
              child: _ActionButton(
                icon: Icons.share_outlined,
                color: Colors.white,
                bgColor: Colors.black.withOpacity(0.4),
                onTap: () => _shareProduct(visibleCards.first),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardAtIndex(int index, RecommendationProduct product) {
    const configs = [
      (scale: 1.00, verticalOffset: 0.0, isTop: true),
      (scale: 0.96, verticalOffset: 10.0, isTop: false),
      (scale: 0.92, verticalOffset: 20.0, isTop: false),
    ];
    final config = configs[index];
    return SwipeProductCard(
      key: ValueKey(product.id),
      product: product,
      isTop: config.isTop,
      scale: config.scale,
      verticalOffset: config.verticalOffset,
      onSwiped: (action) => _onCardSwiped(action, product),
    );
  }

  Widget _buildHintBar() {
    return Container(
      color: Colors.white,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHintIcon(
              icon: Icons.close_rounded,
              color: Colors.red,
              label: 'Nope',
              action: SwipeAction.dislikeProduct),
          _buildHintIcon(
              icon: Icons.open_in_new_rounded,
              color: Colors.grey[600]!,
              label: 'View',
              action: SwipeAction.swipeDown),
          _buildHintIcon(
              icon: Icons.bookmark_add_outlined,
              color: lightPurpleColor,
              label: 'Save',
              action: SwipeAction.swipeUp),
          _buildHintIcon(
              icon: Icons.favorite_rounded,
              color: lightPurpleColor,
              label: 'Like',
              action: SwipeAction.likeProduct),
        ],
      ),
    );
  }

  Widget _buildHintIcon({
    required IconData icon,
    required Color color,
    required String label,
    required SwipeAction action,
  }) {
    return GestureDetector(
      onTap: () {
        if (_cards.isNotEmpty) _onCardSwiped(action, _cards.first);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 2.sp),
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Reusable pill button ─────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.sp, vertical: 14.sp),
        decoration: BoxDecoration(
          color: homeAppBarColor,
          borderRadius: BorderRadius.circular(30.sp),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Clash Display',
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: Colors.white)),
      ),
    );
  }
}

// ─── Small circular action button ────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.color,
      required this.bgColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.sp,
        height: 36.sp,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }
}

// ─── Cart flash overlay ───────────────────────────────────────────────────────

class _CartFlashOverlay extends StatelessWidget {
  final Animation<double> animation;
  const _CartFlashOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Opacity(
          opacity:
              (animation.value * (1 - animation.value) * 4).clamp(0.0, 0.65),
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_rounded,
                      color: Colors.white, size: 48.sp),
                  SizedBox(height: 8.sp),
                  Text('Added to cart ✓',
                      style: TextStyle(
                          fontFamily: 'Clash Display Semibold',
                          fontSize: 16.sp,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Wishlist flash overlay ───────────────────────────────────────────────────

class _WishlistFlashOverlay extends StatelessWidget {
  const _WishlistFlashOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          builder: (_, v, child) => Opacity(
            opacity: v > 0.5 ? (1 - v) * 2 : v * 2,
            child: child,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 14.sp),
            decoration: BoxDecoration(
              color: lightPurpleColor,
              borderRadius: BorderRadius.circular(30.sp),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_rounded, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.sp),
                Text('Added to LF Swipes',
                    style: TextStyle(
                        fontFamily: 'Clash Display Semibold',
                        fontSize: 14.sp,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── First-time tutorial overlay ─────────────────────────────────────────────

class _TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  const _TutorialOverlay({required this.onDismiss});

  @override
  State<_TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<_TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  int _step = 0;

  static const _steps = [
    _TutorialStep(
        icon: Icons.swipe_right_rounded,
        color: Color(0xFF988AFF),
        label: 'Swipe right to Like',
        sub: 'Saves to your LF Swipes wishlist board'),
    _TutorialStep(
        icon: Icons.swipe_left_rounded,
        color: Color(0xFFF44336),
        label: 'Swipe left to Nope',
        sub: 'Hides this style from your feed'),
    _TutorialStep(
        icon: Icons.swipe_up_rounded,
        color: Color(0xFF171717),
        label: 'Swipe up to Add to Cart',
        sub: 'Opens the product so you can pick your size'),
    _TutorialStep(
        icon: Icons.swipe_down_rounded,
        color: Color(0xFF374151),
        label: 'Swipe down to View',
        sub: 'Opens the full product page'),
    _TutorialStep(
        icon: Icons.touch_app_rounded,
        color: Color(0xFF988AFF),
        label: 'Tap to cycle photos',
        sub: 'Tap left or right on the card to see more images'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _ctrl.reverse().then((_) => widget.onDismiss());
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: _next,
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated swipe icon
                TweenAnimationBuilder<double>(
                  key: ValueKey(_step),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, child) => Transform.scale(
                      scale: 0.7 + 0.3 * v,
                      child: Opacity(opacity: v, child: child)),
                  child: Container(
                    width: 100.sp,
                    height: 100.sp,
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: step.color, width: 2),
                    ),
                    child: Icon(step.icon, color: step.color, size: 48.sp),
                  ),
                ),
                SizedBox(height: 28.sp),
                Text(
                  step.label,
                  style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.sp),
                Text(
                  step.sub,
                  style: TextStyle(
                      fontFamily: 'Clash Display Regular',
                      fontSize: 15.sp,
                      color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.sp),
                // Step dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      _steps.length,
                      (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: 4.sp),
                            width: i == _step ? 20.sp : 6.sp,
                            height: 6.sp,
                            decoration: BoxDecoration(
                              color: i == _step ? Colors.white : Colors.white38,
                              borderRadius: BorderRadius.circular(3.sp),
                            ),
                          )),
                ),
                SizedBox(height: 32.sp),
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.sp, vertical: 14.sp),
                    decoration: BoxDecoration(
                      color: step.color,
                      borderRadius: BorderRadius.circular(30.sp),
                    ),
                    child: Text(
                      _step < _steps.length - 1 ? 'Next' : 'Let\'s go!',
                      style: TextStyle(
                          fontFamily: 'Clash Display',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16.sp),
                GestureDetector(
                  onTap: () => _ctrl.reverse().then((_) => widget.onDismiss()),
                  child: Text('Skip',
                      style: TextStyle(
                          fontFamily: 'Clash Display Regular',
                          fontSize: 13.sp,
                          color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  const _TutorialStep(
      {required this.icon,
      required this.color,
      required this.label,
      required this.sub});
}
