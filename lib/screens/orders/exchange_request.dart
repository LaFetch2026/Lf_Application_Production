import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/text/app_text.dart';
import 'package:lafetch/controllers/product_controller.dart';
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
  String? selectedColor;
  int? selectedVariantId;
  String? selectedReason;

  /// Reason ID -> Text mapping (Backend expects ID)
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

  /// Variants extracted from product object
  List<Map<String, dynamic>> variantOptions = [];

  List<String> colorOptions = [];
  List<String> sizeOptions = [];

  @override
  void initState() {
    super.initState();
    _loadFullProductDetails();
  }

  /// --------------------------------------------
  /// 🔥 UPDATED VARIANT LOGIC
  /// --------------------------------------------
  Future<void> _loadFullProductDetails() async {
    final productId = widget.order['product']?['id'];

    if (productId == null) {
      print("❌ productId missing in order!");
      return;
    }

    final fullProduct =
        await Get.find<ProductController>().fetchProductDetails(productId);

    if (fullProduct == null) {
      print("❌ Failed to load full product details!");
      return;
    }

    // Replace order.product with latest full product
    widget.order['product'] = fullProduct;

    // FIRST BUILD VARIANTS 🔥
    _initVariants();

    // Then resolve correct variant id
    _resolveVariantId();

    setState(() {});
  }

  void _initVariants() {
    final product = widget.order['product'] ?? {};
    final variants = (product['variants'] ?? []) as List;

    variantOptions.clear();

    for (final raw in variants) {
      if (raw is! Map) continue;
      final v = raw;

      String size = "";
      String color = "";

      if (v["selectedOptions"] is List) {
        for (final opt in v["selectedOptions"]) {
          final n = opt["name"].toString().toLowerCase();
          if (n == "size") size = opt["value"];
          if (n == "color" || n == "colour") color = opt["value"];
        }
      }

      final stock =
          int.tryParse("${v["inventory"]?["availableStock"] ?? 0}") ?? 0;

      variantOptions.add({
        "id": v["id"],
        "size": size,
        "color": color,
        "stocks": stock,
      });
    }

    // Color list
    colorOptions = variantOptions
        .map((e) => e["color"].toString())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    // Size list
    sizeOptions = variantOptions
        .map((e) => e["size"].toString())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  void _resolveVariantId() {
    if (selectedColor == null || selectedSize == null) return;

    final match = variantOptions.firstWhere(
      (v) => v['color'] == selectedColor && v['size'] == selectedSize,
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      selectedVariantId = match['id'];
    }
  }

  /// --------------------------------------------
  /// 🔥 GET REASON ID FROM TEXT
  /// --------------------------------------------
  int _getReasonId(String reasonText) {
    return reasons.entries.firstWhere((e) => e.value == reasonText).key;
  }

  /// --------------------------------------------
  /// UI BUILDING
  /// --------------------------------------------
  @override
  Widget build(BuildContext context) {
    final product = widget.order['product'] ?? {};
    final imageList = (product['imageUrls'] ?? []) as List;
    final imageUrl =
        imageList.isNotEmpty ? imageList.first.toString() : dummyWishlistImage;

    final productName = product['title'] ?? "Unknown Product";
    final description = product['shortDescription'] ??
        product['description'] ??
        "No description available";

    final qty = widget.order['quantity']?.toString() ?? "1";

    /// Display safe values
    final rawSize = widget.order['size']?.toString();
    final rawColor =
        widget.order['color']?.toString() ?? widget.order['colour']?.toString();

    final currentSize =
        (rawSize == null || rawSize == "null" || rawSize.isEmpty)
            ? selectedSize ?? "-"
            : rawSize;

    final currentColor =
        (rawColor == null || rawColor == "null" || rawColor.isEmpty)
            ? selectedColor ?? "-"
            : rawColor;

    /// Sizes available for selected color
    final sizeOptionsForColor = selectedColor == null
        ? []
        : variantOptions.where((v) => v['color'] == selectedColor).toList();

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
          text: "EXCHANGE REQUEST",
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w700,
          color: blackColor,
          fontSize: 16,
        ),
      ),

      // ------------------------------------------------------
      // BODY
      // ------------------------------------------------------
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PRODUCT HEADER
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
                        fontSize: 14,
                        color: blackColor,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 2.sp),
                      AppText(
                        text: description,
                        fontSize: 12,
                        maxLines: 2,
                        color: subtitleColor,
                      ),
                      SizedBox(height: 4.sp),
                      AppText(
                        text:
                            "Size: $currentSize   Color: $currentColor   Qty: $qty",
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.sp),

            /// COLOR SELECTOR -------------------------------------
            const AppText(
              text: "CHOOSE THE COLOR",
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),

            if (colorOptions.isEmpty)
              const AppText(
                text: "No colors available for exchange.",
                color: subtitleColor,
                fontSize: 12,
              )
            else
              Wrap(
                spacing: 8.sp,
                runSpacing: 8.sp,
                children: colorOptions.map((c) {
                  final isSelected = selectedColor == c;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = c;

                        /// Filter sizes for this color
                        final allowedSizes = variantOptions
                            .where((v) => v["color"] == c)
                            .map((v) => v["size"])
                            .toList();

                        if (!allowedSizes.contains(selectedSize)) {
                          selectedSize = null;
                        }

                        selectedVariantId = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.sp, vertical: 8.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.sp),
                        color: isSelected ? blackColor : whiteColor,
                        border: Border.all(
                          color: isSelected ? blackColor : Colors.grey.shade300,
                        ),
                      ),
                      child: AppText(
                        text: c,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? whiteColor : blackColor,
                      ),
                    ),
                  );
                }).toList(),
              ),

            SizedBox(height: 20.sp),

            /// SIZE SELECTOR -------------------------------------
            const AppText(
              text: "CHOOSE THE NEW SIZE",
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),

            if (selectedColor == null)
              const AppText(
                text: "Please select a color first.",
                color: subtitleColor,
                fontSize: 12,
              )
            else if (sizeOptionsForColor.isEmpty)
              const AppText(
                text: "No sizes available for the selected color.",
                color: subtitleColor,
                fontSize: 12,
              )
            else
              Wrap(
                spacing: 8.sp,
                runSpacing: 8.sp,
                children: sizeOptionsForColor.map((opt) {
                  final s = opt["size"].toString();
                  final stk = opt["stocks"] ?? 0;

                  final isSelected = selectedSize == s;
                  final out = stk == 0;

                  return GestureDetector(
                    onTap: out
                        ? null
                        : () {
                            setState(() {
                              selectedSize = s;

                              final match = variantOptions.firstWhere(
                                (v) =>
                                    v["color"] == selectedColor &&
                                    v["size"] == s,
                                orElse: () => {},
                              );

                              if (match.isNotEmpty) {
                                selectedVariantId = match["id"];
                              }
                            });
                          },
                    child: Opacity(
                      opacity: out ? 0.3 : 1,
                      child: Container(
                        width: 48.sp,
                        height: 40.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? blackColor : Colors.grey.shade300,
                          ),
                          color: isSelected ? blackColor : whiteColor,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                        child: AppText(
                          text: s,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? whiteColor : blackColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            SizedBox(height: 20.sp),

            /// REASON DROPDOWN -------------------------------------
            const AppText(
              text: "REASON FOR EXCHANGE",
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            SizedBox(height: 10.sp),

            DropdownButtonFormField<String>(
              value: selectedReason,
              dropdownColor: whiteColor,
              items: reasons.values
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(
                          r,
                          style:
                              const TextStyle(color: blackColor, fontSize: 12),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedReason = v),
              decoration: InputDecoration(
                hintText: "Select a reason",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.sp),
                ),
              ),
            ),

            SizedBox(height: 20.sp),

            /// INFO NOTE
            Row(
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: subtitleColor),
                SizedBox(width: 6.sp),
                const Expanded(
                  child: AppText(
                    text:
                        "Your replacement will be shipped once the item passes quality check. This typically takes 2–3 business days.",
                    color: subtitleColor,
                    fontSize: 11,
                    maxLines: 3,
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// FOOTER BUTTONS -------------------------------------
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      alignment: Alignment.center,
                      height: 48.sp,
                      color: const Color(0xFFF9FAFB),
                      child: const AppText(
                        text: "CANCEL",
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _submitExchange,
                    child: Container(
                      alignment: Alignment.center,
                      height: 48.sp,
                      color: blackColor,
                      child: const AppText(
                        text: "EXCHANGE ITEM",
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// --------------------------------------------
  /// SUBMIT EXCHANGE REQUEST (NOW FIXED)
  /// --------------------------------------------
  Future<void> _submitExchange() async {
    if (selectedColor == null) {
      Get.snackbar("Select Color", "Please select a color");
      return;
    }
    if (selectedSize == null || selectedVariantId == null) {
      Get.snackbar("Select Size", "Please select a size");
      return;
    }
    if (selectedReason == null) {
      Get.snackbar("Select Reason", "Please select a reason");
      return;
    }

    final reasonId = _getReasonId(selectedReason!); // int

    final success = await orderController.requestExchange(
      orderItemId: widget.order["id"],
      userId: widget.order["order"]["userId"],
      newVariantId: selectedVariantId!,
      reason: reasonId.toString(), // 🔥 FIXED — backend expects STRING
    );

    if (success) {
      Get.off(() => ExchangeStatusScreen(order: widget.order));
    }
  }

  /// --------------------------------------------
  /// IMAGE BUILDER
  /// --------------------------------------------
  Widget _buildProductImage(String url) {
    if (url.startsWith("http")) {
      return Image.network(
        url,
        height: 70.sp,
        width: 70.sp,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          dummyWishlistImage,
          height: 70.sp,
          width: 70.sp,
        ),
      );
    }
    return Image.asset(
      dummyWishlistImage,
      height: 70.sp,
      width: 70.sp,
    );
  }
}
