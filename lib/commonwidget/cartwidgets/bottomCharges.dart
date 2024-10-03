// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class BottomCharges extends StatefulWidget {
  final String title;
  final String text;
  const BottomCharges({
    Key? key,
    required this.title,
    required this.text,
  }) : super(key: key);

  @override
  State<BottomCharges> createState() => BottomChargesState();
}

class BottomChargesState extends State<BottomCharges> {
  Map<String, dynamic> selectedProductSize = {};
  int inventoryId = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 220,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: whiteTextColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 20, bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: loginText,
                        fontSize: 16.sp,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Image.asset(blackCrossImage,
                          height: 18, width: 18, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: greyBorder,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppText(
                text: widget.text,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: textColor,
                maxLines: 9,
                fontSize: 14.sp,
              ),
            ),
          ],
        ));
  }
}
