import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/product_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';

class RateProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const RateProductScreen({super.key, required this.product});

  @override
  State<RateProductScreen> createState() => _RateProductScreenState();
}

class _RateProductScreenState extends State<RateProductScreen> {
  final ProductController productController = Get.put(ProductController());
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

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
          icon: SvgPicture.asset(arrowBack, height: 18, width: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: "RATE & REVIEW PRODUCT",
          fontFamily: "Clash Display",
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
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w700,
                        color: nameText,
                        fontSize: 14,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text: product['productDescription'] ??
                            'Product description',
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                        maxLines: 2,
                      ),
                      SizedBox(height: 8.sp),
                      AppText(
                        text:
                            "Size: ${product['size'] ?? 'M'}   Qty: ${product['quantity'] ?? '1'}",
                        fontFamily: "Clash Display Regular",
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                      SizedBox(height: 8.sp),
                      AppText(
                        text: "₹${(product['price'] ?? 0).toStringAsFixed(2)}",
                        fontFamily: "Clash Display",
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
              fontFamily: "Clash Display",
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
                        ? const Color(0xFFFACC15)
                        : const Color(0xFFD1D5DB),
                  ),
                );
              }),
            ),

            SizedBox(height: 24.sp),

            // ✅ Review Section
            const AppText(
              text: "SHARE YOUR EXPERIENCE",
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 14,
            ),
            SizedBox(height: 8.sp),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              style: const TextStyle(
                fontFamily: "Clash Display Regular",
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
                          fontFamily: "Clash Display",
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
                    onTap: _isSubmitting ? null : _submitReview,
                    child: Container(
                      height: 48.sp,
                      decoration: BoxDecoration(
                        color: _isSubmitting ? Colors.grey : blackColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4.sp),
                          bottomRight: Radius.circular(4.sp),
                        ),
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(child: LfLogoLoader(size: 12, showGlow: false)),
                              )
                            : const AppText(
                                text: "SUBMIT",
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
        fit: BoxFit.fill,
        errorWidget: (_, __, ___) =>
            Image.asset(dummyWishlistImage, fit: BoxFit.fill),
      );
    } else {
      return Image.asset(
        dummyWishlistImage,
        width: 80.sp,
        height: 100.sp,
        fit: BoxFit.fill,
      );
    }
  }

  /// ✅ Call API on Submit
  Future<void> _submitReview() async {
    if (_rating == 0) {
      showAppSnackBar('Please select a star rating before submitting.',
          type: SnackBarType.error);
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      showAppSnackBar('Please write a short review before submitting.',
          type: SnackBarType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? prefs.getInt('userId') ?? 0;

    // Extract productId from the product data
    final productId = widget.product["productId"] ??
        widget.product["product_id"] ??
        widget.product["product"]?["id"] ??
        0;

    final success = await productController.submitProductReview(
      userId: userId,
      productId: productId, // ✅ Added productId parameter
      orderItemId: widget.product["id"], // ✅ from order item
      variantId: widget.product["variantId"], // ✅ from API
      rating: _rating,
      comment: _reviewController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      showAppSnackBar('Your review has been submitted successfully.',
          type: SnackBarType.success);
      Get.back();
    } else {
      showAppSnackBar('Failed to submit review. Please try again.',
          type: SnackBarType.error);
    }
  }
}
