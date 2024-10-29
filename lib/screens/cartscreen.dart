// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/commonwidget/appbarwidgets/cart_appbar.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomCharges.dart';
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
      controller.couponList.clear();
      controller.getCouponData();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.hasnextpage.value = true;
      productController.loadMore.value = false;
      productController.isProduct.value = false;
      productController.page.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    });
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
            icon: heartImage,
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
                              padding: EdgeInsets.only(top: 60.sp),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.sp,
                                                vertical: 20.sp),
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
                                                      fontSize: 16,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 5.sp),
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
                                                            fontSize: 12,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp),
                                                            child: Container(
                                                              width: 1.sp,
                                                              color:
                                                                  textHintColor,
                                                              height: 16.sp,
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
                                                            fontSize: 12,
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
                                                  padding: EdgeInsets.only(
                                                      bottom: 15.sp),
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
                                                        ImageIcon(
                                                          AssetImage(
                                                              deleteIcon),
                                                          color: colorPrimary,
                                                          size: 16.sp,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      2.sp),
                                                          child: AppText(
                                                            text: "Clear Bag",
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: colorPrimary,
                                                            fontSize: 12,
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
                                              padding: EdgeInsets.only(
                                                  bottom: 10.sp, top: 5.sp),
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      5.sp),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.sp,
                                                                    left: 16.sp,
                                                                    right:
                                                                        16.sp),
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
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(
                                                                              MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.orderList[index]["product"]["id"], type: "add")))
                                                                          .then((value) => setState(
                                                                                () {
                                                                                  productController.hasnextpage.value = true;
                                                                                  productController.loadMore.value = false;
                                                                                  productController.isProduct.value = false;
                                                                                  productController.page.value = 1;
                                                                                  productController.getProductData("relevant");
                                                                                  controller.getCartData();
                                                                                  controller.update();
                                                                                },
                                                                              ));
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
                                                                                        height: 78.sp,
                                                                                        width: 64.sp,
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
                                                                                            height: 78.sp,
                                                                                            width: 64.sp,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Image.asset(dummyWishlistImage, height: 78.sp, width: 64.sp, fit: BoxFit.cover)
                                                                                : Image.asset(dummyWishlistImage, height: 78.sp, width: 64.sp, fit: BoxFit.cover)),
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 8.sp),
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
                                                                                  fontSize: 14,
                                                                                  color: blackColor,
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                                                  child: AppText(
                                                                                    text: value.orderList[index]["product"]["short_description"] ?? "",
                                                                                    color: nameText,
                                                                                    maxLines: 2,
                                                                                    fontSize: 12,
                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                                AppText(
                                                                                  text: Bidi.stripHtmlIfNeeded(value.orderList[index]["product"]["description"] ?? ""),
                                                                                  color: textHintColor,
                                                                                  fontSize: 10,
                                                                                  fontFamily: "Franklin Gothic Regular",
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                                value.orderList[index]["express_delivery"] == 0
                                                                                    ? value.orderList[index]["estimated_delivery_by"] != null
                                                                                        ? value.orderList[index]["estimated_delivery_by"]["show_shipping_cost"]
                                                                                            ? Padding(
                                                                                                padding: EdgeInsets.only(top: 5.sp),
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    value.orderList[index]["estimated_delivery_by"]["message"] != null
                                                                                                        ? AppText(
                                                                                                            text: value.orderList[index]["estimated_delivery_by"]["message"],
                                                                                                            color: nameText,
                                                                                                            fontSize: 12,
                                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                                            fontWeight: FontWeight.w400,
                                                                                                          )
                                                                                                        : SizedBox(
                                                                                                            height: 0,
                                                                                                          ),
                                                                                                    AppText(
                                                                                                      text: "Shipping Cost : \u{20B9} ${value.orderList[index]["estimated_delivery_by"]["shipping_cost"]}",
                                                                                                      color: nameText,
                                                                                                      fontSize: 12,
                                                                                                      fontFamily: "Franklin Gothic Regular",
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              )
                                                                                            : SizedBox(
                                                                                                height: 0,
                                                                                              )
                                                                                        : SizedBox(
                                                                                            height: 0,
                                                                                          )
                                                                                    : SizedBox(
                                                                                        height: 0,
                                                                                      ),
                                                                                value.orderList[index]["product"]["express_delivery"]
                                                                                    ? Padding(
                                                                                        padding: EdgeInsets.only(
                                                                                          top: 8.0.sp,
                                                                                        ),
                                                                                        child: Row(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(right: 10.0.sp),
                                                                                              child: Image.asset(
                                                                                                truckImage,
                                                                                                height: 18.sp,
                                                                                                width: 18.sp,
                                                                                              ),
                                                                                            ),
                                                                                            AppText(
                                                                                              text: 'Express Delivery',
                                                                                              fontFamily: "Franklin Gothic Regular",
                                                                                              fontWeight: FontWeight.w500,
                                                                                              color: blackColor,
                                                                                              fontSize: 12,
                                                                                            ),
                                                                                            /*  controller.isExpress.value
                                                                                                ? SizedBox(
                                                                                                    height: 10.sp,
                                                                                                    width: 10.sp,
                                                                                                    child: Center(child: CircularProgressIndicator()),
                                                                                                  )
                                                                                                : */
                                                                                            Padding(
                                                                                              padding: EdgeInsets.only(left: 12.sp),
                                                                                              child: Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(3.sp),
                                                                                                    border: Border(
                                                                                                      top: BorderSide(width: 2.0.sp, color: greyBorder),
                                                                                                      left: BorderSide(width: 2.0.sp, color: greyBorder),
                                                                                                      right: BorderSide(width: 2.0.sp, color: greyBorder),
                                                                                                      bottom: BorderSide(width: 2.0.sp, color: greyBorder),
                                                                                                    ),
                                                                                                  ),
                                                                                                  width: 20,
                                                                                                  height: 20,
                                                                                                  child: Checkbox(
                                                                                                    value: value.orderList[index]["express_delivery"] == 1 ? true : false,
                                                                                                    checkColor: btnTextColor,
                                                                                                    activeColor: whiteBorderColor,
                                                                                                    side: const BorderSide(color: btnTextColor, width: 0),
                                                                                                    onChanged: (value) {
                                                                                                      controller.callAddtoCart(controller.orderList[index]["quantity"], "express", controller.orderList[index]["inventory"]["id"], controller.orderList[index]["product"]["id"], controller.orderList[index]["express_delivery"] == 0 ? 1 : 0);
                                                                                                    },
                                                                                                  )),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox(
                                                                                        height: 0,
                                                                                      ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(vertical: 5.sp),
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
                                                                                                      onPressedCross: () {
                                                                                                        Get.back();
                                                                                                      },
                                                                                                      sizeList: value.orderList[index]["product"]["new_inventories"],
                                                                                                      controller: controller,
                                                                                                      onPressed: (p0) {
                                                                                                        controller.callAddtoCart(1, "size", p0, value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0);
                                                                                                      },
                                                                                                      selectedSizeId: value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["id"] : 0,
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
                                                                                                height: 40.sp,
                                                                                                width: 75.sp,
                                                                                                child: Row(
                                                                                                  children: [
                                                                                                    Padding(
                                                                                                      padding: EdgeInsets.only(left: 4.sp, right: 2.sp, top: 5.sp, bottom: 5.sp),
                                                                                                      child: AppText(
                                                                                                        text: "Size : ${value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["product_matrix_name_size"] : ""}",
                                                                                                        color: blackColor,
                                                                                                        fontSize: 10,
                                                                                                        fontFamily: "Franklin Gothic Regular",
                                                                                                        fontWeight: FontWeight.w400,
                                                                                                      ),
                                                                                                    ),
                                                                                                    ImageIcon(
                                                                                                      AssetImage(dropdownImage),
                                                                                                      color: nameText,
                                                                                                      size: 16.sp,
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
                                                                                                  controller.callAddtoCart(p0, "quantity", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0);
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
                                                                                          padding: EdgeInsets.only(left: 10.sp, top: 5.sp, bottom: 5.sp),
                                                                                          child: Container(
                                                                                            color: whiteTextColor,
                                                                                            height: 40.sp,
                                                                                            width: 70.sp,
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 5.sp),
                                                                                                  child: AppText(
                                                                                                    text: "Qty : ${value.orderList[index]["quantity"] ?? "0"}",
                                                                                                    color: blackColor,
                                                                                                    fontSize: 10,
                                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                                    fontWeight: FontWeight.w400,
                                                                                                  ),
                                                                                                ),
                                                                                                ImageIcon(
                                                                                                  AssetImage(dropdownImage),
                                                                                                  color: nameText,
                                                                                                  size: 16.sp,
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
                                                                                  padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      AppText(
                                                                                        text: "\u{20B9} ${value.orderList[index]["product"]["price"] ?? "0"}",
                                                                                        color: blackColor,
                                                                                        fontSize: 12,
                                                                                        fontFamily: "Franklin Gothic Regular",
                                                                                        fontWeight: FontWeight.w400,
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: EdgeInsets.only(left: 10.sp),
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
                                                                                        padding: EdgeInsets.only(left: 10.sp),
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
                                                                                      value.callAddtoCart(0, "remove", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0);
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
                                                                              padding: EdgeInsets.symmetric(horizontal: 4.sp, vertical: 4.sp),
                                                                              child: Image.asset(blackCrossImage, height: 14.sp, width: 14.sp, fit: BoxFit.cover),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            8.sp),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      color:
                                                                          colorSecondary,
                                                                      height:
                                                                          1.sp,
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
                                              padding: EdgeInsets.only(
                                                  top: 24.sp, left: 16.sp),
                                              child: AppText(
                                                text: "You may also like",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: colorPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp,
                                                  vertical: 10.sp),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  height: 310.sp,
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
                                                                                  controller.getCartData();
                                                                                  controller.update();
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
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                              8.sp),
                                                                      color:
                                                                          whiteColor,
                                                                      width: 122
                                                                          .sp,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          productController.productList[index]["images"].isNotEmpty && productController.productList[index]["images"] != null
                                                                              ? SizedBox(
                                                                                  height: 150.sp,
                                                                                  width: 122.sp,
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
                                                                                      height: 150.sp,
                                                                                      width: 122.sp,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Image.asset(dummyWishlistImage, height: 150, width: 122, fit: BoxFit.cover),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                                                                            child:
                                                                                AppText(
                                                                              text: value.productList[index]["name"] ?? "",
                                                                              color: nameText,
                                                                              fontSize: 12,
                                                                              maxLines: 1,
                                                                              fontFamily: "Franklin Gothic",
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
                                                                            child:
                                                                                AppText(
                                                                              text: value.productList[index]["short_description"] ?? "",
                                                                              color: nameText,
                                                                              maxLines: 1,
                                                                              fontSize: 11,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.only(
                                                                                top: 10.sp,
                                                                                left: 10.sp,
                                                                                right: 1.sp),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                AppText(
                                                                                  text: "\u{20B9} ${value.productList[index]["price"] ?? "0"}",
                                                                                  color: deepGreytextColor,
                                                                                  maxLines: 2,
                                                                                  fontSize: 11,
                                                                                  fontFamily: "Franklin Gothic",
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: 5.sp),
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
                                                                                EdgeInsets.only(top: 10.sp),
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
                                                                                width: 122.sp),
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.sp, vertical: 20.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "Coupons",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: colorPrimary,
                                          fontSize: 12,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: borderColor,
                                                    width: 1.sp),
                                                borderRadius:
                                                    BorderRadius.circular(1)),
                                            child: Padding(
                                              padding: EdgeInsets.all(16.sp),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {},
                                                    child: Row(
                                                      children: [
                                                        ImageIcon(
                                                          AssetImage(
                                                              coupanImage),
                                                          color: colorPrimary,
                                                          size: 20.sp,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      8.sp),
                                                          child: AppText(
                                                            text: controller
                                                                .couponText
                                                                .value,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: textColor,
                                                            fontSize: 14,
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
                                                      if (controller
                                                                  .cartDetails[
                                                              "discount"] !=
                                                          null) {
                                                        controller
                                                            .callRemoveCoupon();
                                                      } else {
                                                        Get.to(BottomCoupon(
                                                          list: controller
                                                              .couponList,
                                                          onPressed: (p0) {
                                                            controller
                                                                .couponText
                                                                .value = p0;
                                                            controller
                                                                .callAddCoupon(
                                                                    p0);
                                                          },
                                                        ));
                                                      }
                                                    },
                                                    child:
                                                        controller
                                                                .isRemoveCoupan
                                                                .value
                                                            ? SizedBox(
                                                                height: 10.sp,
                                                                width: 10.sp,
                                                                child: Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                              )
                                                            : AppText(
                                                                text: controller
                                                                            .cartDetails["discount"] !=
                                                                        null
                                                                    ? "Remove"
                                                                    : "Select",
                                                                fontFamily:
                                                                    "Franklin Gothic",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: controller
                                                                            .cartDetails["discount"] !=
                                                                        null
                                                                    ? redColor
                                                                    : textColor,
                                                                fontSize: 12,
                                                              ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        /*    controller.cartDetails[
                                                    "express_delivery_charges"] ==
                                                "0.00"
                                            ? SizedBox(
                                                height: 0,
                                              )
                                            : Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.sp,
                                                    vertical: 10.sp),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (controller
                                                            .isExpress.value) {
                                                          controller.isExpress
                                                              .value = false;
                                                          controller
                                                              .expressValue
                                                              .value = 0;
                                                        } else {
                                                          controller.isExpress
                                                              .value = true;
                                                          controller
                                                              .expressValue
                                                              .value = 1;
                                                        }
                                                        controller
                                                            .callEnableExpressDelivery();
                                                      },
                                                      child: AppText(
                                                        text:
                                                            "Express Delivery Charges \u{20B9} ${controller.cartDetails["express_delivery_charges"]} ",
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: loginText,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: const SizedBox(
                                                        width: 0,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 0.sp),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3.sp),
                                                            border: Border(
                                                              top: BorderSide(
                                                                  width: 2.0.sp,
                                                                  color:
                                                                      greyBorder),
                                                              left: BorderSide(
                                                                  width: 2.0.sp,
                                                                  color:
                                                                      greyBorder),
                                                              right: BorderSide(
                                                                  width: 2.0.sp,
                                                                  color:
                                                                      greyBorder),
                                                              bottom: BorderSide(
                                                                  width: 2.0.sp,
                                                                  color:
                                                                      greyBorder),
                                                            ),
                                                          ),
                                                          width: 20,
                                                          height: 20,
                                                          child: Checkbox(
                                                            value: controller
                                                                .isExpress
                                                                .value,
                                                            checkColor:
                                                                btnTextColor,
                                                            activeColor:
                                                                whiteBorderColor,
                                                            side: const BorderSide(
                                                                color:
                                                                    btnTextColor,
                                                                width: 0),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                controller
                                                                        .isExpress
                                                                        .value =
                                                                    value!;
                                                                if (controller
                                                                    .isExpress
                                                                    .value) {
                                                                  controller
                                                                      .expressValue
                                                                      .value = 1;
                                                                } else {
                                                                  controller
                                                                      .expressValue
                                                                      .value = 0;
                                                                }
                                                                controller
                                                                    .callEnableExpressDelivery();
                                                              });
                                                            },
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                       */
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.sp),
                                          child: AppText(
                                            text: "Price Details",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: colorPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.sp),
                                          child: Container(
                                            width: double.infinity,
                                            color: colorSecondary,
                                            height: 1.sp,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 4.sp),
                                                child: AppText(
                                                  text: "Total MRP",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12,
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
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.cartDetails[
                                                    "express_delivery_charges"] ==
                                                "0.00"
                                            ? SizedBox(
                                                height: 0,
                                              )
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10.sp),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4.sp),
                                                      child: AppText(
                                                        text:
                                                            "Express Delivery Charges",
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: textColor,
                                                        fontSize: 12,
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
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textColor,
                                                      fontSize: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 4.sp),
                                                child: AppText(
                                                  text: "Discount on MRP",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12,
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
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.cartDetails[
                                                    "coupon_discount"] ==
                                                "0.00"
                                            ? SizedBox(
                                                height: 0,
                                              )
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10.sp),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4.sp),
                                                      child: AppText(
                                                        text: "Coupon Discount",
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: textColor,
                                                        fontSize: 12,
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
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: greenText,
                                                      fontSize: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 4.sp),
                                                child: AppText(
                                                  text: "Shipping Cost",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(
                                                  height: 0,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    "\u{20B9} ${controller.cartDetails["shipping_cost"] ?? "0"}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: greenText,
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 4.sp),
                                                    child: AppText(
                                                      text: "Convenience Fee",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      scaffoldKey.currentState
                                                          ?.showBottomSheet(
                                                              (context) =>
                                                                  BottomCharges(
                                                                    text:
                                                                        "This fee covers the costs of our convenient online shopping services, including secure payment processing, 24/7 customer support, and fast order processing. It helps us offer you a hassle-free shopping experience from the comfort of your home.",
                                                                    title:
                                                                        "Convenience Fee",
                                                                  ));
                                                    },
                                                    child: Image.asset(
                                                        questionIcon,
                                                        height: 16.sp,
                                                        width: 16.sp,
                                                        fit: BoxFit.cover),
                                                  )
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
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 4.sp),
                                                    child: AppText(
                                                      text: "Tax & Charges",
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      scaffoldKey.currentState
                                                          ?.showBottomSheet(
                                                              (context) =>
                                                                  BottomCharges(
                                                                    text:
                                                                        "This amount includes applicable sales tax and any additional charges required by local regulations. The exact breakdown may vary based on your location and the items in your cart.",
                                                                    title:
                                                                        "Tax & Charges",
                                                                  ));
                                                    },
                                                    child: Image.asset(
                                                        questionIcon,
                                                        height: 16.sp,
                                                        width: 16.sp,
                                                        fit: BoxFit.cover),
                                                  )
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
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.sp),
                                          child: Container(
                                            width: double.infinity,
                                            color: colorSecondary,
                                            height: 1.5,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 6.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 4.sp),
                                                child: AppText(
                                                  text: "Bill total",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: colorPrimary,
                                                  fontSize: 16,
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
                                                fontSize: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.sp,
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
              ? SizedBox(
                  height: 20.sp,
                  width: 20.sp,
                  child: Padding(
                    padding: EdgeInsets.all(10.0.sp),
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
                            padding: EdgeInsets.only(
                                top: 16.sp, left: 20.sp, right: 20.sp),
                            child: AppText(
                              text: controller.orderList.length == 1 ||
                                      controller.orderList.isEmpty
                                  ? "${controller.orderList.length} item in shopping bag"
                                  : "${controller.orderList.length} items in shopping bag",
                              textAlign: TextAlign.center,
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.sp),
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
                                      .cartDetails["discount_on_mrp"]
                                      .toString();
                                  controller.coupanDiscount.value = controller
                                          .cartDetails["coupon_discount"] ??
                                      "";
                                  controller.convenienceFee.value = controller
                                      .cartDetails["convenience_fee"]
                                      .toString();
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
