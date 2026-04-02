// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/SplashController.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/widget/appbar/login_appbar.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/other/login_widget.dart';
import '../common/widget/other/or_widget.dart';
import '../common/widget/text/app_text.dart';
import '../common/widget/text/multiple_text.dart';
import '../common/widget/text/number_widget.dart';
import '../controllers/login_controller.dart';
import '../core/constant/constants.dart';

class LoginScreen extends StatefulWidget {
  final int initialTab;
  final bool hideBack;

  const LoginScreen({
    required this.initialTab,
    this.hideBack = false,
    super.key,
  });

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ✅ Use the globally bound controller (set up in main.dart initialBinding)
  final LoginController loginController = Get.find<LoginController>();

  Color appbarColor = colorPrimary;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String _authStatus = 'Unknown';

  // ✅ TabController for smooth swipe transitions
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize TabController
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    // ✅ Listen to tab changes (both tap and swipe)
    _tabController.addListener(_onTabChanged);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      systemNavigationBarColor: statusBarColor,
    ));

    if (widget.initialTab == 0) {
      appbarColor = colorPrimary;
      loginController.loginError.value = "";
    } else {
      appbarColor = btnTextColor;
      loginController.registerError.value = "";
    }

    requestNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging)
      return; // Wait for animation to complete
    setState(() {
      appbarColor = (_tabController.index == 0) ? colorPrimary : btnTextColor;
      loginController.loginError.value = "";
      loginController.registerError.value = "";
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (!mounted) return;
    setState(() => _authStatus = '$status');

    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      await Future.delayed(const Duration(milliseconds: 200));
      final TrackingStatus newStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      if (!mounted) return;
      setState(() => _authStatus = '$newStatus');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
    print("value: $_authStatus");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dear User'),
        content: const Text(
          'We care about your privacy and data security. We keep this app free by showing ads. '
          'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
          'Our partners will collect data and use a unique identifier on your device to show you ads.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            LoginAppbar(
              controller: loginController,
              hideBack: widget.hideBack,
              onPressedSkip: () async {
                try {
                  await analytics.logEvent(
                    name: 'login_skip',
                    parameters: {'page_name': 'login_skip'},
                  );

                  final prefs = await SharedPreferences.getInstance();

                  // ✅ Mark full guest mode (to prevent Splash nav)
                  await prefs.setBool('skip', true);
                  await prefs.setBool('isGuest', true);
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('token');

                  // ✅ Abort SplashController navigation if still running
                  if (Get.isRegistered<SplashController>()) {}

                  print("🟢 Guest mode (from LoginScreen) → BottomNavScreen");
                } catch (e) {
                  print("❌ Skip error: $e");
                }

                // ✅ Navigate & clear all previous routes
                Get.offAll(() => const BottomNavScreen());
              },
            ),

            // Tabs with smooth swipe indicator
            Container(
              color: whiteColor,
              child: PreferredSize(
                preferredSize: Size.fromHeight(40.sp),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TabBar(
                    controller: _tabController, // ✅ Use TabController
                    isScrollable: false,
                    indicatorColor: homeAppBarColor,
                    dividerColor: lightgreyColor,
                    unselectedLabelColor: searchTextColor,
                    labelColor: homeAppBarColor,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                        child: Text(
                          "Sign In".toUpperCase(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: "Clash Display Semibold",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "I'm new here".toUpperCase(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: "Clash Display Semibold",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ TabBarView with swipe support
            Expanded(
              child: TabBarView(
                controller: _tabController, // ✅ Use TabController
                children: [
                  buildLoginTab(),
                  buildRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.sp),
          const LoginWidget(
            text1: "Welcome Back!",
            fontfamily: "Clash Display",
            text2:
                "Great to see you again - let's dive back into your Shoping journey!",
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.sp),
            child: NumberWidget(
              readonly: false,
              fillColor: whiteColor,
              login: true,
              onPressedLogin: () async {
                FocusScope.of(context).unfocus();
                final phone = loginController.phoneNumberLogin.text.trim();
                if (loginController.checkNumberValidation(phone)) {
                  await loginController.callSendOtp(
                    phoneNumber: "+91$phone",
                    isLogin: true,
                  );
                  await analytics.logEvent(
                    name: 'signin_phonelogin',
                    parameters: {'page_name': 'signin_phonelogin'},
                  );
                }
              },
              controller: loginController.phoneNumberLogin,
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.only(left: 16.sp, right: 5.sp, bottom: 10.sp),
              child: AppText(
                text: loginController.loginError.value,
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: lightPurpleColor,
                fontSize: 12,
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.only(bottom: 16.sp),
              child: getSingleButton(
                label: "Continue".toUpperCase(),
                textColor: whiteTextColor,
                borderColor:
                    loginController.phoneNumberLogin.text.trim().length == 10
                        ? homeAppBarColor
                        : colorSecondary,
                controller: loginController,
                onPressed: () async {
                  final phone = loginController.phoneNumberLogin.text.trim();
                  if (phone.length == 10 &&
                      loginController.checkNumberValidation(phone)) {
                    await loginController.callSendOtp(
                      phoneNumber: "+91$phone",
                      isLogin: true,
                    );
                    await analytics.logEvent(
                      name: 'login_btnSignIn',
                      parameters: {'page_name': 'login_btnSignIn'},
                    );
                  }
                },
                fontSize: 14,
                backgroundColor:
                    loginController.phoneNumberLogin.text.trim().length == 10
                        ? homeAppBarColor
                        : colorSecondary,
              ),
            ),
          ),
          buildTermsWidget(),
          const ORWidget(),
          buildGoogleSignInButton(),
          if (Platform.isIOS) buildAppleSignInButton(),
        ],
      ),
    );
  }

  Widget buildRegisterTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.sp),
          const LoginWidget(
            fontfamily: "Clash Display Regular",
            text1: "Hey there,",
            text2:
                "Lets set you up around, for a tailored shopping experience!",
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.sp),
            child: NumberWidget(
              readonly: false,
              login: true,
              fillColor: whiteColor,
              onPressedLogin: () async {
                FocusScope.of(context).unfocus();
                final phone = loginController.phoneNumberRegister.text.trim();
                if (loginController.checkNumberValidation(phone)) {
                  await loginController.callSendOtp(
                    phoneNumber: "+91$phone",
                    isLogin: false,
                  );
                  await analytics.logEvent(
                    name: 'signup_phonelogin',
                    parameters: {'page_name': 'signup_phonelogin'},
                  );
                }
              },
              controller: loginController.phoneNumberRegister,
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.only(left: 16.sp, right: 5.sp),
              child: AppText(
                text: loginController.registerError.value,
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: lightPurpleColor,
                fontSize: 12,
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.only(bottom: 16.sp),
              child: getSingleButton(
                label: "Continue".toUpperCase(),
                textColor: whiteTextColor,
                borderColor:
                    loginController.phoneNumberRegister.text.trim().length == 10
                        ? homeAppBarColor
                        : colorSecondary,
                controller: loginController,
                onPressed: () async {
                  final phone = loginController.phoneNumberRegister.text.trim();
                  if (phone.length == 10 &&
                      loginController.checkNumberValidation(phone)) {
                    await loginController.callSendOtp(
                      phoneNumber: "+91$phone",
                      isLogin: false,
                    );
                    await analytics.logEvent(
                      name: 'login_btnRegister',
                      parameters: {'page_name': 'login_btnRegister'},
                    );
                  }
                },
                fontSize: 14,
                backgroundColor:
                    loginController.phoneNumberRegister.text.trim().length == 10
                        ? colorPrimary
                        : colorSecondary,
              ),
            ),
          ),
          buildTermsWidget(),
          const ORWidget(),
          buildGoogleSignInButton(),
        ],
      ),
    );
  }

  Widget buildGoogleSignInButton() {
    return Padding(
      padding: EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: Platform.isIOS ? 16.sp : 40.sp),
      child: SizedBox(
        width: double.infinity,
        height: 50.sp,
        child: ElevatedButton(
          onPressed: () async {
            await analytics.logEvent(
              name: 'login_google_signin',
              parameters: {'page_name': 'login_google_signin'},
            );
            await loginController.signInWithGoogle();
          },
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1.sp),
              ),
            ),
            side: WidgetStateProperty.all(
              BorderSide(width: 1.sp, color: homeAppBarColor),
            ),
            elevation: WidgetStateProperty.all(0.0),
            backgroundColor: WidgetStateProperty.all(whiteColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google.png',
                height: 20.sp,
                width: 20.sp,
              ),
              SizedBox(width: 10.sp),
              AppText(
                text: "CONTINUE WITH GOOGLE",
                fontFamily: "Clash Display Semibold",
                fontWeight: FontWeight.w600,
                color: homeAppBarColor,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppleSignInButton() {
    return Padding(
      padding: EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 40.sp),
      child: SizedBox(
        width: double.infinity,
        height: 50.sp,
        child: ElevatedButton(
          onPressed: () async {
            await analytics.logEvent(
              name: 'login_apple_signin',
              parameters: {'page_name': 'login_apple_signin'},
            );
            await loginController.signInWithApple();
          },
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1.sp),
              ),
            ),
            side: WidgetStateProperty.all(
              BorderSide(width: 1.sp, color: homeAppBarColor),
            ),
            elevation: WidgetStateProperty.all(0.0),
            backgroundColor: WidgetStateProperty.all(whiteColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple, color: homeAppBarColor, size: 22.sp),
              SizedBox(width: 10.sp),
              AppText(
                text: "CONTINUE WITH APPLE",
                fontFamily: "Clash Display Semibold",
                fontWeight: FontWeight.w600,
                color: homeAppBarColor,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTermsWidget() {
    return Padding(
      padding: EdgeInsets.only(bottom: 40.sp),
      child: MultipleTextWidget(
        fontSize: 10.sp,
        text1: "By continuing, I agree to the ",
        text2: "Terms of Use",
        text3: " and ",
        text4: "Privacy Policy",
        onPressedTerm: () => launchUrl(
          Uri.parse("https://la-fetch.com/terms-and-conditions/"),
        ),
        onPressedPolicy: () async {
          launchUrl(Uri.parse("https://la-fetch.com/privacy-policy/"));
          await analytics.logEvent(
            name: 'signin_privacypolicy',
            parameters: {'page_name': 'signin_privacypolicy'},
          );
        },
      ),
    );
  }
}
