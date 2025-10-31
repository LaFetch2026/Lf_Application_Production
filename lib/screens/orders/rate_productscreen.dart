import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';

class RateProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const RateProductScreen({super.key, required this.product});

  @override
  State<RateProductScreen> createState() => _RateProductScreenState();
}

class _RateProductScreenState extends State<RateProductScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            arrowBack, // ✅ Using constant from const.dart
            height: 18,
            width: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "RATE & REVIEW PRODUCT",
          fontFamily: "Franklin Gothic",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Product Card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.sp),
                  child: _buildProductImage(product),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: product['productName'] ?? 'Product Name',
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w700,
                        color: nameText,
                        fontSize: 14,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text: product['productDescription'] ??
                            'Product description',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                        maxLines: 2,
                      ),
                      SizedBox(height: 8.sp),
                      AppText(
                        text:
                            "Size: ${product['size'] ?? 'M'}   Qty: ${product['quantity'] ?? '1'}",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                      SizedBox(height: 8.sp),
                      AppText(
                        text: "₹${(product['price'] ?? 0).toStringAsFixed(2)}",
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
            Divider(color: dividerColor, thickness: 1),

            // ✅ Rating Section
            SizedBox(height: 16.sp),
            const AppText(
              text: "RATING",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),

            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Icon(
                    Icons.star,
                    size: 30.sp,
                    color: starIndex <= _rating
                        ? const Color(0xFFFACC15) // Yellow
                        : const Color(0xFFD1D5DB), // Grey
                  ),
                );
              }),
            ),

            SizedBox(height: 24.sp),

            // ✅ Review Section
            const AppText(
              text: "SHARE YOUR EXPERIENCE",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),

            TextField(
              controller: _reviewController,
              maxLines: 5,
              style: const TextStyle(
                fontFamily: "Franklin Gothic Regular",
                fontSize: 13,
                color: blackColor,
              ),
              decoration: InputDecoration(
                hintText: "Write your review here...",
                hintStyle: const TextStyle(color: subtitleColor),
                contentPadding: EdgeInsets.all(12.sp),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: dividerColor),
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: homeAppBarColor),
                  borderRadius: BorderRadius.circular(4.sp),
                ),
              ),
            ),

            const Spacer(),

            // ✅ Buttons
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
                    onTap: _submitReview,
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
                          text: "SUBMIT",
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
  Widget _buildProductImage(Map<String, dynamic> product) {
    final imageUrl = product['imageUrl'];
    final isNetwork =
        imageUrl != null && imageUrl.toString().startsWith('http');

    if (isNetwork) {
      return CachedNetworkImage(
        cacheManager: CacheManager(
          Config("rateProductCache",
              stalePeriod: const Duration(days: 10), maxNrOfCacheObjects: 50),
        ),
        imageUrl: imageUrl,
        width: 80.sp,
        height: 100.sp,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            Image.asset(dummyWishlistImage, fit: BoxFit.cover),
      );
    } else {
      return Image.asset(
        dummyWishlistImage,
        width: 80.sp,
        height: 100.sp,
        fit: BoxFit.cover,
      );
    }
  }

  /// ✅ Handle Submit Logic
  void _submitReview() {
    if (_rating == 0) {
      Get.snackbar(
        'Alert',
        'Please select a star rating before submitting.',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Alert',
        'Please write a short review before submitting.',
        backgroundColor: Colors.orangeAccent.withOpacity(0.1),
        colorText: Colors.orangeAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Thank you!',
      'Your review has been submitted successfully.',
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.back();
  }
}
