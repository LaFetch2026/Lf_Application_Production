import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/appbar/productdetails_appbar.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/orders/my_order.dart';
import 'package:lafetch/screens/cartscreen.dart';

class OrderStatusScreen extends StatelessWidget {
  final String status; // 'success', 'failed', 'error'

  const OrderStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final content = _getContent(status);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.sp),
        child: ProductdetailsAppbar(
          dark: false,
          onPressedHeart: () => print('❤️ Heart pressed'),
          onPressedShare: () => print('🔗 Share pressed'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusImage(content["image"]),
              SizedBox(height: 30.sp),
              AppText(
                text: content["title"],
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
              if (content["subtitle"] != null) ...[
                SizedBox(height: 8.sp),
                AppText(
                  text: content["subtitle"],
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                  fontSize: 13,
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 40.sp),
              SizedBox(
                width: double.infinity,
                height: 50.sp,
                child: ElevatedButton(
                  onPressed: content["onTap"],
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: blackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.sp),
                    ),
                  ),
                  child: AppText(
                    text: content["buttonText"],
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w600,
                    color: whiteColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusImage(String imagePath) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(imagePath, width: 180.sp, height: 180.sp);
    } else {
      return Image.asset(imagePath, width: 180.sp, height: 180.sp);
    }
  }

  Map<String, dynamic> _getContent(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return {
          "image": paysuccess,
          "title": "ORDER PLACED SUCCESSFULLY",
          "subtitle": "Thank you for placing your order",
          "buttonText": "GO TO MY ORDERS",
          "onTap": () => Get.offAll(() => const MyOrdersScreen()),
        };
      case 'failed':
        return {
          "image": payfield,
          "title": "PAYMENT FAILED",
          "subtitle": null,
          "buttonText": "TRY AGAIN",
          "onTap": () => Get.back(),
        };
      default:
        return {
          "image": somethingwentwrong,
          "title": "UH-OH SOMETHING WENT WRONG!",
          "subtitle": null,
          "buttonText": "GO TO BAG",
          "onTap": () => Get.offAll(() => const CartScreen()),
        };
    }
  }
}
