import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class ORWidget extends StatelessWidget {
  const ORWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 16.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: 100.sp,
              color: lightText,
              height: 1.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: AppText(
              text: "OR",
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
              color: lightText,
              fontSize: 11,
            ),
          ),
          Expanded(
            child: Container(
              width: 100.sp,
              color: lightText,
              height: 1.sp,
            ),
          ),
        ],
      ),
    );
  }
}
