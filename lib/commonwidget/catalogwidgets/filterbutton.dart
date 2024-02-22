import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class FilterButton extends StatelessWidget {
  final List<String>? list;
  const FilterButton({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 1,
              color: borderColor,
              height: 30,
            ),
          ),
          Text(
            "Show ${list?.length} items",
            style: TextStyle(
              color: btnTextColor,
              decoration: TextDecoration.none,
              fontSize: 14.sp,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
