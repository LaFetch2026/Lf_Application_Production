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

  @override
  void initState() {
    super.initState();
    // Register controller scoped to this screen; auto-deleted on dispose
    _ctrl = Get.put(SwipeFeedController());
    _wishlistCtrl = Get.find<WishlistController>();
    _cartCtrl = Get.find<CartController>();

    _cartFlashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    ever(_ctrl.cartFlash, (bool active) {
      if (active) {
        _cartFlashAnim.forward(from: 0).then((_) => _cartFlashAnim.reverse());
      }
    });
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

      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
        child: Row(
          children: [
            // Gender tabs
            ..._genderTabs(),
            // Right-side actions
            if (hasUndo || hasError) ...[
              const Spacer(),
              if (hasUndo)
                _TabChip(
                  label: 'Undo',
                  icon: Icons.replay_rounded,
                  filled: false,
                  onTap: _ctrl.rewind,
                ),
              if (hasError) ...[
                if (hasUndo) SizedBox(width: 8.sp),
                _TabChip(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  filled: true,
                  onTap: _ctrl.fetchBatch,
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
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You've seen it all! 🎉",
                  style: TextStyle(
                    fontFamily: 'Clash Display Semibold',
                    fontWeight: FontWeight.w600,
                    fontSize: 22.sp,
                    color: homeAppBarColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Check back later for new arrivals',
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28.sp),
                _PillButton(label: 'Refresh', onTap: _ctrl.fetchBatch),
              ],
            ),
          ),
        );
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
    return SwipeCard(
      key: ValueKey(product.id),
      product: product,
      isTop: c.isTop,
      scale: c.scale,
      verticalOffset: c.verticalOffset,
      onSwiped: (action) => _ctrl.onCardSwiped(action, product),
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
