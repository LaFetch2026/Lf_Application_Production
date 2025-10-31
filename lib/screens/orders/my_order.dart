import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/orders/cancel_order.dart';
import 'package:lafetch/screens/orders/confirm_orderdetails.dart';
import 'package:lafetch/screens/orders/exchange_request.dart';
import 'package:lafetch/screens/orders/return_request.dart';
import 'package:lafetch/screens/orders/rate_productscreen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  // Mock order list for testing
  final List<Map<String, dynamic>> orders = [
    {
      'status': 'Confirmed',
      'statusSubtext': 'Arriving by Tue, 28 Nov 2025',
      'statusIcon': Icons.check_circle,
      'statusColor': Color(0xFF10B981),
      'productName': 'THE CLOTHING FACTORY',
      'productDescription': 'Garfield: Grumpy Printed...',
      'size': 'M',
      'quantity': '1',
      'price': 2630.00,
      'imageUrl': 'https://via.placeholder.com/80',
      'primaryAction': 'VIEW DETAILS',
      'secondaryAction': 'CANCEL ITEM',
      'showReview': false,
    },
    {
      'status': 'Delivered',
      'statusSubtext': 'On Wed, 23 May 2025',
      'statusIcon': Icons.check_circle,
      'statusColor': Color(0xFF10B981),
      'productName': 'LA DOUBLEJ',
      'productDescription': 'Embroidered double-brea...',
      'size': 'M',
      'quantity': '1',
      'price': 2630.00,
      'imageUrl': 'https://via.placeholder.com/80',
      'primaryAction': 'RETURN',
      'secondaryAction': 'EXCHANGE',
      'showReview': true,
    },
    {
      'status': 'Cancelled',
      'statusSubtext': 'Mon, 21 Oct 2025',
      'statusIcon': Icons.cancel,
      'statusColor': Color(0xFFEF4444),
      'productName': 'LA DOUBLEJ',
      'productDescription': 'Embroidered double-brea...',
      'size': 'M',
      'quantity': '1',
      'price': 2630.00,
      'imageUrl': 'https://via.placeholder.com/80',
      'primaryAction': 'VIEW DETAILS',
      'showReview': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            arrowBack, // ✅ from constants.dart
            height: 18,
            width: 18,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const AppText(
          text: "MY ORDERS",
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8.sp),
        itemCount: orders.length,
        separatorBuilder: (_, __) => Divider(
          color: Color(0xFFE5E7EB),
          thickness: 1,
          height: 1,
        ),
        itemBuilder: (context, index) => _buildOrderItem(orders[index]),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(order),
          SizedBox(height: 12.sp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.sp,
                height: 100.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.sp),
                  color: const Color(0xFFF3F4F6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.sp),
                  child: CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config("orderCache",
                          stalePeriod: const Duration(days: 15),
                          maxNrOfCacheObjects: 100),
                    ),
                    imageUrl: order['imageUrl'],
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Image.asset(dummyWishlistImage, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: order['productName'],
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w600,
                      color: nameText,
                      fontSize: 14,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.sp),
                    AppText(
                      text: order['productDescription'],
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      fontSize: 12,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8.sp),
                    AppText(
                      text: 'Size ${order['size']}  Qty: ${order['quantity']}',
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                    SizedBox(height: 8.sp),
                    AppText(
                      text: '₹${order['price'].toStringAsFixed(2)}',
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w700,
                      color: nameText,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order['showReview'] == true) ...[
            SizedBox(height: 12.sp),
            _buildReviewLink(order),
          ],
          SizedBox(height: 16.sp),
          _buildActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> order) {
    return Row(
      children: [
        Icon(order['statusIcon'], color: order['statusColor'], size: 16.sp),
        SizedBox(width: 8.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: order['status'],
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w600,
              color: nameText,
              fontSize: 13,
            ),
            SizedBox(height: 2.sp),
            AppText(
              text: order['statusSubtext'],
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 11,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewLink(Map<String, dynamic> order) {
    return Row(
      children: [
        Icon(Icons.star_border, color: const Color(0xFF8B5CF6), size: 14.sp),
        SizedBox(width: 4.sp),
        GestureDetector(
          onTap: () => Get.to(() => RateProductScreen(product: order)),
          child: const AppText(
            text: 'Rate & Review Product',
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B5CF6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            text: order['primaryAction'],
            isPrimary: order['secondaryAction'] == null,
            onTap: () => _handlePrimaryAction(order),
          ),
        ),
        if (order['secondaryAction'] != null) ...[
          SizedBox(width: 12.sp),
          Expanded(
            child: _buildButton(
              text: order['secondaryAction'],
              isPrimary: true,
              onTap: () => _handleSecondaryAction(order),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.sp,
        decoration: BoxDecoration(
          color: isPrimary ? homeAppBarColor : whiteColor,
          border: Border.all(
            color: isPrimary ? homeAppBarColor : const Color(0xFFE5E7EB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Center(
          child: AppText(
            text: text,
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w500,
            color: isPrimary ? whiteColor : nameText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ✅ Handle Navigation Logic
  void _handlePrimaryAction(Map<String, dynamic> order) {
    final action = order['primaryAction'];
    switch (action) {
      case 'VIEW DETAILS':
        Get.to(() => ConfirmOrderDetailsScreen(order: order));
        break;
      case 'RETURN':
        Get.to(() => ReturnRequestScreen(order: order));
        break;
      default:
        Get.to(() => ConfirmOrderDetailsScreen(order: order));
    }
  }

  void _handleSecondaryAction(Map<String, dynamic> order) {
    final action = order['secondaryAction'];
    switch (action) {
      case 'CANCEL ITEM':
        Get.to(() => CancelOrderScreen(order: order));
        break;
      case 'EXCHANGE':
        Get.to(() => ExchangeRequestScreen(order: order));
        break;
      default:
        Get.snackbar("Action", "Feature coming soon");
    }
  }
}
