// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import 'package:lafetch/commonwidget/wishlistwidgets/bottomsheetboard.dart';
import 'package:lafetch/screens/wishlist/createboardscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/common_widgets.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';
import '../catalog/productlist/productdetailsscreen.dart';

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
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool isDrawer = false;

  @override
  void initState() {
    wishlistController.wishListProduct.clear();
    wishlistController.addList.clear();
    wishlistController.deleteidList.clear();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => wishlistController.getWishlistDetails(widget.boardId, 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isDrawer) {
            Get.back();
            isDrawer = false;
          }
        });
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isDrawer ? const Color(0xF2F7F7F5) : whiteColor,
        body: Column(
          children: [
            BackButtonAppbar(
              text: "Board",
              threeDot: true,
              icon: threeDotImage,
              backgroundColor: isDrawer ? const Color(0xF2F7F7F5) : whiteColor,
              onPressedThreeDot: () {
                if (isDrawer == false) {
                  isDrawer = true;
                  setState(() {});
                  scaffoldKey.currentState?.showBottomSheet((context) =>
                      BottomSheetBoard(
                        onPressedEdit: () async {
                          Get.back();
                          setState(() {
                            isDrawer = false;
                          });
                          Get.to(CreateBoardScreen(
                            btnText: "",
                            wishlistId: widget.boardId,
                            type: "edit",
                          ));
                          await analytics.logEvent(
                            name: 'board_edit_click',
                            parameters: <String, Object>{
                              'page_name': 'board_edit_click',
                            },
                          );
                        },
                        onPressedAddItem: () async {
                          setState(() {
                            isDrawer = false;
                          });
                          Get.back();
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CreateBoardScreen(
                                        btnText: "Add",
                                        type: "addmore",
                                        wishlistId: widget.boardId,
                                      )))
                              .then((value) => setState(
                                    () {
                                      wishlistController.wishListProduct
                                          .clear();
                                      wishlistController.addList.clear();
                                      wishlistController.deleteidList.clear();
                                      wishlistController.getWishlistDetails(
                                          widget.boardId, 1);
                                    },
                                  ));
                          await analytics.logEvent(
                            name: 'board_additem_click',
                            parameters: <String, Object>{
                              'page_name': 'board_additem_click',
                            },
                          );
                        },
                        onPressedDelete: () async {
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
                                  text:
                                      "Are you sure you want to delete board?",
                                  btn1Text: "No",
                                  btn2Text: "Yes");
                            },
                          );
                          await analytics.logEvent(
                            name: 'board_delete_click',
                            parameters: <String, Object>{
                              'page_name': 'board_delete_click',
                            },
                          );
                        },
                        onPressedRename: () async {
                          Get.back();
                          setState(() {
                            isDrawer = false;
                          });
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      NewBoardScreen(
                                        title: "Edit Board Name",
                                        hintName: "",
                                        boardId: widget.boardId,
                                        boardName: widget.boardName,
                                        btnText: "Save changes",
                                      )))
                              .then((value) => setState(
                                    () {
                                      wishlistController.wishListProduct
                                          .clear();
                                      wishlistController.addList.clear();
                                      wishlistController.deleteidList.clear();
                                      wishlistController.getWishlistDetails(
                                          widget.boardId, 1);
                                    },
                                  ));
                          await analytics.logEvent(
                            name: 'board_rename_click',
                            parameters: <String, Object>{
                              'page_name': 'board_rename_click',
                            },
                          );
                        },
                      ));
                }
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
                                text: wishlistController.wishListProduct.isEmpty
                                    ? ""
                                    : wishlistController
                                                .wishListProduct.length ==
                                            1
                                        ? "${wishlistController.wishListProduct.length} item"
                                        : "${wishlistController.wishListProduct.length} items",
                                color: textHintColor,
                                fontSize: 12.sp,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            wishlistController.isDetails.value
                                ? const DummyGridList()
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
                                                  onTap: () async {
                                                    if (isDrawer) {
                                                    } else {
                                                      Get.to(() =>
                                                          ProductDetailsScreen(
                                                              productId: value
                                                                      .wishListProduct[
                                                                  index]["id"],
                                                              type: "add"));
                                                    }
                                                    await analytics.logEvent(
                                                      name:
                                                          'board_product_details',
                                                      parameters: <String,
                                                          Object>{
                                                        'page_name':
                                                            'board_product_details',
                                                      },
                                                    );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Center(
                                                            child: wishlistController
                                                                        .wishListProduct[
                                                                            index]
                                                                            [
                                                                            "images"]
                                                                        .isNotEmpty &&
                                                                    wishlistController.wishListProduct[index]
                                                                            [
                                                                            "images"] !=
                                                                        null
                                                                ? SizedBox(
                                                                    height: 190,
                                                                    width: 152,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      cacheManager: CacheManager(Config(
                                                                          "customCacheKey",
                                                                          stalePeriod: const Duration(
                                                                              days:
                                                                                  15),
                                                                          maxNrOfCacheObjects:
                                                                              100)),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      imageUrl: isImage(wishlistController.wishListProduct[index]["images"][0]
                                                                              [
                                                                              "name"])
                                                                          ? wishlistController.wishListProduct[index]["images"][0]
                                                                              [
                                                                              "name"]
                                                                          : wishlistController.wishListProduct[index]["images"][1]
                                                                              [
                                                                              "name"],
                                                                      /*  progressIndicatorBuilder: (context,
                                                                              url,
                                                                              downloadProgress) =>
                                                                          Center(
                                                                        child: CircularProgressIndicator(
                                                                            value:
                                                                                downloadProgress.progress),
                                                                      ), */
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Image
                                                                              .asset(
                                                                        downloadImage,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            190,
                                                                        width:
                                                                            152,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Image.asset(
                                                                    dummyWishlistImage,
                                                                    height: 190,
                                                                    width: 152,
                                                                    fit: BoxFit
                                                                        .cover),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              if (isDrawer) {
                                                                Get.back();
                                                                isDrawer =
                                                                    false;
                                                                setState(() {});
                                                              }
                                                              showDialog(
                                                                barrierColor:
                                                                    Colors
                                                                        .black26,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return showDoubleBtnDailog(
                                                                      click1:
                                                                          () {
                                                                        Get.back();
                                                                      },
                                                                      click2:
                                                                          () {
                                                                        value.deleteId.removeWhere((item) =>
                                                                            item ==
                                                                            value.wishListProduct[index]["id"]);
                                                                        wishlistController
                                                                            .callDeleteSingleProduct(widget.boardId);
                                                                      },
                                                                      btncolor:
                                                                          colorPrimary,
                                                                      text:
                                                                          "Remove this from wishlist?",
                                                                      btn1Text:
                                                                          "No",
                                                                      btn2Text:
                                                                          "Yes");
                                                                },
                                                              );
                                                              await analytics
                                                                  .logEvent(
                                                                name:
                                                                    'remove_product_fromwishlistClick',
                                                                parameters: <String,
                                                                    Object>{
                                                                  'page_name':
                                                                      'remove_product_fromwishlistClick',
                                                                },
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 10),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: InkWell(
                                                                  child:
                                                                      SizedBox(
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
                                                                        width:
                                                                            24,
                                                                      ),
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
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              2),
                                                                      child: Image
                                                                          .asset(
                                                                        starImage,
                                                                        height:
                                                                            16,
                                                                        color:
                                                                            bottomnavBack,
                                                                        width:
                                                                            16,
                                                                      ),
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
                                                                      text: value
                                                                          .wishListProduct[
                                                                              index]
                                                                              [
                                                                              "reviews_count"]
                                                                          .toString(),
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
                                                                right: 1),
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
                                                                      left: 5),
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
                                                          child: getSmallButton(
                                                              label:
                                                                  "Move to bag",
                                                              textColor:
                                                                  btnTextColor,
                                                              backgroundColor:
                                                                  whiteColor,
                                                              borderColor:
                                                                  btnTextColor,
                                                              onPressed:
                                                                  () async {
                                                                if (isDrawer) {
                                                                } else {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(
                                                                          builder: (BuildContext context) => ProductDetailsScreen(
                                                                                productId: value.wishListProduct[index]["id"],
                                                                                type: "move",
                                                                                boardId: widget.boardId,
                                                                                wishlistProductId: value.wishListProduct[index]["id"],
                                                                              )))
                                                                      .then((value) => setState(
                                                                            () {
                                                                              //  wishlistController.getWishlistDetails(widget.boardId, 1);
                                                                            },
                                                                          ));
                                                                }
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'board_product_movetobagClick',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'board_product_movetobagClick',
                                                                  },
                                                                );
                                                              },
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
          ],
        ),
      ),
    );
  }
}
