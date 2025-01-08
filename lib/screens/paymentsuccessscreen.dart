// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/shopwishlist_appbar.dart';
import 'package:lafetch/commonwidget/paymentwidgets/paymentfailwidget.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import '../controller/cart_controller.dart';
import '../utils/constants.dart';
import 'bottomnavscreen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String text1;
  final String text2;
  final String image;
  final int orderId;
  const PaymentSuccessScreen(
      {required this.text1,
      required this.text2,
      required this.image,
      required this.orderId,
      super.key});

  @override
  State<PaymentSuccessScreen> createState() => PaymentSuccessScreenState();
}

class PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final controller = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            ShopWishlistAppbar(
              onPressedCart: () async {
                Get.to(const CartScreen());
                await analytics.logEvent(
                  name: 'cart_page',
                  parameters: <String, Object>{
                    'page_name': 'cart_page',
                  },
                );
              },
              onPressedBackButton: () {
                if (widget.text1 == "Order Placed Successfully") {
                  Get.close(1);
                  controller.orderList.clear();
                  controller.cartTotalValue.value = 0;
                  controller.getCartData();
                } else {
                  Get.close(1);
                }
              },
              onPressedheart: () async {
                Get.to(const BottomNavScreen(
                  index: 2,
                ));
                await analytics.logEvent(
                  name: 'catalog_page',
                  parameters: <String, Object>{
                    'page_name': 'catalog_page',
                  },
                );
              },
            ),
            Divider(
              color: dividerColor,
              height: 1.sp,
            ),
            PaymentFailWidget(
              text1: widget.text1,
              text2: widget.text2,
              btntext: widget.text1 == "Order Placed Successfully"
                  ? "Go to my orders"
                  : widget.text1 == "Payment Failed"
                      ? "TRY again"
                      : "BACK to cart",
              image: widget.image,
              onPressed: () {
                if (widget.text1 == "Order Placed Successfully") {
                  Get.close(1);
                  Get.off(OrderDetailsScreen(
                    orderId: widget.orderId,
                  ));
                  controller.orderList.clear();
                  controller.cartTotalValue.value = 0;
                  controller.getCartData();
                } else if (widget.text1 == "Payment Failed") {
                  Get.close(1);
                } else {
                  Get.close(1);
                }
              },
              visible:
                  widget.text1 == "Order Placed Successfully" ? true : false,
            ),
          ],
        ));
  }
}
