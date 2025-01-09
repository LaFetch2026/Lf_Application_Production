import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/doublebutton_new.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

class BottomCategory extends StatefulWidget {
  final Function(String) onPressedButton;

  const BottomCategory({
    Key? key,
    required this.onPressedButton,
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
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: whiteColor,
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
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 5.sp),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Category".toUpperCase(),
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 16.sp,
                              fontFamily: "Franklin Gothic Semibold",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "View All Filters".toUpperCase(),
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: appBarColor,
                              fontSize: 10.sp,
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
                          activeColor: colorPrimary,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("category", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "Men";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("category", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Men",
                          style: TextStyle(
                            color: colorPrimary,
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
                          activeColor: colorPrimary,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("category", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
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
                            color: colorPrimary,
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
                          value: "Accesories",
                          activeColor: colorPrimary,
                          groupValue: text1,
                          onChanged: (value) async {
                            text1 = value.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("category", text1!);
                            setState(() {});
                          }),
                      GestureDetector(
                        onTap: () async {
                          text1 = "Accesories";
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("category", text1!);
                          setState(() {});
                        },
                        child: Text(
                          "Accesories",
                          style: TextStyle(
                            color: colorPrimary,
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
