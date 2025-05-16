import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';


class ProfileBottom extends StatelessWidget {
  final Function? onPressedDelivery;
  final Function? onPressedQuality;
  final Function? onPressedLocationBase;
  final Function? onPressedExchange;
  final String version;

  const ProfileBottom({
    Key? key,
    this.onPressedDelivery,
    this.onPressedQuality,
    this.onPressedLocationBase,
    this.onPressedExchange,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.sp),
          child: Container(
            width: double.infinity,
            color: borderColor,
            height: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 10.sp, left: 16.sp, right: 16.sp, bottom: 10.sp),
          child: Center(
            child: AppText(
              text: "App version $version",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: textHintColor,
              fontSize: 11,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 10.sp, left: 16.sp, right: 16.sp, bottom: 40.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(deliveredImage,
                      height: 40.sp, width: 40.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp),
                    child: AppText(
                      text: "Delivered in\n6 hours",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(qualityImage,
                      height: 40.sp, width: 40.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp),
                    child: AppText(
                      text: "100% Quality\nassured",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(locationBaseImage,
                      height: 40.sp, width: 40.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp),
                    child: AppText(
                      text: "Location based\nDeliveries",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(exchangeImage,
                      height: 40.sp, width: 40.sp, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.only(top: 4.sp),
                    child: AppText(
                      text: "exchange\navailable",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
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
