// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/paymentwidgets/paymentfailwidget.dart';
import '../utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
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
