import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/smallbtn.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class PaymentFailWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String btntext;
  final String? image;
  final bool visible;
  final Function? onPressed;

  const PaymentFailWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.btntext,
    required this.visible,
    this.image,
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
              child: Image.asset(image!,
                  height: 180, width: 200, fit: BoxFit.cover),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: Center(
            child: AppText(
              text: text1,
              fontFamily: "Franklin Gothic Bold",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 18.sp,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: AppText(
            text: text2,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: blackColor,
            fontSize: 14.sp,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: SmallButton(
              width: 150,
              label: btntext,
              textColor: whiteBorderColor,
              backgroundColor: btnTextColor,
              onPressed: () {
                onPressed?.call();
              },
              borderColor: btnTextColor),
        )
      ],
    );
  }
}
