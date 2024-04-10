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
import '../../commonwidget/common_widgets.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';

class BoardScreen extends StatefulWidget {
  final String boardName;
  final int boardId;
  const BoardScreen({
    super.key,
    required this.boardName,
    required this.boardId,
  });

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final wishlistController = Get.put(WishlistController());

  @override
  void initState() {
    wishlistController.wishListProduct.clear();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => wishlistController.getWishlistDetails(widget.boardId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          BackButtonAppbar(
            text: "Board",
            threeDot: true,
            icon: threeDotImage,
            onPressedThreeDot: () {
              scaffoldKey.currentState?.showBottomSheet((context) =>
                  BottomSheetBoard(
                    onPressedEdit: () {
                      Get.to(CreateBoardScreen(
                        btnText: "",
                        wishlistId: widget.boardId,
                      ));
                    },
                    onPressedAddItem: () {
                      Get.back();
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CreateBoardScreen(
                                    btnText: "Add",
                                    wishlistId: widget.boardId,
                                  )))
                          .then((value) => setState(
                                () {
                                  wishlistController.wishListProduct.clear();
                                  wishlistController
                                      .getWishlistDetails(widget.boardId);
                                },
                              ));
                    },
                    onPressedDelete: () {
                      showDialog(
                        barrierColor: Colors.black26,
                        context: context,
                        builder: (context) {
                          return showDoubleBtnDailog(
                              click1: () {
                                Get.back();
                              },
                              click2: () {
                                wishlistController
                                    .callDeleteWishlist(widget.boardId);
                              },
                              btncolor: colorPrimary,
                              text: "Are you sure you want to delete board?",
                              btn1Text: "No",
                              btn2Text: "Yes");
                        },
                      );
                    },
                    onPressedRename: () {
                      Get.back();
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (BuildContext context) => NewBoardScreen(
                                    title: "Edit Board Name",
                                    hintName: "",
                                    boardId: widget.boardId,
                                    boardName: widget.boardName,
                                    btnText: "Save changes",
                                  )))
                          .then((value) => setState(
                                () {
                                  wishlistController.wishListProduct.clear();
                                  wishlistController
                                      .getWishlistDetails(widget.boardId);
                                },
                              ));
                    },
                  ));
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 10),
                      child: AppText(
                        text: widget.boardName,
                        color: blackColor,
                        fontSize: 25.sp,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 10),
                              child: AppText(
                                text:
                                    "${wishlistController.wishListProduct.length} items",
                                color: textHintColor,
                                fontSize: 12.sp,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            wishlistController.isDetails.value
                                ? const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : wishlistController.wishListProduct.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: GetBuilder<WishlistController>(
                                          builder: (value) => GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 2,
                                            scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.zero,
                                            childAspectRatio: 0.5,
                                            physics: const ScrollPhysics(),
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 0,
                                            children: List.generate(
                                              value.wishListProduct.length,
                                              (index) {
                                                return GestureDetector(
                                                  onTap: () {},
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Center(
                                                            child: Image.asset(
                                                                backImage,
                                                                height: 190,
                                                                width: 152,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: InkWell(
                                                                child: SizedBox(
                                                                  height: 24,
                                                                  width: 24,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        whiteColor,
                                                                    child: Image
                                                                        .asset(
                                                                      whiteCrossCircleImage,
                                                                      height:
                                                                          24,
                                                                      width: 24,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomLeft,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            140),
                                                                color: const Color(
                                                                    0xB3F7F7F5),
                                                                height: 26,
                                                                width: 80,
                                                                child: Row(
                                                                  children: [
                                                                    Image.asset(
                                                                      starImage,
                                                                      height:
                                                                          24,
                                                                      color:
                                                                          bottomnavBack,
                                                                      width: 24,
                                                                    ),
                                                                    AppText(
                                                                      text: value.wishListProduct[index]["aggregated_rating"] !=
                                                                              null
                                                                          ? value
                                                                              .wishListProduct[index]["aggregated_rating"]
                                                                              .toString()
                                                                          : "",
                                                                      color:
                                                                          colorPrimary,
                                                                      fontSize:
                                                                          12.sp,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            textHintColor,
                                                                        height:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    AppText(
                                                                      text: "8",
                                                                      color:
                                                                          colorPrimary,
                                                                      fontSize:
                                                                          12.sp,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        child: AppText(
                                                          text:
                                                              value.wishListProduct[
                                                                          index]
                                                                      [
                                                                      "name"] ??
                                                                  "",
                                                          color: nameText,
                                                          maxLines: 1,
                                                          fontSize: 12.sp,
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: AppText(
                                                          text: value.wishListProduct[
                                                                      index][
                                                                  "short_description"] ??
                                                              "",
                                                          color: nameText,
                                                          maxLines: 1,
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 10,
                                                                left: 10,
                                                                right: 10),
                                                        child: Row(
                                                          children: [
                                                            AppText(
                                                              text:
                                                                  "\u{20B9} ${value.wishListProduct[index]["price"] ?? ""}",
                                                              color:
                                                                  deepGreytextColor,
                                                              maxLines: 2,
                                                              fontSize: 11.sp,
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                              child: Text(
                                                                "\u{20B9} ${value.wishListProduct[index]["mrp"] ?? ""}",
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      textHintColor,
                                                                  fontSize:
                                                                      11.sp,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Center(
                                                          child: SmallButton(
                                                              label:
                                                                  "Move to bag",
                                                              textColor:
                                                                  btnTextColor,
                                                              backgroundColor:
                                                                  whiteTextColor,
                                                              borderColor:
                                                                  btnTextColor,
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
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 40),
                                        child: Center(
                                          child: Text("No Item Found",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      "Franklin Gothic Regular")),
                                        ),
                                      ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
