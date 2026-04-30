// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widget/other/lf_loader_widget.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';
import '../../screens/bottomnavscreen.dart';
import '../../screens/cartscreen.dart';
import '../../screens/wishlistscreen.dart';
import '../controllers/swipe_feed_controller.dart';
import '../models/swipe_product.dart';
import '../services/swipe_tracking_service.dart';
import '../widgets/swipe_card.dart';
import '../widgets/swipe_hint_bar.dart';
import '../widgets/swipe_overlays.dart';
import '../widgets/swipe_tutorial.dart';

class SwipeFeedScreen extends StatefulWidget {
  const SwipeFeedScreen({super.key});

  @override
  State<SwipeFeedScreen> createState() => _SwipeFeedScreenState();
}

class _SwipeFeedScreenState extends State<SwipeFeedScreen>
    with SingleTickerProviderStateMixin {
  late final SwipeFeedController _ctrl;
  late final WishlistController _wishlistCtrl;
  late final CartController _cartCtrl;

  // Cart flash animation lives in the screen (needs vsync)
  late final AnimationController _cartFlashAnim;

  // GlobalKey for the top card — keyed by product ID so Flutter creates a
  // fresh SwipeCardState whenever the top product changes.
  // This prevents stale _swipeUpLocked / _dragOffset from leaking into the
  // next card after a successful swipe-up.
  GlobalKey<SwipeCardState>? _topCardKey;
  int? _topCardProductId;

  @override
  void initState() {
    super.initState();
    // Force-delete any stale instance before creating a fresh one.
    // This handles hot-reload and cases where dispose didn't run cleanly.
    if (Get.isRegistered<SwipeFeedController>()) {
      debugPrint('[SwipeFeedScreen] Deleting stale SwipeFeedController');
      Get.delete<SwipeFeedController>(force: true);
    }
    _ctrl = Get.put(SwipeFeedController());
    debugPrint('[SwipeFeedScreen] SwipeFeedController created');
    _wishlistCtrl = Get.find<WishlistController>();
    _cartCtrl = Get.find<CartController>();

    _cartFlashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    ever(_ctrl.cartFlash, (bool active) {
      if (active) {
        _cartFlashAnim.forward(from: 0);
      }
    });

    // Wire the top-card callbacks into the controller so it can trigger
    // the fly-up and spring-back animations at the right moment.
    // These are updated each time a new top card is built — see _buildCard.
    _ctrl.onSwipeUpFlyUp = null;
    _ctrl.onSwipeUpReset = null;
  }

  @override
  void dispose() {
    _cartFlashAnim.dispose();
    Get.delete<SwipeFeedController>();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(() => Stack(
            children: [
              Column(
                children: [
                  _buildFilterRow(),
                  Expanded(child: _buildBody()),
                ],
              ),
              if (_ctrl.cartFlash.value)
                CartFlashOverlay(
                  animation: CurvedAnimation(
                    parent: _cartFlashAnim,
                    curve: Curves.easeOut,
                  ),
                ),
              if (_ctrl.wishlistFlash.value) const WishlistFlashOverlay(),
              if (_ctrl.showTutorial.value)
                SwipeTutorialOverlay(onDismiss: _ctrl.dismissTutorial),
            ],
          )),
      bottomNavigationBar: SwipeHintBar(
        onAction: (action) {
          if (_ctrl.cards.isNotEmpty) {
            _ctrl.onCardSwiped(action, _ctrl.cards.first);
          }
        },
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18.sp, color: homeAppBarColor),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
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
        // Wishlist with badge
        Obx(() {
          final count = _wishlistCtrl.wishlistCount.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.favorite_border_rounded,
                    size: 20.sp, color: homeAppBarColor),
                onPressed: () => Get.to(() => const WishlistScreen()),
              ),
              if (count > 0)
                Positioned(
                  right: 6.sp,
                  top: 6.sp,
                  child: _Badge(count: count, color: lightPurpleColor),
                ),
            ],
          );
        }),
        // Cart with badge
        Obx(() {
          final count = _cartCtrl.cartTotalValue.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.shopping_bag_outlined,
                    size: 20.sp, color: homeAppBarColor),
                onPressed: () => Get.to(() => const CartScreen()),
              ),
              if (count > 0)
                Positioned(
                  right: 6.sp,
                  top: 6.sp,
                  child: _Badge(count: count, color: homeAppBarColor),
                ),
            ],
          );
        }),
        SizedBox(width: 8.sp),
      ],
    );
  }

  // ── Filter row (All / Men / Women + Undo + Retry) ─────────────────────────

  Widget _buildFilterRow() {
    return Obx(() {
      final hasUndo = _ctrl.lastSwiped.value != null;
      final hasError = _ctrl.hasError.value && _ctrl.cards.isEmpty;
      final isExhausted = _ctrl.isExhausted.value && _ctrl.cards.isEmpty;

      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
        child: Row(
          children: [
            // Gender tabs
            ..._genderTabs(),
            // Right-side actions
            if (hasUndo || hasError || isExhausted) ...[
              const Spacer(),
              if (hasUndo)
                _TabChip(
                  label: 'Undo',
                  icon: Icons.replay_rounded,
                  filled: false,
                  onTap: _ctrl.rewind,
                ),
              if (hasError || isExhausted) ...[
                if (hasUndo) SizedBox(width: 8.sp),
                _TabChip(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  filled: true,
                  onTap: _ctrl.retryFetch,
                ),
              ],
            ],
          ],
        ),
      );
    });
  }

  List<Widget> _genderTabs() {
    const labels = ['All', 'Men', 'Women'];
    return List.generate(3, (i) {
      final selected = _ctrl.genderFilter.value == i;
      return GestureDetector(
        onTap: () => _ctrl.setGenderFilter(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 8.sp),
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
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
    });
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      final cards = _ctrl.cards;
      final fetching = _ctrl.isFetching.value;
      final error = _ctrl.hasError.value;

      // Loading
      if (cards.isEmpty && fetching) {
        return const Center(
          child:
              LfLogoLoader(size: 48, brandColor: Colors.grey, showGlow: false),
        );
      }

      // Error
      if (cards.isEmpty && error) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LfLogoLoader(
                    size: 48, brandColor: Colors.grey, showGlow: false),
                SizedBox(height: 20.sp),
                Text(
                  'Could not load feed',
                  style: TextStyle(
                    fontFamily: 'Clash Display Semibold',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: homeAppBarColor,
                  ),
                ),
                SizedBox(height: 6.sp),
                Text(
                  'Tap Retry above to try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Exhausted
      if (cards.isEmpty && !fetching && !error) {
        return const _ExhaustedView();
      }

      // Card stack
      final visible = cards.take(3).toList();
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
        child: Stack(
          children: [
            for (int i = visible.length - 1; i >= 0; i--)
              _buildCard(i, visible[i]),
            // Share button
            if (visible.isNotEmpty)
              Positioned(
                right: 12.sp,
                bottom: 80.sp,
                child: _CircleButton(
                  icon: Icons.share_outlined,
                  onTap: () => _ctrl.shareProduct(visible.first),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCard(int index, SwipeProduct product) {
    const configs = [
      (scale: 1.00, verticalOffset: 0.0, isTop: true),
      (scale: 0.96, verticalOffset: 10.0, isTop: false),
      (scale: 0.92, verticalOffset: 20.0, isTop: false),
    ];
    final c = configs[index];
    final isTopCard = index == 0;

    // Create a fresh GlobalKey whenever the top product changes.
    // This guarantees a brand-new SwipeCardState with clean _swipeUpLocked=false
    // and _dragOffset=zero — no stale state leaks from the previous card.
    if (isTopCard && _topCardProductId != product.id) {
      _topCardKey = GlobalKey<SwipeCardState>();
      _topCardProductId = product.id;
      // Re-wire controller callbacks to the new key
      _ctrl.onSwipeUpFlyUp = () => _topCardKey?.currentState?.triggerFlyUp();
      _ctrl.onSwipeUpReset = () => _topCardKey?.currentState?.resetSwipeUp();
    }

    return SwipeCard(
      key: isTopCard ? _topCardKey : ValueKey(product.id),
      product: product,
      isTop: c.isTop,
      scale: c.scale,
      verticalOffset: c.verticalOffset,
      onSwiped: (action) => _ctrl.onCardSwiped(action, product),
      onSwipeUpFlyUp:
          isTopCard ? () => _topCardKey?.currentState?.triggerFlyUp() : null,
      onSwipeUpReset:
          isTopCard ? () => _topCardKey?.currentState?.resetSwipeUp() : null,
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  const _Badge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.sp),
      constraints: BoxConstraints(minWidth: 14.sp, minHeight: 14.sp),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 8.sp,
          color: Colors.white,
          fontFamily: 'Clash Display Regular',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _TabChip({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: filled ? homeAppBarColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(
            color: filled ? homeAppBarColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: filled ? Colors.white : homeAppBarColor, size: 14.sp),
            SizedBox(width: 4.sp),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Clash Display',
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: filled ? Colors.white : homeAppBarColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Clash Display',
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.sp,
        height: 36.sp,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}

// ── Exhausted state ───────────────────────────────────────────────────────────

class _ExhaustedView extends StatelessWidget {
  const _ExhaustedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72.sp,
              height: 72.sp,
              decoration: const BoxDecoration(
                color: homeAppBarColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.style_rounded,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 24.sp),
            Text(
              'You\'re ahead of the curve.',
              style: TextStyle(
                fontFamily: 'Clash Display Semibold',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: homeAppBarColor,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.sp),
            Text(
              'You\'ve seen everything curated for you right now. New arrivals drop regularly — check back soon.',
              style: TextStyle(
                fontFamily: 'Clash Display Regular',
                fontSize: 13.sp,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.sp),
            // Subtle divider line
            Container(
              width: 40.sp,
              height: 1,
              color: Colors.grey[200],
            ),
            SizedBox(height: 20.sp),
            Text(
              'LF SWIPE',
              style: TextStyle(
                fontFamily: 'Clash Display Semibold',
                fontSize: 10.sp,
                color: Colors.grey[400],
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
