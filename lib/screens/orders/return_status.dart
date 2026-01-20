import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/orders/my_order.dart';

class ReturnStatusScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const ReturnStatusScreen({super.key, required this.order});

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

  final List<Map<String, String>> steps = const [
    {"title": "Return Request Submitted", "date": "16 Oct"},
    {"title": "Pickup Scheduled", "date": "17 Oct"},
    {"title": "Quality Check", "date": "18 Oct"},
    {"title": "Refund Processed", "date": "20 Oct"},
  ];

  @override
  Widget build(BuildContext context) {
    // ----------- SAME EXTRACTION LOGIC AS CancelSuccessScreen -------------
    final data = order['data'] ?? order;

    final product = _extractProduct(data['product']);
    final orderInfo = data['order'] ?? {};
    final variant = data['variant'] ?? {};

    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl =
        imageList.isNotEmpty ? imageList.first : dummyWishlistImage;

    final productName =
        product['title'] ?? product['name'] ?? 'Unknown Product';

    final description = product['shortDescription'] ??
        product['description'] ??
        "No description available";

    final size = variant['size'] ?? product['product_matrix_size_name'] ?? "-";

    final quantity = data['quantity'] ?? 1;

    // ---------------------------------------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
          text: "RETURN STATUS",
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: "TRACK RETURN STATUS",
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 15,
            ),
            SizedBox(height: 20.sp),

            // ===== PRODUCT CARD (Same UI as CancelSuccessScreen) =====
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8.sp),
                border: Border.all(color: dividerColor),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.sp),
                      child: Image.network(
                        imageUrl,
                        height: 60.sp,
                        width: 60.sp,
                        fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => Image.asset(
                          dummyWishlistImage,
                          height: 60.sp,
                          width: 60.sp,
                          fit: BoxFit.fill,
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
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w700,
                            color: blackColor,
                            fontSize: 13,
                          ),
                          SizedBox(height: 2.sp),
                          AppText(
                            text: description,
                            fontFamily: "Clash Display Regular",
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            fontSize: 11,
                            maxLines: 2,
                          ),
                          SizedBox(height: 6.sp),
                          AppText(
                            text: "Size: $size   Qty: $quantity",
                            fontFamily: "Clash Display Regular",
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            fontSize: 11,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.sp),

            const AppText(
              text: "RETURN TIMELINE",
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 16.sp),

            // ===== TIMELINE =====
            Column(
              children: List.generate(steps.length, (index) {
                final step = steps[index];
                final isCompleted = index <= 2;
                final isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16.sp,
                          height: 16.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade400,
                          ),
                          child: Icon(
                            Icons.check,
                            color: whiteColor,
                            size: 10.sp,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            height: 40.sp,
                            width: 2.sp,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade400,
                          ),
                      ],
                    ),
                    SizedBox(width: 12.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: step["title"] ?? '',
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : blackColor,
                          fontSize: 13,
                        ),
                        SizedBox(height: 2.sp),
                        AppText(
                          text: step["date"] ?? '',
                          fontFamily: "Clash Display Regular",
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                          fontSize: 11,
                        ),
                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ],
                );
              }),
            ),

            SizedBox(height: 40.sp),

            // ===== BACK TO ORDERS =====
            GestureDetector(
              onTap: () => Get.offAll(() => MyOrdersScreen()),
              child: Container(
                width: double.infinity,
                height: 48.sp,
                decoration: BoxDecoration(
                  color: blackColor,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: const Center(
                  child: AppText(
                    text: "BACK TO ORDERS",
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w700,
                    color: whiteColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }
}
