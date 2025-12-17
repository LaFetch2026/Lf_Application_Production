import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'cancel_success.dart';

class CancelOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const CancelOrderScreen({super.key, required this.order});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  final OrderController orderController = Get.put(OrderController());
  int? selectedReason;
  final TextEditingController otherReason = TextEditingController();

  // ✅ Centralized reasons map
  final Map<int, String> cancelReason = const {
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

    final imageUrls = (product['imageUrls'] ?? []) as List;
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    final productName = product['title'] ?? 'Unknown Product';
    final productDescription = product['description'] ?? '';
    final size = orderItem['size'] ?? product['size'] ?? '-';
    final quantity = orderItem['quantity']?.toString() ?? '1';
    final price = double.tryParse(orderItem['total']?.toString() ?? '0') ?? 0.0;

    final List<String> reasons = cancelReason.values.toList();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(arrowBack, height: 18, width: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "CANCELLATION",
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w700,
          color: Color(0xFF3B3B3B),
          fontSize: 16,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Product info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.sp),
                  child: _buildProductImage(imageUrl),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: productName,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                        fontSize: 14,
                        maxLines: 2,
                      ),
                      SizedBox(height: 2.sp),
                      AppText(
                        text: productDescription.isNotEmpty
                            ? productDescription
                            : "Product details unavailable",
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                        maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.sp),
                      AppText(
                        text: "Size: $size   Qty: $quantity",
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                      SizedBox(height: 6.sp),
                      AppText(
                        text: "₹${price.toStringAsFixed(2)}",
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.sp),
            Divider(color: dividerColor, thickness: 1),
            SizedBox(height: 16.sp),

            const AppText(
              text: "WHY DO YOU WISH TO CANCEL THIS ORDER?",
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),

            // ✅ Reason list
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: reasons.length,
                separatorBuilder: (_, __) =>
                    Divider(color: dividerColor, thickness: 1),
                itemBuilder: (context, index) {
                  final isSelected = selectedReason == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedReason = index),
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppText(
                              text: reasons[index],
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF374151),
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            height: 18.sp,
                            width: 18.sp,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? blackColor
                                    : const Color(0xFFD1D5DB),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      height: 9.sp,
                                      width: 9.sp,
                                      decoration: const BoxDecoration(
                                        color: blackColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ✅ "Other" reason text input
            if (selectedReason == reasons.length - 1)
              Padding(
                padding: EdgeInsets.only(top: 10.sp, bottom: 12.sp),
                child: TextField(
                  controller: otherReason,
                  style: const TextStyle(
                    fontFamily: "Clash Display Regular",
                    fontSize: 13,
                    color: blackColor,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type reason here...",
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.sp),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.sp,
                      vertical: 10.sp,
                    ),
                  ),
                ),
              ),

            // ✅ Bottom buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 48.sp,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(color: dividerColor),
                      ),
                      child: const Center(
                        child: AppText(
                          text: "BACK",
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
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
                        Get.snackbar('Alert', 'Please select a reason.');
                        return;
                      }

                      final reasonText = selectedReason == reasons.length - 1 &&
                              otherReason.text.trim().isNotEmpty
                          ? otherReason.text.trim()
                          : reasons[selectedReason!];

                      await orderController.requestCancel(
                        userId: order['userId'],
                        orderItemId: orderItem['id'],
                        reason: reasonText,
                        shipRocketId:
                            order['shiprocketOrderId']?.toString() ?? "",
                      );

                      Get.to(() => CancelSuccessScreen(order: widget.order));
                    },
                    child: Container(
                      height: 48.sp,
                      color: blackColor,
                      child: const Center(
                        child: AppText(
                          text: "CANCEL ITEM",
                          fontFamily: "Clash Display",
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

  /// ✅ Safe Image loader
  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 60.sp,
        width: 60.sp,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          dummyWishlistImage,
          height: 60.sp,
          width: 60.sp,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        dummyWishlistImage,
        height: 60.sp,
        width: 60.sp,
        fit: BoxFit.cover,
      );
    }
  }
}
