// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';

class NewBoardScreen extends StatefulWidget {
  final String title;
  final String boardName;
  final String hintName;
  final int boardId;
  final String btnText;
  const NewBoardScreen(
      {required this.title,
      required this.boardName,
      required this.hintName,
      required this.boardId,
      required this.btnText,
      super.key});

  @override
  State<NewBoardScreen> createState() => NewBoardScreenState();
}

class NewBoardScreenState extends State<NewBoardScreen> {
  final wishlistController = Get.put(WishlistController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    print(widget.btnText);
    if (widget.boardName.isNotEmpty) {
      wishlistController.boardNameController.text = widget.boardName;
    } else {
      wishlistController.boardNameController.clear();
    }
    super.initState();
  }

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
                    icon: threeDotImage,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40.sp),
                    child: TextFieldWidget(
                      hint: widget.hintName,
                      controller: wishlistController.boardNameController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => Padding(
                padding: EdgeInsets.symmetric(vertical: 20.sp),
                child: getSingleButton(
                    label: widget.btnText,
                    textColor: whiteBorderColor,
                    backgroundColor: colorPrimary,
                    controller: wishlistController,
                    onPressed: () async {
                      if (widget.boardId == 0) {
                        if (wishlistController.checkIdNamevalidation(
                            wishlistController.boardNameController.text
                                .toString())) {
                          wishlistController.callCreateWishlist(
                            wishlistController.boardNameController.text
                                .toString(),
                          );
                          await analytics.logEvent(
                            name: 'create_board_btnClick',
                            parameters: <String, Object>{
                              'page_name': 'create_board_btnClick',
                            },
                          );
                        }
                      } else {
                        if (wishlistController.checkIdNamevalidation(
                            wishlistController.boardNameController.text
                                .toString())) {
                          wishlistController.callUpdateWishlist(
                              wishlistController.boardNameController.text
                                  .toString(),
                              widget.boardId);
                          await analytics.logEvent(
                            name: 'edit_board_btnClick',
                            parameters: <String, Object>{
                              'page_name': 'edit_board_btnClick',
                            },
                          );
                        }
                      }
                    },
                    borderColor: colorPrimary),
              ))
        ],
      ),
    );
  }
}
