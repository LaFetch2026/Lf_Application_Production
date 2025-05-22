// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widget/appbar/home_appbar.dart';
import '../../common/widget/bottom_sheets/profilebottom.dart';
import '../../common/widget/button/singlebtn.dart';
import '../../common/widget/lists/dummy_account.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/other/customercare.dart';
import '../../common/widget/other/deleteaccount.dart';
import '../../common/widget/other/notification_setting.dart';
import '../../common/widget/other/saved_address.dart';
import '../../common/widget/other/settingwidget.dart';
import '../../common/widget/other/supportwidget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constant/constants.dart';
import '../cart/cartscreen.dart';
import '../order/orderexchangescreen.dart';
import '../wishlist/wishlistscreen.dart';
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
  final productController = Get.put(ProductController());
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
            HomeAppbar(
              showSearch: false,
              title: "Profile",
              onPressedHeart: () async {
                Get.to(const WishlistScreen())?.then(
                  (value) {
                    SystemChrome.setSystemUIOverlayStyle(
                        const SystemUiOverlayStyle(
                            statusBarColor: whiteColor,
                            systemNavigationBarColor: whiteColor));
                  },
                );
                await analytics.logEvent(
                  name: 'wishlist_page',
                  parameters: <String, Object>{
                    'page_name': 'wishlist_page',
                  },
                );
              },
              onPressedCart: () async {
                Get.to(const CartScreen())?.then(
                  (value) {
                    SystemChrome.setSystemUIOverlayStyle(
                        const SystemUiOverlayStyle(
                            statusBarColor: whiteColor,
                            systemNavigationBarColor: whiteColor));
                  },
                );
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
                                              Obx(() {
                                                final name =
                                                    controller.profileDetails[
                                                            "name"] ??
                                                        "";
                                                return AppText(
                                                  text: name,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: blackColor,
                                                  fontSize: 28,
                                                );
                                              }),
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
                                                      child: Obx(() {
                                                        final phone = controller
                                                                    .profileDetails[
                                                                "phone"] ??
                                                            "";
                                                        return AppText(
                                                          text: phone,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: greyTextColor,
                                                          fontSize: 14,
                                                        );
                                                      }),
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
                                    Get.to(WishlistScreen())?.then(
                                      (value) {
                                        SystemChrome.setSystemUIOverlayStyle(
                                            const SystemUiOverlayStyle(
                                                statusBarColor: whiteColor,
                                                systemNavigationBarColor:
                                                    whiteColor));
                                      },
                                    );
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
                                      onTap: () async {
                                        Get.to(CustomerCareScreen());
                                        await analytics.logEvent(
                                          name: 'customer_care',
                                          parameters: <String, Object>{
                                            'page_name': 'customer_care',
                                          },
                                        );
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
                                        ))?.then(
                                          (value) {
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                                    const SystemUiOverlayStyle(
                                              statusBarColor: whiteColor,
                                            ));
                                            productController
                                                .getDefaultAddressData(
                                                    0, context);
                                          },
                                        );
                                        await analytics.logEvent(
                                          name: 'saveaddress_page',
                                          parameters: <String, Object>{
                                            'page_name': 'saveaddress_page',
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
                                    SettingWidgets(
                                      onPressedDelete: () async {
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
                                                    SystemChrome
                                                        .setSystemUIOverlayStyle(
                                                            const SystemUiOverlayStyle(
                                                      statusBarColor:
                                                          whiteColor,
                                                    ));
                                                  },
                                                ));
                                        await analytics.logEvent(
                                          name: 'delete_account_screen',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'delete_account_screen',
                                          },
                                        );
                                      },
                                      onPressedNotification: () async {
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
                                              statusBarIconBrightness:
                                                  Brightness.dark,
                                              statusBarBrightness:
                                                  Brightness.light,
                                            ));
                                          },
                                        );
                                        await analytics.logEvent(
                                          name: 'notification_screen',
                                          parameters: <String, Object>{
                                            'page_name': 'notification_screen',
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SupportWidgets(
                                  visibilty: false,
                                  onPressedAboutUs: () async {
                                    launchUrl(Uri.parse(
                                        "https://la-fetch.com/about-us/"));
                                    await analytics.logEvent(
                                      name: 'about_us',
                                      parameters: <String, Object>{
                                        'page_name': 'about_us',
                                      },
                                    );
                                  },
                                  onPressedTC: () async {
                                    launchUrl(Uri.parse(
                                        "https://la-fetch.com/terms-and-conditions/"));
                                    await analytics.logEvent(
                                      name: 'teams_condition',
                                      parameters: <String, Object>{
                                        'page_name': 'teams_condition',
                                      },
                                    );
                                  },
                                  onPressedPrivacy: () async {
                                    launchUrl(Uri.parse(
                                        "https://la-fetch.com/privacy-policy/"));
                                    await analytics.logEvent(
                                      name: 'privacy_policy',
                                      parameters: <String, Object>{
                                        'page_name': 'privacy_policy',
                                      },
                                    );
                                  },
                                  onPressedCancelation: () async {
                                    launchUrl(Uri.parse(
                                        "https://www.la-fetch.com/cancellation-policy/"));
                                    await analytics.logEvent(
                                      name: 'cancellation_policy',
                                      parameters: <String, Object>{
                                        'page_name': 'cancellation_policy',
                                      },
                                    );
                                  },
                                  onPressedShiping: () async {
                                    launchUrl(Uri.parse(
                                        "https://www.la-fetch.com/shipping-policy/"));
                                    await analytics.logEvent(
                                      name: 'shiping_policy',
                                      parameters: <String, Object>{
                                        'page_name': 'shiping_policy',
                                      },
                                    );
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
