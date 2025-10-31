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

  final List<Map<String, String>> steps = const [
    {"title": "Return Request Submitted", "date": "16 Oct"},
    {"title": "Pickup Scheduled", "date": "17 Oct"},
    {"title": "Quality Check", "date": "18 Oct"},
    {"title": "Refund Processed", "date": "20 Oct"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            arrowBack, // ✅ Using constant
            height: 18,
            width: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "RETURN STATUS",
          fontFamily: "Franklin Gothic",
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
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 15,
            ),
            SizedBox(height: 20.sp),

            // ✅ Product Info Section
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8.sp),
                border: Border.all(color: dividerColor),
              ),
              padding: EdgeInsets.all(10.sp),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.sp),
                    child: _buildProductImage(),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: order['productName'] ?? 'Product Name',
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w700,
                          color: blackColor,
                          fontSize: 13,
                        ),
                        SizedBox(height: 2.sp),
                        AppText(
                          text: order['productDescription'] ??
                              'Product description',
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                          fontSize: 11,
                          maxLines: 2,
                        ),
                        SizedBox(height: 4.sp),
                        AppText(
                          text:
                              "Size: ${order['size'] ?? 'M'}  Qty: ${order['quantity'] ?? '1'}",
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.sp),

            const AppText(
              text: "RETURN TIMELINE",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 16.sp),

            // ✅ Return Status Timeline
            Column(
              children: List.generate(steps.length, (index) {
                final step = steps[index];
                final isCompleted = index <= 2; // simulate current progress
                final isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dots + line
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
                            isCompleted ? Icons.check : Icons.circle,
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

                    // Step Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: step["title"] ?? '',
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : blackColor,
                          fontSize: 13,
                        ),
                        SizedBox(height: 2.sp),
                        AppText(
                          text: step["date"] ?? '',
                          fontFamily: "Franklin Gothic Regular",
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

            // ✅ Back Button
            GestureDetector(
              onTap: () => Get.to(MyOrdersScreen()),
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
                    fontFamily: "Franklin Gothic",
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

  /// ✅ Safe Product Image Loader
  Widget _buildProductImage() {
    final imageUrl = order['imageUrl'];
    final isNetwork =
        imageUrl != null && imageUrl.toString().startsWith('http');

    if (isNetwork) {
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
        height: 70.sp,
        width: 70.sp,
        fit: BoxFit.cover,
      );
    }
  }
}
