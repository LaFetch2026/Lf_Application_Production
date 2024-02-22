import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class SupportWidgets extends StatelessWidget {
  final Function? onPressedAboutUs;
  final Function? onPressedTC;
  final Function? onPressedPrivacy;
  final bool visibilty;

  const SupportWidgets({
    Key? key,
    this.onPressedAboutUs,
    this.onPressedTC,
    this.onPressedPrivacy,
    required this.visibilty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: visibilty,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: double.infinity,
              color: borderColor,
              height: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: AppText(
            text: "Support",
            fontFamily: "Franklin Gothic Bold",
            fontWeight: FontWeight.w700,
            color: nameText,
            fontSize: 18.sp,
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedAboutUs?.call();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: AppText(
              text: "About Us",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: nameText,
              fontSize: 14.sp,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedTC?.call();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: AppText(
              text: "Terms & Conditions",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: nameText,
              fontSize: 14.sp,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedPrivacy?.call();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: AppText(
              text: "Privacy Policy",
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
