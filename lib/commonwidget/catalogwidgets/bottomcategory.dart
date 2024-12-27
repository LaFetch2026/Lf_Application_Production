import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      height: 240.sp,
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
                "Category",
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
                    value: "Women",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("category", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);

                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "Women";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("category", text1!);
                    widget.onPressedButton.call(text1!);
                    setState(() {});
                    closeSheet();
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
                    value: "Men",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("category", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "Men";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("category", text1!);
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
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
                    value: "Accesories",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) async {
                      text1 = value.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("category", text1!);
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () async {
                    text1 = "Accesories";
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("category", text1!);
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
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
    );
  }
}
