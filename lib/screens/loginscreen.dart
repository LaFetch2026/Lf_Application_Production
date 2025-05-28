// ignore_for_file: avoid_print
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/widget/appbar/login_appbar.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/other/login_widget.dart';
import '../common/widget/text/app_text.dart';
import '../common/widget/text/multiple_text.dart';
import '../common/widget/text/number_widget.dart';
import '../controllers/login_controller.dart';
import '../core/constant/constants.dart';
import '../core/utils/analytics_helper.dart';

class LoginScreen extends StatefulWidget {
  final int initialTab;
  final bool hideBack;

  const LoginScreen(
      {required this.initialTab, this.hideBack = false, super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final loginController = Get.put(LoginController());
  Color appbarColor = colorPrimary;
  Map<String, dynamic>? fbData;
  AccessToken? accessToken;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String _authStatus = 'Unknown';

  @override
  void initState() {
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
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
    super.initState();
  }

  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
    print("value: $_authStatus");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
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

  requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      print("permission not granted");
      Permission.notification.request();
    }
  }

  facebooklogin(String type) async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      accessToken = result.accessToken;

      final userData = await FacebookAuth.instance.getUserData();
      fbData = userData;
      print(fbData);
      print("${fbData!["name"]}");
      print("${fbData!["email"]}");
      loginController.callSocailMediaLogin(
          fbData!["name"], fbData!["email"], "facebook", fbData!["id"]);
      await analytics.logEvent(
        name: '$type btnFacebook',
        parameters: <String, Object>{
          'page_name': '$type btnFacebook',
        },
      );
    } else {
      print(result.status);
      print(result.message);
    }
  }

  void googleSignInProcess(BuildContext context, String type) async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      String? token = googleAuth.idToken;
      print("name $googleUser");
      print("name ${googleUser.displayName}");
      print("email ${googleUser.email}");
      print("photoUrl ${googleUser.photoUrl}");
      print("id ${googleUser.id}");
      print("token $token");
      if (googleUser.displayName != null) {
        loginController.callSocailMediaLogin(
            googleUser.displayName!, googleUser.email, "google", googleUser.id);
        await analytics.logEvent(
          name: '$type btnGoogle',
          parameters: <String, Object>{
            'page_name': '$type btnGoogle',
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            /*   appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: appbarColor,
              title: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    loginController.callGuestUser();
                  },
                  child: Obx(() => loginController.isGuest.value
                      ? Transform.scale(
                          scale: 0.3.sp,
                          child: const CircularProgressIndicator(
                            color: whiteColor,
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.sp, horizontal: 12.sp),
                          child: AppText(
                            text: "Skip".toUpperCase(),
                            textAlign: TextAlign.right,
                            fontFamily: "Franklin Gothic bold",
                            fontWeight: FontWeight.w600,
                            color: searchTextColor,
                            fontSize: 12,
                          ),
                        )),
                ),
              ),
              bottom: PreferredSize(
                  preferredSize: Size.fromHeight(40.sp),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                        isScrollable: true,
                        onTap: (value) {
                          if (appbarColor == btnTextColor) {
                            appbarColor = colorPrimary;
                            loginController.loginError.value = "";
                          } else {
                            appbarColor = btnTextColor;
                            loginController.registerError.value = "";
                          }
                          setState(() {});
                        },
                        indicatorColor: whiteTextColor,
                        unselectedLabelColor: textHintColor,
                        labelColor: whiteBorderColor,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 2,
                        tabs: [
                          Tab(
                              child: Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400),
                          )),
                          Tab(
                              child: Text(
                            "I’m new here",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400),
                          ))
                        ]),
                  )),
            ),
           */
            backgroundColor: whiteColor,
            body: Column(
              children: [
                LoginAppbar(
                  controller: loginController,
                  hideBack: widget.hideBack,
                  onPressedSkip: () async {
                    AnalyticsHelper.logInitiateCheckout(
                      productId: 'guest_login', // or some meaningful identifier
                      value: 0.0, // or whatever value makes sense
                    );
                    loginController.callGuestUser();
                    await analytics.logEvent(
                      name: 'login_skip',
                      parameters: <String, Object>{
                        'page_name': 'login_skip',
                      },
                    );
                  },
                ),
                Container(
                  color: whiteColor,
                  child: PreferredSize(
                      preferredSize: Size.fromHeight(40.sp),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: TabBar(
                            onTap: (value) {
                              if (appbarColor == btnTextColor) {
                                appbarColor = colorPrimary;
                                loginController.loginError.value = "";
                              } else {
                                appbarColor = btnTextColor;
                                loginController.registerError.value = "";
                              }
                              setState(() {});
                            },
                            isScrollable: false,
                            physics: const NeverScrollableScrollPhysics(),
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
                                    fontFamily: "Franklin Gothic Semibold",
                                    fontWeight: FontWeight.w400),
                              )),
                              Tab(
                                  child: Text(
                                "I’m new here".toUpperCase(),
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontFamily: "Franklin Gothic Semibold",
                                    fontWeight: FontWeight.w400),
                              ))
                            ]),
                      )),
                ),
                Expanded(
                  child: TabBarView(children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: whiteColor,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16.sp,
                            ),
                            LoginWidget(
                                text1: "Welcome Back!",
                                fontfamily: "Franklin Gothic",
                                text2:
                                    "Great to see you again - let's dive back into your Shoping journey!"),
                            /*  Padding(
                              padding: EdgeInsets.only(top: 50.sp),
                              child: AppButton(
                                  label: "Continue with Facebook",
                                  fontFamily: "Franklin Gothic Regular",
                                  image: facebookImage,
                                  textColor: whiteColor,
                                  borderColor: blue,
                                  onPressed: () {
                                    facebooklogin("SignIn");
                                  },
                                  fontSize: 14.sp,
                                  backgroundColor: blue),
                            ), */
                            /*  Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.sp),
                              child: AppButton(
                                  label: "Continue with Gmail",
                                  fontFamily: "Franklin Gothic Regular",
                                  image: googleImage,
                                  textColor: greyTextColor,
                                  onPressed: () {
                                    //  signup(context);
                                    googleSignInProcess(context, "SignIn");
                                  },
                                  borderColor: colorSecondary,
                                  fontSize: 14.sp,
                                  backgroundColor: whiteTextColor),
                            ), */
                            // const ORWidget(),
                            /* Padding(
                          padding: EdgeInsets.only(top: 40.sp, left: 16.sp),
                          child: AppText(
                            text: "Let’s quickly verify it’s you",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: loginText,
                            fontSize: 14,
                          ),
                        ), */
                            Padding(
                              padding: EdgeInsets.only(top: 30.sp),
                              child: NumberWidget(
                                  readonly: false,
                                  fillColor: whiteColor,
                                  login: true,
                                  onPressedLogin: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    if (loginController.checkNumbervalidation(
                                        loginController.phoneNumberLogin.text
                                            .toString()
                                            .trim())) {
                                      loginController.number.value =
                                          "+91${loginController.phoneNumberLogin.text.toString().trim()}";
                                      loginController.callRegisterAccount();
                                      await analytics.logEvent(
                                        name: 'signin_phonelogin',
                                        parameters: <String, Object>{
                                          'page_name': 'signin_phonelogin',
                                        },
                                      );
                                    }
                                  },
                                  controller: loginController.phoneNumberLogin),
                            ),
                            Obx(() => Padding(
                                  padding: EdgeInsets.only(
                                      left: 16.sp, right: 5.sp, bottom: 10.sp),
                                  child: AppText(
                                    text: loginController.loginError.value,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: redColor,
                                    fontSize: 12,
                                  ),
                                )),
                            Obx(
                              () => Padding(
                                padding: EdgeInsets.only(bottom: 16.sp),
                                child: getSingleButton(
                                    label: "Continue".toUpperCase(),
                                    textColor: whiteTextColor,
                                    borderColor: loginController
                                                .phoneNumberLogin.text
                                                .toString()
                                                .trim()
                                                .length ==
                                            10
                                        ? homeAppBarColor
                                        : colorSecondary,
                                    controller: loginController,
                                    onPressed: () async {
                                      if (loginController.phoneNumberLogin.text
                                              .toString()
                                              .trim()
                                              .length ==
                                          10) {
                                        if (loginController
                                            .checkNumbervalidation(
                                                loginController
                                                    .phoneNumberLogin.text
                                                    .toString()
                                                    .trim())) {
                                          loginController.number.value =
                                              "+91${loginController.phoneNumberLogin.text.toString().trim()}";
                                          loginController.callRegisterAccount();
                                          await analytics.logEvent(
                                            name: 'login_btnRegister',
                                            parameters: <String, Object>{
                                              'page_name': 'login_btnRegister',
                                            },
                                          );
                                        }
                                      }
                                    },
                                    fontSize: 14,
                                    backgroundColor: loginController
                                                .phoneNumberLogin.text
                                                .toString()
                                                .trim()
                                                .length ==
                                            10
                                        ? homeAppBarColor
                                        : colorSecondary),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 40.sp),
                              child: MultipleTextWidget(
                                fontSize: 10.sp,
                                text1: "By continuing, I agree to the ",
                                text2: "Terms of Use",
                                text3: " and ",
                                text4: "Privacy Policy",
                                onPressedTerm: () {
                                  launchUrl(Uri.parse(
                                      "https://la-fetch.com/terms-and-conditions/"));
                                },
                                onPressedPolicy: () async {
                                  launchUrl(Uri.parse(
                                      "https://la-fetch.com/privacy-policy/"));
                                  await analytics.logEvent(
                                    name: 'signin_privacypolicy',
                                    parameters: <String, Object>{
                                      'page_name': 'signin_privacypolicy',
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: whiteColor,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16.sp,
                            ),
                            const LoginWidget(
                                fontfamily: "Franklin Gothic Regular",
                                text1: "Hey there,",
                                text2:
                                    "Lets set you up around, for a tailored shopping experience!"),
                            /*  Padding(
                              padding: EdgeInsets.only(top: 50.sp),
                              child: AppButton(
                                  label: "Continue with Facebook",
                                  image: facebookImage,
                                  fontFamily: "Franklin Gothic Regular",
                                  textColor: whiteColor,
                                  borderColor: blue,
                                  onPressed: () {
                                    facebooklogin("SignUp");
                                  },
                                  fontSize: 14.sp,
                                  backgroundColor: blue),
                            ), */
                            /* Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.sp),
                              child: AppButton(
                                  label: "Continue with Gmail",
                                  fontFamily: "Franklin Gothic Regular",
                                  image: googleImage,
                                  textColor: greyTextColor,
                                  borderColor: colorSecondary,
                                  fontSize: 14.sp,
                                  onPressed: () {
                                    googleSignInProcess(context, "SignUp");
                                  },
                                  backgroundColor: whiteTextColor),
                            ), */
                            // const ORWidget(),
                            /*  Padding(
                              padding: EdgeInsets.only(top: 40.sp, left: 16.sp),
                              child: AppText(
                                text: "Let’s quickly verify it’s you",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: loginText,
                                fontSize: 14,
                              ),
                            ), */
                            Padding(
                              padding: EdgeInsets.only(top: 30.sp),
                              child: NumberWidget(
                                  readonly: false,
                                  login: true,
                                  fillColor: whiteColor,
                                  onPressedLogin: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    if (loginController.checkRegistervalidation(
                                        loginController.phoneNumberRegister.text
                                            .toString()
                                            .trim())) {
                                      loginController.number.value =
                                          "+91${loginController.phoneNumberRegister.text.toString().trim()}";
                                      loginController.callRegisterAccount();
                                      await analytics.logEvent(
                                        name: 'signup_phonelogin',
                                        parameters: <String, Object>{
                                          'page_name': 'signup_phonelogin',
                                        },
                                      );
                                    }
                                  },
                                  controller:
                                      loginController.phoneNumberRegister),
                            ),
                            Obx(() => Padding(
                                  padding:
                                      EdgeInsets.only(left: 16.sp, right: 5.sp),
                                  child: AppText(
                                    text: loginController.registerError.value,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: redColor,
                                    fontSize: 12,
                                  ),
                                )),
                            Obx(() => Padding(
                                  padding: EdgeInsets.only(bottom: 16.sp),
                                  child: getSingleButton(
                                      label: "Continue".toUpperCase(),
                                      textColor: whiteTextColor,
                                      borderColor: loginController
                                                  .phoneNumberRegister.text
                                                  .toString()
                                                  .trim()
                                                  .length ==
                                              10
                                          ? homeAppBarColor
                                          : colorSecondary,
                                      controller: loginController,
                                      onPressed: () async {
                                        if (loginController
                                                .phoneNumberRegister.text
                                                .toString()
                                                .trim()
                                                .length ==
                                            10) {
                                          if (loginController
                                              .checkRegistervalidation(
                                                  loginController
                                                      .phoneNumberRegister.text
                                                      .toString()
                                                      .trim())) {
                                            loginController.number.value =
                                                "+91${loginController.phoneNumberRegister.text.toString().trim()}";
                                            loginController
                                                .callRegisterAccount();
                                            await analytics.logEvent(
                                              name: 'login_btnlogin',
                                              parameters: <String, Object>{
                                                'page_name': 'login_btnlogin',
                                              },
                                            );
                                          }
                                        }
                                      },
                                      fontSize: 14,
                                      backgroundColor: loginController
                                                  .phoneNumberRegister.text
                                                  .toString()
                                                  .trim()
                                                  .length ==
                                              10
                                          ? colorPrimary
                                          : colorSecondary),
                                )),
                            Padding(
                              padding: EdgeInsets.only(bottom: 40.sp),
                              child: MultipleTextWidget(
                                fontSize: 10.sp,
                                text1: "By continuing, I agree to the ",
                                text2: "Terms of Use",
                                text3: " and ",
                                text4: "Privacy Policy",
                                onPressedTerm: () {
                                  launchUrl(Uri.parse(
                                      "https://la-fetch.com/terms-and-conditions/"));
                                },
                                onPressedPolicy: () async {
                                  launchUrl(Uri.parse(
                                      "https://la-fetch.com/privacy-policy/"));
                                  await analytics.logEvent(
                                    name: 'signin_privacypolicy',
                                    parameters: <String, Object>{
                                      'page_name': 'signin_privacypolicy',
                                    },
                                  );
                                },
                              ),
                            )
                            /*  MultipleTextWidget(
                              text1: "By continuing, I agree to the",
                              text2: " Terms of Use",
                              text3: " and",
                              visible: false,
                              onPressedTerm: () {
                                launchUrl(Uri.parse(
                                    "https://la-fetch.com/terms-and-conditions/"));
                              },
                              text4: "",
                              fontSize: 11.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 40.sp),
                              child: GestureDetector(
                                onTap: () async {
                                  launchUrl(Uri.parse(
                                      "https://la-fetch.com/privacy-policy/"));
                                  await analytics.logEvent(
                                    name: 'signin_privacypolicy',
                                    parameters: <String, Object>{
                                      'page_name': 'signin_privacypolicy',
                                    },
                                  );
                                },
                                child: Center(
                                  child: Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w400,
                                      color: deepGreytextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                           */
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            )),
      ),
    );
  }
}
