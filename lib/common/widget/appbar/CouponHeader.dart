import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// if you already have these, remove the duplicates
// import '../../../core/constant/constants.dart';
// import '../text/app_text.dart';

class CouponHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onWishlist;

  const CouponHeader({super.key, this.onBack, this.onWishlist});

  @override
  Size get preferredSize => Size.fromHeight(56.sp);

  @override
  Widget build(BuildContext context) {
    // dark status bar icons on light header
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            color: Colors.white,
            height: 56.sp,
            padding: EdgeInsets.symmetric(horizontal: 8.sp),
            child: Row(
              children: [
                // LEFT: back
                SizedBox(
                  width: 44.sp,
                  height: 44.sp,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 22.sp,
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black87, size: 18),
                    onPressed: onBack ?? () => Get.back(),
                  ),
                ),

                // CENTER: title (true-center by balancing left/right widths)
                Expanded(
                  child: Center(
                    child: Text(
                      "APPLY COUPON",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 0.6,
                        color: Colors.black87,
                        fontSize: 16.sp,
                        fontWeight:
                            FontWeight.w600, // Franklin Gothic Semibold vibe
                        fontFamily: "Franklin Gothic Semibold",
                      ),
                    ),
                  ),
                ),

                // RIGHT: wishlist/heart — same width as left to keep title centered
                SizedBox(
                  width: 44.sp,
                  height: 44.sp,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 22.sp,
                    icon: const Icon(Icons.favorite_border,
                        color: Colors.black87, size: 20),
                    onPressed: onWishlist,
                  ),
                ),
              ],
            ),
          ),
        ),

        // thin divider exactly like your screenshot
        Container(height: 1, color: const Color(0xFFE5E7EB)),
      ],
    );
  }
}
