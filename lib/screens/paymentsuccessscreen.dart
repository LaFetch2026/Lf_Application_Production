// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/paymentwidgets/paymentfailwidget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteTextColor,
        body: PaymentFailWidget(
          text1: widget.text1,
          text2: widget.text2,
          btntext: widget.text1 == "Order Placed Successfully"
              ? "View Order"
              : "Back Home",
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
            } else {
              Get.offAll(
                () => const BottomNavScreen(),
              );
            }
          },
          visible: true,
        ));
  }
}
