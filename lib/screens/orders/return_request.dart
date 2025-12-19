// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'return_status.dart';

class ReturnRequestScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const ReturnRequestScreen({super.key, required this.order});

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final OrderController orderController = Get.put(OrderController());
  String? selectedReason;

  final Map<int, String> reasons = const {
    25: "Other",
    26: "Changed my mind",
    27: "Does not fit",
    28: "Size not as expected",
    29: "Item is damaged",
    30: "Received wrong item",
    31: "Parcel damaged on arrival",
    32: "Quality not as expected",
    33: "Missing item or accessories",
    34: "Performance not adequate",
    35: "Not as described",
    36: "Arrived too late",
  };

  @override
  Widget build(BuildContext context) {
    final orderItem = widget.order;
    final product = orderItem['product'] ?? {};
    final order = orderItem['order'] ?? {};

    /// REQUIRED FOR API (NO MORE ERRORS)
    final int orderItemId = orderItem['id'] ?? 0;
    final int userId = order['userId'] ?? 0;
    final int addressId = order['shippingAddressId'] ?? 0;
    final String shipRocketId = order['shiprocketOrderId']?.toString() ?? "0";

    // 🔥 Safety Log
    print("----- RETURN API PARAMS ------");
    print("orderItemId = $orderItemId");
    print("userId      = $userId");
    print("addressId   = $addressId");
    print("shipRocketId = $shipRocketId");
    print("-------------------------------");

    final productName = product['title'] ?? 'Unknown Product';
    final description =
        product['shortDescription'] ?? product['description'] ?? '';
    final size = orderItem['size'] ?? 'M';
    final quantity = orderItem['quantity']?.toString() ?? '1';

    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl =
        imageList.isNotEmpty ? imageList.first : dummyWishlistImage;

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
          text: "RETURN REQUEST",
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.sp),
                  child: _buildProductImage(imageUrl),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: productName,
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                        fontSize: 14,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text: description,
                        maxLines: 2,
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text: "Size: $size   Qty: $quantity",
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.sp),
            const AppText(
              text: "REASON FOR RETURN",
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),
            DropdownButtonFormField<String>(
              value: selectedReason,
              items: reasons.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => selectedReason = v),
              decoration: InputDecoration(
                hintText: "Select a reason",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.sp),
                ),
              ),
            ),
            SizedBox(height: 20.sp),
            Row(
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: subtitleColor),
                SizedBox(width: 6.sp),
                const Expanded(
                  child: AppText(
                    text:
                        "Once the item is picked up and verified, refund will be processed within 5–7 working days.",
                    maxLines: 3,
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 48.sp,
                      color: const Color(0xFFF9FAFB),
                      child: const Center(
                        child: AppText(
                          text: "CANCEL",
                          color: subtitleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (selectedReason == null) {
                        Get.snackbar("Select Reason",
                            "Please choose a reason before submitting.");
                        return;
                      }

                      final success = await orderController.requestReturn(
                        orderItemId: orderItemId,
                        userId: userId,
                        reason: selectedReason!,
                        addressId: addressId,
                        shipRocketId: shipRocketId,
                      );

                      if (success) {
                        Get.off(() => ReturnStatusScreen(order: widget.order));
                      }
                    },
                    child: Container(
                      height: 48.sp,
                      color: blackColor,
                      child: const Center(
                        child: AppText(
                          text: "RETURN ITEM",
                          color: whiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith("http")) {
      return Image.network(url,
          height: 70.sp,
          width: 70.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Image.asset(dummyWishlistImage, height: 70.sp, width: 70.sp));
    }
    return Image.asset(dummyWishlistImage,
        height: 70.sp, width: 70.sp, fit: BoxFit.cover);
  }
}
