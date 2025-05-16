// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoubleButton extends StatelessWidget {
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

  const DoubleButton(
      {Key? key,
        required this.firstText,
        required this.secondText,
        required this.firstTextColor,
        required this.secondTextColor,
        required this.firstBackgroundColor,
        required this.secondBackgroundColor,
        required this.firstBorderColor,
        required this.secondBorderColor,
        this.firstFontSize = 12,
        this.secondFontSize = 12,
        this.fontFamily = "Franklin Gothic",
        this.onPressedFirst,
        this.onPressedSecond})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(left: 16.sp, right: 16.sp, top: 10.sp, bottom: 10.sp),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Center(
                child: SizedBox(
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    height: 50.sp,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2))),
                            side: MaterialStateProperty.all(
                              BorderSide(width: 1, color: firstBorderColor),
                            ),
                            elevation: MaterialStateProperty.all(0.0),
                            backgroundColor:
                            MaterialStateProperty.all(firstBackgroundColor),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              color: firstTextColor,
                              fontSize: firstFontSize.sp,
                            ))),
                        onPressed: () {
                          onPressedFirst?.call();
                        },
                        child: Text(
                          firstText,
                          style: TextStyle(
                              color: firstTextColor,
                              fontFamily: fontFamily,
                              fontSize: firstFontSize.sp),
                        ))),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Center(
                child: SizedBox(
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    height: 50.sp,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2))),
                            side: MaterialStateProperty.all(BorderSide(
                                color: secondBorderColor,
                                width: 1.0,
                                style: BorderStyle.solid)),
                            elevation: MaterialStateProperty.all(0.0),
                            backgroundColor: MaterialStateProperty.all(
                                secondBackgroundColor),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              color: secondTextColor,
                              fontSize: secondFontSize.sp,
                            ))),
                        onPressed: () {
                          onPressedSecond?.call();
                        },
                        child: Text(
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
      ),
    );
  }
}
