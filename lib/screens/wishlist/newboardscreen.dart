// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import 'package:lafetch/screens/wishlist/createboardscreen.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/singlebtn.dart';
import '../../utils/constants.dart';

class NewBoardScreen extends StatefulWidget {
  const NewBoardScreen({super.key});

  @override
  State<NewBoardScreen> createState() => NewBoardScreenState();
}

class NewBoardScreenState extends State<NewBoardScreen> {
  final boardNameController = TextEditingController();

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
                  const BackButtonAppbar(
                    text: "New Board",
                    threeDot: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: TextFieldWidget(
                      hint: "Name of the Board",
                      controller: boardNameController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleButton(
                label: "Next",
                textColor: whiteBorderColor,
                backgroundColor: btnTextColor,
                onPressed: () {
                  Get.to(
                    () => const CreateBoardScreen(),
                  );
                },
                borderColor: btnTextColor),
          )
        ],
      ),
    );
  }
}
