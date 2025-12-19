import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class BackButtonAppbar extends StatelessWidget {
  final String text;
  final bool threeDot;
  final String icon;
  final Function? onPressedThreeDot;
  final Color backgroundColor;

  const BackButtonAppbar(
      {Key? key,
      required this.text,
      required this.threeDot,
      required this.icon,
      this.backgroundColor = whiteTextColor,
      this.onPressedThreeDot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.sp,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: backgroundColor),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(left: 2.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  color: backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, right: 16.sp, top: 48.sp, bottom: 10.sp),
                    child: SvgPicture.asset(arrowBack,
                        height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40.sp),
                child: AppText(
                  text: text,
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  fontSize: 22,
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 40.sp,
                ),
                child: Visibility(
                  visible: threeDot,
                  child: InkWell(
                    onTap: () {
                      onPressedThreeDot?.call();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.sp),
                      child: SvgPicture.asset(
                        threeDotSvgImage,
                        height: 16.sp,
                        width: 4.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
