import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class WishlistAppbar extends StatefulWidget {
  final Function? onPressedSearch;
  final Function? onPressedCart;
  final Function? onPressedHeart;
  final bool isHandPicked;
  final bool isWishlist;
  final bool isCart;
  final String text;
  final Color backColor;
  final bool showBack;

  /// Optional custom back handler
  final VoidCallback? onPressedBack;

  const WishlistAppbar({
    Key? key,
    this.onPressedSearch,
    this.onPressedCart,
    this.onPressedHeart,
    this.isWishlist = true,
    this.isCart = true,
    this.text = "",
    this.isHandPicked = false,
    this.backColor = statusBarColor,
    this.showBack = true,
    this.onPressedBack,
  }) : super(key: key);

  @override
  State<WishlistAppbar> createState() => _WishlistAppbarState();
}

class _WishlistAppbarState extends State<WishlistAppbar> {
  final controller = Get.put(CartController());

  void _handleBack() {
    // If user passed a custom back callback, use that
    if (widget.onPressedBack != null) {
      widget.onPressedBack!();
      return;
    }

    // Safely pop: only if navigator can pop
    final canPop = Get.key.currentState?.canPop() ?? false;

    if (canPop) {
      Get.off(() => BottomNavScreen());
    } else {
      // Root screen: either do nothing or close the app.
      // If you want to close app on root back button, uncomment:
      // SystemNavigator.pop();
      // For now, we just do nothing to avoid crash.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: widget.backColor,
      child: Padding(
        padding: EdgeInsets.only(right: 10.sp, top: 56.sp, bottom: 8.sp),
        child: Row(
          children: [
            if (widget.showBack)
              InkWell(
                onTap: _handleBack,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 16.sp, right: 12.sp, top: 4.sp),
                  child: SvgPicture.asset(
                    arrowBack,
                    height: 15.sp,
                    width: 15.sp,
                  ),
                ),
              ),

            /// Title (hand picked)
            if (widget.isHandPicked)
              Expanded(
                child: AppText(
                  text: widget.text,
                  color: homeAppBarColor,
                  fontSize: 16,
                  fontFamily: "Franklin Gothic Semibold",
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const Spacer(),

            /// Logo
            if (!widget.isHandPicked)
              Image.asset(
                lafetchLogoImage,
                color: homeAppBarColor,
                height: 25.sp,
              ),

            const Spacer(),

            /// Search icon
            InkWell(
              onTap: () => widget.onPressedSearch?.call(),
              child: Padding(
                padding: EdgeInsets.all(8.sp),
                child: SvgPicture.asset(
                  searchSvgImage,
                  height: 18.sp,
                  width: 18.sp,
                ),
              ),
            ),

            /// Heart icon
            if (widget.isWishlist)
              InkWell(
                onTap: () => widget.onPressedHeart?.call(),
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: SvgPicture.asset(
                    heartSvgImage,
                    height: 18.sp,
                    width: 18.sp,
                  ),
                ),
              ),

            /// Cart icon with count
            // if (widget.isCart)
            //   InkWell(
            //     onTap: () => widget.onPressedCart?.call(),
            //     child: Padding(
            //       padding: EdgeInsets.all(8.sp),
            //       child: Stack(
            //         children: [
            //           SvgPicture.asset(
            //             cartSvgImage,
            //             height: 18.sp,
            //             width: 18.sp,
            //           ),
            //           Obx(
            //             () => controller.cartTotalValue.value != 0
            //                 ? Positioned(
            //                     right: 0,
            //                     child: CircleAvatar(
            //                       radius: 5.sp,
            //                       backgroundColor: homeAppBarColor,
            //                       child: Text(
            //                         controller.cartTotalValue.value.toString(),
            //                         style: TextStyle(
            //                           fontSize: 8.sp,
            //                           color: whiteColor,
            //                         ),
            //                       ),
            //                     ),
            //                   )
            //                 : const SizedBox.shrink(),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
