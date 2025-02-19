// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
        height: 220.sp,
        width: double.infinity,
        decoration: BoxDecoration(
          color: whiteTextColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0.sp),
              topRight: Radius.circular(16.0.sp)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.sp,
                right: 16.sp,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.sp, bottom: 5.sp),
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
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10.sp,
                            right: 16.sp,
                            top: 20.sp,
                            bottom: 5.sp),
                        child: SvgPicture.asset(crossSearchImage,
                            // ignore: deprecated_member_use
                            color: loginText,
                            height: 13.sp,
                            width: 13.sp,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: greyBorder,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: AppText(
                text: widget.text,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: textColor,
                maxLines: 9,
                fontSize: 14,
              ),
            ),
          ],
        ));
  }
}
