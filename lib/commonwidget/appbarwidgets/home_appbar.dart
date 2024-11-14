import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';

class HomeAppbar extends StatelessWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final Function? onPressedCatalog;

  const HomeAppbar({
    Key? key,
    this.onPressedCart,
    this.onPressedCatalog,
    this.onPressedSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.sp,
      width: MediaQuery.of(context).size.width,
      color: whiteColor,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 16.sp, top: 60.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(lafetchBlackImage,
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
                    AssetImage(searchNewImage),
                    // color: textHintColor,
                    size: 20.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPressedCatalog?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                  child: ImageIcon(
                    AssetImage(saveIcon),
                    color: blackColor,
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
                    child: /* SizedBox(
                    height: 28.sp,
                    width: 28.sp,
                    child: CircleAvatar(
                      backgroundColor: whiteColor,
                      child: ImageIcon(
                        AssetImage(cartImage),
                        color: colorPrimary,
                        size: 20.sp,
                      ),
                    ),
                  ), */
                        ImageIcon(
                      AssetImage(cartNewImage),
                      color: blackColor,
                      size: 24.sp,
                    )),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
