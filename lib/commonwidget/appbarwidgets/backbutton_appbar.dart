import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class BackButtonAppbar extends StatelessWidget {
  final String text;
  final bool threeDot;
  final String icon;
  final Function? onPressedThreeDot;
  final Color backgroundColor;

  const BackButtonAppbar(
      {Key? key,
      required this.text,
      required this.threeDot,
      required this.icon,
      this.backgroundColor = whiteTextColor,
      this.onPressedThreeDot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: backgroundColor,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(backArrowImage,
                    height: 16, width: 10, fit: BoxFit.cover),
              ),
              const SizedBox(
                width: 10,
              ),
              AppText(
                text: text,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: appbarText,
                fontSize: 22.sp,
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
                    onPressedThreeDot?.call();
                  },
                  child: ImageIcon(
                    AssetImage(icon),
                    color: appbarText,
                    size: 20,
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
