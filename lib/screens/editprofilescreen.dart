// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import 'package:lafetch/controller/profile_controller.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/loginwidgets/number_widget.dart';
import '../controller/login_controller.dart';
import '../utils/constants.dart';

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
  final profileController = Get.put(ProfileController());
  final otpController = Get.put(LoginController());

  @override
  void initState() {
    profileController.nameController.text = widget.name;
    profileController.emailController.text = widget.email;
    /* profileController.phoneController.text =
        widget.number.replaceAll("+91", ""); */
    if (widget.number != "") {
      profileController.phoneController.text =
          widget.number.replaceAll("+91", "");
    }
    profileController.genderId.value = widget.genderId;
    if (widget.genderId == 1) {
      profileController.gerderController.text = "Female";
    } else if (widget.genderId == 2) {
      profileController.gerderController.text = "Male";
    } else if (widget.genderId == 3) {
      profileController.gerderController.text = "Non-Binary";
    }
    super.initState();
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
                      padding: const EdgeInsets.only(top: 40),
                      child: TextFieldWidget(
                        hint: "First Name and Last Name",
                        controller: profileController.nameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: NumberWidget(
                          readonly: false,
                          controller: profileController.phoneController),
                    ),
                    Obx(
                      () => profileController.isPhoneNumber.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: AppText(
                                    text: "Enter OTP",
                                    fontFamily: "Franklin Gothic",
                                    fontSize: 14.sp,
                                    color: colorPrimary,
                                  ),
                                ),
                                Padding(
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
                              ],
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFieldWidget(
                        hint: "Email ID",
                        controller: profileController.emailController,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 20, right: 16),
                      child: SizedBox(
                        height: 44,
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
                            suffixIcon: const ImageIcon(
                              AssetImage(dropdownImage),
                              color: nameText,
                              size: 30,
                            ),
                            fillColor: whiteTextColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            counterText: "",
                            hintText: "Gender",
                            hintStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => profileController.showList.value
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10),
                                                    child: Text(
                                                      profileController
                                                          .genderList[index],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: nameText,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              index == 2
                                                  ? const SizedBox(
                                                      width: double.infinity,
                                                      height: 5,
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16,
                                                          vertical: 2),
                                                      child: Container(
                                                        width: double.infinity,
                                                        color: colorSecondary,
                                                        height: 1,
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: getSingleButton(
                    label: "Save Changes",
                    textColor: whiteBorderColor,
                    backgroundColor: colorPrimary,
                    controller: profileController,
                    onPressed: () {
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
                        if (profileController.isAddress.value) {
                          getSnackBar("Enter OTP");
                        } else {
                          profileController.callupdateProfile(
                              "edit",
                              "+91${profileController.phoneController.text.toString().trim()}",
                              otpController.otp.value);
                        }
                      }
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
