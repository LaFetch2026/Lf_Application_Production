// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constant/constants.dart';


class DoubleIconButton extends StatelessWidget {
  final String firstText;
  final String secondText;
  final double firstFontSize;
  final double secondFontSize;
  final String fontFamily;
  final Color firstTextColor;
  final Color secondTextColor;
  final Color firstBackgroundColor;
  final Color secondBackgroundColor;
  final Color firstBorderColor;
  final Color secondBorderColor;
  final Function? onPressedFirst;
  final Function? onPressedSecond;
  final String firstIcon;
  final String secondIcon;

  const DoubleIconButton(
      {Key? key,
        required this.firstText,
        required this.secondText,
        required this.firstTextColor,
        required this.secondTextColor,
        required this.firstBackgroundColor,
        required this.secondBackgroundColor,
        required this.firstBorderColor,
        required this.secondBorderColor,
        required this.firstIcon,
        required this.secondIcon,
        this.firstFontSize = 13,
        this.secondFontSize = 13,
        this.fontFamily = "Franklin Gothic",
        this.onPressedFirst,
        this.onPressedSecond})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 4,
                  height: 48.sp,
                  child: ElevatedButton.icon(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 4.sp),
                        child: SvgPicture.asset(firstIcon,
                            height: 13.sp,
                            color: homeAppBarColor,
                            width: 13.sp,
                            fit: BoxFit.cover),
                      ),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1))),
                          side: MaterialStateProperty.all(
                            BorderSide(width: 1.sp, color: firstBorderColor),
                          ),
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor:
                          MaterialStateProperty.all(firstBackgroundColor),
                          textStyle: MaterialStateProperty.all(TextStyle(
                            color: firstTextColor,
                            fontSize: firstFontSize,
                          ))),
                      onPressed: () {
                        onPressedFirst?.call();
                      },
                      label: Text(
                        firstText,
                        style: TextStyle(
                            color: firstTextColor,
                            fontFamily: fontFamily,
                            fontSize: firstFontSize.sp),
                      ))),
            ),
          ),
        ),
        SizedBox(
          width: 20.sp,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 4,
                  height: 48.sp,
                  child: ElevatedButton.icon(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 4.sp),
                        child: SvgPicture.asset(secondIcon,
                            height: 18.sp,
                            color: secondIcon == heartSvgImage
                                ? whiteColor
                                : redColor,
                            width: 18.sp,
                            fit: BoxFit.cover),
                      ),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1))),
                          side: MaterialStateProperty.all(BorderSide(
                              color: secondBorderColor,
                              width: 1.0.sp,
                              style: BorderStyle.solid)),
                          backgroundColor:
                          MaterialStateProperty.all(secondBackgroundColor),
                          elevation: MaterialStateProperty.all(0.0),
                          textStyle: MaterialStateProperty.all(TextStyle(
                            color: secondTextColor,
                            fontSize: secondFontSize,
                          ))),
                      onPressed: () {
                        onPressedSecond?.call();
                      },
                      label: Text(
                        secondText,
                        style: TextStyle(
                            fontFamily: fontFamily,
                            color: secondTextColor,
                            fontSize: secondFontSize.sp),
                      ))),
            ),
          ),
        ),
      ],
    );
  }
}
