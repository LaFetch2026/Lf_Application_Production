import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/core/constant/constants.dart';
import 'package:lafetch/controllers/order_controller.dart';
import 'exchange_status.dart';

class ExchangeRequestScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const ExchangeRequestScreen({super.key, required this.order});

  @override
  State<ExchangeRequestScreen> createState() => _ExchangeRequestScreenState();
}

class _ExchangeRequestScreenState extends State<ExchangeRequestScreen> {
  final OrderController orderController = Get.put(OrderController());

  String? selectedSize;
  int? selectedVariantId;
  String? selectedReason;

  /// Reason ID -> Text mapping (as per backend)
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

  late List<Map<String, dynamic>> sizeOptions;

  @override
  void initState() {
    super.initState();
    _initSizes();
  }

  /// ✅ Dynamically builds size options from product variants.
  void _initSizes() {
    final product = widget.order['product'] ?? {};
    final variants = (product['variants'] ?? []) as List;

    if (variants.isNotEmpty) {
      sizeOptions = variants.map((variant) {
        String sizeValue = '';
        if (variant['selectedOptions'] is List) {
          final selectedOpt = (variant['selectedOptions'] as List).firstWhere(
            (opt) => opt['name'].toString().toLowerCase() == 'size',
            orElse: () => {},
          );
          sizeValue = selectedOpt['value']?.toString() ?? '';
        }

        final availableStock = variant['inventory']?['availableStock'] ??
            variant['available'] ??
            0;

        return {
          'id': variant['id'] ?? variant['shopifyVariantId'] ?? 0,
          'size': sizeValue,
          'availableStock': availableStock is int ? availableStock : 0,
        };
      }).toList();
    } else {
      // fallback only if product has no variant data
      sizeOptions = [
        {'id': 0, 'size': 'S', 'availableStock': 5},
        {'id': 0, 'size': 'M', 'availableStock': 5},
        {'id': 0, 'size': 'L', 'availableStock': 5},
        {'id': 0, 'size': 'XL', 'availableStock': 0},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.order['product'] ?? {};
    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl =
        imageList.isNotEmpty ? imageList.first : dummyWishlistImage;
    final productName = product['title'] ?? "Unknown Product";
    final description = product['shortDescription'] ??
        product['description'] ??
        "No description available";
    final currentSize = widget.order['size'] ?? "M";
    final qty = widget.order['quantity']?.toString() ?? "1";

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
          text: "EXCHANGE REQUEST",
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
                        text: "Size: $currentSize   Qty: $qty",
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

            // ✅ Size Selection
            const AppText(
              text: "CHOOSE THE NEW SIZE",
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),

            Wrap(
              spacing: 8.sp,
              runSpacing: 8.sp,
              children: sizeOptions.map((opt) {
                final s = opt['size'] ?? '';
                final availableStock = opt['availableStock'] ?? 0;
                final isSelected = selectedSize == s;
                final isOutOfStock = availableStock == 0;

                return GestureDetector(
                  onTap: isOutOfStock
                      ? null
                      : () => setState(() {
                            selectedSize = s;
                            selectedVariantId = opt['id'];
                          }),
                  child: Opacity(
                    opacity: isOutOfStock ? 0.4 : 1,
                    child: Container(
                      width: 48.sp,
                      height: 40.sp,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.sp),
                        border: Border.all(
                          color: isSelected ? blackColor : Colors.grey.shade300,
                        ),
                        color: isSelected ? blackColor : whiteColor,
                      ),
                      child: Center(
                        child: AppText(
                          text: s,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w700,
                          color: isSelected ? whiteColor : blackColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20.sp),

            // ✅ Reason Dropdown
            const AppText(
              text: "REASON FOR EXCHANGE",
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

            // ✅ Info Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: subtitleColor, size: 18.sp),
                SizedBox(width: 6.sp),
                const Expanded(
                  child: AppText(
                    text:
                        "Your replacement will be shipped once the item passes quality check. This typically takes 2–3 business days.",
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
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
                    onTap: () async {
                      if (selectedVariantId == null) {
                        Get.snackbar("Select Size",
                            "Please select a new size to continue",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            colorText: Colors.redAccent);
                        return;
                      }

                      if (selectedReason == null) {
                        Get.snackbar("Select Reason",
                            "Please select a reason before continuing",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            colorText: Colors.redAccent);
                        return;
                      }

                      final orderItemId = widget.order['id'] ?? 0;
                      final userId = widget.order['order']?['userId'] ?? 0;

                      final success = await orderController.requestExchange(
                        orderItemId: orderItemId,
                        userId: userId,
                        newVariantId: selectedVariantId!,
                        reason: selectedReason!,
                      );

                      if (success) {
                        Get.off(
                            () => ExchangeStatusScreen(order: widget.order));
                      }
                    },
                    child: Container(
                      height: 48.sp,
                      color: blackColor,
                      child: const Center(
                        child: AppText(
                          text: "EXCHANGE ITEM",
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

  /// ✅ Safe Product Image with fallback
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
