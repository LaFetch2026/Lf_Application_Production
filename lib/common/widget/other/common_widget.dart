// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/base_controller.dart';
import '../../../core/constant/constants.dart';

import 'package:get/get.dart';

enum SnackBarType { success, error, info, warning }

void showAppSnackBar(
  String message, {
  SnackBarType type = SnackBarType.info,
  SnackPosition position = SnackPosition.BOTTOM,
  Duration duration = const Duration(seconds: 3),
}) {
  Color backgroundColor;
  Color textColor;
  IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = snackBarBrandColor.withOpacity(0.12);
      textColor = snackBarBrandColor;
      icon = Icons.check_circle_outline;
      break;

    case SnackBarType.error:
      backgroundColor = snackBarBrandColor.withOpacity(0.12);
      textColor = snackBarBrandColor;
      icon = Icons.error_outline;
      break;

    case SnackBarType.warning:
      backgroundColor = snackBarBrandColor.withOpacity(0.12);
      textColor = snackBarBrandColor;
      icon = Icons.warning_amber_outlined;
      break;

    case SnackBarType.info:
      backgroundColor = snackBarBrandColor.withOpacity(0.12);
      textColor = snackBarBrandColor;
      icon = Icons.info_outline;
      break;
  }

  Get.snackbar(
    '',
    message,
    titleText: Container(),
    duration: duration,
    snackPosition: position,
    backgroundColor: backgroundColor,
    colorText: textColor,
    icon: Icon(icon, color: textColor, size: 24.sp),
    borderRadius: 8.sp,
    margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
    padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    messageText: Text(
      message,
      style: TextStyle(
        color: textColor,
        fontSize: 13.sp,
        fontFamily: "Clash Display Regular",
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

// Legacy support - keep old function name but use new implementation
@Deprecated('Use showAppSnackBar instead')
void getSnackBar(String message, {SnackPosition? snackPosition}) {
  showAppSnackBar(
    message,
    type: SnackBarType.info,
    position: snackPosition ?? SnackPosition.BOTTOM,
  );
}

bool isImage(String path) {
  return path.contains('product_photo');
}

Widget getSingleButton(
    {required String label,
    double fontSize = 14,
    String fontFamily = "Clash Display",
    double roundness = 1,
    FontWeight fontWeight = FontWeight.bold,
    double width = double.infinity,
    required Color textColor,
    required Color borderColor,
    double right = 16,
    double left = 16,
    required Color backgroundColor,
    BaseController? controller,
    Widget? trailingWidget,
    Function? onPressed}) {
  return Padding(
    padding: EdgeInsets.only(left: left.sp, right: right.sp),
    child: Container(
        width: width,
        height: 50.sp,
        color: backgroundColor,
        child: (controller != null && controller.pageState == PageState.LOADING)
            ? Center(
                child: Transform.scale(
                  scale: 0.5.sp,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : ElevatedButton(
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
                child: Text(
                  label,
                  style: TextStyle(
                      color: textColor,
                      fontFamily: fontFamily,
                      fontSize: fontSize.sp),
                ))),
  );
}

Widget getSmallButton(
    {String label = "",
    double fontSize = 14,
    String fontFamily = "Clash Display",
    double roundness = 1,
    FontWeight fontWeight = FontWeight.bold,
    double width = double.infinity,
    required Color textColor,
    required Color borderColor,
    required Color backgroundColor,
    BaseController? controller,
    Widget? trailingWidget,
    Function? onPressed}) {
  return Container(
      width: width,
      height: 44.sp,
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
              child: Text(
                label,
                style: TextStyle(
                    color: textColor,
                    fontFamily: fontFamily,
                    fontSize: fontSize.sp),
              )));
}

Route scaleIn(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, page) {
      var begin = 0.0;
      var end = 1.0;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return ScaleTransition(
        scale: animation.drive(tween),
        child: page,
      );
    },
  );
}

Widget showSingleBtnNonCancelableDailog({
  Color btncolor = colorPrimary,
  required String text,
  required String btn1Text,
  Function? click1,
}) {
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
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.0,
              color: colorPrimary,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100))),
                    side: MaterialStateProperty.all(
                      BorderSide(width: 1, color: btncolor),
                    ),
                    backgroundColor: MaterialStateProperty.all(btncolor),
                    textStyle: MaterialStateProperty.all(const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ))),
                onPressed: () {
                  click1?.call();
                },
                child: Text(
                  btn1Text,
                  style: const TextStyle(color: colorSecondary, fontSize: 12),
                )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    ),
  );
}

Widget showDoubleBtnDailog(
    {Color btncolor = colorPrimary,
    required String text,
    required String btn1Text,
    required String btn2Text,
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
        SizedBox(height: 15.sp),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10.sp),
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.cancel,
                color: btncolor,
                size: 24.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 25.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0.sp,
              color: colorPrimary,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.sp),
                  child: Center(
                    child: SizedBox(
                        width: 90.sp,
                        height: 30.sp,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.sp))),
                                side: MaterialStateProperty.all(
                                  BorderSide(width: 1.sp, color: btncolor),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(btncolor),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ))),
                            onPressed: () async {
                              click1?.call();
                            },
                            child: Text(
                              btn1Text,
                              style: TextStyle(
                                  color: colorSecondary, fontSize: 12.sp),
                            ))),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.sp),
                  child: Center(
                    child: SizedBox(
                        width: 95.sp,
                        height: 30.sp,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.sp))),
                                side: MaterialStateProperty.all(
                                  BorderSide(width: 1.sp, color: btncolor),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(btncolor),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ))),
                            onPressed: () {
                              click2?.call();
                            },
                            child: Text(
                              btn2Text,
                              style: TextStyle(
                                  color: colorSecondary, fontSize: 12.sp),
                            ))),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.sp,
        ),
      ],
    ),
  );
}
