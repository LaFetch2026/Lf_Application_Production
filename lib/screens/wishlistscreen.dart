// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlist/boardscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';

import '../common/widget/appbar/productlist_appbar.dart';
import '../common/widget/button/singlebtn.dart';
import '../common/widget/lists/dummy_wishlist_list.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../core/constant/constants.dart';
import 'cartscreen.dart';

class WishlistScreen extends StatefulWidget {
  final Function? onPressed;

  const WishlistScreen({this.onPressed, super.key});

  @override
  State<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  final wishlistController = Get.put(WishlistController());
  final cartController = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      wishlistController.wishlistListController.addListener(() {
        wishlistController.fetchMoreData();
        wishlistController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: statusBarColor,
      ));
    });
    wishlistController.hasnextpage.value = true;
    wishlistController.loadMore.value = false;
    wishlistController.isWishlist.value = false;
    wishlistController.page.value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isImage(String path) {
    print(path);
    return path.contains('product_photo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          ProductAppbar(
              text: "Wishlist",
              onPressedSearch: () async {
                Get.to(const SearchScreen())?.then((value) => setState(
                      () {},
                    ));
                analytics
                    .logEvent(name: "search_page", parameters: <String, Object>{
                  "page_name": "search_page",
                });
              },
              isHandPicked: true,
              isWishlist: false,
              onPressedCart: () async {
                Get.to(CartScreen())?.then((value) => setState(
                      () {
                        cartController.getCartData();
                      },
                    ));
                analytics
                    .logEvent(name: "cart_page", parameters: <String, Object>{
                  "page_name": "cart_page",
                });
              }),
          Expanded(
            child: SingleChildScrollView(
              controller: wishlistController.wishlistListController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
                    child: AppText(
                      text: "Wishlist",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                      fontSize: 25,
                    ),
                  ),
                  Obx(() => wishlistController.isWishlist.value
                      ? const DummyWishlistList()
                      : wishlistController.wishlistList.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.sp, left: 16.sp, right: 16.sp),
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const NewBoardScreen(
                                                    title: "New Board",
                                                    boardId: 0,
                                                    productId: 0,
                                                    hintName:
                                                        "Name of the Board",
                                                    boardName: "",
                                                    btnText: "Next",
                                                  )))
                                          .then((value) => setState(
                                                () {
                                                  wishlistController
                                                      .hasnextpage.value = true;
                                                  wishlistController
                                                      .loadMore.value = false;
                                                  wishlistController
                                                      .isWishlist.value = false;
                                                  wishlistController
                                                      .page.value = 1;
                                                  wishlistController
                                                      .getWishlistData();
                                                },
                                              ));
                                      await analytics.logEvent(
                                        name: 'wishlist_page_newboardclick',
                                        parameters: <String, Object>{
                                          'page_name':
                                              'wishlist_page_newboardclick',
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: "0 board",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: textHintColor,
                                          fontSize: 12,
                                        ),
                                        const Expanded(
                                          child: SizedBox(
                                            width: 0,
                                          ),
                                        ),
                                        Icon(
                                          Icons.add,
                                          color: blackColor,
                                          size: 16.sp,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.sp),
                                          child: AppText(
                                            text: "New Board",
                                            color: blackColor,
                                            fontSize: 12,
                                            fontFamily: "Franklin Gothic Bold",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.sp,
                                ),
                                Image.asset(emptyBoxImage,
                                    height: 160.sp,
                                    width: 196.sp,
                                    fit: BoxFit.cover),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 40.sp, left: 16.sp, right: 16.sp),
                                  child: AppText(
                                    text: "Your Wishlist is empty",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: colorPrimary,
                                    fontSize: 22,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 20.sp,
                                      left: 16.sp,
                                      right: 16.sp,
                                      bottom: 20.sp),
                                  child: AppText(
                                    text:
                                        "Add products to your wishlist, review them anytime and easily move to cart",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    color: nameText,
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 20.sp),
                                  child: SingleButton(
                                      label: "Continue Shopping",
                                      textColor: btnTextColor,
                                      backgroundColor: whiteColor,
                                      onPressed: () {
                                        widget.onPressed?.call();
                                      },
                                      borderColor: btnTextColor),
                                )
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.sp, left: 16.sp, right: 16.sp),
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const NewBoardScreen(
                                                    title: "New Board",
                                                    boardId: 0,
                                                    productId: 0,
                                                    hintName:
                                                        "Name of the Board",
                                                    boardName: "",
                                                    btnText: "Next",
                                                  )))
                                          .then((value) => setState(
                                                () {
                                                  wishlistController
                                                      .hasnextpage.value = true;
                                                  wishlistController
                                                      .loadMore.value = false;
                                                  wishlistController
                                                      .isWishlist.value = false;
                                                  wishlistController
                                                      .page.value = 1;
                                                  wishlistController
                                                      .getWishlistData();
                                                },
                                              ));
                                      await analytics.logEvent(
                                        name: 'create_board',
                                        parameters: <String, Object>{
                                          'page_name': 'create_board',
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: wishlistController
                                                      .totalBoard.value ==
                                                  1
                                              ? "${wishlistController.totalBoard.value} board"
                                              : "${wishlistController.totalBoard.value} boards",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: textHintColor,
                                          fontSize: 12,
                                        ),
                                        const Expanded(
                                          child: SizedBox(
                                            width: 0,
                                          ),
                                        ),
                                        Icon(
                                          Icons.add,
                                          color: blackColor,
                                          size: 16.sp,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: AppText(
                                            text: "New Board",
                                            color: blackColor,
                                            fontSize: 12,
                                            fontFamily: "Franklin Gothic Bold",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 10.sp),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    controller: wishlistController
                                        .wishlistListController,
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
                                          onTap: () async {
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
                                                            .hasnextpage
                                                            .value = true;
                                                        wishlistController
                                                            .loadMore
                                                            .value = false;
                                                        wishlistController
                                                            .isWishlist
                                                            .value = false;
                                                        wishlistController
                                                            .page.value = 1;
                                                        wishlistController
                                                            .getWishlistData();
                                                      },
                                                    ));
                                            await analytics.logEvent(
                                              name: 'wishlist_click',
                                              parameters: <String, Object>{
                                                'page_name': 'wishlist_click',
                                              },
                                            );
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
                                                          8.0.sp),
                                                  child: wishlistController
                                                          .wishlistList[index]
                                                              ["images"]
                                                          .isNotEmpty
                                                      ? SizedBox(
                                                          height: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2) -
                                                              24.sp,
                                                          width: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2) -
                                                              24.sp,
                                                          child:
                                                              CachedNetworkImage(
                                                            cacheManager: CacheManager(Config(
                                                                "customCacheKey",
                                                                stalePeriod:
                                                                    const Duration(
                                                                        days:
                                                                            15),
                                                                maxNrOfCacheObjects:
                                                                    100)),
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                wishlistController
                                                                            .wishlistList[
                                                                        index][
                                                                    "images"][0],
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              downloadImage,
                                                              height: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2) -
                                                                  24.sp,
                                                              width: (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2) -
                                                                  24.sp,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          dummyWishlistImage,
                                                          height: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2) -
                                                              24.sp,
                                                          width: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2) -
                                                              24.sp,
                                                          fit: BoxFit.cover),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.sp,
                                                      vertical: 5.sp),
                                                  child: AppText(
                                                    text:
                                                        "${wishlistController.wishlistList[index]["name"]}"
                                                            .capitalize!,
                                                    color: blackColor,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.sp),
                                                  child: AppText(
                                                    text: wishlistController.wishlistList[
                                                                        index][
                                                                    "products_count"] ==
                                                                1 ||
                                                            wishlistController
                                                                            .wishlistList[
                                                                        index][
                                                                    "products_count"] ==
                                                                0
                                                        ? "${wishlistController.wishlistList[index]["products_count"]} item"
                                                        : "${wishlistController.wishlistList[index]["products_count"]} items",
                                                    color: textHintColor,
                                                    fontSize: 12,
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
                                wishlistController.loadMore.value
                                    ? const DummyWishlistList()
                                    : const SizedBox(
                                        height: 0,
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
