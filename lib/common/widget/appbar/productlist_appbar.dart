import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/home/women/homescreen.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class ProductAppbar extends StatefulWidget {
  final Function? onPressedSearch;
  final Function? onPressedCart;
  final Function? onPressedHeart;
  final bool isHandPicked;
  final bool isWishlist;
  final bool isCart;
  final String text;
  final Color backColor;

  const ProductAppbar(
      {Key? key,
      this.onPressedSearch,
      this.isWishlist = true,
      this.isCart = true,
      this.onPressedCart,
      this.onPressedHeart,
      this.backColor = statusBarColor,
      this.text = "",
      this.isHandPicked = false})
      : super(key: key);

  @override
  State<ProductAppbar> createState() => _ProductAppbarState();
}

class _ProductAppbarState extends State<ProductAppbar> {
  final controller = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: widget.backColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(right: 10.sp, top: 56.sp, bottom: 8.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  // Always navigate back to HomeScreen

                  Get.offAll(() => const BottomNavScreen());
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      EdgeInsets.only(left: 16.sp, right: 12.sp, top: 4.sp),
                  child: SvgPicture.asset(
                    arrowBack,
                    height: 15.sp,
                    width: 15.sp,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Visibility(
                visible: widget.isHandPicked,
                child: Container(
                  height: 28.sp,
                  width: MediaQuery.of(context).size.width / 2.sp,
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: AppText(
                      text: widget.text,
                      color: homeAppBarColor,
                      fontSize: 16,
                      fontFamily: "Franklin Gothic Semibold",
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Visibility(
                visible: !widget.isHandPicked,
                child: Padding(
                  padding: EdgeInsets.only(left: 76.sp),
                  child: Image.asset(
                    lafetchLogoImage,
                    color: homeAppBarColor,
                    height: 25.sp,
                    width: 20.sp,
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onPressedSearch?.call();
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  child: SvgPicture.asset(searchSvgImage,
                      height: 18.sp, width: 18.sp, fit: BoxFit.cover),
                ),
              ),
              Visibility(
                visible: widget.isWishlist,
                child: InkWell(
                  onTap: () {
                    widget.onPressedHeart?.call();
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                    child: SvgPicture.asset(heartSvgImage,
                        height: 18.sp, width: 18.sp, fit: BoxFit.cover),
                  ),
                ),
              ),
              Visibility(
                visible: widget.isCart,
                child: InkWell(
                  onTap: () {
                    widget.onPressedCart?.call();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: 10.sp, left: 8.sp, top: 8.sp, bottom: 5.sp),
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
                                        color: homeAppBarColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          controller.cartTotalValue.value
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: whiteColor,
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
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
