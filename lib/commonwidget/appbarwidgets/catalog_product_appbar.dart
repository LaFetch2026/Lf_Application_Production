import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

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
    return Container(
      height: 80.sp,
      width: MediaQuery.of(context).size.width,
      color: colorPrimary,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 16.sp, top: 40.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  arrowBack,
                  height: 20.sp,
                  width: 20.sp,
                  color: whiteColor,
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Image.asset(appNameImage,
                  height: 28.sp, width: 70.sp, fit: BoxFit.cover),
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
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: ImageIcon(
                    AssetImage(searchImage),
                    color: textHintColor,
                    size: 20.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedCart?.call();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 10.sp),
                  child: SizedBox(
                    height: 28.sp,
                    width: 28.sp,
                    child: CircleAvatar(
                        backgroundColor: whiteColor,
                        child: Image.asset(
                          cartNewImage,
                          height: 20.sp,
                          width: 20.sp,
                        )),
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
