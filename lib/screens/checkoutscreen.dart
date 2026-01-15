// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/change_address.dart';
import 'package:lafetch/screens/mapscreen.dart';
import 'package:lafetch/screens/paymentsuccessscreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../common/widget/appbar/backbutton_appbar.dart';
import '../common/widget/lists/dummy_estimatedelivery.dart';
import '../common/widget/lists/dummy_saveaddress.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/shipaddress_controller.dart';
import '../core/constant/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  final String amount;
  final int cartId;
  final String mrp;
  final String expressDelivery;
  final String discount;
  final String coupanDiscount;
  final String convenienceFee;
  final String tax;
  final int addressId;
  final String total;
  final String ShipCost;
  final String lafetchtax;

  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.cartId,
    required this.mrp,
    required this.expressDelivery,
    required this.discount,
    required this.coupanDiscount,
    required this.convenienceFee,
    required this.tax,
    required this.addressId,
    required this.total,
    required this.lafetchtax,
    required this.ShipCost,
  });

  @override
  State<CheckoutScreen> createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final controller = Get.put(CartController());
  // final orderController = Get.put(OrderController());
  final shipController = Get.put(ShipAddressController());
  final Razorpay razorpay = Razorpay();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    if (widget.addressId != 0) {
      shipController.addressId.value = widget.addressId;
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          shipController.getAddressDetails(widget.addressId, 1, widget.cartId));
    } else {
      shipController.addressId.value = 0;
      shipController.addressDetails = "";
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    super.initState();
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    print("order id ${response.orderId}");
    print("payment id ${response.paymentId}");
    print("singature ${response.signature}");
    print("data ${response.data}");

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
        backgroundColor: whiteColor,
        body: Obx(
          () => controller.isPayment.value
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    BackButtonAppbar(
                      text: "Checkout",
                      threeDot: false,
                      icon: threeDotImage,
                      backgroundColor: whiteColor,
                      onPressedThreeDot: () {},
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() => shipController.isDetails.value
                                ? const DummySaveAddress(
                                    size: 1,
                                  )
                                : shipController.addressDetails != null &&
                                        shipController.addressDetails != ""
                                    ? Container(
                                        color: whiteColor,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 10.sp,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 14.sp,
                                                              vertical: 5.sp),
                                                      child: AppText(
                                                        text: shipController
                                                                    .addressDetails[
                                                                "name"] ??
                                                            "",
                                                        color: loginText,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            "Clash Display Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 14.sp,
                                                    ),
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      margin: EdgeInsets.only(
                                                          right: 5.sp),
                                                      width: 80.sp,
                                                      height: 20.sp,
                                                      decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20.sp),
                                                        border: Border.all(
                                                            color: btnTextColor,
                                                            width: 1.sp),
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          ChangeAddressScreen(
                                                                            cartId:
                                                                                widget.cartId,
                                                                          )))
                                                              .then((value) =>
                                                                  setState(
                                                                    () {},
                                                                  ));
                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'checkoutPage_changeAddressclick',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'checkoutPage_changeAddressclick',
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5.sp),
                                                          child: Center(
                                                            child: AppText(
                                                              text: "Change",
                                                              color:
                                                                  btnTextColor,
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  "Clash Display",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14.sp,
                                                    vertical: 2.sp),
                                                child: AppText(
                                                  text: shipController
                                                              .addressDetails[
                                                          "address"] ??
                                                      "",
                                                  color: greyTextColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14.sp,
                                                    vertical: 2.sp),
                                                child: AppText(
                                                  text:
                                                      "${shipController.addressDetails["locality"] ?? ""} ,${shipController.addressDetails["city"] != null ? shipController.addressDetails["city"]["name"] : ""}",
                                                  color: greyTextColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14.sp,
                                                    vertical: 2.sp),
                                                child: AppText(
                                                  text: shipController
                                                              .addressDetails[
                                                          "type"] ??
                                                      "",
                                                  color: loginText,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14.sp,
                                                    vertical: 2.sp),
                                                child: AppText(
                                                  text: shipController
                                                      .addressDetails["zip"]
                                                      .toString(),
                                                  color: loginText,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.sp),
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.to(MapScreen(
                                                  addressId: widget.addressId,
                                                  cartId: widget.cartId,
                                                ));
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      16.sp),
                                                          child: AppText(
                                                            text:
                                                                "Shipping Address",
                                                            fontFamily:
                                                                "Clash Display",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: loginText,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 16.sp,
                                                                  top: 2.sp),
                                                          child: AppText(
                                                            text:
                                                                "Add a shipping address",
                                                            fontFamily:
                                                                "Clash Display Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                greyTextColor,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 22.sp),
                                                    child: Image.asset(
                                                        rightArrowImage,
                                                        color: loginText,
                                                        height: 18.sp,
                                                        width: 18.sp,
                                                        fit: BoxFit.cover),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          /*  Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  child: Container(
                                    width: double.infinity,
                                    color: colorSecondary,
                                    height: 1,
                                  ),
                                ), */
                                        ],
                                      )),
                            /*   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        // Get.to(const PaymentScreen());
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: AppText(
                                    text: "Payment",
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                    color: loginText,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 2),
                                  child: AppText(
                                    text: "Select payment method",
                                    fontFamily: "Clash Display Regular",
                                    fontWeight: FontWeight.w400,
                                    color: greyTextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 22),
                            child: Image.asset(rightArrowImage,
                                color: loginText,
                                height: 18,
                                width: 18,
                                fit: BoxFit.cover),
                          )
                        ],
                      ),
                    ),
                  ),
                  */
                            /*  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      color: colorSecondary,
                      height: 1,
                    ),
                  ), */
                            Obx(() => shipController.isDelivery.value
                                ? const DummyEstimateDelivery()
                                : shipController.estimateDeliveryList.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 16.sp, top: 20.sp),
                                            child: AppText(
                                              text: "Delivery Estimates",
                                              fontFamily:
                                                  "Clash Display Regular",
                                              fontWeight: FontWeight.w400,
                                              color: blackColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 8.sp, top: 5.sp),
                                            child: ListView.builder(
                                                primary: false,
                                                shrinkWrap: true,
                                                physics: const ScrollPhysics(),
                                                itemCount: shipController
                                                    .estimateDeliveryList
                                                    .length,
                                                padding: EdgeInsets.zero,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder: (ctx, index) {
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.sp),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8.sp,
                                                          left: 16.sp,
                                                          right: 16.sp),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          shipController
                                                                      .estimateDeliveryList[
                                                                          index]
                                                                          [
                                                                          "image"]
                                                                      .isNotEmpty &&
                                                                  shipController
                                                                              .estimateDeliveryList[index]
                                                                          [
                                                                          "image"] !=
                                                                      null
                                                              ? SizedBox(
                                                                  height: 60.sp,
                                                                  width: 50.sp,
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
                                                                    imageUrl: isImage(shipController
                                                                                .estimateDeliveryList[index]["image"][0]
                                                                            [
                                                                            "name"])
                                                                        ? shipController.estimateDeliveryList[index]["image"][0]
                                                                            [
                                                                            "name"]
                                                                        : shipController.estimateDeliveryList[index]["image"][1]
                                                                            [
                                                                            "name"],
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      height:
                                                                          60.sp,
                                                                      width:
                                                                          50.sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  dummyWishlistImage,
                                                                  height: 60.sp,
                                                                  width: 50.sp,
                                                                  fit: BoxFit
                                                                      .cover),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left:
                                                                        16.sp),
                                                            child: AppText(
                                                              text:
                                                                  " Estimated delivery :",
                                                              fontFamily:
                                                                  "Clash Display Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: blackColor,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          AppText(
                                                            text: shipController
                                                                        .estimateDeliveryList[
                                                                    index][
                                                                "estimated_delivery"],
                                                            fontFamily:
                                                                "Clash Display Bold",
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: blackColor,
                                                            fontSize: 12,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(
                                        height: 0,
                                      )),
                            Container(
                              color: whiteColor,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.sp, vertical: 20.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /*      Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: borderColor, width: 1),
                                  borderRadius: BorderRadius.circular(1)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: AppText(
                                        text: "Have a gift card?",
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                        fontSize: 14.sp,
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
                                          name: 'checkoutPage_apply_gift',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'checkoutPage_apply_gift',
                                          },
                                        );
                                      },
                                      child: AppText(
                                        text: "Apply",
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        */
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.sp),
                                      child: AppText(
                                        text: "Price Details",
                                        fontFamily: "Clash Display Regular",
                                        fontWeight: FontWeight.w400,
                                        color: colorPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.sp),
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
                                            padding:
                                                EdgeInsets.only(right: 4.sp),
                                            child: AppText(
                                              text: "Total MRP",
                                              fontFamily:
                                                  "Clash Display Regular",
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
                                            text: "\u{20B9} ${widget.mrp}",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    widget.expressDelivery != "0.00"
                                        ? Padding(
                                            padding:
                                                EdgeInsets.only(top: 10.sp),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
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
                                                        "Clash Display Regular",
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
                                                      "\u{20B9} ${widget.expressDelivery}",
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.sp),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 4.sp),
                                            child: AppText(
                                              text: "Discount on MRP",
                                              fontFamily:
                                                  "Clash Display Regular",
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
                                            text: "\u{20B9} ${widget.discount}",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: lightPurpleColor,
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    widget.coupanDiscount != "0.00"
                                        ? Padding(
                                            padding:
                                                EdgeInsets.only(top: 10.sp),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 4.sp),
                                                  child: AppText(
                                                    text: "Coupon Discount",
                                                    fontFamily:
                                                        "Clash Display Regular",
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
                                                      "\u{20B9} ${widget.coupanDiscount}",
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: lightPurpleColor,
                                                  fontSize: 12,
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    widget.ShipCost != "0.00"
                                        ? Padding(
                                            padding:
                                                EdgeInsets.only(top: 10.sp),
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
                                                        "Clash Display Regular",
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
                                                      "\u{20B9} ${widget.ShipCost}",
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: lightPurpleColor,
                                                  fontSize: 12,
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.sp),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 4.sp),
                                            child: AppText(
                                              text: "Service tax",
                                              fontFamily:
                                                  "Clash Display Regular",
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
                                                "\u{20B9} ${widget.lafetchtax.toString()}",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: lightPurpleColor,
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
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Image.asset(questionIcon,
                                                  height: 16.sp,
                                                  width: 16.sp,
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
                                                "\u{20B9} ${widget.convenienceFee}",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: lightPurpleColor,
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
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Image.asset(questionIcon,
                                                  height: 16.sp,
                                                  width: 16.sp,
                                                  fit: BoxFit.cover)
                                            ],
                                          ),
                                          const Expanded(
                                            child: SizedBox(
                                              height: 0,
                                            ),
                                          ),
                                          AppText(
                                            text: "\u{20B9} ${widget.tax}",
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.sp),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1.5.sp,
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
                                            padding:
                                                EdgeInsets.only(right: 4.sp),
                                            child: AppText(
                                              text: "Bill total",
                                              fontFamily: "Clash Display",
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
                                            text: "\u{20B9} ${widget.total}",
                                            fontFamily: "Clash Display Bold",
                                            fontWeight: FontWeight.w700,
                                            color: colorPrimary,
                                            fontSize: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            /*   Container(
                    color: backWhite,
                    height: 34,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 6, bottom: 6),
                      child: Center(
                        child: AppText(
                          text:
                              "You will earn 100 LaFetch coins on this purchase",
                          fontFamily: "Clash Display Regular",
                          fontWeight: FontWeight.w400,
                          color: deepPurple,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ), */
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: whiteColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 30.sp,
                                left: 20.sp,
                                right: 8.sp,
                                bottom: 16.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "INR ${widget.amount}",
                                  textAlign: TextAlign.center,
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                  fontSize: 16,
                                ),
                                /* const SizedBox(
                        height: 2,
                      ),
                      AppText(
                        text: "View details",
                        textAlign: TextAlign.center,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: 12.sp,
                      ), */
                              ],
                            ),
                          ),
                          Obx(() => Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 30.sp, bottom: 16.sp),
                                  child: getSingleButton(
                                      label: "Pay Now",
                                      textColor: whiteColor,
                                      backgroundColor: colorPrimary,
                                      controller: controller,
                                      onPressed: () async {
                                        if (shipController.addressId.value !=
                                            0) {
                                          var options = {
                                            'key': ApiConstants.razorPayKey,
                                            'amount':
                                                double.parse(widget.amount) *
                                                    100,
                                            'name': 'Lafetch',
                                            'order_id': widget.orderId,
                                            'description': 'Lafetch Customer',
                                            'timeout': 60,
                                            'theme': {
                                              'color': '#070707',
                                            },
                                            'fullscreen': true,
                                          };
                                          razorpay.open(options);
                                        } else {
                                          getSnackBar("Add Address");
                                        }
                                        await analytics.logEvent(
                                          name: 'checkoutPage_btnpaynow',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'checkoutPage_btnpaynow',
                                          },
                                        );
                                      },
                                      borderColor: colorPrimary),
                                ),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
        ));
  }
}
