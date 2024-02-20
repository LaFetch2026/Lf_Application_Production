import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class SettingWidgets extends StatelessWidget {
  final Function? onPressedNotification;

  const SettingWidgets({
    Key? key,
    this.onPressedNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: AppText(
            text: "Settings",
            fontFamily: "Franklin Gothic Bold",
            fontWeight: FontWeight.w700,
            color: nameText,
            fontSize: 18.sp,
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedNotification?.call();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: AppText(
              text: "Notifications & Settings",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: nameText,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
