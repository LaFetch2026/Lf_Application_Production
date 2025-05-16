import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';

import '../text/app_text.dart';

class SettingWidgets extends StatelessWidget {
  final Function? onPressedNotification;
  final Function? onPressedDelete;

  const SettingWidgets({
    Key? key,
    this.onPressedNotification,
    this.onPressedDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 40.sp, left: 16.sp, right: 16.sp),
          child: AppText(
            text: "Settings",
            fontFamily: "Franklin Gothic Bold",
            fontWeight: FontWeight.w700,
            color: nameText,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedNotification?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: AppText(
              text: "Notifications & Settings",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: nameText,
              fontSize: 14,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedDelete?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: AppText(
              text: "Delete Account",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: nameText,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
