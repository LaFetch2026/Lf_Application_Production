// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlist/boardscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';
import '../commonwidget/app_text.dart';
import '../controller/wishlist_controller.dart';
import '../utils/constants.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  final wishlistController = Get.put(WishlistController());

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          HomeAppbar(
            onPressedSearch: () {
              Get.to(const SearchScreen());
            },
            onPressedCatalog: () {
              Get.to(const CatalogScreen());
            },
            onPressedCart: () {
              Get.to(const CartScreen());
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => wishlistController.isWishlist.value
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : wishlistController.wishlistList.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 90,
                                ),
                                Image.asset(emptyBoxImage,
                                    height: 160, width: 196, fit: BoxFit.cover),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 40, left: 16, right: 16),
                                  child: AppText(
                                    text: "Your Wishlist is empty",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: colorPrimary,
                                    fontSize: 22.sp,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 16, right: 16, bottom: 20),
                                  child: AppText(
                                    text:
                                        "Add products to your wishlist, review them anytime and easily move to cart",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    color: nameText,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: SingleButton(
                                      label: "Continue Shopping",
                                      textColor: btnTextColor,
                                      backgroundColor: whiteTextColor,
                                      onPressed: () {},
                                      borderColor: btnTextColor),
                                )
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 16, right: 16),
                                  child: AppText(
                                    text: "Wishlist",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: blackColor,
                                    fontSize: 25.sp,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 16, right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const NewBoardScreen(
                                                    title: "New Board",
                                                    boardId: 0,
                                                    hintName:
                                                        "Name of the Board",
                                                    boardName: "",
                                                    btnText: "Next",
                                                  )))
                                          .then((value) => setState(
                                                () {
                                                  wishlistController
                                                      .getWishlistData();
                                                },
                                              ));
                                    },
                                    child: Row(
                                      children: [
                                        AppText(
                                          text:
                                              "${wishlistController.wishlistList.length} boards",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: textHintColor,
                                          fontSize: 12.sp,
                                        ),
                                        const Expanded(
                                          child: SizedBox(
                                            width: 0,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.add,
                                          color: blackColor,
                                          size: 16,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: AppText(
                                            text: "New Board",
                                            color: blackColor,
                                            fontSize: 12.sp,
                                            fontFamily: "Franklin Gothic Bold",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                    childAspectRatio: 0.7,
                                    physics: const ScrollPhysics(),
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 0,
                                    children: List.generate(
                                      wishlistController.wishlistList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder:
                                                        (BuildContext
                                                                context) =>
                                                            BoardScreen(
                                                              boardName: wishlistController
                                                                              .wishlistList[
                                                                          index]
                                                                      [
                                                                      "name"] ??
                                                                  "",
                                                              boardId: wishlistController
                                                                      .wishlistList[
                                                                  index]["id"],
                                                            )))
                                                .then((value) => setState(
                                                      () {
                                                        wishlistController
                                                            .getWishlistData();
                                                      },
                                                    ));
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.asset(
                                                      sneakerImage,
                                                      height: 156,
                                                      width: 156,
                                                      fit: BoxFit.cover),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: AppText(
                                                    text: wishlistController
                                                                .wishlistList[
                                                            index]["name"] ??
                                                        "",
                                                    color: blackColor,
                                                    fontSize: 16.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: AppText(
                                                    text:
                                                        "${wishlistController.wishlistList[index]["products_count"] ?? "0"} items",
                                                    color: textHintColor,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
