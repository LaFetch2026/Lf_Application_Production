import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class LoginWidget extends StatelessWidget {
  final String text1;
  final String text2;

  const LoginWidget({
    Key? key,
    required this.text1,
    required this.text2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 16),
          child: AppText(
            text: text1,
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w400,
            color: btnTextColor,
            fontSize: 25.sp,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 16),
          child: AppText(
            text: text2,
            maxLines: 2,
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w400,
            color: textColor,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
