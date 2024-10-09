import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmallButton extends StatelessWidget {
  final String label;
  final double roundness;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets padding;
  final Color textColor;
  final double width;
  final Color borderColor;
  final Color backgroundColor;
  final Widget? trailingWidget;
  final Function? onPressed;

  const SmallButton({
    Key? key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.width,
    this.fontSize = 14,
    this.roundness = 1,
    this.fontWeight = FontWeight.bold,
    this.fontFamily = "Franklin Gothic",
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.trailingWidget,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: 44.sp,
        child: ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1))),
                side: MaterialStateProperty.all(
                  BorderSide(width: 1, color: borderColor),
                ),
                elevation: MaterialStateProperty.all(0.0),
                backgroundColor: MaterialStateProperty.all(backgroundColor),
                textStyle: MaterialStateProperty.all(TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                ))),
            onPressed: () {
              onPressed?.call();
            },
            child: Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontFamily: fontFamily,
                  fontSize: fontSize.sp),
            )));
  }
}
