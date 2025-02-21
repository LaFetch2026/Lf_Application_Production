// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/cart_controller.dart';
import '../../utils/constants.dart';

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
    return Container(
      // height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: homeAppBarColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(right: 10.sp, top: 56.sp, bottom: 16.sp),
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
                    left: 16.sp,
                    right: 12.sp,
                  ),
                  child: SvgPicture.asset(arrowBack,
                      color: whiteColor,
                      height: 15.sp,
                      width: 15.sp,
                      fit: BoxFit.cover),
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
                      height: 18.sp, width: 18.sp, fit: BoxFit.cover),
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
                      height: 18.sp, width: 18.sp, fit: BoxFit.cover),
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
                            height: 18.sp, width: 18.sp, fit: BoxFit.cover),
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
      ]),
    );
  }
}
