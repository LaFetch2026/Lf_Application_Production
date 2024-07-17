import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final int maxLines;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;
  final Color color;
  final TextAlign? textAlign;

  const AppText({
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
        fontSize: fontSize,
        height: 1.3,
        decoration: TextDecoration.none,
        overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: color,
      ),
    );
  }
}
