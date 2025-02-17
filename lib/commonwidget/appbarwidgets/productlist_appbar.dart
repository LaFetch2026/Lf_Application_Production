import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/controller/cart_controller.dart';
import '../../utils/constants.dart';

class ProductAppbar extends StatefulWidget {
  final Function? onPressedSearch;
  final Function? onPressedCart;
  final Function? onPressedHeart;
  final bool isHandPicked;
  final bool isWishlist;
  final String text;
  final Color backColor;

  const ProductAppbar(
      {Key? key,
      this.onPressedSearch,
      this.isWishlist = true,
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
          padding: EdgeInsets.only(right: 16.sp, top: 56.sp, bottom: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16.sp, right: 12.sp, bottom: 6.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                ),
              ),
              Visibility(
                visible: widget.isHandPicked,
                child: Container(
                  height: 28.sp,
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
                  padding: EdgeInsets.only(left: 64.sp, right: 10.sp),
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
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ImageIcon(
                    AssetImage(searchNewImage),
                    color: homeAppBarColor,
                    size: 22.sp,
                  ),
                ),
              ),
              Visibility(
                visible: widget.isWishlist,
                child: InkWell(
                  onTap: () {
                    widget.onPressedHeart?.call();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: ImageIcon(
                      AssetImage(wishlistBottomIcon),
                      color: homeAppBarColor,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
              InkWell(
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
                          color: homeAppBarColor,
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
            ],
          ),
        ),
      ]),
    );
  }
}
