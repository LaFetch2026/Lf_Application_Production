import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class QuestionCardWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String icon;
  final double size;
  final Function? onPressed;

  const QuestionCardWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.icon,
    required this.size,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
      child: GestureDetector(
        onTap: () {
          onPressed?.call();
        },
        child: Container(
          height: 70.sp,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(1),
            border: Border.all(color: btnTextColor, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage(icon),
                  color: expressText,
                  size: size,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
                      child: AppText(
                        text: text1,
                        color: colorPrimary,
                        fontSize: 14,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.sp, top: 5.sp),
                      child: AppText(
                        text: text2,
                        color: nameText,
                        fontSize: 11,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
