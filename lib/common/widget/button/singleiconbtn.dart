// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SingleIconButton extends StatelessWidget {
  final String label;
  final double roundness;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;
  final Widget? trailingWidget;
  final Function? onPressed;
  final String icon;

  const SingleIconButton({
    Key? key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    this.fontSize = 14,
    this.roundness = 1,
    this.fontWeight = FontWeight.bold,
    this.fontFamily = "Clash Display",
    this.trailingWidget,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 40.sp,
        child: ElevatedButton.icon(
            icon: ImageIcon(
              AssetImage(icon),
              color: textColor,
              size: 16.sp,
            ),
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.sp))),
                side: MaterialStateProperty.all(
                  BorderSide(width: 1.sp, color: borderColor),
                ),
                elevation: MaterialStateProperty.all(0.0),
                backgroundColor: MaterialStateProperty.all(backgroundColor),
                textStyle: MaterialStateProperty.all(TextStyle(
                  color: textColor,
                  fontSize: fontSize.sp,
                ))),
            onPressed: () {
              onPressed?.call();
            },
            label: Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                  fontSize: fontSize.sp),
            )));
  }
}
