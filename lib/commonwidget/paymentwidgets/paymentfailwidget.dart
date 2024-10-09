import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/smallbtn.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

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
        Visibility(
            visible: visible,
            child: Center(
              child: Image.asset(image,
                  height: 180.sp, width: 200.sp, fit: BoxFit.cover),
            )),
        Padding(
          padding: EdgeInsets.only(top: 40.sp, left: 16.sp, right: 16.sp),
          child: Center(
            child: AppText(
              text: text1,
              fontFamily: "Franklin Gothic Bold",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
          child: AppText(
            text: text2,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: blackColor,
            fontSize: 14,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30.sp, left: 16.sp, right: 16.sp),
          child: SmallButton(
              width: 160.sp,
              label: btntext,
              textColor: whiteBorderColor,
              backgroundColor: colorPrimary,
              onPressed: () {
                onPressed?.call();
              },
              borderColor: colorPrimary),
        )
      ],
    );
  }
}
