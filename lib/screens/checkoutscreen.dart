// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_estimatedelivery.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import 'package:lafetch/screens/change_address.dart';
import 'package:lafetch/screens/mapscreen.dart';
import 'package:lafetch/screens/paymentsuccessscreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/common_widgets.dart';
import '../commonwidget/singlebtn.dart';
import '../controller/cart_controller.dart';
import '../controller/order_controller.dart';
import '../utils/constants.dart';

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
  });

  @override
  State<CheckoutScreen> createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final controller = Get.put(CartController());
  final orderController = Get.put(OrderController());
  final shipController = Get.put(ShipAddressController());
  final Razorpay razorpay = Razorpay();
  final razorPayKey = "rzp_test_qByVM96GsY8Ydt";
  final razorPaySecret = "Mo5w1Av5SV84qO0c4k1Uc0Ob";

  @override
  void initState() {
    if (widget.addressId != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          shipController.getAddressDetails(widget.addressId, 1, widget.cartId));
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
    controller.callProcessPayment(widget.cartId, response.paymentId!,
        response.orderId!, response.signature!);
    // Do something when payment succeeds
  }

  void handlePaymentError(PaymentFailureResponse response) {
    print("Error ${response.message}");
    print("Error ${response.code}");
    print("Error ${response.error}");
    Get.to(const PaymentSuccessScreen(
        text1: "Payment Failed",
        text2: "Thank you for placing your order",
        image: paymentFailImage));
    // Do something when payment fails
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    print("Wallet ${response.walletName}");
    Get.to(const PaymentSuccessScreen(
        text1: "Uh-oh something went wrong!",
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
      body: Column(
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
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : shipController.addressDetails != null &&
                              shipController.addressDetails != ""
                          ? Container(
                              color: whiteColor,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 5),
                                            child: AppText(
                                              text: shipController
                                                      .addressDetails["name"] ??
                                                  "",
                                              color: loginText,
                                              fontSize: 16.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            width: 80,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: btnTextColor,
                                                  width: 1),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ChangeAddressScreen(
                                                              cartId:
                                                                  widget.cartId,
                                                            )))
                                                    .then((value) => setState(
                                                          () {},
                                                        ));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Center(
                                                  child: AppText(
                                                    text: "Change",
                                                    color: btnTextColor,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 2),
                                      child: AppText(
                                        text: shipController
                                                .addressDetails["address"] ??
                                            "",
                                        color: greyTextColor,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 2),
                                      child: AppText(
                                        text:
                                            "${shipController.addressDetails["locality"] ?? ""} ,${shipController.addressDetails["city"] != null ? shipController.addressDetails["city"]["name"] : ""}",
                                        color: greyTextColor,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 2),
                                      child: AppText(
                                        text: shipController
                                                .addressDetails["type"] ??
                                            "",
                                        color: loginText,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 2),
                                      child: AppText(
                                        text: shipController
                                            .addressDetails["zip"]
                                            .toString(),
                                        color: loginText,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
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
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: AppText(
                                                  text: "Shipping Address",
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: loginText,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16, top: 2),
                                                child: AppText(
                                                  text:
                                                      "Add a shipping address",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: greyTextColor,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 22),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  child: Container(
                                    width: double.infinity,
                                    color: colorSecondary,
                                    height: 1,
                                  ),
                                ),
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
                                    fontFamily: "Franklin Gothic",
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
                                    fontFamily: "Franklin Gothic Regular",
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
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 20),
                              child: AppText(
                                text: "Delivery Estimates",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: blackColor,
                                fontSize: 16.sp,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 5),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: shipController
                                      .estimateDeliveryList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 16, right: 16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(backImage,
                                                height: 60,
                                                width: 50,
                                                fit: BoxFit.cover),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16),
                                              child: AppText(
                                                text: " Estimated delivery :",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: blackColor,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            AppText(
                                              text: shipController
                                                      .estimateDeliveryList[
                                                  index]["estimated_delivery"],
                                              fontFamily:
                                                  "Franklin Gothic Bold",
                                              fontWeight: FontWeight.w700,
                                              color: blackColor,
                                              fontSize: 12.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        )),
                  Container(
                    color: whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
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
                                        fontFamily: "Franklin Gothic",
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
                                    AppText(
                                      text: "Apply",
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: AppText(
                              text: "Price Details",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: colorPrimary,
                              fontSize: 12.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              width: double.infinity,
                              color: colorSecondary,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Total MRP",
                                    fontFamily: "Franklin Gothic Regular",
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
                                  text: "\u{20B9} ${widget.mrp}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Express Delivery Charges",
                                    fontFamily: "Franklin Gothic Regular",
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
                                  text: "\u{20B9} ${widget.expressDelivery}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Discount on MRP",
                                    fontFamily: "Franklin Gothic Regular",
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
                                  text: "\u{20B9} ${widget.discount}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Coupon Discount",
                                    fontFamily: "Franklin Gothic Regular",
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
                                  text: "\u{20B9} ${widget.coupanDiscount}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: AppText(
                                        text: "Convenience Fee",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
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
                                  text: widget.convenienceFee,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: AppText(
                                        text: "Tax & Charges",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
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
                                  text: "\u{20B9} ${widget.tax}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              width: double.infinity,
                              color: colorSecondary,
                              height: 1.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
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
                                  text: "\u{20B9} ${widget.total}",
                                  fontFamily: "Franklin Gothic Bold",
                                  fontWeight: FontWeight.w700,
                                  color: colorPrimary,
                                  fontSize: 18.sp,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
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
                  ),
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
                  padding: const EdgeInsets.only(
                      top: 30, left: 20, right: 8, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "INR ${widget.amount}",
                        textAlign: TextAlign.center,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        fontSize: 16.sp,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      AppText(
                        text: "View details",
                        textAlign: TextAlign.center,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontSize: 12.sp,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 16),
                    child: SingleButton(
                        label: "Pay Now",
                        textColor: whiteColor,
                        backgroundColor: colorPrimary,
                        onPressed: () {
                          if (shipController.addressId.value != 0) {
                            var options = {
                              'key': razorPayKey,
                              'amount': double.parse(widget.amount) * 100,
                              'name': 'Lafetch',
                              'order_id': widget.orderId,
                              'description': 'Lafetch Customer',
                              'timeout': 60,
                              'prefill': {
                                'contact': '9002973232',
                                'email': 'sonamagrahari11@gmail.com'
                              }
                            };
                            razorpay.open(options);
                          } else {
                            getSnackBar("Add Address");
                          }
                        },
                        borderColor: colorPrimary),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
