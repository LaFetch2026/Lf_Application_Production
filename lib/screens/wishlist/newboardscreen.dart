// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import 'package:lafetch/screens/wishlist/createboardscreen.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/singlebtn.dart';
import '../../utils/constants.dart';

class NewBoardScreen extends StatefulWidget {
  final String title;
  final String boardName;
  final String btnText;
  const NewBoardScreen(
      {required this.title,
      required this.boardName,
      required this.btnText,
      super.key});

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
                  BackButtonAppbar(
                    text: widget.title,
                    threeDot: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: TextFieldWidget(
                      hint: widget.boardName,
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
                label: widget.btnText,
                textColor: whiteBorderColor,
                backgroundColor: btnTextColor,
                onPressed: () {
                  Get.to(
                    () => const CreateBoardScreen(
                      btnText: "Create board",
                    ),
                  );
                },
                borderColor: btnTextColor),
          )
        ],
      ),
    );
  }
}
