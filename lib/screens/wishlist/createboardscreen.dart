// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/editboard_appbar.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/singlebtn.dart';
import '../../utils/constants.dart';

class CreateBoardScreen extends StatefulWidget {
  final String btnText;
  const CreateBoardScreen({required this.btnText, super.key});

  @override
  State<CreateBoardScreen> createState() => CreateBoardScreenState();
}

class CreateBoardScreenState extends State<CreateBoardScreen> {
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "400",
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
                  widget.btnText == ""
                      ? EditBoardAppbar(
                          text: "Edit Board",
                          onPressedDelete: () {},
                          onPressedShare: () {},
                        )
                      : const BackButtonAppbar(
                          text: "Add items to board",
                          threeDot: false,
                        ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 10),
                    child: AppText(
                      text: "2 items selected",
                      color: textHintColor,
                      fontSize: 12.sp,
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      childAspectRatio: 0.5,
                      physics: const ScrollPhysics(),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 0,
                      children: List.generate(
                        items.length,
                        (index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Image.asset(backImage,
                                            height: 190,
                                            width: 152,
                                            fit: BoxFit.cover),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircleAvatar(
                                                  backgroundColor: whiteColor,
                                                  child: Image.asset(
                                                    blackRightCircleImage,
                                                    height: 24,
                                                    width: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  top: 140),
                                              color: whiteBorderColor,
                                              height: 26,
                                              width: 80,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    heartImage,
                                                    height: 24,
                                                    color: bottomnavBack,
                                                    width: 24,
                                                  ),
                                                  AppText(
                                                    text: "4.4",
                                                    color: colorPrimary,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: Container(
                                                      width: 1,
                                                      color: textHintColor,
                                                      height: 16,
                                                    ),
                                                  ),
                                                  AppText(
                                                    text: "8",
                                                    color: colorPrimary,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: AppText(
                                        text: "Jack & Jones Core ",
                                        color: nameText,
                                        maxLines: 2,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: AppText(
                                        text:
                                            "Topman super skinny suit jacket and trousers in light blue",
                                        color: nameText,
                                        maxLines: 2,
                                        fontSize: 11.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: Row(
                                        children: [
                                          AppText(
                                            text: "\u{20B9} ${items[index]}",
                                            color: deepGreytextColor,
                                            maxLines: 2,
                                            fontSize: 11.sp,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w400,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: AppText(
                                              text: "\u{20B9} ${items[index]}",
                                              color: textHintColor,
                                              maxLines: 2,
                                              fontSize: 11.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.btnText == ""
              ? const SizedBox(
                  height: 0,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SingleButton(
                      label: widget.btnText,
                      textColor: whiteBorderColor,
                      backgroundColor: btnTextColor,
                      onPressed: () {
                        Get.close(2);
                      },
                      borderColor: btnTextColor),
                )
        ],
      ),
    );
  }
}
