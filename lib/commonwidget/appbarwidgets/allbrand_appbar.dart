import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class AllBrandAppbar extends StatelessWidget {
  final Function? onPressedCart;
  final Function? onPressedSearch;
  final Function? onPressedback;
  final String text;

  const AllBrandAppbar(
      {Key? key,
      this.onPressedCart,
      this.onPressedSearch,
      required this.text,
      required this.onPressedback})
      : super(key: key);

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
                  onPressedback!.call();
                },
                child: Image.asset(backArrowImage,
                    height: 16.sp, width: 10.sp, fit: BoxFit.cover),
              ),
              SizedBox(
                width: 10.sp,
              ),
              AppText(
                text: text,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: whiteBorderColor,
                fontSize: 14,
              ),
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
                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
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
                  padding: EdgeInsets.only(left: 5.sp),
                  child: SizedBox(
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
