// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/common_widgets.dart';
import '../controller/profile_controller.dart';
import '../utils/constants.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  final userController = Get.put(ProfileController());

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
        backgroundColor: whiteTextColor,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 70, left: 16, right: 16),
                      child: AppText(
                        text: "Let’s get to know you\na bit more",
                        fontFamily: "Franklin Gothic",
                        maxLines: 2,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontSize: 28.sp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: TextFieldWidget(
                        hint: "First Name and Last Name",
                        controller: userController.nameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFieldWidget(
                        hint: "Email Address",
                        controller: userController.emailController,
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
                            if (userController.showList.value) {
                              userController.showList.value = false;
                            } else {
                              userController.showList.value = true;
                            }
                          },
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: userController.gerderController,
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
                      () => userController.showList.value
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
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
                                          color: whiteTextColor,
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10),
                                                    child: Text(
                                                      userController
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
                    label: "Continue",
                    textColor: greyTextColor,
                    controller: userController,
                    backgroundColor: colorSecondary,
                    onPressed: () {
                      if (userController.checkUservalidation(
                          userController.nameController.text.toString().trim(),
                          userController.emailController.text.toString().trim(),
                          userController.genderId.value)) {
                        userController.callupdateProfile("user");
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
