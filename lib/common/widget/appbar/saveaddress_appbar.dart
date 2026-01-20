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
    return Container(
      height: 90.sp,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: statusBarColor),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 16.sp, right: 12.sp, top: 53.sp, bottom: 10.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.fill),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 45.sp),
              child: AppText(
                text: text.toUpperCase(),
                fontFamily: "Clash Display Semibold",
                fontWeight: FontWeight.w600,
                color: appBarColor,
                fontSize: 16,
              ),
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
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 45.sp,
                            left: 16.sp,
                            right: 16.sp,
                            bottom: 5.sp),
                        child: SvgPicture.asset(heartSvgImage,
                            height: 18.sp, width: 18.sp, fit: BoxFit.fill),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 20.sp,
                  ),
          ],
        ),
      ]),
    );
  }
}
