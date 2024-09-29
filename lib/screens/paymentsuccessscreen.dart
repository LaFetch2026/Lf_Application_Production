// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/paymentwidgets/paymentfailwidget.dart';
import '../utils/constants.dart';
import 'bottomnavscreen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String text1;
  final String text2;
  final String image;
  const PaymentSuccessScreen(
      {required this.text1,
      required this.text2,
      required this.image,
      super.key});

  @override
  State<PaymentSuccessScreen> createState() => PaymentSuccessScreenState();
}

class PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteTextColor,
        body: PaymentFailWidget(
          text1: widget.text1,
          text2: widget.text2,
          btntext: "Back Home",
          image: widget.image,
          onPressed: () {
            Get.offAll(
              () => const BottomNavScreen(),
            );
            // Get.close(3);
          },
          visible: true,
        ));
  }
}
