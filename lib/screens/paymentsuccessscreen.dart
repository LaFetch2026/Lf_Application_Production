// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/paymentwidgets/paymentfailwidget.dart';
import '../utils/constants.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => PaymentSuccessScreenState();
}

class PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteTextColor,
        body: PaymentFailWidget(
          text1: "Order Placed Successfully",
          text2: "Thank you for placing your order",
          btntext: "Back Home",
          image: orderSucessImage,
          onPressed: () {},
          visible: true,
        ));
  }
}
