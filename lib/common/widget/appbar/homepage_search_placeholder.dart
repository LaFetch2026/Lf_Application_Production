// ─────────────────────────────────────────────────────────────────────────────
// HomeSearchBar — smooth expand / collapse animation, zero memory leaks
// Strategy: search bar is always Expanded (fills remaining row space).
// Icons slide out via AnimatedSize(→ SizedBox.shrink) + AnimatedOpacity.
// Cart is always visible at the far right.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lafetch/common/widget/appbar/cycling_hint_animation.dart';
import 'package:lafetch/common/widget/appbar/home_appbar.dart';
import 'package:lafetch/core/constant/constants.dart';

class HomeSearchBar extends StatelessWidget {
  final bool collapsed;
  final String placeholder;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onHeartTap;
  final VoidCallback? onProfileTap;

  const HomeSearchBar({
    Key? key,
    required this.collapsed,
    required this.placeholder,
    this.onSearchTap,
    this.onCartTap,
    this.onHeartTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 320);
    const curve = Curves.easeInOut;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Search field — expands to fill space as icons collapse ──

        Expanded(
          child: GestureDetector(
            onTap: onSearchTap,
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              height: 46.sp,
              // decoration: BoxDecoration(
              //   // color: Colors.white.withValues(alpha: 0.25),
              //   color: Colors.white.withValues(alpha: 0.10),
              //   borderRadius: BorderRadius.circular(10.sp),
              //   border: Border.all(
              //       // color: homeAppBarSearchBorder.withValues(alpha: 1.0)),
              //       color: Colors.white.withValues(alpha: 0.55)),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withValues(alpha: 0.07),
              //       blurRadius: 17,
              //       offset: Offset.zero,
              //     ),
              //   ],
              // ),
              decoration: BoxDecoration(
                color: collapsed
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.sp),
                border: Border.all(
                  color: collapsed
                      ? Colors.black.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  children: [
                    Image.asset(
                      applogoCondensed,
                      height: 24.sp,
                      width: 24.sp,
                      fit: BoxFit.contain,
                      // color: Colors.black,
                      // color: Colors.white.withValues(alpha: 0.8),
                      // color: whiteColor,
                      color: collapsed
                          ? Colors.black.withValues(alpha: 0.7)
                          : Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                    SizedBox(width: 10.sp),
                    Expanded(
                      child: CyclingHint(
                        // color: homeAppBarHintColor,
                        // color: Colors.white.withValues(alpha: 0.8),
                        color: collapsed
                            ? Colors.black.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Heart + Profile — slide out on collapse ─────────────────
        // AnimatedSize shrinks width to 0; AnimatedOpacity fades them out.
        // No controllers = no leaks.
        AnimatedSize(
          duration: duration,
          curve: curve,
          child: collapsed
              ? const SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8.sp),
                    if (onHeartTap != null)
                      AppbarIconButton(
                        onTap: onHeartTap!,
                        child: SvgPicture.asset(
                          newWishlistIcon,
                          // height: 18.sp,
                          // width: 18.sp,
                          colorFilter: ColorFilter.mode(
                            // homeAppBarIconColor,
                            whiteColor.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    if (onProfileTap != null) SizedBox(width: 6.sp),
                    AppbarIconButton(
                      onTap: onProfileTap!,
                      child: SvgPicture.asset(
                        newProfileImage,
                        height: 28.sp,
                        colorFilter: ColorFilter.mode(
                          whiteColor.withValues(alpha: 0.7),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        // ── Cart — always visible, slides into new position naturally ─
        SizedBox(width: 2.sp),
        AnimatedContainer(
          duration: duration,
          curve: curve,
          margin: EdgeInsets.only(left: collapsed ? 10.sp : 4.sp),
          child: GestureDetector(
            onTap: onCartTap,
            child: AnimatedContainer(
              duration: duration,
              curve: curve,
              decoration: BoxDecoration(
                color: collapsed
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.0),
                borderRadius: BorderRadius.circular(102),
                border: Border.all(
                  // color: collapsed
                  //     ? Colors.white.withValues(alpha: 0.55)
                  //     : Colors.white.withValues(alpha: 0.35),
                  color: collapsed
                      ? Colors.black.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              padding: EdgeInsets.all(5.sp),
              child: SvgPicture.asset(
                newCartSvgImage,
                colorFilter: ColorFilter.mode(
                  collapsed
                      ? Colors.black.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.7),
                  BlendMode.srcIn,
                ),
                height: 30.sp,
                width: 30.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
