import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';
import '../smallbtn.dart';

class SaleCardWidget extends StatelessWidget {
  const SaleCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
            color: greyBack, borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AppText(
                text: "The Sale is Big!",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w500,
                color: bottomnavBack,
                fontSize: 11.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AppText(
                text: "Upto 50% Off",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                color: bottomnavBack,
                fontSize: 28.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: AppText(
                text:
                    "Get your favorite pieces - choose from over 10,000+ styles now ",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w500,
                color: bottomnavBack,
                textAlign: TextAlign.center,
                maxLines: 2,
                fontSize: 12.sp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: SmallButton(
                  label: "Shop Now",
                  width: 105,
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
