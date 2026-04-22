import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class SaveAddressAppbar extends StatelessWidget {
  final String text;
  final Function? onPressedWishlist;
  final bool showWishlist;

  const SaveAddressAppbar(
      {Key? key,
      required this.text,
      this.onPressedWishlist,
      this.showWishlist = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: statusBarColor),
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp,
            top: statusBarHeight + 8.sp,
            right: 10.sp,
            bottom: 8.sp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: EdgeInsets.only(right: 12.sp),
                child: SvgPicture.asset(arrowBack,
                    height: 15.sp, width: 15.sp, fit: BoxFit.fill),
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            AppText(
              text: text.toUpperCase(),
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w600,
              color: appBarColor,
              fontSize: 16,
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            showWishlist
                ? GestureDetector(
                    onTap: () {
                      onPressedWishlist?.call();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.sp, right: 6.sp),
                      child: SvgPicture.asset(heartSvgImage,
                          height: 18.sp, width: 18.sp, fit: BoxFit.fill),
                    ),
                  )
                : SizedBox(
                    width: 20.sp,
                  ),
          ],
        ),
      ),
    );
  }
}
