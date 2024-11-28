import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class FilterButton extends StatefulWidget {
  final Function onPresedApply;
  const FilterButton({Key? key, required this.onPresedApply}) : super(key: key);

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool isFilter = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
      child: Row(
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
    );
  }
}
