import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class QuestionCardWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String icon;
  final Function? onPressed;

  const QuestionCardWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: () {
          onPressed?.call();
        },
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: whiteBorderColor,
            borderRadius: BorderRadius.circular(1),
            border: Border.all(color: btnTextColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage(icon),
                  color: expressText,
                  size: 36,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppText(
                        text: text1,
                        color: colorPrimary,
                        fontSize: 14.sp,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: AppText(
                        text: text2,
                        color: nameText,
                        fontSize: 11.sp,
                        fontFamily: "Franklin Gothic",
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
