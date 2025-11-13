import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/orders/cancel_order.dart';
import 'package:lafetch/screens/orders/exchange_request.dart';
import 'package:lafetch/screens/orders/rate_productscreen.dart';
import 'package:lafetch/screens/orders/return_request.dart';
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

  /// 🧩 Build each order item card
  Widget _buildOrderItem(Map<String, dynamic> orderItem) {
    final order = orderItem['order'] ?? {};
    final product = orderItem['product'] ?? {};

    final status = (orderItem['status'] ?? 'pending').toString().toLowerCase();
    final orderItemId = orderItem['id'] ?? 0;
    final date = order['orderedAt'] != null
        ? order['orderedAt'].toString().split('T')[0]
        : '';

    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl = imageList.isNotEmpty
        ? imageList.first
        : 'https://via.placeholder.com/100';
    final productName = product['title'] ?? 'Unknown Product';
    final quantity = orderItem['quantity']?.toString() ?? '1';
    final price = double.tryParse(orderItem['total']?.toString() ?? '0') ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Status header
          _buildStatusHeader(status, orderItemId, date, orderItem, product),
          SizedBox(height: 12.sp),

          // ✅ Product info card
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

          // ✅ Bottom action buttons
          Row(
            children: [
              if (status == "confirmed" || status == "processing") ...[
                Expanded(
                  child: _buildButton(
                    text: "VIEW DETAILS",
                    isPrimary: false,
                    onTap: () => _handleViewDetails(orderItem),
                  ),
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: _buildButton(
                    text: "CANCEL ITEM",
                    isPrimary: true,
                    onTap: () => Get.to(
                      () => CancelOrderScreen(order: orderItem),
                      transition: Transition.rightToLeft,
                    ),
                  ),
                ),
              ] else if (status == "delivered") ...[
                Expanded(
                  child: _buildButton(
                    text: "RETURN",
                    isPrimary: true,
                    onTap: () => Get.to(
                      () => ReturnRequestScreen(order: orderItem),
                      transition: Transition.rightToLeft,
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: _buildButton(
                    text: "EXCHANGE",
                    isPrimary: true,
                    onTap: () => Get.to(
                      () => ExchangeRequestScreen(order: orderItem),
                      transition: Transition.rightToLeft,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _buildButton(
                    text: "VIEW DETAILS",
                    isPrimary: false,
                    onTap: () => _handleViewDetails(orderItem),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  /// 🟣 Build Status Header Row
  Widget _buildStatusHeader(String status, int orderItemId, String date,
      Map<String, dynamic> orderItem, Map<String, dynamic> product) {
    final lower = status.toLowerCase();
    IconData iconData;
    Color iconColor;

    if (lower.contains("cancel")) {
      iconData = Icons.cancel_outlined;
      iconColor = const Color(0xFFEF4444);
    } else if (lower.contains("pending")) {
      iconData = Icons.timelapse_outlined;
      iconColor = const Color(0xFFF59E0B);
    } else if (lower.contains("returned")) {
      iconData = Icons.refresh_rounded;
      iconColor = const Color(0xFF3B82F6);
    } else if (lower.contains("delivered") || lower.contains("confirmed")) {
      iconData = Icons.check_circle_rounded;
      iconColor = const Color(0xFF10B981);
    } else {
      iconData = Icons.info_outline_rounded;
      iconColor = const Color(0xFF9CA3AF);
    }

    final isDelivered = lower.contains("delivered");

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
              color: iconColor,
              fontSize: 13,
            ),
          ],
        ),
        isDelivered
            ? GestureDetector(
                onTap: () {
                  // ✅ Build product data for RateProductScreen
                  final productData = {
                    "id": orderItemId,
                    "variantId": orderItem['variantId'] ?? 0,
                    "productName": product['title'] ?? 'Unknown Product',
                    "productDescription": product['description'] ?? '',
                    "size": product['size'] ??
                        (orderItem['variant']?['title'] ?? '-'),
                    "quantity": orderItem['quantity'] ?? 1,
                    "price": double.tryParse(
                            orderItem['total']?.toString() ?? '0') ??
                        0,
                    "imageUrl": (product['imageUrls'] is List &&
                            (product['imageUrls'] as List).isNotEmpty)
                        ? product['imageUrls'][0]
                        : 'https://via.placeholder.com/100',
                  };

                  Get.to(() => RateProductScreen(product: productData),
                      transition: Transition.rightToLeft);
                },
                child: AppText(
                  text: "Rate & Review Product",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B5CF6),
                  fontSize: 12,
                ),
              )
            : AppText(
                text: "ID #$orderItemId",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                fontSize: 12,
              ),
      ],
    );
  }

  /// 🔘 Reusable button
  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    final Color primaryColor = homeAppBarColor;
    final Color borderColor =
        isPrimary ? primaryColor : const Color(0xFFE5E7EB);
    final Color backgroundColor = isPrimary ? primaryColor : whiteColor;
    final Color textColor =
        isPrimary ? whiteColor : nameText.withOpacity(isDisabled ? 0.5 : 1);

    return Opacity(
      opacity: isDisabled ? 0.6 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(6.sp),
        splashColor: primaryColor.withOpacity(0.15),
        highlightColor: Colors.transparent,
        child: Ink(
          height: 44.sp,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(6.sp),
          ),
          child: Center(
            child: AppText(
              text: text,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _handleViewDetails(Map<String, dynamic> orderItem) {
    Get.to(() => ConfirmOrderDetailsScreen(order: orderItem));
  }
}
