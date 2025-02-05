import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class Cartbottom extends StatelessWidget {
  final Function? onPressedQuality;
  final Function? onPressedLocationBase;
  final Function? onPressedExchange;
  final Color backgroundColor;
  const Cartbottom({
    Key? key,
    this.onPressedQuality,
    this.onPressedLocationBase,
    this.onPressedExchange,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: 10.sp, left: 4.sp, right: 4.sp, bottom: 40.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(qualityNewImage,
                      height: 50.sp, width: 50.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp, right: 4.sp),
                    child: AppText(
                      text: "100% Quality assured",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: backgroundColor == whiteColor
                          ? subtitleColor
                          : productSubtitleColor,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(priorityNewImage,
                      height: 50.sp, width: 50.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp, right: 4.sp),
                    child: AppText(
                      text: "Priority Deliveries",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: backgroundColor == whiteColor
                          ? subtitleColor
                          : productSubtitleColor,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(exchangeNewimage,
                      height: 50.sp, width: 50.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp),
                    child: AppText(
                      text: "2 exchanges in 2 days",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: backgroundColor == whiteColor
                          ? subtitleColor
                          : productSubtitleColor,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      fontSize: 10,
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
