// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/commonwidget/appbarwidgets/cart_appbar.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomCoupon.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomquantity.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomsize.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartwidgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_order_list.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/common_widgets.dart';
import '../commonwidget/homewidget/dummy_product_list.dart';
import '../controller/cart_controller.dart';
import '../controller/product_controller.dart';
import '../utils/constants.dart';
import 'catalog/productlist/productdetailsscreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final controller = Get.put(CartController());
  final productController = Get.put(ProductController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List qtyList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.couponList.clear();
      controller.getCouponData();
    });
    productController.hasnextpage.value = true;
    productController.loadMore.value = false;
    productController.isProduct.value = false;
    productController.page.value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      key: scaffoldKey,
      body: Column(
        children: [
          CartAppbar(
            text: "Shopping Bag",
            threeDot: true,
            icon: bigHeartImage,
            onPressedHeart: () {
              Get.offAll(const BottomNavScreen(
                index: 2,
              ));
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  //  Get.back();
                },
                child: Obx(
                  () => controller.isOrder.value
                      ? const DummyOrderList()
                      : controller.orderList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: CartWidget(
                                  image: shopBagImage,
                                  text1: "There is still room for more",
                                  onPressed: () {
                                    Get.offAll(const BottomNavScreen(
                                      index: 0,
                                    ));
                                  },
                                  text2:
                                      "Looking for items you previously saved?\nSign in to pick up where you left out",
                                  btntext: "Continue Shopping",
                                  visible: true),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                controller.isOrder.value
                                    ? const DummyOrderList()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 20),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text: "Shopping Bag",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: blackColor,
                                                      fontSize: 16.sp,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Row(
                                                        children: [
                                                          AppText(
                                                            text: controller.orderList
                                                                            .length ==
                                                                        1 ||
                                                                    controller
                                                                        .orderList
                                                                        .isEmpty
                                                                ? "${controller.orderList.length} item"
                                                                : "${controller.orderList.length} items",
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                textHintColor,
                                                            fontSize: 12.sp,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Container(
                                                              width: 1,
                                                              color:
                                                                  textHintColor,
                                                              height: 16,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text:
                                                                "\u{20B9} ${controller.cartDetails["total"] ?? "0"}",
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                textHintColor,
                                                            fontSize: 12.sp,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const Expanded(
                                                  child: SizedBox(
                                                    height: 0,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 15),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      showDialog(
                                                        barrierColor:
                                                            Colors.black26,
                                                        context: context,
                                                        builder: (context) {
                                                          return showDoubleBtnDailog(
                                                              click1: () {
                                                                Get.back();
                                                              },
                                                              click2: () {
                                                                if (controller
                                                                        .cartId
                                                                        .value !=
                                                                    0) {
                                                                  controller
                                                                      .callDeleteCart();
                                                                }
                                                              },
                                                              btncolor:
                                                                  colorPrimary,
                                                              text:
                                                                  "Are you sure you want to clear cart?",
                                                              btn1Text:
                                                                  "Cancel",
                                                              btn2Text:
                                                                  "Clear");
                                                        },
                                                      );

                                                      await analytics.logEvent(
                                                        name:
                                                            'cart_page_clearbagclick',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'cart_page_clearbagclick',
                                                        },
                                                      );
                                                    },
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const ImageIcon(
                                                          AssetImage(
                                                              deleteIcon),
                                                          color: colorPrimary,
                                                          size: 16,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      2),
                                                          child: AppText(
                                                            text: "Clear Bag",
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: colorPrimary,
                                                            fontSize: 12.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10, top: 5),
                                              child: GetBuilder<CartController>(
                                                builder: (value) =>
                                                    RefreshIndicator(
                                                  onRefresh: () {
                                                    return Future.delayed(
                                                        const Duration(
                                                            seconds: 1), () {
                                                      value.getCartData();
                                                    });
                                                  },
                                                  child: ListView.builder(
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      //  physics: const AlwaysScrollableScrollPhysics(),
                                                      itemCount: value
                                                          .orderList.length,
                                                      padding: EdgeInsets.zero,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10,
                                                                    left: 16,
                                                                    right: 16),
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      await analytics
                                                                          .logEvent(
                                                                        name:
                                                                            'cart_product_details',
                                                                        parameters: <String,
                                                                            Object>{
                                                                          'page_name':
                                                                              'cart_product_details',
                                                                        },
                                                                      );
                                                                    },
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Expanded(
                                                                            flex:
                                                                                1,
                                                                            child: value.orderList[index]["product"] != null
                                                                                ? value.orderList[index]["product"]["images"].isNotEmpty && value.orderList[index]["product"]["images"] != null
                                                                                    ? SizedBox(
                                                                                        height: 78,
                                                                                        width: 64,
                                                                                        child: CachedNetworkImage(
                                                                                          cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                          fit: BoxFit.cover,
                                                                                          imageUrl: isImage(value.orderList[index]["product"]["images"][0]["name"]) ? value.orderList[index]["product"]["images"][0]["name"] : value.orderList[index]["product"]["images"][1]["name"],
                                                                                          /*  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                            child: CircularProgressIndicator(value: downloadProgress.progress),
                                                                                          ), */
                                                                                          errorWidget: (context, url, error) => Image.asset(
                                                                                            downloadImage,
                                                                                            fit: BoxFit.cover,
                                                                                            height: 78,
                                                                                            width: 64,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Image.asset(dummyWishlistImage, height: 78, width: 64, fit: BoxFit.cover)
                                                                                : Image.asset(dummyWishlistImage, height: 78, width: 64, fit: BoxFit.cover)),
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 8),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                AppText(
                                                                                  text: value.orderList[index]["product"]["name"] ?? "",
                                                                                  maxLines: 1,
                                                                                  fontFamily: "Franklin Gothic",
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontSize: 14.sp,
                                                                                  color: blackColor,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                  child: AppText(
                                                                                    text: value.orderList[index]["product"]["short_description"] ?? "",
                                                                                    color: nameText,
                                                                                    maxLines: 2,
                                                                                    fontSize: 12.sp,
                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                                AppText(
                                                                                  text: Bidi.stripHtmlIfNeeded(value.orderList[index]["product"]["description"] ?? ""),
                                                                                  color: textHintColor,
                                                                                  fontSize: 10.sp,
                                                                                  fontFamily: "Franklin Gothic Regular",
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      /*   value.orderList[index]["inventory"] != null
                                                                                          ? value.orderList[index]["inventory"]["product_matrix"]["product_matrix_group"]["name"] == "Size"
                                                                                              ? Container(
                                                                                                  color: whiteTextColor,
                                                                                                  height: 40,
                                                                                                  width: 75,
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      GestureDetector(
                                                                                                        onTap: () {
                                                                                                          scaffoldKey.currentState?.showBottomSheet((context) => BottomSize(
                                                                                                                sizeList: sizeList,
                                                                                                                selectedSize: value.orderList[index]["inventory"] != null
                                                                                                                    ? value.orderList[index]["inventory"]["product_matrix"]["product_matrix_group"]["name"] == "Size"
                                                                                                                        ? value.orderList[index]["inventory"]["product_matrix"]["name"]
                                                                                                                        : ""
                                                                                                                    : "",
                                                                                                              ));
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.only(left: 4, right: 2, top: 5, bottom: 5),
                                                                                                          child: AppText(
                                                                                                            text: "Size : ${value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["product_matrix"]["product_matrix_group"]["name"] == "Size" ? value.orderList[index]["inventory"]["product_matrix"]["name"] : "S" : "S"}",
                                                                                                            color: blackColor,
                                                                                                            fontSize: 10.sp,
                                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                                            fontWeight: FontWeight.w400,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      const ImageIcon(
                                                                                                        AssetImage(dropdownImage),
                                                                                                        color: nameText,
                                                                                                        size: 16,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              : const SizedBox(
                                                                                                  height: 0,
                                                                                                )
                                                                                          : const SizedBox(
                                                                                              height: 0,
                                                                                            ), */
                                                                                      value.orderList[index]["inventory"] != null
                                                                                          ? GestureDetector(
                                                                                              onTap: () async {
                                                                                                scaffoldKey.currentState?.showBottomSheet((context) => BottomSize(
                                                                                                      sizeList: value.orderList[index]["product"]["new_inventories"],
                                                                                                      controller: controller,
                                                                                                      onPressed: (p0) {
                                                                                                        controller.callAddtoCart(1, "size", p0, value.orderList[index]["product"]["id"]);
                                                                                                      },
                                                                                                      selectedSize: value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["product_matrix_name_size"] : "",
                                                                                                    ));
                                                                                                await analytics.logEvent(
                                                                                                  name: 'cart_product_updatesizeClick',
                                                                                                  parameters: <String, Object>{
                                                                                                    'page_name': 'cart_product_updatesizeClick',
                                                                                                  },
                                                                                                );
                                                                                              },
                                                                                              child: Container(
                                                                                                color: whiteTextColor,
                                                                                                height: 40,
                                                                                                width: 75,
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.only(left: 4, right: 2, top: 5, bottom: 5),
                                                                                                      child: AppText(
                                                                                                        text: "Size : ${value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["product_matrix_name_size"] : ""}",
                                                                                                        color: blackColor,
                                                                                                        fontSize: 10.sp,
                                                                                                        fontFamily: "Franklin Gothic Regular",
                                                                                                        fontWeight: FontWeight.w400,
                                                                                                      ),
                                                                                                    ),
                                                                                                    const ImageIcon(
                                                                                                      AssetImage(dropdownImage),
                                                                                                      color: nameText,
                                                                                                      size: 16,
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : const SizedBox(
                                                                                              height: 0,
                                                                                            ),
                                                                                      GestureDetector(
                                                                                        onTap: () async {
                                                                                          scaffoldKey.currentState?.showBottomSheet((context) => BottomQuantity(
                                                                                                qtyList: qtyList,
                                                                                                selectedQty: value.orderList[index]["quantity"].toString(),
                                                                                                controller: controller,
                                                                                                stock: value.orderList[index]["inventory"]["stocks"] > 10 ? qtyList.length : value.orderList[index]["inventory"]["stocks"],
                                                                                                onPressed: (p0) {
                                                                                                  controller.callAddtoCart(p0, "quantity", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"]);
                                                                                                },
                                                                                              ));
                                                                                          await analytics.logEvent(
                                                                                            name: 'cart_product_updateqtyClick',
                                                                                            parameters: <String, Object>{
                                                                                              'page_name': 'cart_product_updateqtyClick',
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                                                                          child: Container(
                                                                                            color: whiteTextColor,
                                                                                            height: 40,
                                                                                            width: 70,
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                                                                  child: AppText(
                                                                                                    text: "Qty : ${value.orderList[index]["quantity"] ?? "0"}",
                                                                                                    color: blackColor,
                                                                                                    fontSize: 10.sp,
                                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                                    fontWeight: FontWeight.w400,
                                                                                                  ),
                                                                                                ),
                                                                                                const ImageIcon(
                                                                                                  AssetImage(dropdownImage),
                                                                                                  color: nameText,
                                                                                                  size: 16,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      AppText(
                                                                                        text: "\u{20B9} ${value.orderList[index]["product"]["price"] ?? "0"}",
                                                                                        color: blackColor,
                                                                                        fontSize: 12.sp,
                                                                                        fontFamily: "Franklin Gothic Regular",
                                                                                        fontWeight: FontWeight.w400,
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 10),
                                                                                        child: Text(
                                                                                          "\u{20B9} ${value.orderList[index]["product"]["mrp"] ?? "0"}",
                                                                                          style: TextStyle(
                                                                                            color: textHintColor,
                                                                                            fontSize: 12.sp,
                                                                                            decoration: TextDecoration.lineThrough,
                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                            fontWeight: FontWeight.w400,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 10),
                                                                                        child: Text(
                                                                                          "${value.orderList[index]["product"]["discount_percentage"] ?? "0 %"} OFF",
                                                                                          style: TextStyle(
                                                                                            color: blackColor,
                                                                                            fontSize: 12.sp,
                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                            fontWeight: FontWeight.w400,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            showDialog(
                                                                              barrierColor: Colors.black26,
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return showDoubleBtnDailog(
                                                                                    click1: () {
                                                                                      Get.back();
                                                                                    },
                                                                                    click2: () {
                                                                                      value.callAddtoCart(0, "remove", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"]);
                                                                                    },
                                                                                    btncolor: colorPrimary,
                                                                                    text: "Are you sure you want to remove this item?",
                                                                                    btn1Text: "Cancel",
                                                                                    btn2Text: "Remove");
                                                                              },
                                                                            );

                                                                            await analytics.logEvent(
                                                                              name: 'cart_product_removeClick',
                                                                              parameters: <String, Object>{
                                                                                'page_name': 'cart_product_removeClick',
                                                                              },
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                Colors.transparent,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                                              child: Image.asset(blackCrossImage, height: 10, width: 10, fit: BoxFit.cover),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      color:
                                                                          colorSecondary,
                                                                      height: 1,
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              )),
                                        ],
                                      ),
                                productController.isProduct.value
                                    ? const DummyProductList(
                                        text: "You may also like")
                                    : Container(
                                        color: whiteBack,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24, left: 16),
                                              child: AppText(
                                                text: "You may also like",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: colorPrimary,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  height: 310,
                                                  child: GetBuilder<
                                                      ProductController>(
                                                    builder: (value) =>
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            primary: false,
                                                            controller:
                                                                productController
                                                                    .listController,
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemCount: value
                                                                .productList
                                                                .length,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemBuilder:
                                                                (ctx, index) {
                                                              return Column(
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(
                                                                              MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.productList[index]["id"], type: "add")))
                                                                          .then((value) => setState(
                                                                                () {
                                                                                  productController.hasnextpage.value = true;
                                                                                  productController.loadMore.value = false;
                                                                                  productController.isProduct.value = false;
                                                                                  productController.page.value = 1;
                                                                                  productController.getProductData("relevant");
                                                                                },
                                                                              ));
                                                                      await analytics
                                                                          .logEvent(
                                                                        name:
                                                                            'cart_youmay_product_details',
                                                                        parameters: <String,
                                                                            Object>{
                                                                          'page_name':
                                                                              'cart_youmay_product_details',
                                                                        },
                                                                      );
                                                                    },
                                                                    child:
                                                                        AnimatedContainer(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8),
                                                                      color:
                                                                          whiteColor,
                                                                      width:
                                                                          122,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          productController.productList[index]["images"].isNotEmpty && productController.productList[index]["images"] != null
                                                                              ? SizedBox(
                                                                                  height: 150,
                                                                                  width: 122,
                                                                                  child: CachedNetworkImage(
                                                                                    cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                    fit: BoxFit.cover,
                                                                                    imageUrl: isImage(productController.productList[index]["images"][0]["name"]) ? productController.productList[index]["images"][0]["name"] : productController.productList[index]["images"][1]["name"],
                                                                                    /*  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                      child: CircularProgressIndicator(value: downloadProgress.progress),
                                                                                    ), */
                                                                                    errorWidget: (context, url, error) => Image.asset(
                                                                                      downloadImage,
                                                                                      fit: BoxFit.cover,
                                                                                      height: 150,
                                                                                      width: 122,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Image.asset(dummyWishlistImage, height: 150, width: 122, fit: BoxFit.cover),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                            child:
                                                                                AppText(
                                                                              text: value.productList[index]["name"] ?? "",
                                                                              color: nameText,
                                                                              fontSize: 12.sp,
                                                                              maxLines: 1,
                                                                              fontFamily: "Franklin Gothic",
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                                            child:
                                                                                AppText(
                                                                              text: value.productList[index]["short_description"] ?? "",
                                                                              color: nameText,
                                                                              maxLines: 1,
                                                                              fontSize: 11.sp,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                top: 10,
                                                                                left: 10,
                                                                                right: 1),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                AppText(
                                                                                  text: "\u{20B9} ${value.productList[index]["price"] ?? "0"}",
                                                                                  color: deepGreytextColor,
                                                                                  maxLines: 2,
                                                                                  fontSize: 11.sp,
                                                                                  fontFamily: "Franklin Gothic",
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 5),
                                                                                  child: Text(
                                                                                    "\u{20B9} ${value.productList[index]["mrp"] ?? "0"}",
                                                                                    style: TextStyle(
                                                                                      color: textHintColor,
                                                                                      fontSize: 11.sp,
                                                                                      decoration: TextDecoration.lineThrough,
                                                                                      fontFamily: "Franklin Gothic Regular",
                                                                                      fontWeight: FontWeight.w400,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 10),
                                                                            child: getSmallButton(
                                                                                label: "Add to bag",
                                                                                onPressed: () async {
                                                                                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.productList[index]["id"], type: "add"))).then((value) => setState(
                                                                                        () {
                                                                                          productController.hasnextpage.value = true;
                                                                                          productController.loadMore.value = false;
                                                                                          productController.isProduct.value = false;
                                                                                          productController.page.value = 1;
                                                                                          productController.getProductData("relevant");
                                                                                        },
                                                                                      ));
                                                                                  await analytics.logEvent(
                                                                                    name: 'cart_youmay_product_addtobag',
                                                                                    parameters: <String, Object>{
                                                                                      'page_name': 'cart_youmay_product_addtobag',
                                                                                    },
                                                                                  );
                                                                                  // controller.callAddtoCart(1, "addproduct");
                                                                                },
                                                                                textColor: btnTextColor,
                                                                                backgroundColor: whiteColor,
                                                                                borderColor: btnTextColor,
                                                                                width: 122),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            }),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  color: whiteColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "Coupons",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: colorPrimary,
                                          fontSize: 12.sp,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: borderColor,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(1)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {},
                                                    child: Row(
                                                      children: [
                                                        const ImageIcon(
                                                          AssetImage(
                                                              coupanImage),
                                                          color: colorPrimary,
                                                          size: 20,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          child: AppText(
                                                            text: controller
                                                                .couponText
                                                                .value,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: textColor,
                                                            fontSize: 14.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    child: SizedBox(
                                                      height: 0,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      await analytics.logEvent(
                                                        name:
                                                            'cart_page_applycouponclick',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'cart_page_applycouponclick',
                                                        },
                                                      );
                                                      Get.to(BottomCoupon(
                                                        list: controller
                                                            .couponList,
                                                        onPressed: (p0) {
                                                          controller.couponText
                                                              .value = p0;
                                                          controller
                                                              .callAddCoupon(
                                                                  p0);
                                                        },
                                                      ));
                                                    },
                                                    child: AppText(
                                                      text: "Select",
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: textColor,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: AppText(
                                            text: "Price Details",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: colorPrimary,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Container(
                                            width: double.infinity,
                                            color: colorSecondary,
                                            height: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: AppText(
                                                  text: "Total MRP",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["total_mrp"] ?? "0"}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: textColor,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: AppText(
                                                  text:
                                                      "Express Delivery Charges",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["express_delivery_charges"] ?? "0"}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: textColor,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: AppText(
                                                  text: "Discount on MRP",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["discount_on_mrp"] ?? "0"}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greenText,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: AppText(
                                                  text: "Coupon Discount",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["coupon_discount"] ?? "0"}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greenText,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4),
                                                    child: AppText(
                                                      text: "Convenience Fee",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textColor,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  Image.asset(questionIcon,
                                                      height: 16,
                                                      width: 16,
                                                      fit: BoxFit.cover)
                                                ],
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["convenience_fee"] ?? "Free"}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greenText,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4),
                                                    child: AppText(
                                                      text: "Tax & Charges",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textColor,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  Image.asset(questionIcon,
                                                      height: 16,
                                                      width: 16,
                                                      fit: BoxFit.cover)
                                                ],
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["total_tax"].toString()}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: textColor,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Container(
                                            width: double.infinity,
                                            color: colorSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: AppText(
                                                  text: "Bill total",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: colorPrimary,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["total"] ?? "0"}",
                                                fontFamily:
                                                    "Franklin Gothic Bold",
                                                fontWeight: FontWeight.w700,
                                                color: colorPrimary,
                                                fontSize: 18.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                /*  Container(
                                  color: backWhite,
                                  height: 34,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 6, bottom: 6),
                                    child: Center(
                                      child: AppText(
                                        text:
                                            "You will earn 100 LaFetch coins on this purchase",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: deepPurple,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ), */
                                /*      Container(
                                  color: whiteColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: whiteBorderColor,
                                              borderRadius:
                                                  BorderRadius.circular(1)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AppText(
                                                  text: "Return/Refund Policy",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: nameText,
                                                  fontSize: 14.sp,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: AppText(
                                                    text:
                                                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nibh augue, commodo eget pulvinar ac, pretium a ipsum.",
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    maxLines: 3,
                                                    color: greyTextColor,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                                AppText(
                                                  text: "READ POLICY",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: greyTextColor,
                                                  fontSize: 12.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, bottom: 30),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Image.asset(deliveredImage,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.cover),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: AppText(
                                                      text:
                                                          "Delivered in\n6 hours",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: greyTextColor,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontSize: 10.sp,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(qualityImage,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.cover),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: AppText(
                                                      text:
                                                          "100% Quality\nassured",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: greyTextColor,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontSize: 10.sp,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(locationBaseImage,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.cover),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: AppText(
                                                      text:
                                                          "Location based\nDeliveries",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: greyTextColor,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontSize: 10.sp,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(exchangeImage,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.cover),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: AppText(
                                                      text:
                                                          "2 exchanges\nwithin 2 days",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: greyTextColor,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontSize: 10.sp,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            */
                              ],
                            ),
                ),
              ),
            ),
          ),
          Obx(() => controller.isOrder.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : controller.orderList.isNotEmpty
                  ? Container(
                      color: whiteColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 20, right: 20),
                            child: AppText(
                              text: controller.orderList.length == 1 ||
                                      controller.orderList.isEmpty
                                  ? "${controller.orderList.length} item in shopping bag"
                                  : "${controller.orderList.length} items in shopping bag",
                              textAlign: TextAlign.center,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: blackColor,
                              fontSize: 12.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: getSingleButton(
                                label: "Proceed to checkout",
                                textColor: whiteBorderColor,
                                backgroundColor: colorPrimary,
                                controller: controller,
                                onPressed: () async {
                                  controller.mrp.value =
                                      controller.cartDetails["total_mrp"] ?? "";
                                  controller.expressDelivery.value =
                                      controller.cartDetails[
                                              "express_delivery_charges"] ??
                                          "";
                                  controller.discount.value = controller
                                          .cartDetails["discount_on_mrp"] ??
                                      "";
                                  controller.coupanDiscount.value = controller
                                          .cartDetails["coupon_discount"] ??
                                      "";
                                  controller.convenienceFee.value = controller
                                          .cartDetails["convenience_fee"] ??
                                      "";
                                  controller.tax.value = controller
                                      .cartDetails["total_tax"]
                                      .toString();
                                  controller.total.value = controller
                                      .cartDetails["total"]
                                      .toString();
                                  if (controller.cartDetails["address"] !=
                                      null) {
                                    controller.callInitiatePayment(
                                        controller.cartDetails["address"]["id"],
                                        context);
                                  } else {
                                    controller.callInitiatePayment(0, context);
                                  }
                                  await analytics.logEvent(
                                    name: 'proceed_checkout_btnclick',
                                    parameters: <String, Object>{
                                      'page_name': 'proceed_checkout_btnclick',
                                    },
                                  );
                                },
                                borderColor: colorPrimary),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 0))
        ],
      ),
    );
  }
}
