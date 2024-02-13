// ignore_for_file: avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';

import '../commonwidget/app_text.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String? gender;
  List<int> genderId = [1, 2, 3];
  int genderPos = 0;
  final List<String> genderList = [
    'Male',
    'Female',
    'Non-Binary',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      controller: nameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFieldWidget(
                      hint: "Email Address",
                      controller: emailController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: DropdownButtonFormField2(
                      value: gender,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.only(left: 16),
                        hintText: 'Gender',
                        hintStyle: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Franklin Gothic Regular"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      isExpanded: true,
                      items: genderList
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: "Franklin Gothic Regular",
                                  ),
                                ),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select Types.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        gender = value;
                        genderPos = genderList.indexOf(gender.toString());
                        print(genderId[genderPos]);
                        setState(() {});
                      },
                      onSaved: (value) {},
                      buttonStyleData: const ButtonStyleData(
                        height: 60,
                        padding: EdgeInsets.only(right: 10),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down_sharp,
                          color: textColor,
                        ),
                        iconSize: 30,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleButton(
                label: "Continue",
                textColor: greyTextColor,
                backgroundColor: colorSecondary,
                onPressed: () {
                  Get.to(
                    () => const BottomNavScreen(),
                  );
                },
                borderColor: colorSecondary),
          )
        ],
      ),
    );
  }
}
