import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'return_status.dart';

class ReturnRequestScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const ReturnRequestScreen({super.key, required this.order});

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  String? selectedReason;

  final List<String> reasons = [
    'Product not as described',
    'Received damaged item',
    'Wrong product delivered',
    'Size/fit issue',
    'Quality not satisfactory',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
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
                  child: _buildProductImage(),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: widget.order['productName'] ?? 'Product Name',
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                        fontSize: 14,
                      ),
                      SizedBox(height: 2.sp),
                      AppText(
                        text: widget.order['productDescription'] ??
                            'Product description',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text:
                            "Size: ${widget.order['size'] ?? 'M'}  Qty: ${widget.order['quantity'] ?? '1'}",
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
              items: reasons
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

            // ✅ Pickup Address
            const AppText(
              text: "PICKUP ADDRESS",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 13,
            ),
            SizedBox(height: 6.sp),
            const AppText(
              text:
                  "B3, 402, street name, close to landmarks\nABC Street, Mumbai, Maharashtra...",
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontSize: 12,
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.sp),
                          bottomLeft: Radius.circular(4.sp),
                        ),
                      ),
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
                    onTap: () {
                      if (selectedReason == null) {
                        Get.snackbar(
                          "Select Reason",
                          "Please select a reason before submitting return request.",
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          colorText: Colors.redAccent,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        Get.to(() => ReturnStatusScreen(order: widget.order));
                      }
                    },
                    child: Container(
                      height: 48.sp,
                      decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4.sp),
                          bottomRight: Radius.circular(4.sp),
                        ),
                      ),
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
  Widget _buildProductImage() {
    final imageUrl = widget.order['imageUrl'];
    final isNetwork =
        imageUrl != null && imageUrl.toString().startsWith('http');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        height: 70.sp,
        width: 70.sp,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(dummyWishlistImage, fit: BoxFit.cover),
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
