import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/doublebutton_new.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

class BottomSortBy extends StatefulWidget {
  final Function(String) onPressedButton;

  const BottomSortBy({
    Key? key,
    required this.onPressedButton,
  }) : super(key: key);

  @override
  State<BottomSortBy> createState() => _BottomSortByState();
}

class _BottomSortByState extends State<BottomSortBy> {
  String? text1;
  final controller = Get.put(CartController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  closeSheet() {
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    getPrefrenceValue();
    super.initState();
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('sortby') != null) {
      text1 = prefs.getString('sortby');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.sp), topRight: Radius.circular(16.sp)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "SORT BY",
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 16.sp,
                              fontFamily: "Franklin Gothic Semibold",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Image.asset(blackCrossImage,
                                height: 18.sp,
                                width: 18.sp,
                                color: appBarColor,
                                fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Radio(
                          value: "recommended",
                          activeColor: appBarColor,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("sortby", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "recommended";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("sortby", text1!);
                          widget.onPressedButton.call(text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Recommended",
                          style: TextStyle(
                            color: appBarColor,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: "low-to-high",
                          activeColor: appBarColor,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("sortby", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "low-to-high";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("sortby", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Price - low to high",
                          style: TextStyle(
                            color: appBarColor,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: "whats-new",
                          activeColor: appBarColor,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("sortby", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "whats-new";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("sortby", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "What’s new",
                          style: TextStyle(
                            color: appBarColor,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: "high-to-low",
                          activeColor: appBarColor,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("sortby", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "high-to-low";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("sortby", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Price - high to low",
                          style: TextStyle(
                            color: appBarColor,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: "customer-rating",
                          activeColor: appBarColor,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("sortby", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "customer-rating";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("sortby", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Customer rating",
                          style: TextStyle(
                            color: appBarColor,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DoubleButtonNew(
            firstText: "CLOSE",
            secondText: "APPLY",
            controller: controller,
            onPressedFirst: () {
              Get.back();
            },
            onPressedSecond: () {
              widget.onPressedButton.call(text1!);
              closeSheet();
            },
          )
        ],
      ),
    );
  }
}
