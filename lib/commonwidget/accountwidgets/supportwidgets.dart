import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class SupportWidgets extends StatelessWidget {
  final Function? onPressedAboutUs;
  final Function? onPressedTC;
  final Function? onPressedPrivacy;
  final Function? onPressedCancelation;
  final Function? onPressedShiping;
  final bool visibilty;

  const SupportWidgets({
    Key? key,
    this.onPressedAboutUs,
    this.onPressedTC,
    this.onPressedPrivacy,
    this.onPressedShiping,
    this.onPressedCancelation,
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
            padding: EdgeInsets.only(top: 20.sp),
            child: Container(
              width: double.infinity,
              color: borderColor,
              height: 1.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 40.sp, left: 16.sp, right: 16.sp),
          child: AppText(
            text: "Support",
            fontFamily: "Franklin Gothic Bold",
            fontWeight: FontWeight.w700,
            color: nameText,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedAboutUs?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: Row(
              children: [
                AppText(
                  text: "About Us",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: nameText,
                  fontSize: 14,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: ImageIcon(
                    AssetImage(linkArrowImage),
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedTC?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: Row(
              children: [
                AppText(
                  text: "Terms & Conditions",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: nameText,
                  fontSize: 14,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: ImageIcon(
                    AssetImage(linkArrowImage),
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedPrivacy?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: Row(
              children: [
                AppText(
                  text: "Privacy Policy",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: nameText,
                  fontSize: 14,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: ImageIcon(
                    AssetImage(linkArrowImage),
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedCancelation?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: Row(
              children: [
                AppText(
                  text: "Cancellation Policy",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: nameText,
                  fontSize: 14,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: ImageIcon(
                    AssetImage(linkArrowImage),
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onPressedShiping?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
            child: Row(
              children: [
                AppText(
                  text: "Shipping Policy",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: nameText,
                  fontSize: 14,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: ImageIcon(
                    AssetImage(linkArrowImage),
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
