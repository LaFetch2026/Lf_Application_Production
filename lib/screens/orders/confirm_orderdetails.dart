import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/screens/orders/cancel_order.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';

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

  /// Helper to extract product data from nested or flat structure
  Map<String, dynamic> _extractProduct(dynamic rawProduct) {
    if (rawProduct is Map) {
      if (rawProduct.containsKey('data') && rawProduct['data'] is Map) {
        return Map<String, dynamic>.from(rawProduct['data']);
      }
      return Map<String, dynamic>.from(rawProduct);
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final orderId = widget.order['id'];
    if (orderId == null) {
      showAppSnackBar("Invalid order ID", type: SnackBarType.error);
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
        body: Center(child: LfLoaderWidget(size: 54)),
      );
    }

    final data = detailedOrder?['data'] ?? detailedOrder ?? widget.order;

    // ✅ Extract nested objects safely
    final order = data['order'] ?? {};
    final product = _extractProduct(data['product']);
    final shippingAddress = order['shippingAddress'] ?? {};

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

    // ✅ Order Information
    final orderId =
        order['id']?.toString() ?? data['orderId']?.toString() ?? 'N/A';
    final orderDate =
        order['orderedAt']?.toString() ?? order['createdAt']?.toString() ?? '';
    final formattedDate =
        orderDate.isNotEmpty ? orderDate.split('T')[0] : 'N/A';
    final awbCode = data['awbCode']?.toString() ?? '';
    final paymentMethod =
        order['paymentMethod']?.toString().toUpperCase() ?? 'N/A';

    // ✅ Price values from nested order
    final unitPrice =
        double.tryParse(data['unitPrice']?.toString() ?? '0') ?? 0.0;
    final discount =
        double.tryParse(data['discount']?.toString() ?? '0') ?? 0.0;
    final tax = double.tryParse(data['tax']?.toString() ?? '0') ?? 0.0;
    final gstAmount =
        double.tryParse(data['gstAmount']?.toString() ?? '0') ?? 0.0;
    final total = double.tryParse(order['total']?.toString() ?? '0') ?? 0.0;
    final totalMRP =
        double.tryParse(order['totalMRP']?.toString() ?? '$total') ?? total;
    final shipping =
        double.tryParse(order['shippingCost']?.toString() ?? '0') ?? 0.0;
    final coupon =
        double.tryParse(order['couponDiscount']?.toString() ?? '0') ?? 0.0;

    // ✅ Delivery Address
    final addressName = shippingAddress['name']?.toString() ?? '';
    final addressPhone = shippingAddress['phone']?.toString() ?? '';
    final addressLine = shippingAddress['addressLine']?.toString() ?? '';
    final city = shippingAddress['city']?.toString() ?? '';
    final state = shippingAddress['state']?.toString() ?? '';
    final postalCode = shippingAddress['postalCode']?.toString() ?? '';
    final country = shippingAddress['country']?.toString() ?? '';

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
          fontFamily: "Clash Display",
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
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    Image.asset(dummyWishlistImage, fit: BoxFit.fill),
              ),
            ),
            SizedBox(height: 12.sp),

            // ✅ Product Info
            AppText(
              text: productName,
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: nameText,
              fontSize: 16,
            ),
            SizedBox(height: 6.sp),
            AppText(
              text: "Size: $size   Qty: $quantity",
              fontFamily: "Clash Display Regular",
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
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                  fontSize: 13,
                ),
                AppText(
                  text: status.capitalizeFirst ?? status,
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontSize: 13,
                ),
              ],
            ),
            SizedBox(height: 16.sp),

            // ✅ Order Status Tracker
            _buildStatusTracker(status),
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
                        fontFamily: "Clash Display",
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

            // ✅ Order Information Section
            const AppText(
              text: "ORDER INFORMATION",
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),
            _infoRow("Order ID", "#$orderId"),
            _infoRow("Order Date", formattedDate),
            if (awbCode.isNotEmpty) _infoRow("Tracking Number", awbCode),
            _infoRow("Payment Method", paymentMethod),
            SizedBox(height: 24.sp),

            // ✅ Delivery Address Section
            if (addressLine.isNotEmpty || city.isNotEmpty) ...[
              const AppText(
                text: "DELIVERY ADDRESS",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 14,
              ),
              SizedBox(height: 8.sp),
              Divider(color: dividerColor),
              SizedBox(height: 8.sp),
              if (addressName.isNotEmpty)
                AppText(
                  text: addressName,
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                  fontSize: 13,
                ),
              if (addressPhone.isNotEmpty) ...[
                SizedBox(height: 4.sp),
                AppText(
                  text: addressPhone,
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ],
              SizedBox(height: 6.sp),
              AppText(
                text: addressLine,
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: nameText,
                fontSize: 12,
                maxLines: 3,
              ),
              SizedBox(height: 4.sp),
              AppText(
                text: "$city, $state - $postalCode",
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: nameText,
                fontSize: 12,
              ),
              if (country.isNotEmpty) ...[
                SizedBox(height: 4.sp),
                AppText(
                  text: country,
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: nameText,
                  fontSize: 12,
                ),
              ],
              SizedBox(height: 24.sp),
            ],

            // ✅ Price Breakdown Section
            const AppText(
              text: "PRICE BREAKDOWN",
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            _priceRow("Item Price (${quantity}x)",
                "₹${unitPrice.toStringAsFixed(2)}"),
            if (discount > 0)
              _priceRow("Discount", "- ₹${discount.toStringAsFixed(2)}",
                  color: const Color(0xFF10B981)),
            if (gstAmount > 0)
              _priceRow("GST", "₹${gstAmount.toStringAsFixed(2)}"),
            if (tax > 0 && gstAmount == 0)
              _priceRow("Tax", "₹${tax.toStringAsFixed(2)}"),
            _priceRow("Total MRP", "₹${totalMRP.toStringAsFixed(2)}"),
            _priceRow("Shipping Cost", "₹${shipping.toStringAsFixed(2)}"),
            if (coupon > 0)
              _priceRow("Coupon Discount", "- ₹${coupon.toStringAsFixed(2)}",
                  color: const Color(0xFF10B981)),
            Divider(color: dividerColor),
            SizedBox(height: 8.sp),

            // ✅ Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  text: "BILL TOTAL",
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                  fontSize: 14,
                ),
                AppText(
                  text: "₹${total.toStringAsFixed(2)}",
                  fontFamily: "Clash Display",
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

  Widget _buildStatusTracker(String status) {
    // Cancelled — show banner instead of stepper
    if (status == 'cancelled') {
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444)),
            SizedBox(width: 10.sp),
            Expanded(
              child: AppText(
                text: "Order Cancelled — a cancellation email has been sent.",
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: const Color(0xFFEF4444),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Steps in order
    final steps = [
      {'key': 'confirmed', 'label': 'Confirmed'},
      {'key': 'shipped', 'label': 'Shipped'},
      {'key': 'out_for_delivery', 'label': 'Out for Delivery'},
      {'key': 'delivered', 'label': 'Delivered'},
    ];

    // Map status string to step index
    int currentStep = -1;
    switch (status) {
      case 'confirmed':
      case 'processing':
        currentStep = 0;
        break;
      case 'pickup_scheduled':
      case 'shipped':
        currentStep = 1;
        break;
      case 'out_for_delivery':
        currentStep = 2;
        break;
      case 'delivered':
        currentStep = 3;
        break;
    }

    return Column(
      children: List.generate(steps.length, (i) {
        final isDone = i <= currentStep;
        final isCurrent = i == currentStep;
        final isLast = i == steps.length - 1;
        final color = isDone ? homeAppBarColor : const Color(0xFFD1D5DB);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28.sp,
                  height: 28.sp,
                  decoration: BoxDecoration(
                    color: isDone ? homeAppBarColor : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle_outlined,
                    size: 14.sp,
                    color: isDone ? whiteColor : color,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32.sp,
                    color: isDone ? homeAppBarColor : const Color(0xFFD1D5DB),
                  ),
              ],
            ),
            SizedBox(width: 10.sp),
            Padding(
              padding: EdgeInsets.only(top: 4.sp),
              child: AppText(
                text: steps[i]['label']!,
                fontFamily: isCurrent
                    ? "Clash Display Semibold"
                    : "Clash Display Regular",
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isDone ? blackColor : const Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
          ],
        );
      }),
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
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            fontSize: 12,
          ),
          AppText(
            text: value,
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            fontSize: 12,
          ),
          Flexible(
            child: AppText(
              text: value,
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w600,
              color: nameText,
              fontSize: 12,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
