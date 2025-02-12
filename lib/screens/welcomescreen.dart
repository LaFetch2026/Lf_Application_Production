// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
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
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final loginController = Get.put(LoginController());
  late VideoPlayerController videoController;
  late Future<void> initializeVideoPlayerFuture;

  @override
  void initState() {
    videoController = VideoPlayerController.asset(
      video,
    );
    initializeVideoPlayerFuture = videoController.initialize();
    videoController.play();
    videoController.setLooping(true);
    super.initState();
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
      body: SingleChildScrollView(
        child: Container(
            child: Stack(
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: Container(
                width: MediaQuery.of(context).size.width.sp,
                height: MediaQuery.of(context).size.height.sp,
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width.sp,
              height: MediaQuery.of(context).size.height.sp,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                  stops: [0.535, 0.8978],
                ),
              ),
            ),
            Transform.scale(
              scaleY: 1.8,
              child: Container(
                width: MediaQuery.of(context).size.width.sp,
                height: MediaQuery.of(context).size.height.sp,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      Color(0x00000000),
                      Color(0XCC000000),
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width.sp,
              height: MediaQuery.of(context).size.height.sp,
              color: Colors.white.withOpacity(0),
            ),
            Center(
                child: Padding(
              padding: EdgeInsets.only(top: 80.sp),
              child:
                  Image.asset(appNameImage, height: 41.sp, fit: BoxFit.cover),
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 510.sp, left: 16.sp),
                  child: AppText(
                    text: "Welcome to Lafetch!".toUpperCase(),
                    fontFamily: "Franklin Gothic",
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
                    fontFamily: "Franklin Gothic Regular",
                    maxLines: 3,
                    fontWeight: FontWeight.w400,
                    color: whiteTextColor,
                    fontSize: 14,
                  ),
                ),
                /*    Padding(
                  padding: EdgeInsets.only(top: 30.sp),
                  child: DoubleButton(
                    firstText: "Create Account",
                    secondText: "Sign In",
                    firstTextColor: whiteTextColor,
                    secondTextColor: btnTextColor,
                    firstBackgroundColor: blackColor,
                    secondBackgroundColor: whiteBorderColor,
                    firstBorderColor: whiteBorderColor,
                    secondBorderColor: whiteBorderColor,
                    onPressedFirst: () async {
                      Get.to(
                        () => const LoginScreen(
                          initialTab: 1,
                        ),
                      );
                      await analytics.logEvent(
                        name: 'welcome_page_btncreateaccount',
                        parameters: <String, Object>{
                          'page_name': 'welcome_page_btncreateaccount',
                        },
                      );
                    },
                    onPressedSecond: () async {
                      Get.to(
                        () => const LoginScreen(
                          initialTab: 0,
                        ),
                      );
                      await analytics.logEvent(
                        name: 'welcome_page_btnsignin',
                        parameters: <String, Object>{
                          'page_name': 'welcome_page_btnsignin',
                        },
                      );
                    },
                  ),
                ),
               */
                Padding(
                  padding: EdgeInsets.only(top: 24.sp),
                  child: getSingleButton(
                      backgroundColor: statusBarColor,
                      borderColor: statusBarColor,
                      textColor: titleColor,
                      label: "I'M NEW HERE",
                      onPressed: () async {
                        videoController.pause();
                        Get.to(
                          () => const LoginScreen(
                            initialTab: 1,
                          ),
                        )?.then(
                          (value) {
                            videoController.play();
                          },
                        );
                        await analytics.logEvent(
                          name: 'welcome_page_btnsignin',
                          parameters: <String, Object>{
                            'page_name': 'welcome_page_btnsignin',
                          },
                        );
                      },
                      fontSize: 13),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24.sp),
                  child: getSingleButton(
                      backgroundColor: Colors.transparent,
                      borderColor: whiteColor,
                      textColor: whiteColor,
                      label: "SIGN IN",
                      onPressed: () async {
                        videoController.pause();
                        Get.to(
                          () => const LoginScreen(
                            initialTab: 0,
                          ),
                        )?.then(
                          (value) {
                            videoController.play();
                          },
                        );
                        await analytics.logEvent(
                          name: 'welcome_page_btncreateaccount',
                          parameters: <String, Object>{
                            'page_name': 'welcome_page_btncreateaccount',
                          },
                        );
                      },
                      fontSize: 13),
                ),
                InkWell(
                  onTap: () {
                    loginController.callGuestUser();
                  },
                  child: Obx(() => loginController.isGuest.value
                      ? Center(
                          child: Transform.scale(
                            scale: 0.3.sp,
                            child: const CircularProgressIndicator(
                              color: whiteColor,
                            ),
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
                              text: "SKIP".toUpperCase(),
                              textAlign: TextAlign.center,
                              fontFamily: "Franklin Gothic Semibold",
                              fontWeight: FontWeight.w600,
                              color: searchTextColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
