// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => ShippingAddressScreenState();
}

class ShippingAddressScreenState extends State<ShippingAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          BackButtonAppbar(
            text: "Shipping Address",
            threeDot: false,
            icon: threeDotImage,
            onPressedThreeDot: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: double.infinity,
                      color: colorSecondary,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: whiteColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleButton(
                      label: "Proceed to checkout",
                      textColor: whiteBorderColor,
                      backgroundColor: colorPrimary,
                      onPressed: () {},
                      borderColor: colorPrimary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
