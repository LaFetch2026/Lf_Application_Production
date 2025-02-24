// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/accountwidgets/profilebottom.dart';
import 'package:lafetch/commonwidget/accountwidgets/settingwidgit.dart';
import 'package:lafetch/commonwidget/accountwidgets/supportwidgets.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_account.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/screens/account/customercare.dart';
import 'package:lafetch/screens/account/deleteaccount.dart';
import 'package:lafetch/screens/account/notification_setting.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/editprofilescreen.dart';
import 'package:lafetch/screens/orderexchangescreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/common_widgets.dart';
import '../utils/constants.dart';
import 'bottomnavscreen.dart';

class AccountScreen extends StatefulWidget {
  final Function? onPressed;
  const AccountScreen({this.onPressed, super.key});

  @override
  State<AccountScreen> createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  final controller = Get.put(ProfileController());
  final homeController = Get.put(HomeController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    controller.getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(const BottomNavScreen(
          index: 0,
        ));
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            /*   Padding(
              padding: EdgeInsets.only(left: 16.sp, top: 40.sp, right: 16.sp),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppText(
                    text: "Profile",
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: appbarText,
                    fontSize: 22,
                  ),
                  const Expanded(
                    child: SizedBox(
                      height: 0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Get.to(const CartScreen());
                      await analytics.logEvent(
                        name: 'cart_page',
                        parameters: <String, Object>{
                          'page_name': 'cart_page',
                        },
                      );
                    },
                    child: SizedBox(
                      height: 30.sp,
                      width: 30.sp,
                      child: CircleAvatar(
                        backgroundColor: blackColor,
                        child: Image.asset(
                          cartNewImage,
                          color: whiteColor,
                          height: 18.sp,
                          width: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
           */
            HomeAppbar(
              showSearch: false,
              title: "Profile",
              onPressedHeart: () async {
                Get.to(const WishlistScreen());
                await analytics.logEvent(
                  name: 'wishlist_page',
                  parameters: <String, Object>{
                    'page_name': 'wishlist_page',
                  },
                );
              },
              onPressedCart: () async {
                Get.to(const CartScreen());
                await analytics.logEvent(
                  name: 'cart_page',
                  parameters: <String, Object>{
                    'page_name': 'cart_page',
                  },
                );
              },
            ),
            Obx(
              () => controller.isProfile.value
                  ? DummyAccount()
                  : controller.profileDetails != ""
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*   controller.profileDetails.isBlank
                                ? const ProfilePicWidgets()
                                : */
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp,
                                          bottom: 20.sp,
                                          right: 16.sp),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText(
                                                text: controller.profileDetails[
                                                        "name"] ??
                                                    "",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: blackColor,
                                                fontSize: 28,
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5.sp),
                                                child: Row(
                                                  children: [
                                                    ImageIcon(
                                                      AssetImage(phoneImage),
                                                      color: greyTextColor,
                                                      size: 18.sp,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.sp),
                                                      child: AppText(
                                                        text: controller
                                                                    .profileDetails[
                                                                "phone"] ??
                                                            "",
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: greyTextColor,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          const Expanded(
                                            child: SizedBox(
                                              height: 0,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          EditProfileScreen(
                                                            name: controller
                                                                        .profileDetails[
                                                                    "name"] ??
                                                                "",
                                                            email: controller
                                                                        .profileDetails[
                                                                    "email"] ??
                                                                "",
                                                            number: controller
                                                                        .profileDetails[
                                                                    "phone"] ??
                                                                "",
                                                            genderId: controller
                                                                        .profileDetails[
                                                                    "gender"] ??
                                                                0,
                                                          )))
                                                  .then((value) => setState(
                                                        () async {
                                                          controller
                                                              .getProfileData();
                                                          controller
                                                              .isEditNumber
                                                              .value = true;
                                                          controller
                                                              .isPhoneNumber
                                                              .value = false;
                                                          final prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          if (prefs.getInt(
                                                                  'gender') !=
                                                              null) {
                                                            int id =
                                                                prefs.getInt(
                                                                    'gender')!;
                                                            if (id == 1) {
                                                              homeController
                                                                  .homeGenderValue
                                                                  .value = 3;
                                                              homeController
                                                                      .genderText
                                                                      .value =
                                                                  "Women";
                                                            } else if (id ==
                                                                2) {
                                                              homeController
                                                                  .homeGenderValue
                                                                  .value = 2;
                                                              homeController
                                                                  .genderText
                                                                  .value = "Men";
                                                            } else {}
                                                          }
                                                        },
                                                      ));
                                              await analytics.logEvent(
                                                name: 'edit_profile_page',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'edit_profile_page',
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 16.sp),
                                              child: AppText(
                                                text: "Edit",
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: colorPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    /*  const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  color: backWhite,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 16, bottom: 16),
                                    child: Row(
                                      children: [
                                        const ImageIcon(
                                          AssetImage(pointImage),
                                          color: btnTextColor,
                                          size: 24,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: AppText(
                                            text:
                                                "${controller.profileDetails["reward_points"].toString()} Lafetch points",
                                            fontFamily: "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: btnTextColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 20, bottom: 20),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: whiteBack,
                                            border: Border.all(
                                                color: profileBorder, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 10,
                                              bottom: 10),
                                          child: Row(
                                            children: [
                                              Image.asset(rewardsImage,
                                                  height: 40,
                                                  width: 40,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AppText(
                                                  text: "Rewards",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: btnTextColor,
                                                  fontSize: 14.sp,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          width: 0,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: whiteBack,
                                            border: Border.all(
                                                color: profileBorder, width: 1)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 10,
                                              bottom: 10),
                                          child: Row(
                                            children: [
                                              Image.asset(mysteryBoxImage,
                                                  height: 40,
                                                  width: 40,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AppText(
                                                  text: "Mystery Box",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: btnTextColor,
                                                  fontSize: 14.sp,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              */
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.sp, left: 16.sp, right: 16.sp),
                                  child: AppText(
                                    text: "My Account",
                                    fontFamily: "Franklin Gothic Bold",
                                    fontWeight: FontWeight.w700,
                                    color: nameText,
                                    fontSize: 18,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Get.to(const OrderExchangeScreen());
                                    await analytics.logEvent(
                                      name: 'order_page',
                                      parameters: <String, Object>{
                                        'page_name': 'order_page',
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 20.sp, left: 16.sp, right: 16.sp),
                                    child: AppText(
                                      text: "Orders & Exchanges",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: nameText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Get.to(WishlistScreen());
                                    await analytics.logEvent(
                                      name: 'wishlist_page',
                                      parameters: <String, Object>{
                                        'page_name': 'wishlist_page',
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 20.sp, left: 16.sp, right: 16.sp),
                                    child: AppText(
                                      text: "My Wishlist",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: nameText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                /*  controller.profileDetails.isEmpty
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : */
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CustomerCareScreen());
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 20.sp,
                                            left: 16.sp,
                                            right: 16.sp),
                                        child: AppText(
                                          text: "Customer Care",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: nameText,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Get.to(const SavedAddressScreen(
                                          type: "address",
                                        ));
                                        await analytics.logEvent(
                                          name: 'addresslist_page',
                                          parameters: <String, Object>{
                                            'page_name': 'addresslist_page',
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 20.sp,
                                            left: 16.sp,
                                            right: 16.sp),
                                        child: AppText(
                                          text: "Saved Addresses",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: nameText,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    /* GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, left: 16, right: 16),
                                    child: AppText(
                                      text: "Payments & Currencies",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: nameText,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ), */
                                    SettingWidgets(
                                      onPressedDelete: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        DeleteAccountScreen(
                                                          date: controller.profileDetails[
                                                                      "account_deletion_requested_at"] !=
                                                                  null
                                                              ? controller
                                                                      .profileDetails[
                                                                  "account_deletion_requested_at"]
                                                              : "",
                                                          account_requested:
                                                              controller.profileDetails[
                                                                          "account_deletion_requested_at"] !=
                                                                      null
                                                                  ? true
                                                                  : false,
                                                        )))
                                            .then((value) => setState(
                                                  () async {
                                                    controller.getProfileData();
                                                  },
                                                ));
                                      },
                                      onPressedNotification: () {
                                        if (controller.profileDetails[
                                                "order_notification_enabled"] ==
                                            0) {
                                          controller.isOrder.value = false;
                                          controller.orderValue.value = 0;
                                        } else {
                                          controller.isOrder.value = true;
                                          controller.orderValue.value = 1;
                                        }
                                        if (controller.profileDetails[
                                                "offer_notification_enabled"] ==
                                            0) {
                                          controller.isOffer.value = false;
                                          controller.offerValue.value = 0;
                                        } else {
                                          controller.isOffer.value = true;
                                          controller.offerValue.value = 1;
                                        }
                                        if (controller.profileDetails[
                                                "promotional_notification_enabled"] ==
                                            0) {
                                          controller.isPermotion.value = false;
                                          controller.permotionValue.value = 0;
                                        } else {
                                          controller.isPermotion.value = true;
                                          controller.permotionValue.value = 1;
                                        }
                                        Get.to(NotificationSettingScreen())
                                            ?.then(
                                          (value) {
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                                    const SystemUiOverlayStyle(
                                              statusBarColor: statusBarColor,
                                            ));
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SupportWidgets(
                                  visibilty: false,
                                  onPressedAboutUs: () {
                                    launchUrl(Uri.parse(
                                        "https://la-fetch.com/about-us/"));
                                  },
                                  onPressedTC: () {
                                    launchUrl(Uri.parse(
                                        "https://la-fetch.com/terms-and-conditions/"));
                                  },
                                  onPressedPrivacy: () {
                                    launchUrl(Uri.parse(
                                        "https://la-fetch.com/privacy-policy/"));
                                  },
                                ),
                                /*   controller.profileDetails.isEmpty
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : */
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 60.sp, bottom: 20.sp),
                                  child: SingleButton(
                                      label: "Logout",
                                      textColor: redColor,
                                      onPressed: () {
                                        showDialog(
                                          barrierColor: Colors.black26,
                                          context: context,
                                          builder: (context) {
                                            return showDoubleBtnDailog(
                                                click1: () {
                                                  Get.back();
                                                },
                                                click2: () async {
                                                  controller.callLogout();
                                                  await analytics.logEvent(
                                                    name: 'logout_btnclick',
                                                    parameters: <String,
                                                        Object>{
                                                      'page_name':
                                                          'logout_btnclick',
                                                    },
                                                  );
                                                },
                                                btncolor: colorPrimary,
                                                text:
                                                    "Are you sure you want to logout?",
                                                btn1Text: "No",
                                                btn2Text: "Yes");
                                          },
                                        );
                                      },
                                      backgroundColor: whiteColor,
                                      borderColor: redColor),
                                ),
                                const ProfileBottom(
                                  version: " 1.0.7",
                                )
                              ],
                            ),
                          ),
                        )
                      : DummyAccount(),
            )
          ],
        ),
      ),
    );
  }
}
