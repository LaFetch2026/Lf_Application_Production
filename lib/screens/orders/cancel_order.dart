import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'cancel_success.dart';

class CancelOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const CancelOrderScreen({super.key, required this.order});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  int? selectedReason;
  final TextEditingController otherReason = TextEditingController();

  final List<String> reasons = [
    'Ordered by mistake',
    'Found a better price elsewhere',
    'Change style/ color',
    'Forgot to apply coupon/ offers',
    'Change size',
    'Want to change product',
    'Delivery date is too late',
    'Change address',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
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
          text: "CANCELLATION",
          fontFamily: "Franklin Gothic",
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
            // ✅ Product Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.sp),
                  child: _buildProductImage(widget.order),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: widget.order['productName'] ??
                            'The Clothing Factory',
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                        fontSize: 14,
                      ),
                      SizedBox(height: 2.sp),
                      AppText(
                        text: widget.order['productDescription'] ??
                            "Garfield: Grumpy Printed Men’s Overs...",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                        maxLines: 1,
                      ),
                      SizedBox(height: 6.sp),
                      AppText(
                        text:
                            "Size: ${widget.order['size'] ?? 'M'}   Qty: ${widget.order['quantity'] ?? '1'}",
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
            SizedBox(height: 16.sp),
            Divider(color: dividerColor, thickness: 1),
            SizedBox(height: 12.sp),

            const AppText(
              text: "WHY DO YOU WISH TO CANCEL THIS ORDER?",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 13,
            ),
            SizedBox(height: 12.sp),

            Expanded(
              child: ListView.separated(
                itemCount: reasons.length,
                separatorBuilder: (_, __) =>
                    Divider(color: dividerColor, thickness: 1),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(vertical: -2),
                        title: AppText(
                          text: reasons[index],
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF374151),
                          fontSize: 13,
                        ),
                        trailing: Radio<int>(
                          value: index,
                          activeColor: blackColor,
                          groupValue: selectedReason,
                          onChanged: (val) =>
                              setState(() => selectedReason = val),
                        ),
                      ),
                      if (index == reasons.length - 1 &&
                          selectedReason == index)
                        Padding(
                          padding: EdgeInsets.only(top: 8.sp, bottom: 4.sp),
                          child: TextField(
                            controller: otherReason,
                            style: const TextStyle(
                              fontFamily: "Franklin Gothic Regular",
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type reason here...",
                              hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF), fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.sp),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.sp, vertical: 8.sp),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // ✅ Bottom buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 50.sp,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(color: dividerColor),
                      ),
                      child: const Center(
                        child: AppText(
                          text: "BACK",
                          fontFamily: "Franklin Gothic",
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
                    onTap: () {
                      if (selectedReason == null) {
                        Get.snackbar('Alert', 'Please select a reason.');
                      } else {
                        Get.to(() => CancelSuccessScreen(order: widget.order));
                      }
                    },
                    child: Container(
                      height: 50.sp,
                      color: blackColor,
                      child: const Center(
                        child: AppText(
                          text: "CANCEL ITEM",
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

  /// ✅ Safe image loader
  Widget _buildProductImage(Map<String, dynamic> order) {
    final imageUrl = order['imageUrl'];
    final isNetwork =
        imageUrl != null && imageUrl.toString().startsWith('http');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        height: 80.sp,
        width: 80.sp,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(dummyWishlistImage, fit: BoxFit.cover),
      );
    } else {
      return Image.asset(
        dummyWishlistImage,
        height: 80.sp,
        width: 80.sp,
        fit: BoxFit.cover,
      );
    }
  }
}
