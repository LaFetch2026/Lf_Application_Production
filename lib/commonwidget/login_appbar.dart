import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/controller/login_controller.dart';
import '../../utils/constants.dart';

class LoginAppbar extends StatefulWidget {
  final Function? onPressedSkip;
  final bool isSkip;
  final LoginController controller;

  const LoginAppbar({
    Key? key,
    this.onPressedSkip,
    this.isSkip = true,
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
      color: whiteColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(right: 16.sp, top: 56.sp, bottom: 16.sp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: EdgeInsets.only(left: 16.sp, bottom: 6.sp),
                  child: SvgPicture.asset(arrowBack,
                      height: 15.sp, width: 15.sp, fit: BoxFit.cover),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 0.sp),
                child: Image.asset(
                  lafetchLogoImage,
                  color: homeAppBarColor,
                  height: 25.sp,
                  width: 20.sp,
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
