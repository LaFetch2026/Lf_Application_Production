import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/cart_controller.dart';
import '../../utils/constants.dart';

class ProductAppbar extends StatefulWidget {
  final Function? onPressedSearch;
  final Function? onPressedCart;

  const ProductAppbar({
    Key? key,
    this.onPressedSearch,
    this.onPressedCart,
  }) : super(key: key);

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
      color: blackColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(left: 6.sp, right: 16.sp, top: 20.sp),
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
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ImageIcon(
                    AssetImage(searchNewImage),
                    color: whiteColor,
                    size: 20.sp,
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
                          height: 20.sp,
                          width: 20.sp,
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
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        controller.cartTotalValue.value
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: blackColor,
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
