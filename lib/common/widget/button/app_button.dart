import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  final String label;
  final double roundness;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;
  final String image;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;
  final Widget? trailingWidget;
  final Function? onPressed;

  const AppButton({
    Key? key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.image,
    this.fontSize = 14,
    this.roundness = 1,
    this.fontWeight = FontWeight.bold,
    this.fontFamily = "Clash Display",
    this.trailingWidget,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: SizedBox(
          width: double.infinity,
          height: 50.sp,
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1))),
                  side: MaterialStateProperty.all(
                    BorderSide(width: 1.sp, color: borderColor),
                  ),
                  elevation: MaterialStateProperty.all(0.0),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all(backgroundColor),
                  textStyle: MaterialStateProperty.all(TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                  ))),
              onPressed: () {
                onPressed?.call();
              },
              child: Row(
                children: [
                  Image.asset(
                    image,
                    height: 22.sp,
                    width: 22.sp,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                            color: textColor,
                            fontFamily: fontFamily,
                            fontSize: fontSize),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
