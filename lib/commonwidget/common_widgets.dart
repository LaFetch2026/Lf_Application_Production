import 'package:flutter/material.dart';

import '../controller/base_controller.dart';

Widget getSingleButton(
    {String label = "",
    double fontSize = 14,
    fontFamily = "Franklin Gothic",
    roundness = 1,
    fontWeight = FontWeight.bold,
    textColor,
    borderColor,
    backgroundColor,
    controller,
    Widget? trailingWidget,
    Function? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
        width: double.infinity,
        height: 50,
        color: backgroundColor,
        child: (controller != null && controller.pageState == PageState.LOADING)
            ? Center(
                child: Transform.scale(
                  scale: 0.5,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : ElevatedButton(
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
