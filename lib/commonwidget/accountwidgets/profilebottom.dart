import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

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
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: double.infinity,
            color: borderColor,
            height: 1,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
          child: Center(
            child: AppText(
              text: "App version $version",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: textHintColor,
              fontSize: 11.sp,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(deliveredImage,
                      height: 40, width: 40, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      text: "Delivered in\n6 hours",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10.sp,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(qualityImage,
                      height: 40, width: 40, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      text: "100% Quality\nassured",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10.sp,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(locationBaseImage,
                      height: 40, width: 40, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      text: "Location based\nDeliveries",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10.sp,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Image.asset(exchangeImage,
                      height: 40, width: 40, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(
                      text: "2 exchanges\nwithin 2 days",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: greyTextColor,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      fontSize: 10.sp,
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
