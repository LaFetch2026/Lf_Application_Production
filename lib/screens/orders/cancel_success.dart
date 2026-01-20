import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/screens/orders/my_order.dart';

class CancelSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const CancelSuccessScreen({super.key, required this.order});

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
  Widget build(BuildContext context) {
    // ----------- SAME EXTRACTION LOGIC AS ConfirmOrderDetailsScreen -------------
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

    // -----------------------------------------------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              cancelorder,
              height: 200.sp,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 24.sp),

            // REFUND TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: "Refund Details",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 6.sp),

            const AppText(
              text:
                  "Refund will be processed to your original payment method within 24 hours.",
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
              maxLines: 3,
              textAlign: TextAlign.left,
            ),

            SizedBox(height: 30.sp),

            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: "Item Cancelled",
                fontFamily: "Clash Display",
                fontWeight: FontWeight.w700,
                color: blackColor,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 12.sp),

            // -------- ITEM CARD --------
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

            const Spacer(),

            // ---- BACK BUTTON ----
            GestureDetector(
              onTap: () => Get.offAll(() => MyOrdersScreen()),
              child: Container(
                width: double.infinity,
                height: 50.sp,
                decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: dividerColor, width: 1),
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                child: const Center(
                  child: AppText(
                    text: "BACK TO ORDERS",
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.sp),
          ],
        ),
      ),
    );
  }
}
