// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/editboard_appbar.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_list.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/common_widgets.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';
import '../catalog/productlist/productdetailsscreen.dart';

class CreateBoardScreen extends StatefulWidget {
  final String btnText;
  final int wishlistId;
  final String type;
  const CreateBoardScreen(
      {required this.btnText,
      required this.wishlistId,
      required this.type,
      super.key});

  @override
  State<CreateBoardScreen> createState() => CreateBoardScreenState();
}

class CreateBoardScreenState extends State<CreateBoardScreen> {
  final wishlistController = Get.put(WishlistController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  @override
  void initState() {
    wishlistController.addItem.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      wishlistController.productListController.addListener(() {
        wishlistController.fetchProductMoreData("relevant");
        wishlistController.update();
      });
    });
    wishlistController.pHasnextpage.value = true;
    wishlistController.pLoadMore.value = false;
    wishlistController.isDetails.value = false;
    wishlistController.productPage.value = 1;
    widget.btnText == ""
        ? WidgetsBinding.instance.addPostFrameCallback(
            (_) => wishlistController.getWishlistDetails(widget.wishlistId, 2))
        : WidgetsBinding.instance.addPostFrameCallback(
            (_) => wishlistController.getProductData("relevant"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          widget.btnText == ""
              ? EditBoardAppbar(
                  text: "Edit Board",
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
                              if (wishlistController.addItem.value != 0) {
                                wishlistController.callDeleteProductWishlist(
                                    widget.wishlistId);
                              } else {
                                Get.back();
                                getSnackBar("Select product");
                              }
                            },
                            btncolor: colorPrimary,
                            text: "Are you sure you want to Delete it?",
                            btn1Text: "No",
                            btn2Text: "Yes");
                      },
                    );
                    await analytics.logEvent(
                      name: 'delete_board_iconclick',
                      parameters: <String, Object>{
                        'page_name': 'delete_board_iconclick',
                      },
                    );
                  },
                  onPressedShare: () async {
                    await analytics.logEvent(
                      name: 'share_board_iconclick',
                      parameters: <String, Object>{
                        'page_name': 'share_board_iconclick',
                      },
                    );
                  },
                )
              : const BackButtonAppbar(
                  text: "Add items to board",
                  threeDot: false,
                  icon: threeDotImage,
                ),
          Obx(() => wishlistController.isDetails.value
              ? const Expanded(child: DummyGridList())
              : wishlistController.wishListProduct.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(
                        controller: wishlistController.productListController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 10),
                              child: AppText(
                                text: wishlistController.addItem.value == 0 ||
                                        wishlistController.addItem.value == 1
                                    ? "${wishlistController.addItem.value} item selected"
                                    : "${wishlistController.addItem.value} items selected",
                                color: textHintColor,
                                fontSize: 12.sp,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 10),
                                child: GetBuilder<WishlistController>(
                                  builder: (value) => GridView.count(
                                    shrinkWrap: true,
                                    primary: false,
                                    crossAxisCount: 2,
                                    controller: wishlistController
                                        .productListController,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    childAspectRatio: 0.6,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 9,
                                    children: List.generate(
                                      value.wishListProduct.length,
                                      (index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Get.to(ProductDetailsScreen(
                                                    productId:
                                                        value.wishListProduct[
                                                            index]["id"],
                                                    type: "add"));
                                                await analytics.logEvent(
                                                  name: 'board_product_details',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'board_product_details',
                                                  },
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Center(
                                                        child: value
                                                                    .wishListProduct[
                                                                        index][
                                                                        "images"]
                                                                    .isNotEmpty &&
                                                                value.wishListProduct[
                                                                            index]
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
                                                                  imageUrl: isImage(value.wishListProduct[index]["images"]
                                                                              [0]
                                                                          [
                                                                          "name"])
                                                                      ? value.wishListProduct[index]
                                                                              ["images"][0]
                                                                          [
                                                                          "name"]
                                                                      : value.wishListProduct[index]
                                                                              ["images"][1]
                                                                          ["name"],
                                                                  /*  progressIndicatorBuilder:
                                                                      (context,
                                                                              url,
                                                                              downloadProgress) =>
                                                                          Center(
                                                                    child: CircularProgressIndicator(
                                                                        value: downloadProgress
                                                                            .progress),
                                                                  ), */
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    downloadImage,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: 190,
                                                                    width: 152,
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
                                                      value.selected[index]
                                                          ? GestureDetector(
                                                              onTap: () async {
                                                                value.selected[
                                                                        index] =
                                                                    false;
                                                                if (value.selected[
                                                                        index] ==
                                                                    false) {
                                                                  value
                                                                      .deleteidList
                                                                      .add(value
                                                                              .wishListProduct[index]
                                                                          [
                                                                          "id"]);
                                                                  value.addList.removeWhere((item) =>
                                                                      item ==
                                                                      value.wishListProduct[
                                                                              index]
                                                                          [
                                                                          "id"]);
                                                                }
                                                                print(
                                                                    "delete${value.deleteidList}");
                                                                print(
                                                                    "add${value.addList}");
                                                                value.addItem
                                                                    .value--;
                                                                print(value
                                                                    .addItem
                                                                    .value);
                                                                /*  value.productId
                                                                    .value = 0; */
                                                                value.update();
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'board_product_selected',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'board_product_selected',
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      InkWell(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          24,
                                                                      width: 24,
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            whiteColor,
                                                                        child: Image
                                                                            .asset(
                                                                          blackRightCircleImage,
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
                                                            )
                                                          : GestureDetector(
                                                              onTap: () async {
                                                                value.selected[
                                                                        index] =
                                                                    !value.selected[
                                                                        index];
                                                                if (value
                                                                        .selected[
                                                                    index]) {
                                                                  value
                                                                      .deleteidList
                                                                      .removeWhere((item) =>
                                                                          item ==
                                                                          value.wishListProduct[index]
                                                                              [
                                                                              "id"]);
                                                                  value.addList.add(
                                                                      value.wishListProduct[
                                                                              index]
                                                                          [
                                                                          "id"]);
                                                                }
                                                                print(
                                                                    "delete${value.deleteidList}");
                                                                print(
                                                                    "add${value.addList}");
                                                                value.addItem
                                                                    .value++;
                                                                print(value
                                                                    .addItem
                                                                    .value);
                                                                /*    value.productId
                                                                    .value = value
                                                                        .wishListProduct[
                                                                    index]["id"]; */
                                                                value.update();
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'board_product_unselected',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'board_product_unselected',
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      InkWell(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          24,
                                                                      width: 24,
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(
                                                                              color: greyBorder,
                                                                              width: 1.0,
                                                                            ),
                                                                            shape: BoxShape.circle),
                                                                        child:
                                                                            const CircleAvatar(
                                                                          backgroundColor:
                                                                              whiteColor,
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
                                                                horizontal: 16,
                                                                vertical: 10),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .bottomLeft,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 140),
                                                            color:
                                                                whiteBorderColor,
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
                                                                    heartImage,
                                                                    height: 16,
                                                                    color:
                                                                        bottomnavBack,
                                                                    width: 16,
                                                                  ),
                                                                ),
                                                                AppText(
                                                                  text: wishlistController.wishListProduct[index]
                                                                              [
                                                                              "aggregated_rating"] !=
                                                                          null
                                                                      ? wishlistController
                                                                          .wishListProduct[
                                                                              index]
                                                                              [
                                                                              "aggregated_rating"]
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
                                                                    width: 1,
                                                                    color:
                                                                        textHintColor,
                                                                    height: 16,
                                                                  ),
                                                                ),
                                                                AppText(
                                                                  text: wishlistController
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: AppText(
                                                      text: wishlistController
                                                                  .wishListProduct[
                                                              index]["name"] ??
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: AppText(
                                                      text: wishlistController
                                                                      .wishListProduct[
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
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            left: 10,
                                                            right: 1),
                                                    child: Row(
                                                      children: [
                                                        AppText(
                                                          text:
                                                              "\u{20B9} ${wishlistController.wishListProduct[index]["price"] ?? ""}",
                                                          color:
                                                              deepGreytextColor,
                                                          maxLines: 2,
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          child: Text(
                                                            "\u{20B9} ${wishlistController.wishListProduct[index]["mrp"] ?? ""}",
                                                            style: TextStyle(
                                                              color:
                                                                  textHintColor,
                                                              fontSize: 11.sp,
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Expanded(
                      child: Center(
                        child: Text("No Item Found",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: "Franklin Gothic Regular")),
                      ),
                    )),
          widget.btnText == ""
              ? const SizedBox(
                  height: 0,
                )
              : Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: getSingleButton(
                        label: widget.btnText == "Add"
                            ? wishlistController.addItem.value == 1 ||
                                    wishlistController.addItem.value == 0
                                ? "Add ${wishlistController.addItem.value} item"
                                : "Add ${wishlistController.addItem.value} items"
                            : widget.btnText,
                        textColor: whiteBorderColor,
                        controller: wishlistController,
                        backgroundColor: colorPrimary,
                        onPressed: () {
                          if (wishlistController.checkIdvalidation()) {
                            wishlistController.callAddWishlist(
                                widget.wishlistId, widget.type);
                          }
                        },
                        borderColor: colorPrimary),
                  ))
        ],
      ),
    );
  }
}
