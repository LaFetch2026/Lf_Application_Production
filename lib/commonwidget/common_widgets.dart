import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

isImage(String path) {
  return path.contains('product_photo');
}

Widget getSingleButton(
    {label,
    double fontSize = 14,
    fontFamily = "Franklin Gothic",
    roundness = 1,
    fontWeight = FontWeight.bold,
    width = double.infinity,
    textColor,
    borderColor,
    double right = 16,
    double left = 16,
    backgroundColor,
    controller,
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
  text,
  btn1Text,
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
              fontFamily: "Franklin Gothic Regular",
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
                  click1!.call();
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
              fontFamily: "Franklin Gothic Regular",
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
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: Center(
                    child: SizedBox(
                        width: 80.sp,
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
                              click1!.call();
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
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: Center(
                    child: SizedBox(
                        width: 80.sp,
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
                              click2!.call();
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
