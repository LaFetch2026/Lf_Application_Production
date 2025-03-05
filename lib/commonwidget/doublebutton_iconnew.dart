// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/utils/constants.dart';

class DoubleButtonIconNew extends StatelessWidget {
  final String firstText;
  final String secondText;
  final String fontFamily;
  final dynamic controller;
  final Function? onPressedFirst;
  final Function? onPressedSecond;
  final Color lineColor;

  const DoubleButtonIconNew(
      {Key? key,
      required this.firstText,
      required this.secondText,
      required this.controller,
      this.fontFamily = "Franklin Gothic",
      this.lineColor = dividerColor,
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
                child: Container(
                    alignment: Alignment.center,
                    width: (MediaQuery.of(context).size.width / 2),
                    height: 56.sp,
                    child: /* (controller.pageState == PageState.LOADING)
                        ? Center(
                            child: Transform.scale(
                              scale: 0.5.sp,
                              child: const CircularProgressIndicator(
                                color: whiteColor,
                              ),
                            ),
                          )
                        : */
                        ElevatedButton.icon(
                            icon: SvgPicture.asset(cartSvgImage,
                                height: 18.sp,
                                color: lineColor == dividerColor
                                    ? homeAppBarColor
                                    : whiteColor,
                                width: 15.sp,
                                fit: BoxFit.cover),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(0))),
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
                                textStyle: MaterialStateProperty.all(
                                    TextStyle(
                                        color: lineColor == dividerColor
                                            ? titleColor
                                            : whiteColor,
                                        fontSize: 13.sp,
                                        fontFamily: fontFamily))),
                            onPressed: () {
                              onPressedFirst?.call();
                            },
                            label: Padding(
                              padding: EdgeInsets.only(top: 4.sp),
                              child: Container(
                                height: 18.sp,
                                child: Text(
                                  firstText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: lineColor == dividerColor
                                          ? titleColor
                                          : whiteColor,
                                      fontFamily: fontFamily,
                                      fontSize: 13.sp),
                                ),
                              ),
                            ))),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.center,
                width: (MediaQuery.of(context).size.width / 2),
                height: 56.sp,
                color: lineColor == dividerColor
                    ? homeAppBarColor
                    : lightPurpleColor,
                child: Obx(() => (controller.pageState == PageState.LOADING)
                    ? Center(
                        child: Transform.scale(
                          scale: 0.5.sp,
                          child: const CircularProgressIndicator(
                            color: whiteColor,
                          ),
                        ),
                      )
                    : lineColor == dividerColor
                        ? ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
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
                            ))
                        : ElevatedButton.icon(
                            icon: SvgPicture.asset(buyNowSvgImage,
                                height: 18.sp, width: 18.sp, fit: BoxFit.cover),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                side: MaterialStateProperty.all(BorderSide(color: lineColor == dividerColor ? homeAppBarColor : lightPurpleColor, width: 1.0, style: BorderStyle.solid)),
                                elevation: MaterialStateProperty.all(0.0),
                                backgroundColor: MaterialStateProperty.all(lineColor == dividerColor ? homeAppBarColor : lightPurpleColor),
                                textStyle: MaterialStateProperty.all(TextStyle(color: whiteColor, fontSize: 13.sp, fontFamily: fontFamily))),
                            onPressed: () {
                              onPressedSecond?.call();
                            },
                            label: Padding(
                              padding: EdgeInsets.only(top: 4.sp),
                              child: Container(
                                height: 18.sp,
                                child: Text(
                                  secondText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: fontFamily,
                                      color: whiteColor,
                                      fontSize: 13.sp),
                                ),
                              ),
                            ))),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
