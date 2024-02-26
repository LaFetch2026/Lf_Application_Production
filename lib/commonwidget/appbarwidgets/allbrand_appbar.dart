import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class AllBrandAppbar extends StatelessWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final String text;

  const AllBrandAppbar(
      {Key? key, this.onPressedCart, this.onPressedSearch, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: colorPrimary,
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
                color: whiteBorderColor,
                fontSize: 14.sp,
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedSearch?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ImageIcon(
                    AssetImage(searchImage),
                    color: textHintColor,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedCart?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircleAvatar(
                      backgroundColor: whiteColor,
                      child: ImageIcon(
                        AssetImage(cartImage),
                        color: colorPrimary,
                        size: 20,
                      ),
                    ),
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
