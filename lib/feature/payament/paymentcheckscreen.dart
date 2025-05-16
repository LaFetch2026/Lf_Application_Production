// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/feature/payament/paymentsuccessscreen.dart';

import 'package:lottie/lottie.dart';

import '../../common/widget/appbar/shopwishlist_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/cart_controller.dart';
import '../../core/constant/constants.dart';
import '../order/orderdetailsscreen.dart';


class PaymentCheckScreen extends StatefulWidget {
  final int orderId;
  const PaymentCheckScreen({super.key, required this.orderId});

  @override
  State<PaymentCheckScreen> createState() => PaymentCheckScreenState();
}

class PaymentCheckScreenState extends State<PaymentCheckScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final cartController = Get.put(CartController());
  Timer? timer;
  int _elapsedTime = 0;
  static const int duration = 120; //for 2 minutes

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
    ));
    /*  timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        cartController.callPaymentStatus(widget.orderId, timer);
      });
    });
    timer = Timer.periodic(Duration(minutes: 2), (Timer timer) {
      Get.off(const PaymentSuccessScreen(
          text1: "Payment Failed",
          orderId: 0,
          text2: "",
          image: paymentFailImage));
      timer.cancel();
    }); */
    startTimer();
  }

  void startTimer() {
    _elapsedTime = 0; // Reset the elapsed time
    timer?.cancel(); // Cancel any existing timer

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_elapsedTime >= duration) {
        timer.cancel();
        Get.off(const PaymentSuccessScreen(
            text1: "Payment Failed",
            orderId: 0,
            text2: "",
            image: paymentFailImage));
        return;
      }

      _elapsedTime += 5;
      cartController.callPaymentStatus(widget.orderId, timer);
      print('Method executed at $_elapsedTime seconds');
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void stopTimer() {
    if (timer != null) {
      timer?.cancel();
      print("Timer stopped!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShopWishlistAppbar(
              hideIcon: false,
              onPressedCart: () async {},
              onPressedBackButton: () {},
              onPressedheart: () async {},
            ),
            Container(
              color: dividerColor,
              height: 1.sp,
            ),
            Padding(
              padding: EdgeInsets.only(top: 80.sp),
              child: Center(
                child: Lottie.asset(
                  width: 200.sp,
                  height: 200.sp,
                  fit: BoxFit.cover,
                  sandLoader,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.sp, left: 16.sp, right: 16.sp),
              child: AppText(
                text: "We are currently verifying your payment.",
                fontFamily: "Franklin Gothic Semibold",
                fontWeight: FontWeight.w500,
                color: homeAppBarColor,
                maxLines: 2,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.sp, left: 16.sp, right: 16.sp),
              child: AppText(
                text:
                "This may take upto 5 minutes to update! You can check your order status in the ${'"'}${"My Orders"}${'"'} section.\nFor any concerns, you can contact support for any assistance.",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: titleColor,
                maxLines: 15,
                fontSize: 12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.sp, bottom: 20.sp),
              child: getSingleButton(
                  width: double.infinity,
                  label: "View Order".toUpperCase(),
                  textColor: whiteColor,
                  fontSize: 13,
                  backgroundColor: homeAppBarColor,
                  onPressed: () async {
                    stopTimer();
                    // Get.close(1);
                    Get.off(OrderDetailsScreen(
                      orderId: widget.orderId,
                      showTrackpayment: true,
                    ));
                    await analytics.logEvent(
                      name: 'payment_btn_myorder',
                      parameters: <String, Object>{
                        'page_name': 'payment_btn_myorder',
                      },
                    );
                  },
                  borderColor: colorPrimary),
            )
          ],
        ),
      ),
    );
  }
}
