// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class TotalTaxcharges extends StatefulWidget {
  final String title;
  final String tax;
  final String total;
  final String price;
  const TotalTaxcharges({
    Key? key,
    required this.title,
    required this.tax,
    required this.price,
    required this.total,
  }) : super(key: key);

  @override
  State<TotalTaxcharges> createState() => TotalTaxchargesState();
}

class TotalTaxchargesState extends State<TotalTaxcharges> {
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
              padding: EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 4.sp),
                    child: AppText(
                      text: "Total Price",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(
                      height: 0,
                    ),
                  ),
                  AppText(
                    text: widget.price,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: homeAppBarColor,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 4.sp),
                    child: AppText(
                      text: "Tax & Charges",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(
                      height: 0,
                    ),
                  ),
                  AppText(
                    text: widget.tax,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: homeAppBarColor,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            const Divider(
              color: greyBorder,
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.sp, left: 16.sp, right: 16.sp),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 4.sp),
                    child: AppText(
                      text: "BILL TOTAL",
                      fontFamily: "Franklin Gothic Bold",
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(
                      height: 0,
                    ),
                  ),
                  AppText(
                    text: widget.total,
                    fontFamily: "Franklin Gothic Bold",
                    fontWeight: FontWeight.w400,
                    color: homeAppBarColor,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
