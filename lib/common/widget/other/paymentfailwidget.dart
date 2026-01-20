import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';
import 'common_widget.dart';

class PaymentFailWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String btntext;
  final String image;
  final bool visible;
  final Function? onPressed;

  const PaymentFailWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.btntext,
    required this.visible,
    required this.image,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 100.sp),
          child: Center(
            child: Image.asset(image,
                height: 200.sp,
                width: text1 == "Order Placed Successfully" ? 200.sp : 220.sp,
                fit: BoxFit.fill),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: visible ? 40.sp : 20.sp,
              left: 16.sp,
              right: 16.sp,
              bottom: 8),
          child: Center(
            child: AppText(
              text: text1.toUpperCase(),
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w600,
              color: homeAppBarColor,
              fontSize: 16,
            ),
          ),
        ),
        Visibility(
          visible: visible,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.sp, left: 16.sp, right: 16.sp),
            child: AppText(
              text: text2,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.sp),
          child: getSingleButton(
              width: double.infinity,
              label: btntext.toUpperCase(),
              textColor: whiteColor,
              fontSize: 13,
              backgroundColor: homeAppBarColor,
              onPressed: () {
                onPressed?.call();
              },
              borderColor: colorPrimary),
        )
      ],
    );
  }
}
