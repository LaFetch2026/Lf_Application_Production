import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/controller/cart_controller.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class CartAppbar extends StatefulWidget {
  final String text;
  final Function? onPressedWishlist;

  const CartAppbar({Key? key, required this.text, this.onPressedWishlist})
      : super(key: key);

  @override
  State<CartAppbar> createState() => _CartAppbarState();
}

class _CartAppbarState extends State<CartAppbar> {
  final controller = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.sp,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: statusBarColor),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 16.sp, right: 12.sp, top: 48.sp, bottom: 10.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 40.sp),
                  child: AppText(
                    text: widget.text.toUpperCase(),
                    fontFamily: "Franklin Gothic Semibold",
                    fontWeight: FontWeight.w600,
                    color: appBarColor,
                    fontSize: 16,
                  ),
                ),
                Obx(() => Padding(
                      padding: EdgeInsets.only(top: 1.sp),
                      child: controller.isOrder.value
                          ? DummyContainer(height: 8, width: 50)
                          : AppText(
                              text: controller.orderList.length == 1
                                  ? "${controller.orderList.length} Product"
                                  : "${controller.orderList.length} Products",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                              fontSize: 10,
                            ),
                    )),
              ],
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.onPressedWishlist?.call();
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 40.sp, left: 16.sp, right: 16.sp, bottom: 5.sp),
                  child: ImageIcon(
                    AssetImage(wishlistBottomIcon),
                    color: homeAppBarColor,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
