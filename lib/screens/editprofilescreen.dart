// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/commonwidget/loginwidgets/number_widget.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import 'package:lafetch/controller/profile_controller.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final profileController = Get.put(ProfileController());
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
                          controller: profileController.phoneController),
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
                                                  profileController
                                                      .showList.value = false;
                                                },
                                                child: Container(
                                                  width: double.infinity,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SingleButton(
                  label: "Save Changes",
                  textColor: whiteBorderColor,
                  backgroundColor: colorPrimary,
                  onPressed: () {},
                  borderColor: colorPrimary),
            )
          ],
        ),
      ),
    );
  }
}
