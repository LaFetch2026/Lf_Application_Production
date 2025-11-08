import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/screens/orders/confirm_orderdetails.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with RouteAware {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderHistory();
    });
  }

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId') ?? prefs.getInt('user_id');

    if (userId == null) {
      Get.snackbar("Error", "Please login again");
      return;
    }

    print("📦 Fetching order history for userId: $userId");
    await orderController.getOrderHistoryByUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(arrowBack, height: 18, width: 18),
          onPressed: () => Get.offAll(() => const BottomNavScreen(index: 3)),
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
      body: Obx(() {
        if (orderController.isOrderHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = orderController.orderHistory;
        if (orders.isEmpty) {
          return const Center(
            child: AppText(
              text: "No orders found",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 14,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadOrderHistory,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.sp),
            itemCount: orders.length,
            separatorBuilder: (_, __) => Divider(
              color: const Color(0xFFE5E7EB),
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) =>
                _buildOrderItem(orders[index] as Map<String, dynamic>),
          ),
        );
      }),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> orderItem) {
    final order = orderItem['order'] ?? {};
    final product = orderItem['product'] ?? {};

    // ✅ Use status from top-level orderItem (e.g., returned / cancelled / pending)
    final status = orderItem['status']?.toString() ?? 'pending';

    // ✅ Show top-level item id
    final orderItemId = orderItem['id']?.toString() ?? '-';

    // ✅ Use ordered date from nested order object
    final date = order['orderedAt'] != null
        ? order['orderedAt'].toString().split('T')[0]
        : '';

    // ✅ Product details
    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl = imageList.isNotEmpty
        ? imageList.first
        : 'https://via.placeholder.com/80';
    final productName = product['title'] ?? 'Unknown Product';
    final quantity = orderItem['quantity']?.toString() ?? '1';
    final price = double.tryParse(orderItem['total']?.toString() ?? '0') ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(status, orderItemId, date),
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
                      Config(
                        "orderCache",
                        stalePeriod: const Duration(days: 15),
                        maxNrOfCacheObjects: 100,
                      ),
                    ),
                    imageUrl: imageUrl,
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
                      text: productName,
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w600,
                      color: nameText,
                      fontSize: 14,
                      maxLines: 2,
                    ),
                    SizedBox(height: 4.sp),
                    AppText(
                      text: 'Qty: $quantity',
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                    SizedBox(height: 8.sp),
                    AppText(
                      text: '₹${price.toStringAsFixed(2)}',
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
          SizedBox(height: 16.sp),
          _buildButton(
            text: "VIEW DETAILS",
            isPrimary: false,
            onTap: () => _handleViewDetails(orderItem),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String status, String orderItemId, String date) {
    final lower = status.toLowerCase();
    IconData iconData;
    Color iconColor;

    if (lower.contains("cancel")) {
      iconData = Icons.cancel_outlined;
      iconColor = const Color(0xFFEF4444); // 🔴 Cancelled
    } else if (lower.contains("pending")) {
      iconData = Icons.timelapse_outlined;
      iconColor = const Color(0xFFF59E0B); // 🟠 Pending
    } else if (lower.contains("confirmed") ||
        lower.contains("delivered") ||
        lower.contains("shipped")) {
      iconData = Icons.check_circle_rounded;
      iconColor = const Color(0xFF10B981); // ✅ Success
    } else {
      iconData = Icons.info_outline_rounded;
      iconColor = const Color(0xFF9CA3AF); // ⚪ Neutral
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(iconData, color: iconColor, size: 18.sp),
            SizedBox(width: 8.sp),
            AppText(
              text: status.capitalizeFirst ?? status,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w600,
              color: nameText,
              fontSize: 13,
            ),
          ],
        ),
        AppText(
          text: "ID #$orderItemId • $date",
          fontFamily: "Franklin Gothic Regular",
          fontWeight: FontWeight.w400,
          color: subtitleColor,
          fontSize: 12,
        ),
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

  void _handleViewDetails(Map<String, dynamic> orderItem) {
    Get.to(() => ConfirmOrderDetailsScreen(order: orderItem));
  }
}
