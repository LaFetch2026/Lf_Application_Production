// ignore_for_file: avoid_print, deprecated_member_use

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../common/widget/appbar/login_appbar.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/other/login_widget.dart';
import '../common/widget/other/text_field.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/login_controller.dart';
import '../controllers/profile_controller.dart';
import '../core/constant/constants.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  final userController = Get.put(ProfileController());
  final loginController = Get.put(LoginController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userController.nameError.value = "";
      userController.phoneError.value = "";
      userController.emailError.value = "";
      userController.genderError.value = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          userController.showList.value = false;
        });
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            LoginAppbar(
              controller: loginController,
              isSkip: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Padding(
                      padding: EdgeInsets.only(
                          top: 70.sp, left: 16.sp, right: 16.sp),
                      child: AppText(
                        text: "Let’s get to know you\na bit more",
                        fontFamily: "Franklin Gothic",
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontSize: 28,
                      ),
                    ), */
                    SizedBox(
                      height: 40.sp,
                    ),
                    const LoginWidget(
                        text1: "ONE LAST STEP!",
                        fontfamily: "Franklin Gothic",
                        text2: "Let’s get to know you a bit more"),
                    Padding(
                      padding: EdgeInsets.only(top: 40.sp),
                      child: TextFieldWidget(
                        hint: "First Name and Last Name",
                        controller: userController.nameController,
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: userController.nameError.value != ""
                              ? true
                              : false,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20.sp,
                              right: 20.sp,
                              top: 2.sp,
                            ),
                            child: AppText(
                              text: userController.nameError.value,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: redColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 24.sp),
                      child: TextFieldWidget(
                        hint: "Email Address",
                        controller: userController.emailController,
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: userController.emailError.value != ""
                              ? true
                              : false,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20.sp,
                              right: 20.sp,
                              top: 2.sp,
                            ),
                            child: AppText(
                              text: userController.emailError.value,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: redColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16.sp, top: 24.sp, right: 16.sp),
                      child: SizedBox(
                        height: 44.sp,
                        child: TextField(
                          textCapitalization: TextCapitalization.words,
                          readOnly: true,
                          onTap: () {
                            if (userController.showList.value) {
                              userController.showList.value = false;
                            } else {
                              userController.showList.value = true;
                            }
                          },
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: userController.gerderController,
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
                                  color: homeAppBarColor,
                                ),
                              ),
                            ),
                            fillColor: whiteColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: productSubtitleColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide:
                                  const BorderSide(color: productSubtitleColor),
                            ),
                            counterText: "",
                            hintText: "Gender",
                            hintStyle: TextStyle(
                                fontSize: 14.sp, color: searchTextColor),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Visibility(
                          visible: userController.genderError.value != ""
                              ? true
                              : false,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20.sp,
                              right: 20.sp,
                              top: 2.sp,
                            ),
                            child: AppText(
                              text: userController.genderError.value,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: redColor,
                              fontSize: 12,
                            ),
                          ),
                        )),
                    Obx(
                      () => userController.showList.value
                          ? Padding(
                              padding:
                                  EdgeInsets.only(left: 16.sp, right: 16.sp),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: userController.genderList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          color: whiteColor,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  userController
                                                          .gerderController
                                                          .text =
                                                      userController
                                                          .genderList[index];
                                                  if (userController
                                                          .gerderController.text
                                                          .toString() ==
                                                      "Female") {
                                                    userController
                                                        .genderId.value = 1;
                                                  } else if (userController
                                                          .gerderController.text
                                                          .toString() ==
                                                      "Male") {
                                                    userController
                                                        .genderId.value = 2;
                                                  } else {
                                                    userController
                                                        .genderId.value = 3;
                                                  }
                                                  userController
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
                                                      userController
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 2),
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: getSingleButton(
                    label: "Continue".toUpperCase(),
                    textColor: greyTextColor,
                    controller: userController,
                    backgroundColor: colorSecondary,
                    onPressed: () async {
                      if (userController.checkUservalidation(
                          userController.nameController.text.toString().trim(),
                          userController.emailController.text.toString().trim(),
                          userController.genderId.value)) {
                        userController.callupdateProfile("user", "", "", false);
                        await analytics.logEvent(
                          name: 'user_detail_btnContinue',
                          parameters: <String, Object>{
                            'page_name': 'user_detail_btnContinue',
                          },
                        );
                      }
                    },
                    borderColor: colorSecondary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
