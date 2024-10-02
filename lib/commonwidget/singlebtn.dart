import 'package:flutter/material.dart';

class SingleButton extends StatelessWidget {
  final String label;
  final double roundness;
  final FontWeight fontWeight;
  final double height;
  final double fontSize;
  final String fontFamily;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;
  final Widget? trailingWidget;
  final Function? onPressed;
  final double horizontal;

  const SingleButton(
      {Key? key,
      required this.label,
      required this.textColor,
      required this.backgroundColor,
      required this.borderColor,
      this.height = 50,
      this.fontSize = 14,
      this.roundness = 1,
      this.fontWeight = FontWeight.bold,
      this.fontFamily = "Franklin Gothic",
      this.trailingWidget,
      this.onPressed,
      this.horizontal = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: SizedBox(
          width: double.infinity,
          height: height,
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
                    fontSize: fontSize),
              ))),
    );
  }
}
