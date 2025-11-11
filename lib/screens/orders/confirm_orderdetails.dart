import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/screens/orders/cancel_order.dart';

class ConfirmOrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const ConfirmOrderDetailsScreen({super.key, required this.order});

  @override
  State<ConfirmOrderDetailsScreen> createState() =>
      _ConfirmOrderDetailsScreenState();
}

class _ConfirmOrderDetailsScreenState extends State<ConfirmOrderDetailsScreen> {
  final OrderController orderController = Get.put(OrderController());
  Map<String, dynamic>? detailedOrder;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final orderId = widget.order['id'];
    if (orderId == null) {
      Get.snackbar("Error", "Invalid order ID");
      return;
    }

    final data = await orderController.viewOrderHistoryById(orderId);
    if (mounted) {
      setState(() {
        detailedOrder = data ?? widget.order;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: whiteColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = detailedOrder?['data'] ?? detailedOrder ?? widget.order;

    // ✅ Extract nested objects safely
    final order = data['order'] ?? {};
    final product = data['product'] ?? {};

    // ✅ Handle product image and info
    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl = imageList.isNotEmpty
        ? imageList.first
        : 'https://via.placeholder.com/200';

    final productName =
        (product['title'] ?? product['name'] ?? 'Unknown Product').toString();
    final size = (product['product_matrix_size_name'] ?? '-').toString();
    final quantity = (data['quantity'] ?? 1).toString();

    // ✅ Use top-level status ("returned", "cancelled", etc.)
    final status = (data['status'] ?? 'pending').toString().toLowerCase();

    // ✅ Price values from nested order
    final total = double.tryParse(order['total']?.toString() ?? '0') ?? 0.0;
    final totalMRP =
        double.tryParse(order['totalMRP']?.toString() ?? '$total') ?? total;
    final shipping =
        double.tryParse(order['shippingCost']?.toString() ?? '0') ?? 0.0;
    final coupon =
        double.tryParse(order['couponDiscount']?.toString() ?? '0') ?? 0.0;
    final tax = double.tryParse(order['tax']?.toString() ?? '0') ?? 0.0;

    // ✅ Dynamic status color mapping
    final statusColor = status == 'cancelled'
        ? const Color(0xFFEF4444)
        : status == 'returned'
            ? const Color(0xFF3B82F6)
            : status == 'pending'
                ? const Color(0xFFF59E0B)
                : status == 'confirmed'
                    ? const Color(0xFF10B981)
                    : status == 'delivered'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(arrowBack, height: 18, width: 18),
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
              child: CachedNetworkImage(
                cacheManager: CacheManager(
                  Config("orderDetailsCache",
                      stalePeriod: const Duration(days: 10),
                      maxNrOfCacheObjects: 50),
                ),
                imageUrl: imageUrl,
                height: 200.sp,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Image.asset(dummyWishlistImage, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 12.sp),

            // ✅ Product Info
            AppText(
              text: productName,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: nameText,
              fontSize: 16,
            ),
            SizedBox(height: 6.sp),
            AppText(
              text: "Size: $size   Qty: $quantity",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
            ),
            SizedBox(height: 12.sp),

            // ✅ Status Display
            Row(
              children: [
                const AppText(
                  text: "Status: ",
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                  fontSize: 13,
                ),
                AppText(
                  text: status.capitalizeFirst ?? status,
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontSize: 13,
                ),
              ],
            ),
            SizedBox(height: 20.sp),

            // ✅ Cancel Button (only for pending/confirmed)
            if (status == "pending" || status == "confirmed") ...[
              GestureDetector(
                onTap: () => Get.to(() => CancelOrderScreen(order: order)),
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
            ],

            // ✅ Order Summary
            const AppText(
              text: "ORDER SUMMARY",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            _priceRow("Total MRP", "₹${totalMRP.toStringAsFixed(2)}"),
            _priceRow("Shipping Cost", "₹${shipping.toStringAsFixed(2)}"),
            _priceRow("Tax", "₹${tax.toStringAsFixed(2)}"),
            if (coupon > 0)
              _priceRow("Coupon Discount", "- ₹${coupon.toStringAsFixed(2)}",
                  color: Colors.green),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            // ✅ Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  text: "BILL TOTAL",
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                  fontSize: 14,
                ),
                AppText(
                  text: "₹${total.toStringAsFixed(2)}",
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
