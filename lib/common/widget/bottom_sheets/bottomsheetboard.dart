import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';

import '../text/app_text.dart';

class BottomSheetBoard extends StatelessWidget {
  final Function? onPressedEdit;
  final Function? onPressedDelete;
  final Function? onPressedRename;
  final Function? onPressedAddItem;
  final Function? onPressedShare;

  const BottomSheetBoard({
    Key? key,
    this.onPressedEdit,
    this.onPressedDelete,
    this.onPressedRename,
    this.onPressedAddItem,
    this.onPressedShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270.sp,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.sp),
              child: Center(
                child: Image.asset(
                  handleImage,
                  height: 7.sp,
                  width: 80.sp,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedAddItem?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(top: 25.sp),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: ImageIcon(
                        AssetImage(addBoardImage),
                        size: 20.sp,
                      ),
                    ),
                    AppText(
                      text: "Add items to board",
                      color: colorPrimary,
                      fontSize: 16,
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedEdit?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(top: 20.sp),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: ImageIcon(
                        AssetImage(editBoardImage),
                        size: 20.sp,
                      ),
                    ),
                    AppText(
                      text: "Edit board",
                      color: colorPrimary,
                      fontSize: 16,
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedRename?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(top: 20.sp),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: ImageIcon(
                        AssetImage(renameBoardImage),
                        size: 20.sp,
                      ),
                    ),
                    AppText(
                      text: "Rename board",
                      color: colorPrimary,
                      fontSize: 16,
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedShare?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(top: 20.sp),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: ImageIcon(
                        AssetImage(shareImage),
                        size: 20.sp,
                      ),
                    ),
                    AppText(
                      text: "Share board",
                      color: colorPrimary,
                      fontSize: 16,
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedDelete?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(top: 20.sp),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.sp),
                      child: ImageIcon(
                        AssetImage(deleteBoardImage),
                        color: lightPurpleColor,
                        size: 20.sp,
                      ),
                    ),
                    AppText(
                      text: "Delete board",
                      color: lightPurpleColor,
                      fontSize: 16,
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
