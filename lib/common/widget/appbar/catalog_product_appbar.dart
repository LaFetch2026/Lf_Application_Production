// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constant/constants.dart';

class CatalogProductAppbar extends StatelessWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;

  const CatalogProductAppbar({
    Key? key,
    this.onPressedCart,
    this.onPressedSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: colorPrimary,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp, top: statusBarHeight + 8.sp, right: 16.sp, bottom: 8.sp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                Get.back();
                final prefs = await SharedPreferences.getInstance();
                prefs.remove("brandList");
                prefs.remove("colorList");
                prefs.remove("sizeList");
                prefs.remove("upper");
                prefs.remove("lower");
                prefs.remove("sortby");
              },
              child: SvgPicture.asset(arrowBack,
                  color: whiteColor,
                  height: 15.sp,
                  width: 15.sp,
                  fit: BoxFit.fill),
            ),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            Image.asset(appNameImage,
                height: 28.sp, width: 70.sp, fit: BoxFit.fill),
            const Expanded(
              child: SizedBox(
                height: 0,
              ),
            ),
            InkWell(
              onTap: () {
                onPressedSearch?.call();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.sp),
                child: ImageIcon(
                  AssetImage(searchImage),
                  color: whiteColor,
                  size: 20.sp,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                onPressedCart?.call();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 10.sp),
                child: Image.asset(
                  cartNewImage,
                  color: whiteColor,
                  height: 20.sp,
                  width: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
