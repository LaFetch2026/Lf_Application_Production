// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/saveaddress_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constant/constants.dart';

class ConfirmDeleteScreen extends StatefulWidget {
  const ConfirmDeleteScreen({
    super.key,
  });

  @override
  State<ConfirmDeleteScreen> createState() => ConfirmDeleteScreenState();
}

class ConfirmDeleteScreenState extends State<ConfirmDeleteScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SaveAddressAppbar(
            text: "Confirm Deletion",
            onPressedWishlist: () {
              Get.to(WishlistScreen());
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
                  text:
                      "Your account deletion has been received and the account deletion will commence in 7 days.",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  maxLines: 3,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 20.sp,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp),
            child: getSingleButton(
                label: "Continue",
                textColor: whiteBorderColor,
                backgroundColor: homeAppBarColor,
                // controller: controller,
                onPressed: () {
                  controller.callLogout();
                },
                borderColor: btnTextColor),
          ),
        ],
      ),
    );
  }
}
