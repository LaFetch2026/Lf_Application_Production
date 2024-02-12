import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';
import '../smallbtn.dart';

class LafetchCardWidget extends StatelessWidget {
  const LafetchCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
            color: colorPrimary, borderRadius: BorderRadius.circular(0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(appNameImage,
                  height: 16, width: 50, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AppText(
                text: "Insider Access",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: whiteBorderColor,
                fontSize: 28.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Center(
                child: AppText(
                  text: "Be the first to access exclusive discounts!",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w500,
                  color: whiteBorderColor,
                  maxLines: 2,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: SmallButton(
                  label: "Get Access",
                  textColor: whiteBorderColor,
                  width: 225,
                  backgroundColor: colorPrimary,
                  onPressed: () {},
                  borderColor: whiteBorderColor),
            )
          ],
        ),
      ),
    );
  }
}
