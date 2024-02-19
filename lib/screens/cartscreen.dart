// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartwidgets.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButtonAppbar(
              text: "Shopping Bag",
              threeDot: false,
            ),
            /*  Padding(
              padding: EdgeInsets.only(top: 60),
              child: CartWidget(
                  image: shopBagImage,
                  text1: "There is still room for more",
                  text2:
                      "Looking for items you previously saved? Sign in to pick up where you left out",
                  btntext: "Continue Shopping",
                  visible: true),
            ) */
          ],
        ),
      ),
    );
  }
}
