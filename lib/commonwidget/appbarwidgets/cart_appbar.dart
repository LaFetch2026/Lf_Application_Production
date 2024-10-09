import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class CartAppbar extends StatelessWidget {
  final String text;
  final bool threeDot;
  final String icon;
  final Function? onPressedHeart;

  const CartAppbar(
      {Key? key,
      required this.text,
      required this.threeDot,
      required this.icon,
      this.onPressedHeart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: whiteColor,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 16.sp, top: 40.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(backArrowImage,
                    height: 16.sp, width: 10.sp, fit: BoxFit.cover),
              ),
              SizedBox(
                width: 10.sp,
              ),
              AppText(
                text: text,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: appbarText,
                fontSize: 22,
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Visibility(
                visible: threeDot,
                child: GestureDetector(
                  onTap: () {
                    onPressedHeart?.call();
                  },
                  child: ImageIcon(
                    AssetImage(icon),
                    color: appbarText,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
