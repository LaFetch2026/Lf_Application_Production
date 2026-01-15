import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constant/constants.dart';
import '../lists/dummy_container.dart';
import '../text/app_text.dart';

class CartAppbar extends StatefulWidget {
  final String text;
  final Function? onPressedWishlist;

  const CartAppbar({Key? key, required this.text, this.onPressedWishlist})
      : super(key: key);

  @override
  State<CartAppbar> createState() => _CartAppbarState();
}

class _CartAppbarState extends State<CartAppbar> {
  final CartController controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.sp,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: statusBarColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.sp,
                    right: 12.sp,
                    top: 48.sp,
                    bottom: 10.sp,
                  ),
                  child: SvgPicture.asset(
                    arrowBack,
                    height: 15.sp,
                    width: 15.sp,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 40.sp),
                    child: AppText(
                      text: widget.text.toUpperCase(),
                      fontFamily: "Clash Display Semibold",
                      fontWeight: FontWeight.w600,
                      color: appBarColor,
                      fontSize: 16,
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding: EdgeInsets.only(top: 1.sp),
                      child: controller.isOrder.value
                          ? DummyContainer(height: 8, width: 50)
                          : AppText(
                              text: controller.orderList.length == 1
                                  ? "${controller.orderList.length} Product"
                                  : "${controller.orderList.length} Products",
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                              fontSize: 10,
                            ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              InkWell(
                onTap: () => widget.onPressedWishlist?.call(),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 40.sp,
                    left: 16.sp,
                    right: 19.sp,
                    bottom: 5.sp,
                  ),
                  child: SvgPicture.asset(
                    heartSvgImage,
                    height: 18.sp,
                    width: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
