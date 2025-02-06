import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class EditBoardAppbar extends StatelessWidget {
  final String text;

  final Function? onPressedDelete;

  final Function? onPressedShare;

  const EditBoardAppbar({
    Key? key,
    required this.text,
    this.onPressedDelete,
    this.onPressedShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: whiteTextColor,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 16.sp, top: 40.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(backArrowImage,
                    height: 16.sp, width: 10.sp, fit: BoxFit.cover),
              ),
              const SizedBox(
                width: 10,
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
              InkWell(
                onTap: () {
                  onPressedDelete?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: ImageIcon(
                    AssetImage(deleteImage),
                    color: appbarText,
                    size: 20.sp,
                  ),
                ),
              ),
              /*  GestureDetector(
                onTap: () {
                  onPressedShare?.call();
                },
                child: const ImageIcon(
                  AssetImage(shareImage),
                  color: appbarText,
                  size: 16.sp,
                ),
              ), */
            ],
          ),
        ),
      ]),
    );
  }
}
