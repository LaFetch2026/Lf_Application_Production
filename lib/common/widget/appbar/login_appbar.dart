import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/login_controller.dart';
import '../../../core/constant/constants.dart';
import '../text/app_text.dart';


class LoginAppbar extends StatefulWidget {
  final Function? onPressedSkip;
  final bool isSkip;
  final bool hideBack;
  final LoginController controller;

  const LoginAppbar({
    Key? key,
    this.onPressedSkip,
    this.isSkip = true,
    this.hideBack = false,
    required this.controller,
  }) : super(key: key);

  @override
  State<LoginAppbar> createState() => LoginAppbarState();
}

class LoginAppbarState extends State<LoginAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: statusBarColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(right: 16.sp, top: 56.sp, bottom: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              !widget.hideBack
                  ? InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: EdgeInsets.only(left: 16.sp, bottom: 6.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                ),
              )
                  : SizedBox(
                width: 24.sp,
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: widget.isSkip ? 0 : 16.sp,
                    left: widget.isSkip ? 10 : 0.sp),
                child: Container(
                  child: Image.asset(
                    lafetchLogoImage,
                    color: homeAppBarColor,
                    height: 25.sp,
                    width: 20.sp,
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Obx(
                    () => widget.controller.isGuest.value
                    ? Transform.scale(
                  scale: 0.3.sp,
                  child: const CircularProgressIndicator(
                    color: homeAppBarColor,
                  ),
                )
                    : Visibility(
                  visible: widget.isSkip,
                  child: InkWell(
                    onTap: () {
                      widget.onPressedSkip?.call();
                    },
                    child: AppText(
                      text: "Skip".toUpperCase(),
                      textAlign: TextAlign.right,
                      fontFamily: "Franklin Gothic Semibold",
                      fontWeight: FontWeight.w600,
                      color: searchTextColor,
                      fontSize: 12,
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
