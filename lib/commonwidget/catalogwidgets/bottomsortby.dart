import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';

class BottomSortBy extends StatefulWidget {
  final Function? onPressedEdit;

  const BottomSortBy({
    Key? key,
    this.onPressedEdit,
  }) : super(key: key);

  @override
  State<BottomSortBy> createState() => _BottomSortByState();
}

class _BottomSortByState extends State<BottomSortBy> {
  String? text1;
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
                    value: "recommended",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "recommended";
                    setState(() {});
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
                    value: "Price Low",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "Price Low";
                    setState(() {});
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
                    value: "What’s new",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "What’s new";
                    setState(() {});
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
                    value: "Price high",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "Price high";
                    setState(() {});
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
                    value: "Customer rating",
                    activeColor: colorPrimary,
                    groupValue: text1,
                    onChanged: (value) {
                      text1 = value.toString();
                      setState(() {});
                    }),
                GestureDetector(
                  onTap: () {
                    text1 = "Customer rating";
                    setState(() {});
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
