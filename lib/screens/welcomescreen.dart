// ignore_for_file: avoid_print, deprecated_member_use

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controllers/SplashController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../common/widget/other/common_widget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/login_controller.dart';
import '../core/constant/constants.dart';
import 'bottomnavscreen.dart'; // ← navigate into the app
import 'loginscreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final loginController = Get.put(LoginController());

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideo;

  // Local guard to prevent accidental double taps on Skip
  final RxBool _skipBusy = false.obs;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset(videoOnboard);
    _initializeVideo = _videoController.initialize().then((_) {
      if (mounted) {
        _videoController
          ..setLooping(true)
          ..play();
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ));
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _openLogin({required int initialTab}) async {
    _videoController.pause();
    await Get.to(() => LoginScreen(initialTab: initialTab));
    if (mounted) _videoController.play();
  }

  Future<void> _handleSkip() async {
    if (_skipBusy.value) return;
    _skipBusy.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ Mark user as guest
      await prefs.setBool('skip', true);
      await prefs.setBool('isGuest', true);
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('token');

      print("🟢 Guest mode activated — navigating to home...");

      // 🧩 Hard stop SplashController
      SplashController.abortSplashFlow = true;

      // ✅ Navigate to home
      Get.offAll(() => const BottomNavScreen());
    } catch (e) {
      print("❌ Skip error: $e");
      getSnackBar("Something went wrong, please try again.");
    } finally {
      _skipBusy.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          // Background video
          Positioned.fill(
            child: FutureBuilder(
              future: _initializeVideo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: media.size.width,
                      height: media.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Bottom gradient overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: media.size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.95)],
                  stops: const [0.0, 0.60],
                ),
              ),
            ),
          ),

          // Logo
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 80.sp),
              child: Image.asset(
                appNameImage,
                height: 41.sp,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.only(left: 16.sp),
                  child: AppText(
                    text: "Welcome to Lafetch!".toUpperCase(),
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w500,
                    color: whiteBack,
                    fontSize: 22,
                  ),
                ),

                // Subtitle
                Padding(
                  padding:
                      EdgeInsets.only(top: 8.sp, left: 16.sp, right: 16.sp),
                  child: AppText(
                    text:
                        "Shape your closet with india's best curation of homegrown brands, designs and boutiques",
                    fontFamily: "Franklin Gothic Regular",
                    maxLines: 3,
                    fontWeight: FontWeight.w400,
                    color: whiteTextColor,
                    fontSize: 14,
                  ),
                ),

                // I'M NEW HERE
                Padding(
                  padding: EdgeInsets.only(top: 24.sp),
                  child: getSingleButton(
                    backgroundColor: statusBarColor,
                    borderColor: statusBarColor,
                    textColor: titleColor,
                    label: "I'M NEW HERE",
                    onPressed: () async {
                      await analytics.logEvent(
                        name: 'welcome_page_btnImNew',
                        parameters: <String, Object>{
                          'page_name': 'welcome_page_btnImNew',
                        },
                      );
                      await _openLogin(initialTab: 1);
                    },
                    fontSize: 13,
                  ),
                ),

                // SIGN IN
                Padding(
                  padding: EdgeInsets.only(top: 24.sp),
                  child: getSingleButton(
                    backgroundColor: Colors.transparent,
                    borderColor: whiteColor,
                    textColor: whiteColor,
                    label: "SIGN IN",
                    onPressed: () async {
                      await analytics.logEvent(
                        name: 'welcome_page_btnsignin',
                        parameters: <String, Object>{
                          'page_name': 'welcome_page_btnsignin',
                        },
                      );
                      await _openLogin(initialTab: 0);
                    },
                    fontSize: 13,
                  ),
                ),

                // SKIP
                Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleSkip,
                      child: Obx(() => _skipBusy.value
                          ? Center(
                              child: Transform.scale(
                                scale: 0.3.sp,
                                child: const CircularProgressIndicator(
                                    color: whiteColor),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: 24.sp,
                                  left: 12.sp,
                                  right: 12.sp,
                                  bottom: 40.sp),
                              child: Center(
                                child: AppText(
                                  text: "SKIP",
                                  textAlign: TextAlign.center,
                                  fontFamily: "Franklin Gothic Semibold",
                                  fontWeight: FontWeight.w600,
                                  color: searchTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            )),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
