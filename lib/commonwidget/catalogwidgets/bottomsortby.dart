import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                      setState(() {
                        text1 = value.toString();
                        widget.onPressedButton.call(text1!);
                      });
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "";
                    widget.onPressedButton.call(text1!);
                    setState(() {});
                    closeSheet();
                  },
                  child: Text(
                    "Recommended",
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 16.sp,
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
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "low-to-high";
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "Price - low to high",
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 16.sp,
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
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "whats-new";
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "What’s new",
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 16.sp,
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
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "high-to-low";
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "Price - high to low",
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 16.sp,
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
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                      widget.onPressedButton.call(text1!);
                      closeSheet();
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "customer-rating";
                    setState(() {});
                    widget.onPressedButton.call(text1!);
                    closeSheet();
                  },
                  child: Text(
                    "Customer rating",
                    style: TextStyle(
                      color: colorPrimary,
                      fontSize: 16.sp,
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
