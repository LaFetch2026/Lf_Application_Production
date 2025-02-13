// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/commonwidget/appbarwidgets/cart_appbar.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomCharges.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomCoupon.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomquantity.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomsize.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartbottom.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartwidgets.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomwishlist.dart';
import 'package:lafetch/commonwidget/doubleiconbtn.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_order_list.dart';
import 'package:lafetch/commonwidget/homewidget/dummyblack_orderlist.dart';
import 'package:lafetch/controller/wishlist_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/change_address.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/mapscreen.dart';
import 'package:lafetch/screens/paymentsuccessscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/common_widgets.dart';
//import '../commonwidget/homewidget/dummy_product_list.dart';
import '../controller/cart_controller.dart';
import '../controller/product_controller.dart';
import '../utils/constants.dart';
import 'catalog/productlist/productdetailsscreen.dart';

class CartScreen extends StatefulWidget {
  final Color backgroundcolor;
  const CartScreen({super.key, this.backgroundcolor = whiteColor});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final controller = Get.put(CartController());
  final productController = Get.put(ProductController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List qtyList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Razorpay razorpay = Razorpay();
  final wishlistController = Get.put(WishlistController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.qtyProductId.value = 0;
      controller.qtyText.value = "";
      controller.couponList.clear();
      controller.selected.clear();
      controller.selected = List.generate(50, (i) => false).obs;
    });
    getPrefrenceValue();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    /*  WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant")); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.hasnextpage.value = true;
      productController.loadMore.value = false;
      productController.isProduct.value = false;
      productController.page.value = 1;
    }); */
    /* WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    }); */
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    super.initState();
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("skip") == true) {
      Get.to(
        () => const LoginScreen(
          initialTab: 0,
        ),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          widget.backgroundcolor == whiteColor
              ? controller.getCartData()
              : controller.getExpressCartData());
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    print("order id ${response.orderId}");
    print("payment id ${response.paymentId}");
    print("singature ${response.signature}");
    print("data ${response.data}");
    controller.callProcessPayment(controller.cartDetails["id"],
        response.paymentId!, response.orderId!, response.signature!);
    // Do something when payment succeeds
  }

  void handlePaymentError(PaymentFailureResponse response) {
    print("Error ${response.message}");
    print("Error ${response.code}");
    print("Error ${response.error}");
    Get.to(const PaymentSuccessScreen(
        text1: "Payment Failed",
        text2: "Thank you for placing your order",
        orderId: 0,
        image: paymentFailImage));
    // Do something when payment fails
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    print("Wallet ${response.walletName}");
    Get.to(const PaymentSuccessScreen(
        text1: "Uh-oh something went wrong!",
        orderId: 0,
        text2: "Thank you for placing your order",
        image: errorImage));
    // Do something when an external wallet is selected
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundcolor,
      key: scaffoldKey,
      body: Stack(
        children: [
          Visibility(
            visible: widget.backgroundcolor == whiteColor ? false : true,
            child: Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                quickBackCircle,
                height: 250.sp,
                width: 300.sp,
              ),
            ),
          ),
          Column(
            children: [
              Visibility(
                visible: widget.backgroundcolor == whiteColor ? true : false,
                child: CartAppbar(
                  text: "Bag",
                  onPressedWishlist: () {
                    Get.to(WishlistScreen());
                  },
                ),
              ),
              Visibility(
                visible: widget.backgroundcolor == whiteColor ? true : false,
                child: Container(
                  color: dividerColor,
                  height: 1.sp,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Visibility(
                        visible:
                            widget.backgroundcolor == whiteColor ? false : true,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 50.sp),
                              child: Center(
                                  child: Image.asset(
                                bagLogoImage,
                                height: 33.sp,
                                width: 17.sp,
                              )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 28.sp, left: 16.sp),
                              child: AppText(
                                text: "Bag".toUpperCase(),
                                fontFamily: "Franklin Gothic Semibold",
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            Obx(() => Padding(
                                  padding:
                                      EdgeInsets.only(top: 1.sp, left: 16.sp),
                                  child: controller.isOrder.value
                                      ? DummyContainer(height: 8, width: 50)
                                      : AppText(
                                          text: controller.orderList.length == 1
                                              ? "${controller.orderList.length} Product"
                                              : "${controller.orderList.length} Products",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w600,
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                )),
                          ],
                        ),
                      ),
                      Obx(
                        () => controller.isPayment.value
                            ? Container(
                                margin: EdgeInsets.only(top: 100.sp),
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : controller.isOrder.value
                                ? widget.backgroundcolor == whiteColor
                                    ? const DummyOrderList(
                                        size: 3,
                                      )
                                    : DummyBlackOrderList(
                                        size: 3,
                                      )
                                : controller.orderList.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 60.sp),
                                        child: CartWidget(
                                            image: shopBagImage,
                                            backColor: widget.backgroundcolor,
                                            text1:
                                                "There is still room for more",
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /*   controller.isOrder.value
                                              ? const DummyOrderList()
                                              : */
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /*  Padding(
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
                                                            CrossAxisAlignment
                                                                .start,
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
                                                            padding:
                                                                EdgeInsets.only(
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
                                                                      FontWeight
                                                                          .w400,
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
                                                                      FontWeight
                                                                          .w400,
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
          
                                                            await analytics
                                                                .logEvent(
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
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      colorPrimary,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ), */
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10.sp, top: 5.sp),
                                                  child: GetBuilder<
                                                      CartController>(
                                                    builder: (value) =>
                                                        RefreshIndicator(
                                                      onRefresh: () {
                                                        return Future.delayed(
                                                            const Duration(
                                                                seconds: 1),
                                                            () {
                                                          widget.backgroundcolor ==
                                                                  whiteColor
                                                              ? controller
                                                                  .getCartData()
                                                              : controller
                                                                  .getExpressCartData();
                                                        });
                                                      },
                                                      child: ListView.builder(
                                                          primary: false,
                                                          shrinkWrap: true,
                                                          //  physics: const AlwaysScrollableScrollPhysics(),
                                                          itemCount: value
                                                              .orderList.length,
                                                          padding:
                                                              EdgeInsets.zero,
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
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 10
                                                                            .sp,
                                                                        left: 16
                                                                            .sp,
                                                                        right: 16
                                                                            .sp),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () async {
                                                                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.orderList[index]["product"]["id"], brandName: value.orderList[index]["product"]["brand_name"], type: "add"))).then((value) => setState(
                                                                                    () {
                                                                                      productController.hasnextpage.value = true;
                                                                                      productController.loadMore.value = false;
                                                                                      productController.isProduct.value = false;
                                                                                      productController.page.value = 1;
                                                                                      productController.getProductData("relevant");
                                                                                      widget.backgroundcolor == whiteColor ? controller.getCartData() : controller.getExpressCartData();
                                                                                      controller.update();
                                                                                    },
                                                                                  ));
                                                                              await analytics.logEvent(
                                                                                name: 'cart_product_details',
                                                                                parameters: <String, Object>{
                                                                                  'page_name': 'cart_product_details',
                                                                                },
                                                                              );
                                                                            },
                                                                            child: value.orderList[index]["product"] != null
                                                                                ? value.orderList[index]["product"]["images"].isNotEmpty && value.orderList[index]["product"]["images"] != null
                                                                                    ? Opacity(
                                                                                        opacity: value.orderList[index]["product"]["total_stock_count"] == 0 ? 0.5 : 1,
                                                                                        child: SizedBox(
                                                                                          height: 130.sp,
                                                                                          width: 100.sp,
                                                                                          child: CachedNetworkImage(
                                                                                            cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                            fit: BoxFit.cover,
                                                                                            imageUrl: isImage(value.orderList[index]["product"]["images"][0]["name"]) ? value.orderList[index]["product"]["images"][0]["name"] : value.orderList[index]["product"]["images"][1]["name"],
                                                                                            errorWidget: (context, url, error) => Image.asset(
                                                                                              downloadImage,
                                                                                              fit: BoxFit.cover,
                                                                                              height: 130.sp,
                                                                                              width: 100.sp,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Image.asset(dummyWishlistImage, height: 130.sp, width: 100.sp, fit: BoxFit.cover)
                                                                                : Image.asset(dummyWishlistImage, height: 130.sp, width: 100.sp, fit: BoxFit.cover),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 8.sp),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.orderList[index]["product"]["id"], brandName: value.orderList[index]["product"]["brand_name"], type: "add"))).then((value) => setState(
                                                                                          () {
                                                                                            productController.hasnextpage.value = true;
                                                                                            productController.loadMore.value = false;
                                                                                            productController.isProduct.value = false;
                                                                                            productController.page.value = 1;
                                                                                            productController.getProductData("relevant");
                                                                                            widget.backgroundcolor == whiteColor ? controller.getCartData() : controller.getExpressCartData();
                                                                                            controller.update();
                                                                                          },
                                                                                        ));
                                                                                    await analytics.logEvent(
                                                                                      name: 'cart_product_details',
                                                                                      parameters: <String, Object>{
                                                                                        'page_name': 'cart_product_details',
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    width: MediaQuery.of(context).size.width - 165.sp,
                                                                                    margin: EdgeInsets.only(top: 10.sp),
                                                                                    child: AppText(
                                                                                      text: value.orderList[index]["product"]["brand_name"].toUpperCase() ?? "",
                                                                                      maxLines: 1,
                                                                                      fontFamily: "Franklin Gothic",
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontSize: 16,
                                                                                      color: widget.backgroundcolor == whiteColor
                                                                                          ? value.orderList[index]["product"]["total_stock_count"] == 0
                                                                                              ? blackColor.withOpacity(0.3)
                                                                                              : blackColor
                                                                                          : whiteColor,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.orderList[index]["product"]["id"], brandName: value.orderList[index]["product"]["brand_name"], type: "add"))).then((value) => setState(
                                                                                          () {
                                                                                            productController.hasnextpage.value = true;
                                                                                            productController.loadMore.value = false;
                                                                                            productController.isProduct.value = false;
                                                                                            productController.page.value = 1;
                                                                                            productController.getProductData("relevant");
                                                                                            widget.backgroundcolor == whiteColor ? controller.getCartData() : controller.getExpressCartData();
                                                                                            controller.update();
                                                                                          },
                                                                                        ));
                                                                                    await analytics.logEvent(
                                                                                      name: 'cart_product_details',
                                                                                      parameters: <String, Object>{
                                                                                        'page_name': 'cart_product_details',
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    width: MediaQuery.of(context).size.width - 165.sp,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.symmetric(vertical: 4.sp),
                                                                                      child: AppText(
                                                                                        text: Bidi.stripHtmlIfNeeded(value.orderList[index]["product"]["name"] ?? ""),
                                                                                        color: widget.backgroundcolor == whiteColor
                                                                                            ? value.orderList[index]["product"]["total_stock_count"] == 0
                                                                                                ? subtitleColor.withOpacity(0.5)
                                                                                                : subtitleColor
                                                                                            : productSubtitleColor,
                                                                                        maxLines: 1,
                                                                                        fontSize: 14,
                                                                                        fontFamily: "Franklin Gothic Regular",
                                                                                        fontWeight: FontWeight.w400,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                /*  value.orderList[index]["discount"] != "0.00"
                                                                                              ? Padding(
                                                                                                  padding: EdgeInsets.only(left: 1.sp),
                                                                                                  child: AppText(
                                                                                                    text: "Discount : \u{20B9} ${value.orderList[index]["discount"] ?? "0.0"}",
                                                                                                    color: subtitleColor,
                                                                                                    fontSize: 12,
                                                                                                    fontFamily: "Franklin Gothic Regular",
                                                                                                    fontWeight: FontWeight.w400,
                                                                                                  ),
                                                                                                )
                                                                                              : SizedBox(
                                                                                                  height: 0,
                                                                                                ),
                                                                                          !value.orderList[index]["express_delivery"]
                                                                                              ? value.orderList[index]["estimated_delivery_by"] != null
                                                                                                  ? value.orderList[index]["estimated_delivery_by"]["show_shipping_cost"]
                                                                                                      ? Padding(
                                                                                                          padding: EdgeInsets.only(top: 2.sp),
                                                                                                          child: Column(
                                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                            children: [
                                                                                                              value.orderList[index]["estimated_delivery_by"]["message"] != null
                                                                                                                  ? AppText(
                                                                                                                      text: value.orderList[index]["estimated_delivery_by"]["message"],
                                                                                                                      color: widget.backgroundcolor == whiteColor ? subtitleColor : productSubtitleColor,
                                                                                                                      fontSize: 12,
                                                                                                                      fontFamily: "Franklin Gothic Regular",
                                                                                                                      fontWeight: FontWeight.w400,
                                                                                                                    )
                                                                                                                  : SizedBox(
                                                                                                                      height: 0,
                                                                                                                    ),
                                                                                                              Padding(
                                                                                                                padding: EdgeInsets.only(top: 5.sp),
                                                                                                                child: AppText(
                                                                                                                  text: "Shipping Cost: \u{20B9} ${value.orderList[index]["estimated_delivery_by"]["shipping_cost"]}",
                                                                                                                  color: widget.backgroundcolor == whiteColor ? subtitleColor : productSubtitleColor,
                                                                                                                  fontSize: 12,
                                                                                                                  fontFamily: "Franklin Gothic Regular",
                                                                                                                  fontWeight: FontWeight.w400,
                                                                                                                ),
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
                                                                                              : value.orderList[index]["estimated_delivery_by"] != null
                                                                                                  ? Padding(
                                                                                                      padding: EdgeInsets.only(top: 2.sp),
                                                                                                      child: Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          AppText(
                                                                                                            text: value.orderList[index]["estimated_delivery_by"]["message"],
                                                                                                            color: widget.backgroundcolor == whiteColor ? subtitleColor : productSubtitleColor,
                                                                                                            fontSize: 12,
                                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                                            fontWeight: FontWeight.w400,
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    )
                                                                                                  : SizedBox(
                                                                                                      height: 0,
                                                                                                    ),
                                                                                          value.orderList[index]["express_delivery"]
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
                                                                                                        color: widget.backgroundcolor == whiteColor ? blackColor : whiteColor,
                                                                                                        fontSize: 12,
                                                                                                      ),
                                                                                                      /*  value.selected[index]
                                                                                                  ? Padding(
                                                                                                      padding: EdgeInsets.only(left: 12.sp),
                                                                                                      child: Center(
                                                                                                        child: SizedBox(
                                                                                                          height: 16.sp,
                                                                                                          width: 16.sp,
                                                                                                          child: Center(child: CircularProgressIndicator()),
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                                  : Padding(
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
                                                                                                            value: value.orderList[index]["express_delivery"],
                                                                                                            checkColor: btnTextColor,
                                                                                                            activeColor: whiteBorderColor,
                                                                                                            side: const BorderSide(color: btnTextColor, width: 0),
                                                                                                            onChanged: (value) {
                                                                                                              controller.selected[index] = !controller.selected[index];
                                                                                                              controller.update();
                                                                                                              controller.callAddtoCart(controller.orderList[index]["quantity"], "express", controller.orderList[index]["inventory"]["id"], controller.orderList[index]["product"]["id"], controller.orderList[index]["express_delivery"] ? 0 : 1, 1);
                                                                                                            },
                                                                                                          )),
                                                                                                    ), */
                                                                                                    ],
                                                                                                  ),
                                                                                                )
                                                                                              : SizedBox(
                                                                                                  height: 0,
                                                                                                ), */
                                                                                Opacity(
                                                                                  opacity: value.orderList[index]["product"]["total_stock_count"] == 0 ? 0.5 : 1,
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.symmetric(vertical: 4.sp),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        value.orderList[index]["inventory"] != null
                                                                                            ? value.orderList[index]["inventory"]["product_matrix_name_size"] != ""
                                                                                                ? GestureDetector(
                                                                                                    onTap: () async {
                                                                                                      if (value.orderList[index]["product"]["total_stock_count"] != 0) {
                                                                                                        showModalBottomSheet(
                                                                                                          context: context,
                                                                                                          isScrollControlled: true,
                                                                                                          constraints: BoxConstraints(
                                                                                                            maxWidth: double.infinity,
                                                                                                            maxHeight: 230.sp,
                                                                                                          ),
                                                                                                          builder: (ctx) {
                                                                                                            return BottomSize(
                                                                                                              onPressedCross: () {
                                                                                                                Get.back();
                                                                                                              },
                                                                                                              sizeList: value.orderList[index]["product"]["new_inventories"],
                                                                                                              controller: controller,
                                                                                                              onPressed: (p0) {
                                                                                                                controller.callAddtoCart(value.orderList[index]["quantity"] ?? 1, "size", p0, value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0, 1);
                                                                                                              },
                                                                                                              selectedSizeId: value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["id"] : 0,
                                                                                                            );
                                                                                                          },
                                                                                                        );
                                                                                                        await analytics.logEvent(
                                                                                                          name: 'cart_product_updatesizeClick',
                                                                                                          parameters: <String, Object>{
                                                                                                            'page_name': 'cart_product_updatesizeClick',
                                                                                                          },
                                                                                                        );
                                                                                                      }
                                                                                                    },
                                                                                                    child: Container(
                                                                                                      decoration: BoxDecoration(color: Color(0xffF3F4F6), border: Border.all(width: 1, color: Color(0xFFE5E7EB))),
                                                                                                      height: 30.sp,
                                                                                                      width: 85.sp,
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.only(left: 8.sp, right: 5.sp, top: 5.sp, bottom: 5.sp),
                                                                                                            child: AppText(
                                                                                                              //  text: "Size : XXXL",
                                                                                                              text: "Size : ${value.orderList[index]["inventory"] != null ? value.orderList[index]["inventory"]["product_matrix_name_size"] : ""}",
                                                                                                              color: titleColor,
                                                                                                              fontSize: 10,
                                                                                                              fontFamily: "Franklin Gothic Regular",
                                                                                                              fontWeight: FontWeight.w400,
                                                                                                            ),
                                                                                                          ),
                                                                                                          ImageIcon(
                                                                                                            AssetImage(dropdownImage),
                                                                                                            color: nameText,
                                                                                                            size: 14.sp,
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                : const SizedBox(
                                                                                                    height: 0,
                                                                                                  )
                                                                                            : const SizedBox(
                                                                                                height: 0,
                                                                                              ),
                                                                                        GestureDetector(
                                                                                          onTap: () async {
                                                                                            if (value.orderList[index]["product"]["total_stock_count"] != 0) {
                                                                                              if (value.orderList[index]["product"]["express_delivery"]) {
                                                                                                value.qtyProductId.value = value.orderList[index]["product"]["id"];
                                                                                                value.qtyText.value = "For express delivery product, quantity cant be updated.";
                                                                                                value.update();
                                                                                              } else {
                                                                                                showModalBottomSheet(
                                                                                                  context: context,
                                                                                                  isScrollControlled: true,
                                                                                                  constraints: BoxConstraints(
                                                                                                    maxWidth: double.infinity,
                                                                                                    maxHeight: 230.sp,
                                                                                                  ),
                                                                                                  builder: (ctx) {
                                                                                                    return BottomQuantity(
                                                                                                      qtyList: qtyList,
                                                                                                      selectedQty: value.orderList[index]["quantity"].toString(),
                                                                                                      controller: controller,
                                                                                                      stock: value.orderList[index]["inventory"]["stocks"] > 10 ? qtyList.length : value.orderList[index]["inventory"]["stocks"],
                                                                                                      onPressed: (p0) {
                                                                                                        controller.callAddtoCart(p0, "quantity", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0, 1);
                                                                                                      },
                                                                                                    );
                                                                                                  },
                                                                                                );
                                                                                                await analytics.logEvent(
                                                                                                  name: 'cart_product_updateqtyClick',
                                                                                                  parameters: <String, Object>{
                                                                                                    'page_name': 'cart_product_updateqtyClick',
                                                                                                  },
                                                                                                );
                                                                                                controller.qtyProductId.value = 0;
                                                                                                controller.qtyText.value = "";
                                                                                                value.update();
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.only(left: 10.sp, top: 5.sp, bottom: 5.sp),
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(color: Color(0xffF3F4F6), border: Border.all(width: 1, color: Color(0xFFE5E7EB))),
                                                                                              height: 30.sp,
                                                                                              width: 85.sp,
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 8.sp),
                                                                                                    child: AppText(
                                                                                                      text: "Qty : ${value.orderList[index]["quantity"] ?? "0"}",
                                                                                                      color: titleColor,
                                                                                                      fontSize: 10,
                                                                                                      fontFamily: "Franklin Gothic Regular",
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                  ),
                                                                                                  ImageIcon(
                                                                                                    AssetImage(dropdownImage),
                                                                                                    color: nameText,
                                                                                                    size: 14.sp,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                value.orderList[index]["product"]["id"] == value.qtyProductId.value
                                                                                    ? Container(
                                                                                        width: MediaQuery.of(context).size.width - 165.sp,
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                                                          child: AppText(
                                                                                            text: value.qtyText.value,
                                                                                            color: deepRed,
                                                                                            fontSize: 12,
                                                                                            maxLines: 3,
                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                            fontWeight: FontWeight.w400,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox(
                                                                                        height: 0,
                                                                                      ),
                                                                                Opacity(
                                                                                  opacity: value.orderList[index]["product"]["total_stock_count"] == 0 ? 0.5 : 1,
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.symmetric(vertical: 4.sp),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Visibility(
                                                                                          visible: value.orderList[index]["product"]["mrp"] == null || value.orderList[index]["product"]["mrp"] == value.orderList[index]["product"]["price"] ? false : true,
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.only(right: 10.sp),
                                                                                            child: Text(
                                                                                              "\u{20B9} ${value.orderList[index]["product"]["mrp"] ?? "0"}",
                                                                                              style: TextStyle(
                                                                                                color: widget.backgroundcolor == whiteColor ? lightText : searchTextColor,
                                                                                                fontSize: 12.sp,
                                                                                                decoration: TextDecoration.lineThrough,
                                                                                                fontFamily: "Franklin Gothic",
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(right: 6.sp),
                                                                                          child: Text(
                                                                                            "\u{20B9} ${value.orderList[index]["product"]["price"] ?? "0"}",
                                                                                            style: TextStyle(
                                                                                              color: widget.backgroundcolor == whiteColor ? nameText : whiteColor,
                                                                                              fontSize: 12.sp,
                                                                                              fontFamily: "Franklin Gothic",
                                                                                              fontWeight: FontWeight.w500,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Visibility(
                                                                                          visible: value.orderList[index]["product"]["discount_percentage"] == "0.00%" ? false : true,
                                                                                          child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                              color: Color(0xffA7F3D0),
                                                                                              borderRadius: BorderRadius.all(Radius.circular(20.sp)),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.only(left: 10.sp, right: 10.sp, top: 4.sp, bottom: 4.sp),
                                                                                              child: Text(
                                                                                                "${value.orderList[index]["product"]["discount_percentage"] ?? "0 %"} OFF",
                                                                                                style: TextStyle(
                                                                                                  color: homeAppBarColor,
                                                                                                  fontSize: 12.sp,
                                                                                                  fontFamily: "Franklin Gothic",
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                /*  value.orderList[index]["estimated_delivery_by"] != null
                                                                                          ? Container(
                                                                                              width: MediaQuery.of(context).size.width - 165.sp,
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                                                                child: AppText(
                                                                                                  text: "${value.orderList[index]["estimated_delivery_by"]["message"]}",
                                                                                                  color: subtitleColor,
                                                                                                  fontSize: 12,
                                                                                                  maxLines: 3,
                                                                                                  fontFamily: "Franklin Gothic Regular",
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : SizedBox(
                                                                                              height: 0,
                                                                                            ), */
                                                                              ],
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
                                                                                        value.callAddtoCart(0, "remove", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0, 1);
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
                                                                              color: Colors.transparent,
                                                                              child: Padding(padding: EdgeInsets.symmetric(horizontal: 4.sp, vertical: 4.sp), child: SvgPicture.asset(crossSearchImage, color: widget.backgroundcolor == whiteColor ? homeAppBarColor : whiteColor, height: 9.sp, width: 9.sp, fit: BoxFit.cover)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Visibility(
                                                                        visible: value.orderList[index]["product"]["total_stock_count"] ==
                                                                                0
                                                                            ? true
                                                                            : false,
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              vertical: 8.sp,
                                                                              horizontal: 16.sp),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Out of Stock".toUpperCase(),
                                                                            color:
                                                                                redColor,
                                                                            fontSize:
                                                                                10,
                                                                            maxLines:
                                                                                1,
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Visibility(
                                                                        visible: value.orderList[index]["product"]["total_stock_count"] ==
                                                                                0
                                                                            ? true
                                                                            : false,
                                                                        child:
                                                                            DoubleIconButton(
                                                                          firstText:
                                                                              "REMOVE",
                                                                          secondText:
                                                                              "WISHLIST",
                                                                          firstTextColor:
                                                                              homeAppBarColor,
                                                                          secondTextColor:
                                                                              whiteColor,
                                                                          firstBackgroundColor:
                                                                              whiteColor,
                                                                          secondBackgroundColor:
                                                                              homeAppBarColor,
                                                                          firstBorderColor:
                                                                              homeAppBarColor,
                                                                          secondBorderColor: widget.backgroundcolor == whiteColor
                                                                              ? homeAppBarColor
                                                                              : lightPurpleColor,
                                                                          firstIcon:
                                                                              crossSearchImage,
                                                                          secondIcon: value.orderList[index]["product"]["wishlisted"]
                                                                              ? redHeartSvgImage
                                                                              : heartSvgImage,
                                                                          onPressedFirst:
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
                                                                                      value.callAddtoCart(0, "remove", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0, 1);
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
                                                                          onPressedSecond:
                                                                              () async {
                                                                            if (value.orderList[index]["product"]["wishlisted"]) {
                                                                              wishlistController.callAddProductToWishlist(value.orderList[index]["product"]["wishlist_id"], value.orderList[index]["product"]["id"]);
                                                                              controller.getCartData();
                                                                              await analytics.logEvent(
                                                                                name: 'cart_wishlist_remove',
                                                                                parameters: <String, Object>{
                                                                                  'page_name': 'productdetails_wishlist_remove',
                                                                                },
                                                                              );
                                                                            } else {
                                                                              scaffoldKey.currentState?.showBottomSheet((context) => BottomWishlist(
                                                                                  controller: wishlistController,
                                                                                  onPressedBoard: () {
                                                                                    Navigator.of(context)
                                                                                        .push(MaterialPageRoute(
                                                                                            builder: (BuildContext context) => NewBoardScreen(
                                                                                                  title: "New Board",
                                                                                                  boardId: 0,
                                                                                                  screen: "Bag",
                                                                                                  productId: value.orderList[index]["product"]["id"],
                                                                                                  hintName: "Name of the Board",
                                                                                                  boardName: "",
                                                                                                  btnText: "Next",
                                                                                                )))
                                                                                        .then(
                                                                                          (value) {},
                                                                                        );
                                                                                  },
                                                                                  productImage: value.orderList[index]["product"]["images"][0]["name"],
                                                                                  onPressed: (p0) {
                                                                                    wishlistController.callAddProductToWishlist(p0, value.orderList[index]["product"]["id"]);
                                                                                    value.callAddtoCart(0, "wishlist", value.orderList[index]["inventory"]["id"], value.orderList[index]["product"]["id"], value.orderList[index]["product"]["express_delivery"] ? 1 : 0, 1);
                                                                                  },
                                                                                  wishlistList: wishlistController.wishlistList));
                                                                              await analytics.logEvent(
                                                                                name: 'cart_wishlist_add',
                                                                                parameters: <String, Object>{
                                                                                  'page_name': 'productdetails_wishlist_add',
                                                                                },
                                                                              );
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 8.sp),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          color: widget.backgroundcolor == whiteColor
                                                                              ? colorSecondary
                                                                              : titleColor,
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
                                              /*  productController.isProduct.value
                                                    ? const DummyProductList(
                                                        text: "You may also like")
                                                    : productController
                                                            .productList.isNotEmpty
                                                        ? Container(
                                                            color: whiteBack,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              24.sp,
                                                                          left: 16
                                                                              .sp),
                                                                  child: AppText(
                                                                    text:
                                                                        "You may also like",
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        colorPrimary,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              16.sp,
                                                                          vertical:
                                                                              10.sp),
                                                                  child: SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          310.sp,
                                                                      child: GetBuilder<
                                                                          ProductController>(
                                                                        builder: (value) => ListView.builder(
                                                                            shrinkWrap: true,
                                                                            primary: false,
                                                                            controller: productController.listController,
                                                                            physics: const BouncingScrollPhysics(),
                                                                            itemCount: value.productList.length,
                                                                            scrollDirection: Axis.horizontal,
                                                                            itemBuilder: (ctx, index) {
                                                                              return Column(
                                                                                children: [
                                                                                  GestureDetector(
                                                                                    onTap: () async {
                                                                                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.productList[index]["id"], brandName: value.productList[index]["brand_name"], type: "add"))).then((value) => setState(
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
                                                                                      await analytics.logEvent(
                                                                                        name: 'cart_youmay_product_details',
                                                                                        parameters: <String, Object>{
                                                                                          'page_name': 'cart_youmay_product_details',
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                    child: AnimatedContainer(
                                                                                      duration: const Duration(milliseconds: 300),
                                                                                      margin: EdgeInsets.only(right: 8.sp),
                                                                                      color: whiteColor,
                                                                                      width: 122.sp,
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                                                                                            child: AppText(
                                                                                              text: value.productList[index]["name"] ?? "",
                                                                                              color: nameText,
                                                                                              fontSize: 12,
                                                                                              maxLines: 1,
                                                                                              fontFamily: "Franklin Gothic",
                                                                                              fontWeight: FontWeight.w500,
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
                                                                                            child: AppText(
                                                                                              text: value.productList[index]["short_description"] ?? "",
                                                                                              color: nameText,
                                                                                              maxLines: 1,
                                                                                              fontSize: 11,
                                                                                              fontFamily: "Franklin Gothic Regular",
                                                                                              fontWeight: FontWeight.w400,
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: EdgeInsets.only(top: 10.sp, left: 10.sp, right: 1.sp),
                                                                                            child: Row(
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
                                                                                            padding: EdgeInsets.only(top: 10.sp),
                                                                                            child: getSmallButton(
                                                                                                label: "Add to bag",
                                                                                                fontSize: 12,
                                                                                                onPressed: () async {
                                                                                                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProductDetailsScreen(productId: value.productList[index]["id"], brandName: value.productList[index]["brand_name"], type: "add"))).then((value) => setState(
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
                                                          )
                                                        : SizedBox(
                                                            height: 0,
                                                          ),
                                                const SizedBox(
                                                  height: 8,
                                                ), */
                                              Container(
                                                color: widget.backgroundcolor,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16.sp,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /*  AppText(
                                                          text: "Coupons",
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: colorPrimary,
                                                          fontSize: 12,
                                                        ), */
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    10.sp),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color:
                                                                      borderColor,
                                                                  width: 1.sp),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1)),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp,
                                                                    vertical:
                                                                        6.sp),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: [
                                                                      Visibility(
                                                                        visible: controller.couponText.value ==
                                                                                "Apply Coupon"
                                                                            ? true
                                                                            : false,
                                                                        child:
                                                                            ImageIcon(
                                                                          AssetImage(
                                                                              coupanImage),
                                                                          color: widget.backgroundcolor == whiteColor
                                                                              ? titleColor
                                                                              : productSubtitleColor,
                                                                          size:
                                                                              22.sp,
                                                                        ),
                                                                      ),
                                                                      controller.couponText.value ==
                                                                              "Apply Coupon"
                                                                          ? Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 8.sp),
                                                                              child: AppText(
                                                                                text: controller.couponText.value,
                                                                                fontFamily: "Franklin Gothic Regular",
                                                                                fontWeight: FontWeight.w500,
                                                                                color: widget.backgroundcolor == whiteColor ? titleColor : productSubtitleColor,
                                                                                fontSize: 14,
                                                                              ),
                                                                            )
                                                                          : Container(
                                                                              color: Color(0xffD1FAE5),
                                                                              child: DottedBorder(
                                                                                borderType: BorderType.RRect,
                                                                                dashPattern: [
                                                                                  5,
                                                                                  5
                                                                                ],
                                                                                color: Color(0xff10B981),
                                                                                strokeWidth: 1,
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.symmetric(vertical: 6.sp, horizontal: 8.sp),
                                                                                  child: AppText(
                                                                                    text: controller.couponText.value.toUpperCase(),
                                                                                    fontFamily: "Franklin Gothic",
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: titleColor,
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                      Visibility(
                                                                        visible: controller.couponText.value ==
                                                                                "Apply Coupon"
                                                                            ? false
                                                                            : true,
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              vertical: 2.sp,
                                                                              horizontal: 10.sp),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Saved ₹${controller.couponSave.value}",
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color:
                                                                                Color(0xff059669),
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  child:
                                                                      SizedBox(
                                                                    height: 0,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await analytics
                                                                        .logEvent(
                                                                      name:
                                                                          'cart_page_applycouponclick',
                                                                      parameters: <String,
                                                                          Object>{
                                                                        'page_name':
                                                                            'cart_page_applycouponclick',
                                                                      },
                                                                    );
                                                                    if (controller
                                                                            .cartDetails["discount"] !=
                                                                        null) {
                                                                      controller
                                                                          .callRemoveCoupon();
                                                                    } else {
                                                                      controller
                                                                          .getCouponData();
                                                                    }
                                                                  },
                                                                  child: controller
                                                                          .isRemoveCoupan
                                                                          .value
                                                                      ? SizedBox(
                                                                          height:
                                                                              10.sp,
                                                                          width:
                                                                              10.sp,
                                                                          child:
                                                                              Center(child: CircularProgressIndicator()),
                                                                        )
                                                                      : controller.cartDetails["discount"] !=
                                                                              null
                                                                          ? AppText(
                                                                              text: "Remove".toUpperCase(),
                                                                              fontFamily: "Franklin Gothic",
                                                                              fontWeight: FontWeight.w500,
                                                                              color: redColor,
                                                                              fontSize: 10,
                                                                            )
                                                                          : Container(
                                                                              width: 80.sp,
                                                                              height: 30.sp,
                                                                              decoration: BoxDecoration(
                                                                                color: homeAppBarColor,
                                                                                border: Border.all(color: btnTextColor, width: 1.sp),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 0.sp),
                                                                                child: Center(
                                                                                  child: AppText(
                                                                                    text: "Select".toUpperCase(),
                                                                                    color: whiteColor,
                                                                                    fontSize: 12,
                                                                                    fontFamily: "Franklin Gothic",
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                ),
                                                                              ),
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 40.sp),
                                                        child: AppText(
                                                          text: "order Details"
                                                              .toUpperCase(),
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: widget
                                                                      .backgroundcolor ==
                                                                  whiteColor
                                                              ? homeAppBarColor
                                                              : whiteColor,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    10.sp),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          color: colorSecondary,
                                                          height: 1.sp,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.sp),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          4.sp),
                                                              child: AppText(
                                                                text:
                                                                    "Total Price",
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: widget
                                                                            .backgroundcolor ==
                                                                        whiteColor
                                                                    ? subtitleColor
                                                                    : productSubtitleColor,
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
                                                                  "\u{20B9}${controller.cartDetails["total_mrp"] ?? "0"}",
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: widget
                                                                          .backgroundcolor ==
                                                                      whiteColor
                                                                  ? homeAppBarColor
                                                                  : whiteColor,
                                                              fontSize: 12,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      /*  controller.cartDetails[
                                                                    "express_delivery_charges"] ==
                                                                "0.00"
                                                            ? SizedBox(
                                                                height: 0,
                                                              )
                                                            : Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                        top: 10.sp),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              right:
                                                                                  4.sp),
                                                                      child:
                                                                          AppText(
                                                                        text: "Express Delivery Charges"
                                                                            .toUpperCase(),
                                                                        fontFamily:
                                                                            "Franklin Gothic Regular",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color:
                                                                            subtitleColor,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                    const Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height: 0,
                                                                      ),
                                                                    ),
                                                                    AppText(
                                                                      text:
                                                                          "\u{20B9} ${controller.cartDetails["express_delivery_charges"] ?? "0"}",
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color:
                                                                          homeAppBarColor,
                                                                      fontSize: 12,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                        */
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 12.sp),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          4.sp),
                                                              child: AppText(
                                                                text:
                                                                    "Delivery Charges",
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: widget
                                                                            .backgroundcolor ==
                                                                        whiteColor
                                                                    ? subtitleColor
                                                                    : productSubtitleColor,
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
                                                                  "\u{20B9}${double.parse(controller.cartDetails["shipping_cost"]) + double.parse(controller.cartDetails["express_delivery_charges"])}",
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: widget
                                                                          .backgroundcolor ==
                                                                      whiteColor
                                                                  ? homeAppBarColor
                                                                  : whiteColor,
                                                              fontSize: 12,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      /*    Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                      top: 12.sp),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            right: 4
                                                                                .sp),
                                                                    child: AppText(
                                                                      text:
                                                                          "Discount on MRP",
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color:
                                                                          subtitleColor,
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
                                                                        "\u{20B9}${controller.cartDetails["discount_on_mrp"] ?? "0"}",
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        greenText,
                                                                    fontSize: 12,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            */
                                                      controller.cartDetails[
                                                                  "coupon_discount"] ==
                                                              "0.00"
                                                          ? SizedBox(
                                                              height: 0,
                                                            )
                                                          : Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 12
                                                                          .sp),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right: 4
                                                                            .sp),
                                                                    child:
                                                                        AppText(
                                                                      text:
                                                                          "Coupon Discount",
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: widget.backgroundcolor ==
                                                                              whiteColor
                                                                          ? subtitleColor
                                                                          : productSubtitleColor,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                  const Expanded(
                                                                    child:
                                                                        SizedBox(
                                                                      height: 0,
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.to(
                                                                          BottomCoupon(
                                                                        list: controller
                                                                            .couponList,
                                                                        onPressed:
                                                                            (p0) {
                                                                          controller
                                                                              .couponText
                                                                              .value = p0;
                                                                          controller.callAddCoupon(
                                                                              p0,
                                                                              "cart");
                                                                        },
                                                                      ));
                                                                    },
                                                                    child:
                                                                        AppText(
                                                                      text: controller.cartDetails["discount"] !=
                                                                              null
                                                                          ? "\u{20B9} ${controller.cartDetails["coupon_discount"] ?? "0"}"
                                                                          : "Apply Coupon",
                                                                      fontFamily:
                                                                          "Franklin Gothic",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: controller.cartDetails["discount"] !=
                                                                              null
                                                                          ? widget.backgroundcolor ==
                                                                                  whiteColor
                                                                              ? homeAppBarColor
                                                                              : whiteColor
                                                                          : Color(
                                                                              0xff7A6ECC),
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                      /*  Padding(
                                                          padding: EdgeInsets.only(
                                                              top: 10.sp),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize.max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                        right:
                                                                            4.sp),
                                                                child: AppText(
                                                                  text:
                                                                      "Service tax",
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
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
                                                                    "\u{20B9} ${controller.cartDetails["lafetch_service_tax"].toString()}",
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
                                                        */
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 12.sp),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              4.sp),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Convenience Fee",
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: widget.backgroundcolor ==
                                                                            whiteColor
                                                                        ? subtitleColor
                                                                        : productSubtitleColor,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      isScrollControlled:
                                                                          true,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth:
                                                                            double.infinity,
                                                                        maxHeight:
                                                                            220.sp,
                                                                      ),
                                                                      builder:
                                                                          (ctx) {
                                                                        return BottomCharges(
                                                                          text:
                                                                              "This fee covers the costs of our convenient online shopping services, including secure payment processing, 24/7 customer support, and fast order processing. It helps us offer you a hassle-free shopping experience from the comfort of your home.",
                                                                          title:
                                                                              "Convenience Fee",
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Image.asset(
                                                                      shipIcon,
                                                                      height:
                                                                          18.sp,
                                                                      width:
                                                                          18.sp,
                                                                      fit: BoxFit
                                                                          .contain),
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
                                                                  "\u{20B9}${controller.cartDetails["convenience_fee"] ?? "Free"}",
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: widget
                                                                          .backgroundcolor ==
                                                                      whiteColor
                                                                  ? homeAppBarColor
                                                                  : whiteColor,
                                                              fontSize: 12,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 12.sp),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              4.sp),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Tax & Charges",
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: widget.backgroundcolor ==
                                                                            whiteColor
                                                                        ? subtitleColor
                                                                        : productSubtitleColor,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      isScrollControlled:
                                                                          true,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth:
                                                                            double.infinity,
                                                                        maxHeight:
                                                                            220.sp,
                                                                      ),
                                                                      builder:
                                                                          (ctx) {
                                                                        return BottomCharges(
                                                                          text:
                                                                              "This amount includes applicable sales tax and any additional charges required by local regulations. The exact breakdown may vary based on your location and the items in your cart.",
                                                                          title:
                                                                              "Tax & Charges",
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Image.asset(
                                                                      shipIcon,
                                                                      height:
                                                                          18.sp,
                                                                      width:
                                                                          18.sp,
                                                                      fit: BoxFit
                                                                          .cover),
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
                                                                  "\u{20B9}${controller.cartDetails["total_tax"].toString()}",
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: widget
                                                                          .backgroundcolor ==
                                                                      whiteColor
                                                                  ? homeAppBarColor
                                                                  : whiteColor,
                                                              fontSize: 12,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    10.sp),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          color: colorSecondary,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 0.sp),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          4.sp),
                                                              child: AppText(
                                                                text:
                                                                    "BILL TOTAL",
                                                                fontFamily:
                                                                    "Franklin Gothic",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: widget
                                                                            .backgroundcolor ==
                                                                        whiteColor
                                                                    ? colorPrimary
                                                                    : whiteColor,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            const Expanded(
                                                              child: SizedBox(
                                                                height: 0,
                                                              ),
                                                            ),
                                                            AppText(
                                                              text:
                                                                  "\u{20B9}${controller.cartDetails["total"] ?? "0"}",
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: widget
                                                                          .backgroundcolor ==
                                                                      whiteColor
                                                                  ? colorPrimary
                                                                  : whiteColor,
                                                              fontSize: 12,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 30.sp,
                                                      ),
                                                      Cartbottom(
                                                        backgroundColor: widget
                                                            .backgroundcolor,
                                                      ),
                                                      SizedBox(
                                                        height: 40.sp,
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
                                        ],
                                      ),
                      ),
                    ],
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
                      ? /* Container(
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
                                            context,
                                            controller.cartDetails["shipping_cost"],
                                            controller
                                                .cartDetails["lafetch_service_tax"]
                                                .toString());
                                      } else {
                                        controller.callInitiatePayment(
                                            0,
                                            context,
                                            controller.cartDetails["shipping_cost"],
                                            controller
                                                .cartDetails["lafetch_service_tax"]
                                                .toString());
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
                        ) */
                      Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (controller.cartDetails["address"] == null) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MapScreen(
                                                addressId: 0,
                                                cartId: controller
                                                    .cartDetails["id"],
                                              )))
                                      .then((value) => setState(
                                            () {
                                              widget.backgroundcolor ==
                                                      whiteColor
                                                  ? controller.getCartData()
                                                  : controller
                                                      .getExpressCartData();
                                            },
                                          ));
                                } else {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ChangeAddressScreen(
                                                cartId: controller
                                                    .cartDetails["id"],
                                              )))
                                      .then((value) => setState(
                                            () {
                                              widget.backgroundcolor ==
                                                      whiteColor
                                                  ? controller.getCartData()
                                                  : controller
                                                      .getExpressCartData();
                                            },
                                          ));
                                  await analytics.logEvent(
                                    name: 'checkoutPage_changeAddressclick',
                                    parameters: <String, Object>{
                                      'page_name':
                                          'checkoutPage_changeAddressclick',
                                    },
                                  );
                                }
                              },
                              child: Container(
                                color: widget.backgroundcolor == whiteColor
                                    ? lightgreyColor
                                    : homeAppBarColor,
                                margin: EdgeInsets.only(top: 10.sp),
                                height: 40.sp,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.sp),
                                  child: Row(
                                    children: [
                                      Obx(() => controller.isOrder.value
                                          ? DummyContainer(
                                              height: 10,
                                              width: 100,
                                            )
                                          : Text(
                                              controller.cartDetails[
                                                          "address"] ==
                                                      null
                                                  ? "Select Shipping Address"
                                                  : "delivering in, ${controller.cartDetails["address"]["type"].toString()} ${controller.cartDetails["address"]["zip"].toString()}"
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? titleColor
                                                    : lightgreyColor,
                                                fontSize: 14.sp,
                                              ),
                                            )),
                                      Expanded(
                                        child: SizedBox(
                                          height: 0,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 2.sp, right: 5.sp),
                                        child: Image.asset(rightArrowImage,
                                            color: widget.backgroundcolor ==
                                                    whiteColor
                                                ? titleColor
                                                : lightgreyColor,
                                            height: 16.sp,
                                            width: 16.sp,
                                            fit: BoxFit.cover),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                /*  controller.mrp.value =
                                    controller.cartDetails["total_mrp"] ?? "";
                                controller.expressDelivery.value = controller
                                        .cartDetails["express_delivery_charges"] ??
                                    "";
                                controller.discount.value = controller
                                    .cartDetails["discount_on_mrp"]
                                    .toString();
                                controller.coupanDiscount.value =
                                    controller.cartDetails["coupon_discount"] ?? "";
                                controller.convenienceFee.value = controller
                                    .cartDetails["convenience_fee"]
                                    .toString();
                                controller.tax.value =
                                    controller.cartDetails["total_tax"].toString();
                                controller.total.value =
                                    controller.cartDetails["total"].toString(); */
                                if (controller.cartDetails["address"] == null) {
                                  getSnackBar("Add Delivery Address");
                                } else {
                                  /*  controller.callInitiatePayment(
                                      0,
                                      context,
                                      controller.cartDetails["shipping_cost"],
                                      controller.cartDetails["lafetch_service_tax"]
                                          .toString()); */
                                  controller.callInitiatePayment(
                                      controller.cartDetails["address"]["id"],
                                      razorpay);
                                }
                                await analytics.logEvent(
                                  name: 'proceed_checkout_btnclick',
                                  parameters: <String, Object>{
                                    'page_name': 'proceed_checkout_btnclick',
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: widget.backgroundcolor == whiteColor
                                    ? 70.sp
                                    : 50.sp,
                                color: widget.backgroundcolor == whiteColor
                                    ? homeAppBarColor
                                    : lightPurpleColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 16.sp),
                                      child: Obx(() => controller.isOrder.value
                                          ? SizedBox(
                                              height: 0,
                                            )
                                          : Text(
                                              controller.cartDetails[
                                                          "address"] ==
                                                      null
                                                  ? "Proceed to checkout"
                                                      .toUpperCase()
                                                  : "Proceed to pay"
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      'Franklin Gothic'))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(height: 0))
            ],
          ),
        ],
      ),
    );
  }
}
