// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/constants.dart';

/// Full-screen black flash shown when the user swipes up (add to cart).
class CartFlashOverlay extends StatelessWidget {
  final Animation<double> animation;
  const CartFlashOverlay({super.key, required this.animation});

  // Single-pass TweenSequence: fast fade-in (0→0.3) then smooth fade-out (0.3→1.0).
  // Peaks at 30% of the animation range — no double-fade, no jank.
  static final _opacitySequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 0.65)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 3, // 30% of the animation
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.65, end: 0.0)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 7, // 70% of the animation
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Opacity(
          opacity: _opacitySequence.evaluate(animation),
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 48.sp),
                  SizedBox(height: 8.sp),
                  Text(
                    'Added to cart ✓',
                    style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lavender toast shown when the user likes a product (adds to LF Swipes board).
class WishlistFlashOverlay extends StatelessWidget {
  const WishlistFlashOverlay({super.key});

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
                Text(
                  'Added to LF Swipes',
                  style: TextStyle(
                    fontFamily: 'Clash Display Semibold',
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
