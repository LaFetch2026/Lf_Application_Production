// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../commonwidget/app_text.dart';
import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
              child: AppText(
                text: "CartScreen",
                fontFamily: "Franklin Gothic",
                maxLines: 2,
                fontWeight: FontWeight.w500,
                color: blackColor,
                fontSize: 28.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
