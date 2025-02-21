import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacingText extends StatelessWidget {
  final String text;
  final int maxLines;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;
  final Color color;
  final TextAlign? textAlign;

  const AppSpacingText({
    Key? key,
    required this.text,
    this.maxLines = 1,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = "Franklin Gothic",
    this.color = Colors.black,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign == null ? null : TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize.sp,
        height: 1.3,
        decoration: TextDecoration.none,
        letterSpacing: 0.65,
        overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: color,
      ),
    );
  }
}
