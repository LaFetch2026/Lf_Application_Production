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
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'package:lafetch/screens/orders/confirm_orderdetails.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with RouteAware {
  final OrderController orderController = Get.put(OrderController());

  /// Helper to extract product data from nested or flat structure
  Map<String, dynamic> _extractProduct(dynamic rawProduct) {
    if (rawProduct is Map) {
      // Check if it's a nested API response: {status, message, data: {...}}
      if (rawProduct.containsKey('data') && rawProduct['data'] is Map) {
        return Map<String, dynamic>.from(rawProduct['data']);
      }
      return Map<String, dynamic>.from(rawProduct);
    }
    return {};
  }

  DateTime _extractOrderDate(Map<String, dynamic> item) {
    final status = item["status"]?.toString().toLowerCase() ?? "";
    String? dateStr;

    if (status == "cancelled") {
      dateStr = item["cancelledAt"];
    } else if (status == "delivered") {
      dateStr = item["deliveredAt"];
    } else if (status == "returned") {
      dateStr = item["returnedAt"];
    } else if (item["order"]?["orderedAt"] != null) {
      dateStr = item["order"]["orderedAt"];
    } else {
      dateStr = item["createdAt"];
    }

    if (dateStr == null) return DateTime(1970);
    return DateTime.tryParse(dateStr) ?? DateTime(1970);
  }

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrderHistory());
  }

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId') ?? prefs.getInt('user_id');

    if (userId == null) {
      showAppSnackBar("Please login again", type: SnackBarType.error);
      return;
    }

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
          fontFamily: "Clash Display Semibold",
          fontWeight: FontWeight.w600,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: Obx(() {
        if (orderController.isOrderHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = [...orderController.orderHistory];

        orders.sort((a, b) {
          final dateA = _extractOrderDate(a);
          final dateB = _extractOrderDate(b);
          return dateB.compareTo(dateA);
        });

        List<Map<String, dynamic>> filteredOrders;

        if (selectedFilter == "All") {
          filteredOrders = orders.cast<Map<String, dynamic>>();
        } else {
          filteredOrders = orders
              .where((order) {
                String status =
                    (order["status"] ?? "").toString().toLowerCase();

                if (selectedFilter == "Exchanged") {
                  return status.contains("exchange") ||
                      status.contains("exchanged");
                }

                return status.contains(selectedFilter.toLowerCase());
              })
              .cast<Map<String, dynamic>>()
              .toList();
        }

        if (filteredOrders.isEmpty) {
          return Column(
            children: [
              _buildFilterBar(),
              const Expanded(
                child: Center(
                  child: AppText(
                    text: "No orders found",
                    fontSize: 14,
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: _loadOrderHistory,
          child: Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => Divider(
                    color: const Color(0xFFE5E7EB),
                    thickness: 1,
                  ),
                  itemBuilder: (_, index) =>
                      _buildOrderItem(filteredOrders[index]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> orderItem) {
    final order = orderItem['order'] ?? {};

    // Extract product from nested or flat structure
    final product = _extractProduct(orderItem['product']);

    final status = (orderItem["status"] ?? "").toString().toLowerCase();
    final orderItemId = orderItem['id'] ?? 0;

    final date = _extractOrderDate(orderItem).toIso8601String().split("T")[0];

    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl = imageList.isNotEmpty
        ? imageList.first
        : "https://via.placeholder.com/100";

    final productName = product['title'] ?? "Unknown Product";
    final quantity = orderItem['quantity']?.toString() ?? "1";
    final price = double.tryParse(orderItem['total']?.toString() ?? "0") ?? 0.0;

    // Get size/color from order item or variant
    final size = orderItem['size']?.toString() ??
        orderItem['variant']?['title']?.toString() ??
        "-";
    final color = orderItem['color']?.toString() ??
        orderItem['colour']?.toString() ??
        "-";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(status, orderItemId, date, orderItem, product),
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
                          maxNrOfCacheObjects: 150),
                    ),
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    errorWidget: (_, __, ___) => Image.asset(
                      dummyWishlistImage,
                      fit: BoxFit.fill,
                    ),
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
                      fontSize: 14,
                      maxLines: 2,
                      fontFamily: "Clash Display Semibold",
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 4.sp),
                    AppText(
                      text: "Size: $size  |  Qty: $quantity",
                      fontSize: 12,
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                    ),
                    if (color != "-") ...[
                      SizedBox(height: 2.sp),
                      AppText(
                        text: "Color: $color",
                        fontSize: 12,
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                      ),
                    ],
                    SizedBox(height: 8.sp),
                    AppText(
                      text: "₹${price.toStringAsFixed(2)}",
                      fontSize: 16,
                      fontFamily: "Clash Display Semibold",
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.sp),
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
          ),
          // Download Invoice Button (shown only if invoiceUrl is available)
          if (orderItem['invoiceUrl'] != null &&
              orderItem['invoiceUrl'].toString().isNotEmpty) ...[
            SizedBox(height: 8.sp),
            _buildButton(
              text: "DOWNLOAD INVOICE",
              isPrimary: false,
              onTap: () => _handleDownloadInvoice(orderItem['invoiceUrl']),
            ),
          ],
        ],
      ),
    );
  }

  void _handleDownloadInvoice(String invoiceUrl) async {
    try {
      final Uri uri = Uri.parse(invoiceUrl);

      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        // Launch URL in external browser/PDF viewer
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        showAppSnackBar(
          "Unable to open invoice URL",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print("🔥 Error opening invoice: $e");
      showAppSnackBar(
        "Failed to download invoice",
        type: SnackBarType.error,
      );
    }
  }

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
    } else if (lower.contains("exchange")) {
      iconData = Icons.swap_horiz_rounded;
      iconColor = const Color(0xFF6366F1);
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
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w600,
              color: iconColor,
              fontSize: 13,
            ),
          ],
        ),
        isDelivered
            ? GestureDetector(
                onTap: () {
                  final productData = {
                    "id": orderItemId,
                    "variantId": orderItem['variantId'] ?? 0,
                    "productName": product['title'] ?? '',
                    "productDescription": product['description'] ?? '',
                    "size": product['size'] ??
                        (orderItem['variant']?['title'] ?? '-'),
                    "quantity": orderItem['quantity'] ?? 1,
                    "price": double.tryParse(
                            orderItem['total']?.toString() ?? '0') ??
                        0,
                    "imageUrl": (product['imageUrls'] is List &&
                            product['imageUrls'].isNotEmpty)
                        ? product['imageUrls'][0]
                        : '',
                  };

                  Get.to(() => RateProductScreen(product: productData));
                },
                child: const AppText(
                  text: "Rate & Review Product",
                  fontFamily: "Clash Display",
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                ),
              )
            : AppText(
                text: "ID #$orderItemId",
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                fontSize: 12,
              ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      "All",
      "Pending",
      "Delivered",
      "Cancelled",
      "Returned",
      "Exchanged"
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 10.sp),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontFamily:
                      isSelected ? "Clash Display Semibold" : "Clash Display",
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              selectedColor: homeAppBarColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontFamily:
                    isSelected ? "Clash Display Semibold" : "Clash Display",
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              onSelected: (_) {
                setState(() => selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    final primaryColor = homeAppBarColor;
    final borderColor = isPrimary ? primaryColor : const Color(0xFFE5E7EB);
    final backgroundColor = isPrimary ? primaryColor : whiteColor;
    final textColor =
        isPrimary ? whiteColor : nameText.withOpacity(isDisabled ? 0.5 : 1);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Ink(
          height: 44.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.sp),
            color: backgroundColor,
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: AppText(
              text: text,
              fontFamily: "Clash Display Semibold",
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
