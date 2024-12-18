import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.sp), topRight: Radius.circular(16.sp)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.sp),
              child: Center(
                child: Image.asset(
                  handleImage,
                  height: 7.sp,
                  width: 80.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
              child: Text(
                "Sort by",
                style: TextStyle(
                  color: greyTextColor,
                  fontSize: 12.sp,
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              children: [
                Radio(
                    value: "",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) {
                      setState(() async {
                        text1 = value.toString();
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString("sortby", text1!);
                        widget.onPressedButton.call(text1!);
                      });
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("sortby", text1!);
                    widget.onPressedButton.call(text1!);
                    setState(() {});
                    closeSheet();
                  },
                  child: Text(
                    "Recommended",
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
                    value: "low-to-high",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("sortby", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "low-to-high";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("sortby", text1!);
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "Price - low to high",
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
                    value: "whats-new",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("sortby", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "whats-new";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("sortby", text1!);
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "What’s new",
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
                    value: "high-to-low",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("sortby", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "high-to-low";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("sortby", text1!);
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "Price - high to low",
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
                    value: "customer-rating",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("sortby", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "customer-rating";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("sortby", text1!);
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "Customer rating",
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
    );
  }
}
