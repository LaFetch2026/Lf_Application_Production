import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class ProductdetailsAppbar extends StatelessWidget {
  final String text;
  const ProductdetailsAppbar({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.sp,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: whiteTextColor),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(left: 6.sp, right: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 10.sp, right: 10.sp, top: 40.sp),
                  child: Image.asset(backArrowImage,
                      height: 16.sp, width: 10.sp, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40.sp, left: 10.sp, right: 20.sp),
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(appLogoImage),
                    ),
                  ),
                  child: null,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40.sp),
                child: AppText(
                  text: text,
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
