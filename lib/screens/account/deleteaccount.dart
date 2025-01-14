// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/utils/constants.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/saveaddress_appbar.dart';
import '../../commonwidget/common_widgets.dart';
import '../../controller/profile_controller.dart';
import '../bottomnavscreen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({
    super.key,
  });

  @override
  State<DeleteAccountScreen> createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SaveAddressAppbar(
            text: "Account Deletion",
            onPressedWishlist: () {
              Get.off(BottomNavScreen(
                index: 2,
              ));
            },
          ),
          Divider(
            color: dividerColor,
            height: 1.sp,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.sp,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: AppText(
                  text: "Are you dure you want to delete your account?",
                  fontFamily: "Franklin Gothic Semibold",
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 10.sp,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: AppText(
                  text:
                      "LaFetch securely maintains the user-collected data integral to user onboarding processes. Information pertaining to user services will be upheld as long as necessary for organisational puposes, while individual user data will be expunged to ensure privacy.",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  maxLines: 8,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 20.sp,
              ),
            ],
          ),
          Obx(() => Padding(
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: getSingleButton(
                    label: "Confirm Deletion",
                    textColor: whiteBorderColor,
                    backgroundColor: homeAppBarColor,
                    controller: controller,
                    onPressed: () {
                      controller.callDeleteAccount();
                    },
                    borderColor: btnTextColor),
              )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp),
            child: getSingleButton(
                label: "Cancel",
                textColor: homeAppBarColor,
                backgroundColor: whiteColor,
                controller: controller,
                onPressed: () {
                  Get.back();
                },
                borderColor: btnTextColor),
          ),
        ],
      ),
    );
  }
}
