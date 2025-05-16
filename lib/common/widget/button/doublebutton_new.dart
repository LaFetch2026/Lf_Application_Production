// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../controllers/base_controller.dart';
import '../../../core/constant/constants.dart';

class DoubleButtonNew extends StatelessWidget {
  final String firstText;
  final String secondText;
  final String fontFamily;
  final dynamic controller;
  final Function? onPressedFirst;
  final Function? onPressedSecond;
  final Color lineColor;

  const DoubleButtonNew(
      {Key? key,
        required this.firstText,
        this.lineColor = dividerColor,
        required this.secondText,
        required this.controller,
        this.fontFamily = "Franklin Gothic",
        this.onPressedFirst,
        this.onPressedSecond})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.sp),
      child: Column(
        children: [
          Container(
            color: lineColor == dividerColor ? dividerColor : titleColor,
            width: double.infinity,
            height: 1.sp,
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                      width: (MediaQuery.of(context).size.width / 2),
                      height: 50.sp,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0))),
                              side: MaterialStateProperty.all(
                                BorderSide(
                                    width: 1,
                                    color: lineColor == dividerColor
                                        ? whiteColor
                                        : homeAppBarColor),
                              ),
                              elevation: MaterialStateProperty.all(0.0),
                              backgroundColor: MaterialStateProperty.all(
                                  lineColor == dividerColor
                                      ? whiteColor
                                      : homeAppBarColor),
                              textStyle: MaterialStateProperty.all(TextStyle(
                                  color: titleColor,
                                  fontSize: 13.sp,
                                  fontFamily: fontFamily))),
                          onPressed: () {
                            onPressedFirst?.call();
                          },
                          child: Text(
                            firstText,
                            style: TextStyle(
                                color: lineColor == dividerColor
                                    ? titleColor
                                    : whiteColor,
                                fontFamily: fontFamily,
                                fontSize: 13.sp),
                          ))),
                ),
              ),
              Obx(() => Expanded(
                child: Center(
                  child: Container(
                      width: (MediaQuery.of(context).size.width / 2),
                      height: 50.sp,
                      color: lineColor == dividerColor
                          ? homeAppBarColor
                          : lightPurpleColor,
                      child: (controller.pageState == PageState.LOADING)
                          ? Center(
                        child: Transform.scale(
                          scale: 0.5.sp,
                          child: const CircularProgressIndicator(
                            color: whiteColor,
                          ),
                        ),
                      )
                          : ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(0))),
                              side: MaterialStateProperty.all(BorderSide(
                                  color: lineColor == dividerColor
                                      ? homeAppBarColor
                                      : lightPurpleColor,
                                  width: 1.0,
                                  style: BorderStyle.solid)),
                              elevation: MaterialStateProperty.all(0.0),
                              backgroundColor: MaterialStateProperty.all(
                                  lineColor == dividerColor
                                      ? homeAppBarColor
                                      : lightPurpleColor),
                              textStyle: MaterialStateProperty.all(TextStyle(
                                  color: whiteColor,
                                  fontSize: 13.sp,
                                  fontFamily: fontFamily))),
                          onPressed: () {
                            onPressedSecond?.call();
                          },
                          child: Text(
                            secondText,
                            style: TextStyle(
                                fontFamily: fontFamily,
                                color: whiteColor,
                                fontSize: 13.sp),
                          ))),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
