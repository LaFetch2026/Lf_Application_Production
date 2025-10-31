import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/orders/cancel_order.dart';

class ConfirmOrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const ConfirmOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            arrowBack, // ✅ Using constant from const.dart
            height: 18,
            width: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "ORDER DETAILS",
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6.sp),
              child: _buildProductImage(order),
            ),
            SizedBox(height: 12.sp),

            // Product Info
            AppText(
              text: order['productName'] ?? 'Product Name',
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: nameText,
              fontSize: 16,
            ),
            SizedBox(height: 4.sp),
            AppText(
              text: order['productDescription'] ?? 'Product description',
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 13,
            ),
            SizedBox(height: 6.sp),
            AppText(
              text:
                  "Size: ${order['size'] ?? 'M'}   Qty: ${order['quantity'] ?? '1'}",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),
            SizedBox(height: 12.sp),

            // Delivery Status
            AppText(
              text: order['statusSubtext'] ??
                  "Arriving by Tue, 28 Oct 2025", // dynamic fallback
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
              fontSize: 14,
            ),
            SizedBox(height: 2.sp),
            AppText(
              text: "Your item has been packed",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),
            SizedBox(height: 20.sp),

            // ✅ Order Progress Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStep("Confirmed", "14 Oct", true),
                _buildConnector(true),
                _buildStep("Shipped", "16 Oct", false),
                _buildConnector(false),
                _buildStep("Delivery", "28 Oct by 11 PM", false, isLast: true),
              ],
            ),
            SizedBox(height: 20.sp),

            // ✅ Cancel Item Button
            GestureDetector(
              onTap: () {
                Get.to(() => CancelOrderScreen(order: order));
              },
              child: Container(
                width: double.infinity,
                height: 45.sp,
                decoration: BoxDecoration(
                  border: Border.all(color: blackColor, width: 1),
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close, color: blackColor, size: 18),
                    SizedBox(width: 6.sp),
                    const AppText(
                      text: "CANCEL ITEM",
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.sp),

            // ✅ Delivery Details
            const AppText(
              text: "DELIVERY DETAILS",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            const AppText(
              text: "Apartment",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 13,
            ),
            SizedBox(height: 4.sp),
            const AppText(
              text:
                  "B3, 402, street name, close to landmarks\nABC Street, Mumbai, Maharashtra...",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),

            SizedBox(height: 20.sp),

            // ✅ Order Price Section
            const AppText(
              text: "ORDER PRICE",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            _priceRow("Total MRP", "₹3336.32"),
            _priceRow("Delivery Charges", "₹112.32"),
            _priceRow("Discount on MRP", "- ₹36", color: Colors.green),
            _priceRow("Coupon Discount", "- ₹56",
                color: const Color(0xFF8B5CF6)),
            _priceRow("Convenience Fee", "Free ₹250",
                color: Colors.green, isFree: true),
            _priceRow("Tax & Charges", "₹36"),

            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                AppText(
                  text: "BILL TOTAL",
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                  fontSize: 14,
                ),
                AppText(
                  text: "₹3336.32",
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                  fontSize: 14,
                ),
              ],
            ),
            SizedBox(height: 30.sp),
          ],
        ),
      ),
    );
  }

  /// ✅ Safely handles image loading (network or asset)
  Widget _buildProductImage(Map<String, dynamic> order) {
    final imageUrl = order['imageUrl'];
    final isNetwork =
        imageUrl != null && imageUrl.toString().startsWith('http');

    if (isNetwork) {
      return CachedNetworkImage(
        cacheManager: CacheManager(
          Config("orderDetailsCache",
              stalePeriod: const Duration(days: 10), maxNrOfCacheObjects: 50),
        ),
        imageUrl: imageUrl,
        height: 200.sp,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            Image.asset(dummyWishlistImage, fit: BoxFit.cover),
      );
    } else {
      return Image.asset(
        dummyWishlistImage,
        height: 200.sp,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildStep(String title, String date, bool isDone,
      {bool isLast = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12.sp,
          backgroundColor:
              isDone ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
          child: Icon(
            isDone ? Icons.check : Icons.local_shipping,
            size: 14.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.sp),
        AppText(
          text: title,
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w600,
          color: blackColor,
          fontSize: 12,
        ),
        SizedBox(height: 2.sp),
        AppText(
          text: date,
          fontFamily: "Franklin Gothic Regular",
          fontWeight: FontWeight.w400,
          color: subtitleColor,
          fontSize: 11,
        ),
      ],
    );
  }

  Widget _buildConnector(bool active) {
    return Expanded(
      child: Container(
        height: 2.sp,
        color: active ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {Color color = blackColor, bool isFree = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            fontSize: 12,
          ),
          AppText(
            text: value,
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}
