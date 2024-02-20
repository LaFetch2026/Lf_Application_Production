// ignore_for_file: avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/commonwidget/loginwidgets/number_widget.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
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
                  const BackButtonAppbar(text: "Edit Profile", threeDot: false),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: TextFieldWidget(
                      hint: "First Name and Last Name",
                      controller: nameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: NumberWidget(controller: phoneController),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFieldWidget(
                      hint: "Email ID",
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
                        fillColor: whiteTextColor,
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
                                    color: textColor,
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
                        icon: ImageIcon(AssetImage(dropdownImage)),
                        iconSize: 30,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          color: whiteTextColor,
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
                label: "Save Changes",
                textColor: whiteBorderColor,
                backgroundColor: btnTextColor,
                onPressed: () {},
                borderColor: btnTextColor),
          )
        ],
      ),
    );
  }
}
