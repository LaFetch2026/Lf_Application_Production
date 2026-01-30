// ignore_for_file: avoid_print, deprecated_member_use

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../common/widget/other/common_widget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/login_controller.dart';
import '../core/constant/constants.dart';
import 'bottomnavscreen.dart';
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

  /// ✅ SKIP HANDLER
  Future<void> _handleSkip() async {
    if (_skipBusy.value) return;

    _skipBusy.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('skip', true);

      await analytics.logEvent(
        name: 'welcome_page_skip',
        parameters: {
          'page_name': 'welcome_page_skip',
          'user_type': 'guest',
        },
      );

      Get.offAll(() => const BottomNavScreen(index: 0));
    } catch (e) {
      print("❌ Error during skip: $e");
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
          /// 🔹 BACKGROUND VIDEO
          Positioned.fill(
            child: FutureBuilder(
              future: _initializeVideo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return FittedBox(
                    fit: BoxFit.fill,
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

          /// 🔹 GRADIENT OVERLAY
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

          /// 🔹 TOP LOGO
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 80.sp),
              child: Image.asset(
                appNameImage,
                height: 41.sp,
              ),
            ),
          ),

          /// 🔹 TOP RIGHT SKIP
          Positioned(
            top: media.padding.top,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _handleSkip,
                child: Obx(
                  () => _skipBusy.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: whiteColor,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: AppText(
                            text: "SKIP",
                            fontFamily: "Clash Display Semibold",
                            fontWeight: FontWeight.w600,
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ),
          ),

          /// 🔹 CONTENT
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.sp),
                  child: AppText(
                    text: "WELCOME TO LAFETCH!",
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w500,
                    color: whiteBack,
                    fontSize: 22,
                  ),
                ),

                Padding(
                  padding:
                      EdgeInsets.only(top: 8.sp, left: 16.sp, right: 16.sp),
                  child: AppText(
                    text:
                        "Shape your closet with india's best curation of homegrown brands, designs and boutiques",
                    fontFamily: "Clash Display Regular",
                    maxLines: 3,
                    fontWeight: FontWeight.w400,
                    color: whiteTextColor,
                    fontSize: 14,
                  ),
                ),

                /// SIGN IN
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
                        parameters: {'page_name': 'welcome_page_btnsignin'},
                      );
                      await _openLogin(initialTab: 0);
                    },
                    fontSize: 13,
                  ),
                ),

                /// I'M NEW HERE
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
                        parameters: {'page_name': 'welcome_page_btnImNew'},
                      );
                      await _openLogin(initialTab: 1);
                    },
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 40.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
