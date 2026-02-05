// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';

class AllBrandAppbar extends StatefulWidget {
  final Function? onPressedShare;
  final Function? onPressedCart;
  final Function? onPressedHeart;
  final Function? onPressedBack;

  const AllBrandAppbar({
    Key? key,
    this.onPressedShare,
    this.onPressedCart,
    this.onPressedBack,
    this.onPressedHeart,
  }) : super(key: key);

  @override
  State<AllBrandAppbar> createState() => AllBrandAppbarState();
}

class AllBrandAppbarState extends State<AllBrandAppbar> {
  final controller = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: homeAppBarColor,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp, top: statusBarHeight + 8.sp, right: 10.sp, bottom: 16.sp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                widget.onPressedBack?.call();
              },
              child: Container(
                padding: EdgeInsets.only(
                  right: 12.sp,
                ),
                child: SvgPicture.asset(arrowBack,
                    color: whiteColor,
                    height: 15.sp,
                    width: 15.sp,
                    fit: BoxFit.fill),
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 70.sp,
              ),
              child: Image.asset(
                lafetchLogoImage,
                color: whiteColor,
                height: 25.sp,
                width: 20.sp,
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            InkWell(
              onTap: () {
                widget.onPressedShare?.call();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.sp,
                ),
                child: SvgPicture.asset(shareSvgImage,
                    color: whiteColor,
                    height: 18.sp,
                    width: 18.sp,
                    fit: BoxFit.fill),
              ),
            ),
            InkWell(
              onTap: () {
                widget.onPressedHeart?.call();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.sp,
                ),
                child: SvgPicture.asset(heartSvgImage,
                    color: whiteColor,
                    height: 18.sp,
                    width: 18.sp,
                    fit: BoxFit.fill),
              ),
            ),
            InkWell(
              onTap: () {
                widget.onPressedCart?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(
                  right: 10.sp,
                  left: 8.sp,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.sp),
                      child: SvgPicture.asset(cartSvgImage,
                          color: whiteColor,
                          height: 18.sp,
                          width: 18.sp,
                          fit: BoxFit.fill),
                    ),
                    Obx(() => controller.cartTotalValue.value != 0
                        ? Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10.sp,
                              height: 10.sp,
                              child: Padding(
                                padding: EdgeInsets.all(0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: whiteColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      controller.cartTotalValue.value
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 8,
                                          color: homeAppBarColor,
                                          fontFamily:
                                              "Libre Franklin Regular",
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ), // inner content
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
