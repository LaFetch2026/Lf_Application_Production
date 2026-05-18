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
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10.sp),
                border: Border.all(
                    color: homeAppBarSearchBorder.withValues(alpha: 1.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 17,
                    offset: Offset.zero,
                  ),
                ],
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
                      color: Colors.black,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                    SizedBox(width: 10.sp),
                    Expanded(
                      child: CyclingHint(
                        color: homeAppBarHintColor,
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
                          color: homeAppBarIconColor,
                        ),
                      ),
                    if (onProfileTap != null)
                      AppbarIconButton(
                        onTap: onProfileTap!,
                        child: SvgPicture.asset(
                          newProfileImage,
                          color: homeAppBarIconColor,
                        ),
                      ),
                  ],
                ),
        ),

        // ── Cart — always visible, slides into new position naturally ─
        AnimatedContainer(
          duration: duration,
          curve: curve,
          margin: EdgeInsets.only(left: collapsed ? 10.sp : 4.sp),
          child: GestureDetector(
            onTap: onCartTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(102),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 17.3,
                    offset: Offset.zero,
                  ),
                ],
              ),
              padding: EdgeInsets.all(6.sp),
              child: SvgPicture.asset(
                // cartSvgImage,
                newCartSvgImage,
                // height: 20.sp,
                // width: 20.sp,
                // fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
