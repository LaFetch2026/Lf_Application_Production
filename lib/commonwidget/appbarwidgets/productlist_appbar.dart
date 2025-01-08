import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/cart_controller.dart';
import '../../utils/constants.dart';

class ProductAppbar extends StatefulWidget {
  final Function? onPressedSearch;
  final Function? onPressedCart;
  final Function? onPressedHeart;

  const ProductAppbar(
      {Key? key, this.onPressedSearch, this.onPressedCart, this.onPressedHeart})
      : super(key: key);

  @override
  State<ProductAppbar> createState() => _ProductAppbarState();
}

class _ProductAppbarState extends State<ProductAppbar> {
  final controller = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: whiteColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(left: 6.sp, right: 16.sp, top: 30.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Image.asset(
                    backWhiteArrow,
                    height: 16.sp,
                    color: homeAppBarColor,
                    width: 16.sp,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.sp),
                child: Image.asset(
                  lafetchLogoImage,
                  color: homeAppBarColor,
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
              GestureDetector(
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
