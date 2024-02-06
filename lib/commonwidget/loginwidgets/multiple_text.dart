import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            text1,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w400,
              color: greyTextColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              onPressedTerm?.call();
            },
            child: Text(
              text2,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w400,
                color: deepGreytextColor,
              ),
            ),
          ),
          Text(
            text3,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w400,
              color: greyTextColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              onPressedPolicy?.call();
            },
            child: Text(
              text4,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w400,
                color: deepGreytextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
