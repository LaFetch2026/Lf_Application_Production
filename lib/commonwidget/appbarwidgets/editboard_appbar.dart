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
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: whiteTextColor,
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
              GestureDetector(
                onTap: () {
                  onPressedDelete?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ImageIcon(
                    AssetImage(deleteImage),
                    color: appbarText,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedShare?.call();
                },
                child: const ImageIcon(
                  AssetImage(shareImage),
                  color: appbarText,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
