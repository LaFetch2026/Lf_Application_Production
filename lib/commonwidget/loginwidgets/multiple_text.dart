import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';

class MultipleTextWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final Function? onPressedTerm;
  final Function? onPressedPolicy;
  final double fontSize;

  const MultipleTextWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.fontSize,
    this.onPressedPolicy,
    this.onPressedTerm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text1,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              onPressedTerm?.call();
            },
            child: Text(
              text2,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontFamily: "Franklin Gothic Semibold",
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                fontSize: fontSize,
              ),
            ),
          ),
          Text(
            text3,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              onPressedPolicy?.call();
            },
            child: Text(
              text4,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: fontSize,
                decoration: TextDecoration.underline,
                overflow: TextOverflow.ellipsis,
                fontFamily: "Franklin Gothic Semibold",
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
