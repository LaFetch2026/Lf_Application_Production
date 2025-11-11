import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          icon: SvgPicture.asset(
            arrowBack,
            height: 18,
            width: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "RETURN REQUEST",
          fontFamily: "Franklin Gothic",
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
            // ✅ Product Info
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
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                        fontSize: 14,
                      ),
                      SizedBox(height: 2.sp),
                      AppText(
                        text: description,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                        maxLines: 2,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text: "Size: $size   Qty: $quantity",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.sp),

            // ✅ Reason Dropdown
            const AppText(
              text: "REASON FOR RETURN",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),

            DropdownButtonFormField<String>(
              value: selectedReason,
              dropdownColor: whiteColor,
              items: reasons.values
                  .map((reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 12,
                            color: blackColor,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedReason = value),
              decoration: InputDecoration(
                hintText: "Select a reason",
                hintStyle: const TextStyle(
                  fontFamily: "Franklin Gothic Regular",
                  fontSize: 12,
                  color: subtitleColor,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.sp),
                  borderSide: const BorderSide(color: dividerColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: homeAppBarColor),
                ),
              ),
            ),
            SizedBox(height: 20.sp),

            // ✅ Info Note
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: subtitleColor, size: 18.sp),
                SizedBox(width: 6.sp),
                const Expanded(
                  child: AppText(
                    text:
                        "Once the item is picked up and verified, the refund will be processed to your original payment method within 5–7 business days.",
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    fontSize: 11,
                    maxLines: 3,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ✅ Bottom Buttons
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
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w700,
                          color: subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (selectedReason == null) {
                        Get.snackbar(
                          "Select Reason",
                          "Please select a reason before submitting return request.",
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          colorText: Colors.redAccent,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final orderItemId = orderItem['id'] ?? 0;
                      final userId = order['userId'] ?? 0;
                      final addressId = order['shippingAddressId'] ?? 0;
                      final shipRocketId =
                          order['shiprocketOrderId']?.toString() ?? '';

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
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w700,
                          color: whiteColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Safe Product Image Loader
  Widget _buildProductImage(String imageUrl) {
    final isNetwork = imageUrl.startsWith('http');
    if (isNetwork) {
      return Image.network(
        imageUrl,
        height: 70.sp,
        width: 70.sp,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          dummyWishlistImage,
          height: 70.sp,
          width: 70.sp,
          fit: BoxFit.cover,
        ),
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
