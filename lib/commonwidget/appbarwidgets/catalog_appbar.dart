import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class CatalogAppbar extends StatelessWidget {
  final Function? onPressedSearch;
  final Function? onPressedCart;
  final String text;

  const CatalogAppbar({
    Key? key,
    required this.text,
    this.onPressedSearch,
    this.onPressedCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: whiteColor,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 6.sp, top: 40.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  color: whiteColor,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 2.sp),
                    child: Image.asset(backArrowImage,
                        height: 16.sp, width: 10.sp, fit: BoxFit.cover),
                  ),
                ),
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
              GestureDetector(
                onTap: () {
                  onPressedSearch?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ImageIcon(
                    AssetImage(searchImage),
                    color: nameText,
                    size: 20.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedCart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 5.sp),
                  child: Image.asset(
                    cartNewImage,
                    color: nameText,
                    height: 20.sp,
                    width: 20.sp,
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
