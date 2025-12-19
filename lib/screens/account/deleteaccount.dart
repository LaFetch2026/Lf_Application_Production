// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/saveaddress_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constant/constants.dart';

class DeleteAccountScreen extends StatefulWidget {
  final bool account_requested;
  final String date;

  const DeleteAccountScreen({
    required this.account_requested,
    required this.date,
    super.key,
  });

  @override
  State<DeleteAccountScreen> createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      systemNavigationBarColor: statusBarColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SaveAddressAppbar(
            text: "Account Deletion",
            showWishlist: false,
            onPressedWishlist: () {
              Get.to(WishlistScreen());
            },
          ),
          Divider(
            color: dividerColor,
            height: 1.sp,
          ),
          widget.account_requested
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 30.sp),
                      child: AppText(
                        text:
                            //  "Your account is scheduled to be deleted at ${widget.date}. If you don't want this to be deleted, please reach out to support@la-fetch.com",
                            "Your account is scheduled to be deleted within 7 days. If you don't want this to be deleted, please reach out to support@la-fetch.com",
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: redColor,
                        maxLines: 4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: AppText(
                        text: "Are you sure you want to delete your account?",
                        fontFamily: "Clash Display Semibold",
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
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: appbarText,
                        maxLines: 8,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 20.sp,
                    ),
                    Obx(() => Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.sp),
                          child: getSingleButton(
                              label: "Confirm Deletion",
                              textColor: whiteBorderColor,
                              backgroundColor: homeAppBarColor,
                              controller: controller,
                              onPressed: () async {
                                controller.callDeleteAccount();
                                await analytics.logEvent(
                                  name: 'confirm_delete_btnclick',
                                  parameters: <String, Object>{
                                    'page_name': 'confirm_delete_btnclick',
                                  },
                                );
                              },
                              borderColor: btnTextColor),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.sp),
                      child: getSingleButton(
                          label: "Cancel",
                          textColor: homeAppBarColor,
                          backgroundColor: whiteColor,
                          // controller: controller,
                          onPressed: () {
                            Get.back();
                          },
                          borderColor: btnTextColor),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
