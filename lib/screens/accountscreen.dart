// ignore_for_file: avoid_print
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/accountwidgets/settingwidgit.dart';
import 'package:lafetch/screens/account/customercare.dart';
import 'package:lafetch/screens/account/deleteaccount.dart';
import 'package:lafetch/screens/account/saved_address.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/editprofilescreen.dart';
import 'package:lafetch/screens/orders/my_order.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/widget/appbar/home_appbar.dart';
import '../common/widget/bottom_sheets/profilebottom.dart';
import '../common/widget/button/singlebtn.dart';
import '../common/widget/lists/dummy_account.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/other/supportwidget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/home_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/profile_controller.dart';
import '../core/constant/constants.dart';
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
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  Future<void> _initProfile() async {
    final prefs = await SharedPreferences.getInstance();
    isGuest = prefs.getBool('isGuest') ?? prefs.getBool('skip') ?? false;

    if (!isGuest) {
      // Only fetch profile if logged in
      controller.getProfileData();
    } else {
      print("👤 Guest mode active — skipping profile fetch");
    }

    if (mounted) setState(() {});
  }

  // Debounce timer for scroll end
  Timer? _scrollEndTimer;

  // Handle scroll notifications for navbar transparency
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _scrollEndTimer?.cancel();
      homeController.isScrolling.value = true;
    } else if (notification is ScrollEndNotification) {
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
        homeController.isScrolling.value = false;
      });
    }
    return false;
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Get.offAll(() => const BottomNavScreen(index: 0));
        }
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
                        systemNavigationBarColor: whiteColor,
                      ),
                    );
                  },
                );
                await analytics.logEvent(
                  name: 'wishlist_page',
                  parameters: {'page_name': 'wishlist_page'},
                );
              },
              onPressedCart: () async {
                Get.to(CartScreen())?.then(
                  (value) {
                    SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                        statusBarColor: whiteColor,
                        systemNavigationBarColor: whiteColor,
                      ),
                    );
                  },
                );
                await analytics.logEvent(
                  name: 'cart_page',
                  parameters: {'page_name': 'cart_page'},
                );
              },
            ),
            Obx(() {
              if (isGuest) {
                // 👤 Guest UI
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/guest_user.png", // replace with your placeholder image
                            height: 120.sp,
                          ),
                          SizedBox(height: 20.sp),
                          const AppText(
                            text: "You're exploring as a guest!",
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w500,
                            color: blackColor,
                            fontSize: 16,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.sp),
                          const AppText(
                            text:
                                "Sign in or create an account to access your orders, addresses, and more.",
                            fontFamily: "Clash Display Regular",
                            fontWeight: FontWeight.w400,
                            color: greyTextColor,
                            fontSize: 13,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.sp),
                          getSingleButton(
                            label: "SIGN IN / REGISTER",
                            textColor: whiteColor,
                            borderColor: homeAppBarColor,
                            backgroundColor: homeAppBarColor,
                            onPressed: () {
                              Get.offAllNamed(
                                  '/login'); // or Get.offAll(() => LoginScreen(initialTab: 0));
                            },
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // 🔒 Logged-in user UI (your existing code)
              return controller.isProfile.value
                  ? const DummyAccount()
                  : controller.profileDetails.value != null
                      ? Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: _handleScrollNotification,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Obx(() {
                                        final profileData =
                                            controller.profileDetails.value ??
                                                {};
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.sp,
                                              bottom: 20.sp,
                                              right: 16.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text: profileData[
                                                              "fullName"] ??
                                                          "",
                                                      fontFamily:
                                                          "Clash Display Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: blackColor,
                                                      fontSize: 28,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5.sp),
                                                      child: Row(
                                                        children: [
                                                          ImageIcon(
                                                            const AssetImage(
                                                                phoneImage),
                                                            color:
                                                                greyTextColor,
                                                            size: 18.sp,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.sp),
                                                            child: AppText(
                                                              text: profileData[
                                                                      "phone"] ??
                                                                  "",
                                                              fontFamily:
                                                                  "Clash Display Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  greyTextColor,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Expanded(child: SizedBox()),
                                              GestureDetector(
                                                onTap: () async {
                                                  final profileData = controller
                                                          .profileDetails
                                                          .value ??
                                                      {};

                                                  Get.to(EditProfileScreen(
                                                    name: profileData[
                                                            'fullName'] ??
                                                        '',
                                                    email:
                                                        profileData['email'] ??
                                                            '',
                                                    number:
                                                        profileData['phone'] ??
                                                            '',
                                                    genderId: controller
                                                        .genderId.value,
                                                  ))?.then((value) {
                                                    SystemChrome
                                                        .setSystemUIOverlayStyle(
                                                      const SystemUiOverlayStyle(
                                                          statusBarColor:
                                                              whiteColor),
                                                    );
                                                    if (value ==
                                                        'phone_changed') {
                                                      // Phone was updated via verify-otp — profileDetails is
                                                      // already updated in memory. Just show success message.
                                                      // Do NOT call getProfileData() — the token may have been
                                                      // invalidated by the backend after a phone change.
                                                      showAppSnackBar(
                                                        "Phone number updated successfully!",
                                                        type: SnackBarType
                                                            .success,
                                                      );
                                                    } else {
                                                      controller
                                                          .getProfileData();
                                                    }
                                                  });
                                                  await analytics.logEvent(
                                                    name: 'edit_profile',
                                                    parameters: {
                                                      'page_name':
                                                          'edit_profile'
                                                    },
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 16.sp),
                                                  child: const AppText(
                                                    text: "Edit",
                                                    fontFamily: "Clash Display",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.sp, left: 16.sp, right: 16.sp),
                                    child: const AppText(
                                      text: "My Account",
                                      fontFamily: "Clash Display SemiBold",
                                      fontWeight: FontWeight.w700,
                                      color: nameText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      Get.to(const MyOrdersScreen());
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.sp,
                                          left: 16.sp,
                                          right: 16.sp),
                                      child: const AppText(
                                        text: "My Orders",
                                        fontFamily: "Clash Display Regular",
                                        fontWeight: FontWeight.w400,
                                        color: nameText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          Get.to(const CustomerCareScreen());
                                          await analytics.logEvent(
                                            name: 'customer_care',
                                            parameters: {
                                              'page_name': 'customer_care'
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 20.sp,
                                              left: 16.sp,
                                              right: 16.sp),
                                          child: const AppText(
                                            text: "Customer Care",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: nameText,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          Get.to(const SavedAddressScreen(
                                                  type: "address"))
                                              ?.then(
                                            (value) {
                                              SystemChrome
                                                  .setSystemUIOverlayStyle(
                                                const SystemUiOverlayStyle(
                                                    statusBarColor: whiteColor),
                                              );
                                            },
                                          );
                                          await analytics.logEvent(
                                            name: 'saveaddress_page',
                                            parameters: {
                                              'page_name': 'saveaddress_page'
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 20.sp,
                                              left: 16.sp,
                                              right: 16.sp),
                                          child: const AppText(
                                            text: "Saved Addresses",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: nameText,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      SettingWidgets(
                                        onPressedDelete: () async {
                                          final profileData =
                                              controller.profileDetails.value ??
                                                  {};

                                          final result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DeleteAccountScreen(
                                                date: profileData[
                                                        "account_deletion_requested_at"] ??
                                                    "",
                                                account_requested: profileData[
                                                            "account_deletion_requested_at"] !=
                                                        null &&
                                                    profileData[
                                                            "account_deletion_requested_at"]
                                                        .isNotEmpty,
                                              ),
                                            ),
                                          );

                                          await controller.getProfileData();
                                          SystemChrome.setSystemUIOverlayStyle(
                                            const SystemUiOverlayStyle(
                                                statusBarColor: whiteColor),
                                          );

                                          if (mounted) {
                                            setState(() {});
                                          }

                                          await analytics.logEvent(
                                            name: 'delete_account_screen',
                                            parameters: {
                                              'page_name':
                                                  'delete_account_screen'
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SupportWidgets(
                                    visibilty: false,
                                    onPressedAboutUs: () async {
                                      launchUrl(
                                        Uri.parse(
                                            "https://www.la-fetch.com/about"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                      await analytics.logEvent(
                                        name: 'about_us',
                                        parameters: {'page_name': 'about_us'},
                                      );
                                    },
                                    onPressedTC: () async {
                                      launchUrl(
                                        Uri.parse(
                                            "https://www.la-fetch.com/terms-and-conditions"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                      await analytics.logEvent(
                                        name: 'teams_condition',
                                        parameters: {
                                          'page_name': 'teams_condition'
                                        },
                                      );
                                    },
                                    onPressedPrivacy: () async {
                                      launchUrl(
                                        Uri.parse(
                                            "https://la-fetch.com/privacy-policy"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                      await analytics.logEvent(
                                        name: 'privacy_policy',
                                        parameters: {
                                          'page_name': 'privacy_policy'
                                        },
                                      );
                                    },
                                    onPressedCancelation: () async {
                                      launchUrl(
                                        Uri.parse(
                                            "https://www.la-fetch.com/cancellation-policy"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                      await analytics.logEvent(
                                        name: 'cancellation_policy',
                                        parameters: {
                                          'page_name': 'cancellation_policy'
                                        },
                                      );
                                    },
                                    onPressedShiping: () async {
                                      launchUrl(
                                        Uri.parse(
                                            "https://www.la-fetch.com/shipping-policy"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                      await analytics.logEvent(
                                        name: 'shiping_policy',
                                        parameters: {
                                          'page_name': 'shiping_policy'
                                        },
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 60.sp, bottom: 20.sp),
                                    child: SingleButton(
                                      label: "Logout",
                                      textColor: lightPurpleColor,
                                      backgroundColor: whiteColor,
                                      borderColor: lightPurpleColor,
                                      onPressed: () {
                                        showDialog(
                                          barrierColor: Colors.black26,
                                          context: context,
                                          builder: (context) {
                                            return showDoubleBtnDailog(
                                              text:
                                                  "Are you sure you want to logout?",
                                              btn1Text: "No",
                                              btn2Text: "Yes",
                                              btncolor: colorPrimary,
                                              click1: () => Get.back(),
                                              click2: () async {
                                                await controller.callLogout();
                                                await analytics.logEvent(
                                                  name: 'logout_btnclick',
                                                  parameters: {
                                                    'page_name':
                                                        'logout_btnclick'
                                                  },
                                                );
                                                Get.back();
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const ProfileBottom(version: "1.0.7"),
                                ],
                              ),
                            ),
                          ),
                        )
                      : DummyAccount();
            })
          ],
        ),
      ),
    );
  }
}
