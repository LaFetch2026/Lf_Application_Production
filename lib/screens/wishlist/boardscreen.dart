// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/smallbtn.dart';
import 'package:lafetch/commonwidget/wishlistwidgets/bottomsheetboard.dart';
import 'package:lafetch/screens/wishlist/createboardscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../utils/constants.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: scaffoldKey,
      backgroundColor: whiteTextColor,
      body: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Column(
          children: [
            BackButtonAppbar(
              text: "Board",
              threeDot: true,
              icon: threeDotImage,
              onPressedThreeDot: () {
                scaffoldKey.currentState
                    ?.showBottomSheet((context) => BottomSheetBoard(
                          onPressedEdit: () {
                            Get.to(CreateBoardScreen(
                              btnText: "",
                            ));
                          },
                          onPressedAddItem: () {
                            Get.back();
                            Get.to(CreateBoardScreen(
                              btnText: "Add 2 items",
                            ));
                          },
                          onPressedDelete: () {},
                          onPressedRename: () {
                            Get.back();
                            Get.to(const NewBoardScreen(
                              title: "Edit Board Name",
                              boardName: "Vintage Vibes",
                              btnText: "Save changes",
                            ));
                          },
                        ));
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 10),
                      child: AppText(
                        text: "Vintage Vibes",
                        color: blackColor,
                        fontSize: 25.sp,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                      ),
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
                            return GestureDetector(
                              onTap: () {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Center(
                                        child: Image.asset(backImage,
                                            height: 190,
                                            width: 152,
                                            fit: BoxFit.cover),
                                      ),
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
                                                  whiteCrossCircleImage,
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
                                            margin:
                                                const EdgeInsets.only(top: 140),
                                            color: const Color(0xB3F7F7F5),
                                            height: 26,
                                            width: 80,
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  starImage,
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
                                          child: Text(
                                            "\u{20B9} ${items[index]}",
                                            style: TextStyle(
                                              color: textHintColor,
                                              fontSize: 11.sp,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Center(
                                      child: SmallButton(
                                          label: "Move to bag",
                                          textColor: btnTextColor,
                                          backgroundColor: whiteTextColor,
                                          borderColor: btnTextColor,
                                          onPressed: () {},
                                          width: 152),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
