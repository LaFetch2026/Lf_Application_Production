import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class BottomSheetBoard extends StatelessWidget {
  final Function? onPressedEdit;
  final Function? onPressedDelete;
  final Function? onPressedRename;
  final Function? onPressedAddItem;

  const BottomSheetBoard({
    Key? key,
    this.onPressedEdit,
    this.onPressedDelete,
    this.onPressedRename,
    this.onPressedAddItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                onPressedAddItem?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: AppText(
                  text: "Add items to board",
                  color: colorPrimary,
                  fontSize: 16.sp,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedEdit?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: AppText(
                  text: "Edit board",
                  color: colorPrimary,
                  fontSize: 16.sp,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedRename?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: AppText(
                  text: "Rename board",
                  color: colorPrimary,
                  fontSize: 16.sp,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressedDelete?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: AppText(
                  text: "Delete board",
                  color: redColor,
                  fontSize: 16.sp,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
