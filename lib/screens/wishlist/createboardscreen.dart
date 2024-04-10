// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/editboard_appbar.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/common_widgets.dart';
import '../../controller/wishlist_controller.dart';
import '../../utils/constants.dart';

class CreateBoardScreen extends StatefulWidget {
  final String btnText;
  final int wishlistId;
  const CreateBoardScreen(
      {required this.btnText, required this.wishlistId, super.key});

  @override
  State<CreateBoardScreen> createState() => CreateBoardScreenState();
}

class CreateBoardScreenState extends State<CreateBoardScreen> {
  final wishlistController = Get.put(WishlistController());
  @override
  void initState() {
    wishlistController.deleteidList.clear();
    wishlistController.addItem.value = 0;
    wishlistController.productId.value = 0;
    wishlistController.wishListProduct.clear();
    widget.btnText == ""
        ? WidgetsBinding.instance.addPostFrameCallback(
            (_) => wishlistController.getWishlistDetails(widget.wishlistId))
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
                              if (wishlistController.deleteidList.isNotEmpty) {
                                wishlistController
                                    .callDeleteProduct(widget.wishlistId);
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
                  },
                  onPressedShare: () {},
                )
              : const BackButtonAppbar(
                  text: "Add items to board",
                  threeDot: false,
                  icon: threeDotImage,
                ),
          Obx(() => wishlistController.isDetails.value
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : wishlistController.wishListProduct.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 10),
                              child: AppText(
                                text:
                                    "${wishlistController.addItem.value} items selected",
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
                                              onTap: () {},
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                            backImage,
                                                            height: 190,
                                                            width: 152,
                                                            fit: BoxFit.cover),
                                                      ),
                                                      value.selected[index]
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                value.selected[
                                                                        index] =
                                                                    false;
                                                                if (value.selected[
                                                                        index] ==
                                                                    false) {
                                                                  value
                                                                      .deleteidList
                                                                      .removeWhere((item) =>
                                                                          item ==
                                                                          value.wishListProduct[index]
                                                                              [
                                                                              "id"]);
                                                                }
                                                                print(value
                                                                    .deleteidList);
                                                                value.addItem
                                                                    .value--;
                                                                print(value
                                                                    .addItem
                                                                    .value);
                                                                value.productId
                                                                    .value = 0;
                                                                value.update();
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
                                                              onTap: () {
                                                                value.selected[
                                                                        index] =
                                                                    !value.selected[
                                                                        index];
                                                                if (value
                                                                        .selected[
                                                                    index]) {
                                                                  value
                                                                      .deleteidList
                                                                      .add(value
                                                                              .wishListProduct[index]
                                                                          [
                                                                          "id"]);
                                                                }
                                                                print(value
                                                                    .deleteidList);
                                                                value.addItem
                                                                    .value++;
                                                                print(value
                                                                    .addItem
                                                                    .value);
                                                                value.productId
                                                                    .value = value
                                                                        .wishListProduct[
                                                                    index]["id"];
                                                                value.update();
                                                              },
                                                              child:
                                                                  const Padding(
                                                                padding: EdgeInsets
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
                                                                Image.asset(
                                                                  heartImage,
                                                                  height: 24,
                                                                  color:
                                                                      bottomnavBack,
                                                                  width: 24,
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
                                                            right: 10),
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
                                                                  left: 10),
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
                            ? "Add ${wishlistController.addItem.value} items"
                            : widget.btnText,
                        textColor: whiteBorderColor,
                        controller: wishlistController,
                        backgroundColor: colorPrimary,
                        onPressed: () {
                          if (wishlistController.checkIdvalidation(
                              wishlistController.productId.value)) {
                            wishlistController.callAddItemWishlist();
                          }
                        },
                        borderColor: colorPrimary),
                  ))
        ],
      ),
    );
  }
}
