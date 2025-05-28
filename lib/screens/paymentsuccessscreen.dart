// ignore_for_file: avoid_print, deprecated_member_use

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../common/widget/appbar/shopwishlist_appbar.dart';
import '../common/widget/other/paymentfailwidget.dart';
import '../controllers/cart_controller.dart';
import '../core/constant/constants.dart';
import '../core/utils/analytics_helper.dart';

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
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
    ));

    if (widget.text1 == "Order Placed Successfully") {
      // Log Facebook Purchase event
      AnalyticsHelper.logPurchase(
        productId: widget.orderId.toString(),
        value: 0.0, // or correct total value
      );

      // Log Firebase Analytics event
      analytics.logEvent(
        name: 'purchase_success',
        parameters: <String, Object>{
          'order_id': widget.orderId,
          'value': controller.cartTotalValue.value,
          'currency': 'USD',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(const BottomNavScreen(
          index: 0,
        ));
        return false;
      },
      child: Scaffold(
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
                    Get.offAll(const BottomNavScreen(
                      index: 0,
                    ));
                    controller.orderList.clear();
                    controller.cartTotalValue.value = 0;
                    controller.getCartData();
                  } else {
                    Get.close(1);
                  }
                },
                onPressedheart: () async {
                  Get.to(const WishlistScreen());
                  await analytics.logEvent(
                    name: 'catalog_page',
                    parameters: <String, Object>{
                      'page_name': 'catalog_page',
                    },
                  );
                },
              ),
              Container(
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
                onPressed: () async {
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
                  await analytics.logEvent(
                    name: 'btn_${widget.text1}',
                    parameters: <String, Object>{
                      'page_name': 'btn_${widget.text1}',
                    },
                  );
                },
                visible:
                    widget.text1 == "Order Placed Successfully" ? true : false,
              ),
            ],
          )),
    );
  }
}
