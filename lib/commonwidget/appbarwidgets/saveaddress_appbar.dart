import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class SaveAddressAppbar extends StatelessWidget {
  final String text;
  final Function? onPressedWishlist;

  const SaveAddressAppbar(
      {Key? key, required this.text, this.onPressedWishlist})
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
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 16.sp, right: 12.sp, top: 53.sp, bottom: 10.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
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
                fontFamily: "Franklin Gothic Semibold",
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
            InkWell(
              onTap: () {
                onPressedWishlist?.call();
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 45.sp, left: 16.sp, right: 16.sp, bottom: 5.sp),
                  child: ImageIcon(
                    AssetImage(wishlistBottomIcon),
                    color: homeAppBarColor,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
