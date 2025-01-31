// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class FilterButton extends StatefulWidget {
  final Function onPresedApply;
  final Color lineColor;

  const FilterButton({
    Key? key,
    required this.onPresedApply,
    this.lineColor = dividerColor,
  }) : super(key: key);

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool isFilter = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: dividerColor,
          width: double.infinity,
          height: 1.sp,
        ),
        Row(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                    width: (MediaQuery.of(context).size.width / 2),
                    height: 50.sp,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0))),
                            side: MaterialStateProperty.all(
                              BorderSide(
                                  width: 1,
                                  color: widget.lineColor == dividerColor
                                      ? whiteColor
                                      : homeAppBarColor),
                            ),
                            elevation: MaterialStateProperty.all(0.0),
                            backgroundColor: MaterialStateProperty.all(
                                widget.lineColor == dividerColor
                                    ? whiteColor
                                    : homeAppBarColor),
                            textStyle: MaterialStateProperty.all(TextStyle(
                                color: widget.lineColor == dividerColor
                                    ? titleColor
                                    : whiteColor,
                                fontSize: 13.sp,
                                fontFamily: "Franklin Gothic"))),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "CLOSE",
                          style: TextStyle(
                              color: widget.lineColor == dividerColor
                                  ? titleColor
                                  : whiteColor,
                              fontFamily: "Franklin Gothic",
                              fontSize: 13.sp),
                        ))),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                    width: (MediaQuery.of(context).size.width / 2),
                    height: 50.sp,
                    color: widget.lineColor == dividerColor
                        ? homeAppBarColor
                        : lightPurpleColor,
                    child: isFilter
                        ? Center(
                            child: SizedBox(
                              height: 14.sp,
                              width: 14.sp,
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: whiteColor,
                              )),
                            ),
                          )
                        : ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(0))),
                                side: MaterialStateProperty.all(BorderSide(
                                    color: widget.lineColor == dividerColor
                                        ? homeAppBarColor
                                        : lightPurpleColor,
                                    width: 1.0,
                                    style: BorderStyle.solid)),
                                elevation: MaterialStateProperty.all(0.0),
                                backgroundColor: MaterialStateProperty.all(
                                    widget.lineColor == dividerColor
                                        ? homeAppBarColor
                                        : lightPurpleColor),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    color: whiteColor,
                                    fontSize: 13.sp,
                                    fontFamily: "Franklin Gothic"))),
                            onPressed: () {
                              setState(() {
                                isFilter = true;
                              });
                              widget.onPresedApply.call();
                            },
                            child: Text(
                              "APPLY",
                              style: TextStyle(
                                  fontFamily: "Franklin Gothic",
                                  color: whiteColor,
                                  fontSize: 13.sp),
                            ))),
              ),
            ),
          ],
        ),
        /*    Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.sp, horizontal: 50.sp),
                  child: Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: btnTextColor,
                      decoration: TextDecoration.none,
                      fontSize: 14.sp,
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              child: Container(
                width: 1.sp,
                color: borderColor,
                height: 32.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isFilter = true;
                });
                widget.onPresedApply.call();
              },
              child: Container(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.sp, horizontal: 50.sp),
                  child: isFilter
                      ? SizedBox(
                          height: 20.sp,
                          width: 20.sp,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Text(
                          "Apply",
                          style: TextStyle(
                            color: btnTextColor,
                            decoration: TextDecoration.none,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      */
      ],
    );
  }
}
