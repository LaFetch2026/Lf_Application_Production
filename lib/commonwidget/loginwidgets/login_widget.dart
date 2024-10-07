import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class LoginWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String fontfamily;

  const LoginWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.fontfamily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.sp, left: 16.sp),
          child: AppText(
            text: text1,
            fontFamily: fontfamily,
            fontWeight: FontWeight.w500,
            color: btnTextColor,
            fontSize: 25,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.sp, left: 16.sp),
          child: AppText(
            text: text2,
            maxLines: 2,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
