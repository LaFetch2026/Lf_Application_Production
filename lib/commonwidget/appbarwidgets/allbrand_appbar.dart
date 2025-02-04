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
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: homeAppBarColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(left: 6.sp, right: 16.sp, top: 30.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: SvgPicture.asset(arrowBack,
                    color: whiteColor,
                    height: 15.sp,
                    width: 15.sp,
                    fit: BoxFit.cover),
                onPressed: () {
                  widget.onPressedBack?.call();
                },
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 48.sp, right: 10.sp),
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
              GestureDetector(
                onTap: () {
                  widget.onPressedShare?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ImageIcon(
                    AssetImage(shareNewimage),
                    color: whiteColor,
                    size: 18.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onPressedHeart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ImageIcon(
                    AssetImage(wishlistBottomIcon),
                    color: whiteColor,
                    size: 18.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onPressedCart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 5.sp),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.sp),
                        child: Image.asset(
                          cartNewImage,
                          color: whiteColor,
                          height: 18.sp,
                          width: 18.sp,
                        ),
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
