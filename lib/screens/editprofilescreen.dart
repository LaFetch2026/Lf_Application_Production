// ignore_for_file: avoid_print
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../common/widget/appbar/backbutton_appbar.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/other/text_field.dart';
import '../common/widget/text/app_text.dart';
import '../common/widget/text/number_widget.dart';
import '../controllers/login_controller.dart';
import '../controllers/profile_controller.dart';
import '../core/constant/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String number;
  final int genderId;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.number,
    required this.genderId,
  });

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final profileController = Get.put(ProfileController());
  final otpController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    otpController.otp.value = "";

    // Add listener for auto-fill detection
    _pinController.addListener(() {
      final text = _pinController.text;
      if (text.isNotEmpty && text != otpController.otp.value) {
        otpController.otp.value = text;
      }
    });

    profileController.isEditNumber.value = true;
    profileController.isPhoneNumber.value = false;
    profileController.nameController.text = widget.name;
    profileController.emailController.text = widget.email;

    if (widget.number.isNotEmpty) {
      profileController.phoneController.text =
          widget.number.replaceAll("+91", "");
    } else {
      profileController.isEditNumber.value = false;
    }

    profileController.genderId.value = widget.genderId;
    if (widget.genderId == 1) {
      profileController.gerderController.text = "Male";
    } else if (widget.genderId == 2) {
      profileController.gerderController.text = "Female";
    } else if (widget.genderId == 3) {
      profileController.gerderController.text = "Non-Binary";
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: whiteTextColor,
        systemNavigationBarColor: whiteTextColor,
      ));
      profileController.nameError.value = "";
      profileController.phoneError.value = "";
      profileController.emailError.value = "";
      profileController.genderError.value = "";
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          profileController.showList.value = false;
        });
      },
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackButtonAppbar(
                      text: "Edit Profile",
                      threeDot: false,
                      icon: threeDotImage,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40.sp),
                      child: TextFieldWidget(
                        hint: "First Name and Last Name",
                        controller: profileController.nameController,
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: profileController.nameError.value.isNotEmpty,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.sp, vertical: 2.sp),
                            child: AppText(
                              text: profileController.nameError.value,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                              color: lightPurpleColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Obx(() => Padding(
                          padding: EdgeInsets.only(top: 10.sp),
                          child: NumberWidget(
                            login: false,
                            onPressedLogin: () {},
                            readonly: profileController.isEditNumber.value,
                            controller: profileController.phoneController,
                          ),
                        )),
                    Obx(() => Visibility(
                          visible:
                              profileController.phoneError.value.isNotEmpty,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.sp, vertical: 2.sp),
                            child: AppText(
                              text: profileController.phoneError.value,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                              color: lightPurpleColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Obx(() => profileController.isEditNumber.value
                        ? Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () async {
                                  profileController.isEditNumber.value = false;
                                  profileController.phoneController.clear();
                                  _pinController.clear();
                                  otpController.otp.value = '';
                                  await analytics.logEvent(
                                    name: 'change_number_click',
                                    parameters: {
                                      'page_name': 'change_number_click'
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 5.sp),
                                  child: AppText(
                                    text: "Change number",
                                    fontFamily: "Clash Display",
                                    fontSize: 14,
                                    color: colorPrimary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox()),
                    Obx(() => profileController.isPhoneNumber.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.sp, vertical: 10.sp),
                                child: AppText(
                                  text: "Enter OTP",
                                  fontFamily: "Clash Display",
                                  fontSize: 14,
                                  color: colorPrimary,
                                ),
                              ),
                              Obx(
                                () {
                                  final defaultPinTheme = PinTheme(
                                    width: (MediaQuery.of(context).size.width -
                                            78) /
                                        4,
                                    height: 56.sp,
                                    textStyle: const TextStyle(
                                      color: loginText,
                                      fontSize: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  );

                                  final focusedPinTheme =
                                      defaultPinTheme.copyWith(
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  );

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.sp, vertical: 10.sp),
                                    child: Center(
                                      child: Pinput(
                                        controller: _pinController,
                                        length: 4,
                                        defaultPinTheme: defaultPinTheme,
                                        focusedPinTheme: focusedPinTheme,
                                        submittedPinTheme: defaultPinTheme,
                                        autofocus: false,
                                        separatorBuilder: (index) =>
                                            SizedBox(width: 4.sp),
                                        cursor: Container(
                                          width: 2,
                                          height: 24.sp,
                                          color: borderColor,
                                        ),
                                        onChanged: (code) {
                                          otpController.otp.value = code;
                                        },
                                        onCompleted: (pin) {
                                          otpController.otp.value = pin;
                                          if (otpController.otp.value.length ==
                                              4) {
                                            otpController.showButton.value =
                                                true;
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : const SizedBox()),
                    Padding(
                      padding: EdgeInsets.only(top: 10.sp),
                      child: TextFieldWidget(
                        hint: "Email ID",
                        controller: profileController.emailController,
                      ),
                    ),
                    Obx(() => Visibility(
                          visible:
                              profileController.emailError.value.isNotEmpty,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.sp, vertical: 2.sp),
                            child: AppText(
                              text: profileController.emailError.value,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                              color: lightPurpleColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: SizedBox(
                        height: 44.sp,
                        child: TextField(
                          readOnly: true,
                          onTap: () {
                            profileController.showList.value =
                                !profileController.showList.value;
                          },
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: "Clash Display Regular",
                          ),
                          controller: profileController.gerderController,
                          decoration: InputDecoration(
                            filled: true,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 20.sp),
                              child: SvgPicture.asset(
                                dropdownSvgImage,
                                height: 8.sp,
                                width: 10.sp,
                                color: homeAppBarColor,
                              ),
                            ),
                            fillColor: whiteColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1.sp),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                            hintText: "Gender",
                            hintStyle: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Visibility(
                          visible:
                              profileController.genderError.value.isNotEmpty,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.sp, vertical: 2.sp),
                            child: AppText(
                              text: profileController.genderError.value,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                              color: lightPurpleColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Obx(() => profileController.showList.value
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.sp),
                            child: ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: profileController.genderList.length,
                              itemBuilder: (ctx, index) {
                                return GestureDetector(
                                  onTap: () {
                                    profileController.gerderController.text =
                                        profileController.genderList[index];
                                    if (profileController
                                            .gerderController.text ==
                                        "Male") {
                                      profileController.genderId.value = 1;
                                    } else if (profileController
                                            .gerderController.text ==
                                        "Female") {
                                      profileController.genderId.value = 2;
                                    } else {
                                      profileController.genderId.value = 3;
                                    }
                                    profileController.showList.value = false;
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.sp),
                                    child: AppText(
                                      text: profileController.genderList[index],
                                      fontFamily: "Clash Display Regular",
                                      fontSize: 14.sp,
                                      color: nameText,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox()),
                  ],
                ),
              ),
            ),
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(vertical: 20.sp),
                child: getSingleButton(
                  label: "Save Changes",
                  textColor: whiteBorderColor,
                  backgroundColor: colorPrimary,
                  controller: profileController,
                  borderColor: colorPrimary,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    bool basicFieldsValid =
                        profileController.validateBasicProfileFields();

                    bool isPhoneBeingEdited =
                        profileController.isPhoneNumber.value;
                    String phoneNumber =
                        profileController.phoneController.text.trim();
                    String otpValue = otpController.otp.value;

                    bool phoneNeedsValidation = isPhoneBeingEdited;

                    if (basicFieldsValid) {
                      if (phoneNeedsValidation) {
                        bool phoneValid =
                            profileController.validatePhoneNumber(phoneNumber);
                        if (phoneValid) {
                          if (isPhoneBeingEdited) {
                            if (otpController.checkOtpValidation(otpValue)) {
                              await profileController.updatePhoneNumberWithOtp(
                                  phone: phoneNumber, otp: otpValue);
                            }
                          } else {
                            await profileController.updateBasicProfile(
                                isInitialSetup: false);
                          }
                        }
                      } else {
                        await profileController.updateBasicProfile(
                            isInitialSetup: false);
                      }

                      await analytics.logEvent(
                        name: 'editprofile_save_btnclick',
                        parameters: {
                          'page_name': 'editprofile_save_btnclick',
                        },
                      );

                      // ✅ Return to AccountScreen and refresh data
                      if (mounted) {
                        Get.back(result: true);
                      }
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
