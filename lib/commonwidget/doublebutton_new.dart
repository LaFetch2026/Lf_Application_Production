// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/utils/constants.dart';

class DoubleButtonNew extends StatelessWidget {
  final String firstText;
  final String secondText;
  final String fontFamily;
  final dynamic controller;
  final Function? onPressedFirst;
  final Function? onPressedSecond;

  const DoubleButtonNew(
      {Key? key,
      required this.firstText,
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
            color: dividerColor,
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
                                BorderSide(width: 1, color: whiteColor),
                              ),
                              elevation: MaterialStateProperty.all(0.0),
                              backgroundColor:
                                  MaterialStateProperty.all(whiteColor),
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
                                color: titleColor,
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
                          color: homeAppBarColor,
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
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0))),
                                      side: MaterialStateProperty.all(
                                          BorderSide(
                                              color: homeAppBarColor,
                                              width: 1.0,
                                              style: BorderStyle.solid)),
                                      elevation: MaterialStateProperty.all(0.0),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              homeAppBarColor),
                                      textStyle: MaterialStateProperty.all(
                                          TextStyle(
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
