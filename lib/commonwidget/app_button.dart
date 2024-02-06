import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final double roundness;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets padding;
  final Color textColor;
  final Color backgroundColor;
  final Widget? trailingWidget;
  final Function? onPressed;

  const AppButton({
    Key? key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
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
      width: double.maxFinite,
      child: ElevatedButton(
        onPressed: () {
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
          elevation: 0,
          backgroundColor: backgroundColor,
          textStyle: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontWeight: fontWeight,
          ),
          padding: padding,
          minimumSize: const Size.fromHeight(50),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            ),
            if (trailingWidget != null)
              Positioned(
                top: 0,
                right: 25,
                child: trailingWidget!,
              ),
          ],
        ),
      ),
    );
  }
}
