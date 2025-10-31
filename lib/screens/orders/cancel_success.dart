import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/orders/my_order.dart';

class CancelSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const CancelSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            arrowBack, // ✅ from const.dart
            height: 18,
            width: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "4F",
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 18,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            // ✅ Cancel illustration (centered)
            Image.asset(
              cancelorder, // from const.dart
              height: 200.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.sp),

            // ✅ Refund details section
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: "Refund Details",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 6.sp),
            const AppText(
              text:
                  "Refund will be processed to your original payment method within 2–5 business days.",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 30.sp),

            // ✅ Item cancelled section
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: "Item Cancelled",
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12.sp),

            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8.sp),
                border: Border.all(color: dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.sp),
                      child: _buildProductImage(order),
                    ),
                    SizedBox(width: 10.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text:
                                order['productName'] ?? 'The Clothing Factory',
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w700,
                            color: blackColor,
                            fontSize: 13,
                          ),
                          SizedBox(height: 2.sp),
                          AppText(
                            text: order['productDescription'] ??
                                "Garfield: Grumpy Printed Men’s Overs...",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            fontSize: 11,
                            maxLines: 2,
                          ),
                          SizedBox(height: 6.sp),
                          AppText(
                            text:
                                "Size: ${order['size'] ?? 'M'}   Qty: ${order['quantity'] ?? '1'}",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ✅ Back to orders button (flat white with border)
            GestureDetector(
              onTap: () => Get.to(MyOrdersScreen()),
              child: Container(
                width: double.infinity,
                height: 50.sp,
                decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: dividerColor, width: 1),
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: const Center(
                  child: AppText(
                    text: "BACK TO ORDERS",
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.sp),
          ],
        ),
      ),
    );
  }

  /// ✅ Safe Image Loader
  Widget _buildProductImage(Map<String, dynamic> order) {
    final imageUrl = order['imageUrl'];
    final isNetwork =
        imageUrl != null && imageUrl.toString().startsWith('http');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        height: 60.sp,
        width: 60.sp,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(dummyWishlistImage,
            height: 60.sp, width: 60.sp, fit: BoxFit.cover),
      );
    } else {
      return Image.asset(
        dummyWishlistImage,
        height: 70.sp,
        width: 70.sp,
        fit: BoxFit.cover,
      );
    }
  }
}
