// ignore_for_file: avoid_print
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

import 'package:telephony/telephony.dart';

import '../../common/widget/appbar/backbutton_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/other/text_field.dart';
import '../../common/widget/text/app_text.dart';
import '../../common/widget/text/number_widget.dart';
import '../../controllers/login_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constant/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String number;

  final int genderId;
  const EditProfileScreen(
      {super.key,
        required this.name,
        required this.email,
        required this.number,
        required this.genderId});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  Telephony telephony = Telephony.instance;
  final profileController = Get.put(ProfileController());
  final otpController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    otpController.otp.value = "";
    if (Platform.isAndroid) {
      callReceiveMsg();
    }
    profileController.isEditNumber.value = true;
    profileController.isPhoneNumber.value = false;
    profileController.nameController.text = widget.name;
    profileController.emailController.text = widget.email;
    /* profileController.phoneController.text =
        widget.number.replaceAll("+91", ""); */
    if (widget.number != "") {
      profileController.phoneController.text =
          widget.number.replaceAll("+91", "");
    } else {
      profileController.isEditNumber.value = false;
    }
    profileController.genderId.value = widget.genderId;
    if (widget.genderId == 1) {
      profileController.gerderController.text = "Female";
    } else if (widget.genderId == 2) {
      profileController.gerderController.text = "Male";
    } else if (widget.genderId == 3) {
      profileController.gerderController.text = "Non-Binary";
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: whiteTextColor,
        systemNavigationBarColor: whiteTextColor,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      profileController.nameError.value = "";
      profileController.phoneError.value = "";
      profileController.emailError.value = "";
      profileController.genderError.value = "";
    });
    super.initState();
  }

  callReceiveMsg() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address);
        print(message.body);

        String sms = message.body.toString();

        if (message.body!.contains('La Fetch')) {
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
          String string = '$otpcode';
          print(string.split(''));
          otpController.otp.value = otpcode;
          print("abc $otpcode");
          otpController.controller.value.set(otpcode.split(""));
          setState(() {});
        } else {
          print("error");
        }
      },
      listenInBackground: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
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
                      visible: profileController.nameError.value != ""
                          ? true
                          : false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.sp,
                          right: 20.sp,
                          top: 2.sp,
                        ),
                        child: AppText(
                          text: profileController.nameError.value,
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: redColor,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    Obx(
                          () => Padding(
                        padding: EdgeInsets.only(top: 10.sp),
                        child: NumberWidget(
                            login: false,
                            onPressedLogin: () {},
                            readonly: profileController.isEditNumber.value,
                            controller: profileController.phoneController),
                      ),
                    ),
                    Obx(() => Visibility(
                      visible: profileController.phoneError.value != ""
                          ? true
                          : false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.sp,
                          right: 20.sp,
                          top: 2.sp,
                        ),
                        child: AppText(
                          text: profileController.phoneError.value,
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: redColor,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    Obx(() => profileController.isEditNumber.value
                        ? Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            profileController.isEditNumber.value = false;
                            profileController.phoneController.clear();
                            await analytics.logEvent(
                              name: 'change_number_click',
                              parameters: <String, Object>{
                                'page_name': 'change_number_click',
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 5.sp),
                            child: AppText(
                              text: "Change number",
                              fontFamily: "Franklin Gothic",
                              fontSize: 14,
                              textAlign: TextAlign.right,
                              color: colorPrimary,
                            ),
                          ),
                        ),
                      ],
                    )
                        : const SizedBox(
                      height: 0,
                    )),
                    Obx(
                          () => profileController.isPhoneNumber.value
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 10.sp),
                            child: AppText(
                              text: "Enter OTP",
                              fontFamily: "Franklin Gothic",
                              fontSize: 14,
                              color: colorPrimary,
                            ),
                          ),
                          /*     Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 10, bottom: 10),
                                  child: Center(
                                    child: OtpTextField(
                                      borderRadius: BorderRadius.circular(1),
                                      numberOfFields: 4,
                                      clearText: otpController.otpClear.value,
                                      fieldWidth:
                                          (MediaQuery.of(context).size.width -
                                                  65) /
                                              4,
                                      textStyle: const TextStyle(
                                          color: loginText,
                                          fontSize: 16,
                                          height: 2.5),
                                      focusedBorderColor: borderColor,
                                      borderWidth: 1,
                                      enabledBorderColor: borderColor,
                                      showFieldAsBox: true,
                                      onCodeChanged: (String code) {
                                        otpController.otpClear.value = false;
                                        otpController.otp.value = code;
                                      },
                                      onSubmit: (String verificationCode) {
                                        otpController.otpClear.value = false;
                                        otpController.otp.value =
                                            verificationCode;
                                        if (otpController.otp.value.length ==
                                            4) {
                                          otpController.showButton.value = true;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              */
                          Obx(
                                () => Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  right: 16.sp,
                                  top: 10.sp,
                                  bottom: 10.sp),
                              child: Center(
                                child: OTPTextFieldV2(
                                    controller:
                                    otpController.controller.value,
                                    length: 4,
                                    autoFocus: false,
                                    width:
                                    MediaQuery.of(context).size.width,
                                    textFieldAlignment:
                                    MainAxisAlignment.spaceAround,
                                    fieldWidth: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        78) /
                                        4,
                                    spaceBetween: 4.sp,
                                    fieldStyle: FieldStyle.box,
                                    outlineBorderRadius: 1,
                                    otpFieldStyle: OtpFieldStyle(
                                        focusBorderColor: borderColor,
                                        enabledBorderColor: borderColor),
                                    style: const TextStyle(
                                      color: loginText,
                                      fontSize: 16,
                                    ),
                                    onChanged: (code) {
                                      otpController.otp.value = code;
                                      print("Changed: " + code);
                                    },
                                    cursorColor: borderColor,
                                    onCompleted: (pin) {
                                      otpController.otp.value = pin;
                                      if (otpController
                                          .otp.value.length ==
                                          4) {
                                        otpController.showButton.value =
                                        true;
                                      }
                                    }),
                              ),
                            ),
                          ),
                        ],
                      )
                          : const SizedBox(
                        height: 0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.sp),
                      child: TextFieldWidget(
                        hint: "Email ID",
                        controller: profileController.emailController,
                      ),
                    ),
                    Obx(() => Visibility(
                      visible: profileController.emailError.value != ""
                          ? true
                          : false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.sp,
                          right: 20.sp,
                          top: 2.sp,
                        ),
                        child: AppText(
                          text: profileController.emailError.value,
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: redColor,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16.sp, top: 20.sp, right: 16.sp),
                      child: SizedBox(
                        height: 44.sp,
                        child: TextField(
                          textCapitalization: TextCapitalization.words,
                          readOnly: true,
                          onTap: () {
                            if (profileController.showList.value) {
                              profileController.showList.value = false;
                            } else {
                              profileController.showList.value = true;
                            }
                          },
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: profileController.gerderController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 2,
                              minHeight: 2,
                            ),
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 20.sp),
                              child: SizedBox(
                                height: 8.sp,
                                width: 10.sp,
                                child: SvgPicture.asset(
                                  dropdownSvgImage,
                                  height: 8.sp,
                                  width: 10.sp,
                                  // ignore: deprecated_member_use
                                  color: homeAppBarColor,
                                ),
                              ),
                            ),
                            fillColor: whiteColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1.sp),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1.sp),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            counterText: "",
                            hintText: "Gender",
                            hintStyle: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Visibility(
                      visible: profileController.genderError.value != ""
                          ? true
                          : false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.sp,
                          right: 20.sp,
                          top: 2.sp,
                        ),
                        child: AppText(
                          text: profileController.genderError.value,
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: redColor,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    Obx(
                          () => profileController.showList.value
                          ? Padding(
                        padding:
                        EdgeInsets.only(left: 16.sp, right: 16.sp),
                        child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount:
                            profileController.genderList.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (ctx, index) {
                              return Column(
                                children: [
                                  Container(
                                    color: whiteTextColor,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            profileController
                                                .gerderController
                                                .text =
                                            profileController
                                                .genderList[index];
                                            if (profileController
                                                .gerderController.text
                                                .toString() ==
                                                "Female") {
                                              profileController
                                                  .genderId.value = 1;
                                            } else if (profileController
                                                .gerderController.text
                                                .toString() ==
                                                "Male") {
                                              profileController
                                                  .genderId.value = 2;
                                            } else {
                                              profileController
                                                  .genderId.value = 3;
                                            }
                                            profileController
                                                .showList.value = false;
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            color: whiteTextColor,
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  vertical: 10.sp),
                                              child: Text(
                                                profileController
                                                    .genderList[index],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: nameText,
                                                  fontFamily:
                                                  "Franklin Gothic Regular",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        index == 2
                                            ? SizedBox(
                                          width: double.infinity,
                                          height: 5.sp,
                                        )
                                            : Padding(
                                          padding:
                                          EdgeInsets.symmetric(
                                              horizontal: 16.sp,
                                              vertical: 2.sp),
                                          child: Container(
                                            width: double.infinity,
                                            color: colorSecondary,
                                            height: 1.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                      )
                          : const SizedBox(
                        height: 0,
                      ),
                    ),
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
                    onPressed: () async {
                      if (profileController.checkvalidation(
                          profileController.nameController.text
                              .toString()
                              .trim(),
                          profileController.phoneController.text
                              .toString()
                              .trim(),
                          profileController.emailController.text
                              .toString()
                              .trim(),
                          profileController.genderId.value)) {
                        FocusScope.of(context).unfocus();
                        if (profileController.isPhoneNumber.value) {
                          if (otpController
                              .checkOtpvalidation(otpController.otp.value)) {
                            profileController.callupdateProfile(
                                "edit",
                                "+91${profileController.phoneController.text.toString().trim()}",
                                otpController.otp.value,
                                profileController.isEditNumber.value);
                          }
                        } else {
                          profileController.callupdateProfile(
                              "edit",
                              "+91${profileController.phoneController.text.toString().trim()}",
                              otpController.otp.value,
                              profileController.isEditNumber.value);
                        }
                      }
                      await analytics.logEvent(
                        name: 'editprofile_save_btnclick',
                        parameters: <String, Object>{
                          'page_name': 'editprofile_save_btnclick',
                        },
                      );
                    },
                    borderColor: colorPrimary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
