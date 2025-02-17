// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/doublebutton_new.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

class BottomCategory extends StatefulWidget {
  final String gender;
  final Function(String) onPressedButton;
  final Function onPressedFilter;
  final Color backgroundColor;

  const BottomCategory({
    Key? key,
    required this.gender,
    required this.onPressedButton,
    this.backgroundColor = whiteColor,
    required this.onPressedFilter,
  }) : super(key: key);

  @override
  State<BottomCategory> createState() => _BottomCategoryState();
}

class _BottomCategoryState extends State<BottomCategory> {
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
    if (prefs.getString('category') != null) {
      text1 = prefs.getString('category');
    } else {
      text1 = widget.gender;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        /*   borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.sp), topRight: Radius.circular(16.sp)), */
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.sp,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.sp,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.sp),
                            child: Text(
                              "Category".toUpperCase(),
                              style: TextStyle(
                                color: widget.backgroundColor == whiteColor
                                    ? blackColor
                                    : whiteColor,
                                fontSize: 16.sp,
                                fontFamily: "Franklin Gothic Semibold",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.onPressedFilter.call();
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.sp),
                              child: Text(
                                "View All Filters".toUpperCase(),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: widget.backgroundColor == whiteColor
                                      ? subtitleColor
                                      : whiteColor,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Radio(
                          value: "Men",
                          activeColor: widget.backgroundColor == whiteColor
                              ? homeAppBarColor
                              : dividerColor,
                          groupValue: text1,
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return widget.backgroundColor == whiteColor
                                    ? homeAppBarColor
                                    : dividerColor;
                              }
                              return searchTextColor;
                            },
                          ),
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("category", text1!);
                            setState(() {});
                          }),
                      InkWell(
                        onTap: () async {
                          text1 = "Men";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("category", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Men",
                          style: TextStyle(
                            color: widget.backgroundColor == whiteColor
                                ? subtitleColor
                                : dividerColor,
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
                          value: "Women",
                          activeColor: widget.backgroundColor == whiteColor
                              ? homeAppBarColor
                              : dividerColor,
                          groupValue: text1,
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return widget.backgroundColor == whiteColor
                                    ? homeAppBarColor
                                    : dividerColor;
                              }
                              return searchTextColor;
                            },
                          ),
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("category", text1!);
                            setState(() {});
                          }),
                      InkWell(
                        onTap: () async {
                          text1 = "Women";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("category", text1!);
                          widget.onPressedButton.call(text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Women",
                          style: TextStyle(
                            color: widget.backgroundColor == whiteColor
                                ? subtitleColor
                                : dividerColor,
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
                          value: "Accessories",
                          activeColor: widget.backgroundColor == whiteColor
                              ? homeAppBarColor
                              : dividerColor,
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return widget.backgroundColor == whiteColor
                                    ? homeAppBarColor
                                    : dividerColor;
                              }
                              return searchTextColor;
                            },
                          ),
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("category", text1!);
                            setState(() {});
                          }),
                      InkWell(
                        onTap: () async {
                          text1 = "Accessories";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("category", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Accessories",
                          style: TextStyle(
                            color: widget.backgroundColor == whiteColor
                                ? subtitleColor
                                : dividerColor,
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
            lineColor: widget.backgroundColor == whiteColor
                ? dividerColor
                : homeAppBarColor,
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
