// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/login_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final loginController = Get.put(LoginController());
  late VideoPlayerController videoController;
  late Future<void> initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    
    videoController = VideoPlayerController.asset(videoOnboard)
      ..initialize().then((_) => setState(() {}))
      ..play()
      ..setLooping(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ));
    });
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          /// **Full-screen Background Video**
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: VideoPlayer(videoController),
              ),
            ),
          ),

          /// **Dark Gradient Overlay**
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.99)],
                  stops: [0.535, 0.8978],
                ),
              ),
            ),
          ),

          /// **Radial Gradient Overlay**
          Positioned.fill(
            child: Transform.scale(
              scaleY: 1.8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.53)],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          /// **App Logo**
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 80.sp),
              child: Image.asset(appNameImage, height: 41.sp, fit: BoxFit.cover),
            ),
          ),

          /// **Bottom Section (Title, Buttons, Skip)**
          Positioned(
            bottom: 40.sp,
            left: 16.sp,
            right: 16.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// **Title**
                AppText(
                  text: "Welcome to Lafetch!".toUpperCase(),
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w500,
                  color: whiteBack,
                  fontSize: 22,
                ),
                SizedBox(height: 8.sp),

                /// **Subtitle**
                AppText(
                  text: "Shape your closet with India's best curation of homegrown brands, designs and boutiques.",
                  fontFamily: "Franklin Gothic Regular",
                  maxLines: 2,
                  fontWeight: FontWeight.w400,
                  color: whiteTextColor,
                  fontSize: 14,
                ),
                SizedBox(height: 24.sp),

                /// **"I'M NEW HERE" Button**
                getSingleButton(
                  backgroundColor: statusBarColor,
                  borderColor: statusBarColor,
                  textColor: titleColor,
                  label: "I'M NEW HERE",
                  onPressed: () async {
                    videoController.pause();
                    Get.to(() => const LoginScreen(initialTab: 1))
                        ?.then((_) => videoController.play());
                    await analytics.logEvent(name: 'welcome_page_btnImNew');
                  },
                  fontSize: 13,
                ),
                SizedBox(height: 16.sp),

                /// **"SIGN IN" Button**
                getSingleButton(
                  backgroundColor: Colors.transparent,
                  borderColor: whiteColor,
                  textColor: whiteColor,
                  label: "SIGN IN",
                  onPressed: () async {
                    videoController.pause();
                    Get.to(() => const LoginScreen(initialTab: 0))
                        ?.then((_) => videoController.play());
                    await analytics.logEvent(name: 'welcome_page_btnsignin');
                  },
                  fontSize: 13,
                ),
                SizedBox(height: 24.sp),

                /// **Skip Button**
                Center(
                  child: InkWell(
                    onTap: () async {
                      loginController.callGuestUser();
                      await analytics.logEvent(name: 'welcome_page_btnSkip');
                    },
                    child: Obx(() => loginController.isGuest.value
                        ? SizedBox(
                            height: 24.sp,
                            width: 24.sp,
                            child: const CircularProgressIndicator(color: whiteColor),
                          )
                        : AppText(
                            text: "SKIP",
                            textAlign: TextAlign.center,
                            fontFamily: "Franklin Gothic Semibold",
                            fontWeight: FontWeight.w600,
                            color: searchTextColor,
                            fontSize: 12,
                          )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

