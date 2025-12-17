import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';

import '../button/smallbtn.dart';
import '../text/app_text.dart';

class SaleCardWidget extends StatelessWidget {
  const SaleCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
            color: greyBack, borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AppText(
                text: "The Sale is Big!",
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w500,
                color: bottomnavBack,
                fontSize: 11.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AppText(
                text: "Upto 50% Off",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w500,
                color: bottomnavBack,
                fontSize: 28.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: AppText(
                text:
                    "Get your favorite pieces - choose\nfrom over 10,000+ styles now ",
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: bottomnavBack,
                textAlign: TextAlign.center,
                maxLines: 2,
                fontSize: 12.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 16, right: 16, bottom: 10),
              child: SmallButton(
                  label: "Shop Now",
                  width: 115,
                  textColor: whiteBorderColor,
                  backgroundColor: colorPrimary,
                  onPressed: () {},
                  borderColor: colorPrimary),
            )
          ],
        ),
      ),
    );
  }
}
