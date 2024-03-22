import 'package:flutter/material.dart';
import '../controller/base_controller.dart';
import 'package:get/get.dart';
import 'package:lafetch/utils/constants.dart';

getSnackBar(message, {SnackPosition? snackPosition}) {
  return Get.snackbar(
    '',
    message,
    titleText: Container(),
    duration: const Duration(seconds: 2),
    snackPosition: snackPosition ?? SnackPosition.TOP,
    backgroundColor: colorSecondary,
    colorText: colorPrimary,
  );
}

Widget getSingleButton(
    {String label = "",
    double fontSize = 14,
    fontFamily = "Franklin Gothic",
    roundness = 1,
    fontWeight = FontWeight.bold,
    width = double.infinity,
    textColor,
    borderColor,
    backgroundColor,
    controller,
    Widget? trailingWidget,
    Function? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
        width: width,
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

Widget getSmallButton(
    {String label = "",
    double fontSize = 14,
    fontFamily = "Franklin Gothic",
    roundness = 1,
    fontWeight = FontWeight.bold,
    double width = double.infinity,
    textColor,
    borderColor,
    backgroundColor,
    controller,
    Widget? trailingWidget,
    Function? onPressed}) {
  return Container(
      width: width,
      height: 44,
      color: backgroundColor,
      child: (controller != null && controller.pageState == PageState.LOADING)
          ? Center(
              child: Transform.scale(
                scale: 0.5,
                child: const CircularProgressIndicator(
                  color: Colors.grey,
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
              )));
}

Widget showDoubleBtnDailog(
    {Color btncolor = colorPrimary,
    text,
    btn1Text,
    btn2Text,
    Function? click1,
    Function? click2}) {
  return Dialog(
    elevation: 0,
    backgroundColor: colorSecondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(Icons.cancel, color: btncolor),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.0,
            color: colorPrimary,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                        width: 80,
                        height: 30,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100))),
                                side: MaterialStateProperty.all(
                                  BorderSide(width: 1, color: btncolor),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(btncolor),
                                textStyle:
                                    MaterialStateProperty.all(const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ))),
                            onPressed: () async {
                              click1!.call();
                            },
                            child: Text(
                              btn1Text,
                              style: const TextStyle(
                                  color: colorSecondary, fontSize: 12),
                            ))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                        width: 80,
                        height: 30,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100))),
                                side: MaterialStateProperty.all(
                                  BorderSide(width: 1, color: btncolor),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(btncolor),
                                textStyle:
                                    MaterialStateProperty.all(const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ))),
                            onPressed: () {
                              click2!.call();
                            },
                            child: Text(
                              btn2Text,
                              style: const TextStyle(
                                  color: colorSecondary, fontSize: 12),
                            ))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    ),
  );
}
