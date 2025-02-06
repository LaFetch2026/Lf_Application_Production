import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class CartWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final String btntext;
  final String? image;
  final bool visible;
  final Function? onPressed;
  final Color backColor;

  const CartWidget({
    Key? key,
    required this.text1,
    required this.text2,
    required this.btntext,
    required this.visible,
    this.backColor = whiteColor,
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
                  height: 220.sp, width: 189.sp, fit: BoxFit.cover),
            )),
        Padding(
          padding: EdgeInsets.only(top: 30.sp, left: 20.sp, right: 20.sp),
          child: Center(
            child: AppText(
              text: text1,
              fontFamily: "Franklin Gothic Bold",
              fontWeight: FontWeight.w700,
              color: backColor == whiteColor ? blackColor : whiteColor,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.sp, left: 20.sp, right: 20.sp),
          child: AppText(
            text: text2,
            textAlign: TextAlign.center,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            maxLines: 2,
            color: backColor == whiteColor ? blackColor : whiteColor,
            fontSize: 14,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30.sp, left: 24.sp, right: 24.sp),
          child: SingleButton(
              label: btntext,
              textColor:
                  backColor == whiteColor ? whiteBorderColor : homeAppBarColor,
              backgroundColor:
                  backColor == whiteColor ? colorPrimary : whiteColor,
              onPressed: () {
                onPressed?.call();
              },
              borderColor: backColor == whiteColor ? colorPrimary : whiteColor),
        )
      ],
    );
  }
}
