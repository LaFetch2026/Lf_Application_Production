// ignore_for_file: avoid_print, deprecated_member_use

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';
import 'package:lafetch/controllers/cart_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/catalog/productlist/ProductImageScreen.dart';
import 'package:lafetch/screens/catalog/productlist/ReviewOrderScreen.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:share_plus/share_plus.dart';
// ✅ Razorpay import
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/widget/appbar/productdetails_appbar.dart';
import '../../../common/widget/bottom_sheets/bottomwishlist.dart';
import '../../../common/widget/button/oublebutton_iconnew.dart';
import '../../../common/widget/lists/dummy_container.dart';
import '../../../common/widget/lists/dummy_productImage.dart';
import '../../../common/widget/lists/dummy_productdetails.dart';
import '../../../common/widget/text/app_space_text.dart';
import '../../../controllers/brand_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../core/utils/analytics_helper.dart';
import '../../cartscreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String type;
  final String brandName;
  final int wishlistProductId;
  final int boardId;
  final String Slug;
  final Color backgroundcolor;
  final String expresshour;
  final int expressValue;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.backgroundcolor = whiteColor,
    this.brandName = "",
    required this.type,
    this.boardId = 0,
    this.Slug = "",
    this.expresshour = "0",
    this.expressValue = 0,
    this.wishlistProductId = 0,
  });

  @override
  State<ProductDetailsScreen> createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController controller = PageController();
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final brandController = Get.put(BrandController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didEnsureSize = false;

  int _curr = 0;
  int commentId = 0;
  int reviewHelpfulId = 0;
  Map<String, dynamic> selectedProductFabric = {};
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var cartQuantityItems = 0;
  final GlobalKey widgetKey = GlobalKey();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  RegExp regExp = RegExp("");
  final PageController _pageController = PageController(initialPage: 0);
  final ScrollController _scrollController = ScrollController();

  // --- spacing scale (use instead of raw 12.sp/18.sp/etc.) ---
  final double gXS = 4.sp; // micro
  final double gS = 6.sp; // small
  final double gM = 8.sp; // medium
  final double gL = 12.sp; // large

  // ===================== QUANTITY STATE =====================
  int _selectedQuantity = 1;

  // ---------- helpers ----------
  final cartController =
      Get.put(CartController()); // ensures controller is available

  // ===================== BUY NOW + RAZORPAY STATE =====================
  // Your LIVE Razorpay key

  // Razorpay instance
  Razorpay? _razorpay;

  // Set to true when user picked an address in SavedAddressScreen
  bool _addressSelected = false;

  // Optionally keep whatever the address screen returns (Map/true/etc.)
  dynamic _addressResult;

  bool _isImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  List<String> _imagesOnly() {
    // ✅ Use currentDisplayImages from controller (color-specific)
    if (productController.currentDisplayImages.isNotEmpty) {
      final images = productController.currentDisplayImages
          .where((u) => u.isNotEmpty && _isImageUrl(u))
          .toList();

      if (images.isNotEmpty) {
        print("✅ Using currentDisplayImages: ${images.length} images");
        return images;
      }
    }

    // Fallback: imageList
    if (productController.imageList.isNotEmpty) {
      final images = productController.imageList
          .map((e) => (e['name']?.toString() ?? '').trim())
          .where((u) => u.isNotEmpty && _isImageUrl(u))
          .toList();

      if (images.isNotEmpty) {
        print("✅ Using imageList: ${images.length} images");
        return images;
      }
    }

    // Fallback: imageUrls from productDetails
    final imageUrls = productController.productDetails['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      final images = imageUrls
          .map((url) => url.toString().trim())
          .where((u) => u.isNotEmpty && _isImageUrl(u))
          .toList();

      print("✅ Using imageUrls from productDetails: ${images.length} images");
      return images;
    }

    print("⚠️ No images found!");
    return [];
  }

  int _imageCount() => _imagesOnly().length;

  Map<String, dynamic>? _selSize() {
    final s = productController.selectedProductSize;

    if (s is RxMap) {
      final value = s.value;
      return value.isEmpty ? null : Map<String, dynamic>.from(value);
    }

    if (s is Rx) {
      final value = s.value;
      if (value is Map && value.isNotEmpty) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    if (s is Map && s.isNotEmpty) {
      return Map<String, dynamic>.from(s);
    }

    return null;
  }

  Map<String, dynamic> _pd() {
    final raw = productController.productDetails;
    if (raw is Map) return Map<String, dynamic>.from(raw as Map);
    try {
      final val = (raw as dynamic).value;
      if (val is Map) return Map<String, dynamic>.from(val as Map);
    } catch (_) {}
    return <String, dynamic>{};
  }

  num _displayPrice() {
    // Try to get from selected variant
    final variant = productController.getSelectedVariant();
    if (variant != null && variant['price'] is num) {
      return variant['price'] as num;
    }

    // Fallback to product details
    final pd = productController.productDetails;
    final price =
        pd['basePrice'] ?? pd['netAmount'] ?? pd['price'] ?? pd['msp'];

    if (price is num && price > 0) return price;
    return num.tryParse(price?.toString() ?? '0') ?? 0;
  }

  num _displayMrp() {
    final pd = productController.productDetails;
    final mrp = pd['mrp'] ?? pd['manufacturingAmount'];

    if (mrp is num && mrp > 0) return mrp;
    return num.tryParse(mrp?.toString() ?? '0') ?? 0;
  }

  String _discountPctStr() {
    final price = _displayPrice();
    final mrp = _displayMrp();
    if (mrp > price && mrp > 0) {
      final pct = ((mrp - price) / mrp) * 100.0;
      return "${pct.toStringAsFixed(0)}%";
    }
    return "0%";
  }

  String _brandText() {
    final m = _pd();

    // Try multiple sources
    final b1 = m['brand_name'];
    final b2 = (m['brand'] is Map ? m['brand']['name'] : null);
    final b3 = widget.brandName;

    final brand = (b1 ?? b2 ?? b3 ?? "").toString();
    print("🏷️ Brand name: $brand");
    return brand;
  }

  String _titleText() {
    final m = _pd();
    final title = m['name'] ?? m['title'] ?? "";
    print("📝 Product title: $title");
    return title.toString();
  }

  // Add Review Modal State
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  void _showAddReviewModal() {
    // Reset state
    _selectedRating = 0;
    _reviewController.clear();

    final firstImg = _imagesOnly().isNotEmpty ? _imagesOnly().first : '';
    final brandName = _brandText();
    final productTitle = _titleText();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 255, 137, 137),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.sp),
                topRight: Radius.circular(20.sp),
              ),
            ),
            child: Column(
              children: [
                // Handle Bar
                Container(
                  margin: EdgeInsets.only(top: 12.sp),
                  width: 40.sp,
                  height: 4.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.sp),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppSpacingText(
                        text: 'WRITE A REVIEW',
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w600,
                        color: blackColor,
                        fontSize: 18,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 24.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Divider(color: colorSecondary, height: 1),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Info Card
                        Container(
                          padding: EdgeInsets.all(12.sp),
                          decoration: BoxDecoration(
                            color: colorSecondary,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.sp),
                                child: firstImg.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: firstImg,
                                        width: 80.sp,
                                        height: 80.sp,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          dummyWishlistImage,
                                          width: 80.sp,
                                          height: 80.sp,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        dummyWishlistImage,
                                        width: 80.sp,
                                        height: 80.sp,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              SizedBox(width: 12.sp),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (brandName.isNotEmpty)
                                      AppSpacingText(
                                        text: brandName.toUpperCase(),
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w600,
                                        color: blackColor,
                                        fontSize: 12,
                                        maxLines: 1,
                                      ),
                                    SizedBox(height: 4.sp),
                                    AppSpacingText(
                                      text: productTitle,
                                      fontFamily: "Clash Display Regular",
                                      fontWeight: FontWeight.w400,
                                      color: subtitleColor,
                                      fontSize: 12,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.sp),

                        // Star Rating
                        AppSpacingText(
                          text: 'Rate this product',
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                          fontSize: 14,
                        ),
                        SizedBox(height: 12.sp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.sp),
                                child: Icon(
                                  index < _selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 36.sp,
                                  color: const Color(0xFFFFB800),
                                ),
                              ),
                            );
                          }),
                        ),

                        SizedBox(height: 24.sp),

                        // Review Text Field
                        AppSpacingText(
                          text: 'Write your review',
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                          fontSize: 14,
                        ),
                        SizedBox(height: 12.sp),
                        TextField(
                          controller: _reviewController,
                          maxLines: 6,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText:
                                'Share your thoughts about this product...',
                            hintStyle: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 13.sp,
                              color: textHintColor,
                            ),
                            filled: true,
                            fillColor: colorSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                              borderSide: BorderSide(
                                color: colorPrimary,
                                width: 1.sp,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(12.sp),
                          ),
                          style: TextStyle(
                            fontFamily: "Clash Display Regular",
                            fontSize: 13.sp,
                            color: blackColor,
                          ),
                        ),

                        SizedBox(height: 24.sp),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final isSubmitting =
                        productController.isSubmittingReview.value;

                    return ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (_selectedRating == 0) {
                                showAppSnackBar('Please select a rating',
                                    type: SnackBarType.error);
                                return;
                              }

                              if (_reviewController.text.trim().isEmpty) {
                                showAppSnackBar('Please write a review',
                                    type: SnackBarType.error);
                                return;
                              }

                              final navigator = Navigator.of(context);

                              // Get userId from SharedPreferences
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;

                              if (userId == 0) {
                                showAppSnackBar(
                                    'Please login to submit a review',
                                    type: SnackBarType.error);
                                return;
                              }

                              // Get selected variant - improved logic
                              var variant =
                                  productController.getSelectedVariant();

                              // If no variant selected but variants exist, try to get the first available one
                              if (variant == null &&
                                  productController
                                      .selectedVariants.isNotEmpty) {
                                variant =
                                    productController.selectedVariants.first;
                                print(
                                    "⚠️ No variant selected, using first variant: ${variant['id']}");
                              }

                              final variantId = variant?['id'] ?? 0;

                              if (variantId == 0) {
                                // More helpful error message
                                final hasSizes = productController
                                    .sizeInventoryList.isNotEmpty;
                                final hasColors = productController
                                    .colorInventoryList.isNotEmpty;

                                String errorMsg = 'Please select ';
                                if (hasSizes && hasColors) {
                                  errorMsg += 'size and color first';
                                } else if (hasSizes) {
                                  errorMsg += 'a size first';
                                } else if (hasColors) {
                                  errorMsg += 'a color first';
                                } else {
                                  errorMsg = 'Product variant not available';
                                }

                                showAppSnackBar(errorMsg,
                                    type: SnackBarType.error);
                                return;
                              }

                              // Submit review
                              final success =
                                  await productController.submitProductReview(
                                userId: userId,
                                productId: widget.productId,
                                orderItemId: 0, // 0 for reviews not from orders
                                variantId: variantId,
                                rating: _selectedRating,
                                comment: _reviewController.text.trim(),
                              );

                              if (success) {
                                navigator.pop();
                                // Refresh reviews after successful submission
                                await productController
                                    .getProductReviews(widget.productId);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSubmitting ? Colors.grey : blackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                        minimumSize: Size(double.infinity, 48.sp),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        whiteColor),
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Text(
                                  'SUBMITTING...',
                                  style: TextStyle(
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w600,
                                    color: whiteColor,
                                    fontSize: 14.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'SUBMIT REVIEW',
                              style: TextStyle(
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                                fontSize: 14.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Product Logger Helper Method
  void _logBuyNowAction({
    String action = "BUY NOW",
    bool isCartFlow = false,
  }) {
    print("=== $action CLICKED ===");
    print("Action Type: ${isCartFlow ? 'From Cart Flow' : 'Direct Purchase'}");
    print("Product ID: ${widget.productId}");
    print("Product Name: ${_titleText()}");
    print("Brand Name: ${_brandText()}");
    final selectedSize = _selSize();
    if (selectedSize != null) {
      print("Selected Size: ${selectedSize}");
      print(
          "Selected Size Label: ${selectedSize['product_matrix_size_name'] ?? selectedSize['title'] ?? 'Unknown'}");
    } else {
      print("Selected Size: null (No size selected)");
    }
    print("Selected Color: ${productController.selectedProductColor}");
    print("Selected Quantity: $_selectedQuantity"); // ✅ Added quantity logging
    print("Price: ₹${_displayPrice().toStringAsFixed(0)}");
    print("MRP: ₹${_displayMrp().toStringAsFixed(0)}");
    print(
        "Total Price: ₹${(_displayPrice() * _selectedQuantity).toStringAsFixed(0)}"); // ✅ Added total price
    print("Discount: ${_discountPctStr()}");
    print("Size Inventory ID: ${productController.sizeInventoryId.value}");
    print("Color Inventory ID: ${productController.colorInventoryId.value}");
    print("Express Value: ${widget.expressValue}");
    print("Express Hour: ${widget.expresshour}");
    print("Background Color: ${widget.backgroundcolor}");
    print("Type: ${widget.type}");
    print("Slug: ${widget.Slug}");
    print("Board ID: ${widget.boardId}");
    print("Wishlist Product ID: ${widget.wishlistProductId}");
    // print("Total Stock: ${_totalStockCount()}");

    print("Product Details Keys: ${_pd().keys.toList()}");
    print("Timestamp: ${DateTime.now()}");
    print("${"=" * (action.length + 20)}");
  }

  // ===================== RAZORPAY FLOW =====================

  Future<void> _onBuyNowPressed({required bool isCartFlow}) async {
    // Validate selection
    if (!productController.checkDetailsValidation()) {
      return;
    }

    _logBuyNowAction(action: "BUY NOW", isCartFlow: isCartFlow);

    // Get selected variant
    final variant = productController.getSelectedVariant();
    if (variant == null) {
      showAppSnackBar('Please select size and color', type: SnackBarType.error);
      return;
    }

    final variantId = variant['id'] as int;
    final stock = int.tryParse(variant['stocks']?.toString() ?? '0') ?? 0;

    if (stock <= 0) {
      showAppSnackBar('Selected variant is out of stock',
          type: SnackBarType.error);
      return;
    }

    final firstImg = _imagesOnly().isNotEmpty ? _imagesOnly().first : '';

    final sizeLabel = "${productController.selectedSize.value}" +
        (productController.selectedColor.value.isNotEmpty
            ? " / ${productController.selectedColor.value}"
            : "");

    // ✅ Use the selected quantity from the quantity selector
    final initialQuantity = _selectedQuantity;

    // ========================================
    // ✅ FETCH COMPLETE VARIANT DATA FROM API
    // ========================================

    print("🔍 === Fetching Complete Variant Data ===");
    print("Product ID: ${widget.productId}");
    print("Variant ID: $variantId");

    String? hsnCode;
    double? gstRate;
    double? statutoryGSTRate;
    String? gstRuleApplied;

    try {
      // Fetch fresh product details from API
      showLoading(); // Show loading indicator

      final productDetails =
          await productController.fetchProductDetails(widget.productId);

      if (productDetails != null && productDetails["variants"] != null) {
        final variants = List<Map<String, dynamic>>.from(
            (productDetails["variants"] as List).whereType<Map>());

        print("📦 Found ${variants.length} variants in API response");

        // Find the matching variant by ID
        final matchingVariant = variants.firstWhere(
          (v) => v["id"] == variantId,
          orElse: () => {},
        );

        if (matchingVariant.isNotEmpty) {
          print("✅ Found matching variant in API response");

          // Extract GST data from variant
          hsnCode = matchingVariant["hsn_code"]?.toString() ??
              matchingVariant["hsnCode"]?.toString();

          gstRate = _extractDouble(
              matchingVariant["gst_rate"] ?? matchingVariant["gstRate"]);

          statutoryGSTRate = _extractDouble(
              matchingVariant["statutory_gst_rate"] ??
                  matchingVariant["statutoryGSTRate"] ??
                  matchingVariant["gst_rate"] ??
                  matchingVariant["gstRate"]);

          gstRuleApplied = matchingVariant["gst_rule"]?.toString() ??
              matchingVariant["gstRule"]?.toString();

          print("📋 Extracted from variant:");
          print("   HSN Code: $hsnCode");
          print("   GST Rate: $gstRate");
          print("   Statutory GST Rate: $statutoryGSTRate");
          print("   GST Rule Applied: $gstRuleApplied");
        } else {
          print("⚠️ Variant $variantId not found in API response");
        }

        // Fallback to product-level GST data if variant doesn't have it
        if (hsnCode == null || hsnCode.isEmpty || gstRate == null) {
          print("📦 Falling back to product-level GST data");

          hsnCode = hsnCode ??
              productDetails["hsn_code"]?.toString() ??
              productDetails["hsnCode"]?.toString();

          gstRate = gstRate ??
              _extractDouble(
                  productDetails["gst_rate"] ?? productDetails["gstRate"]);

          statutoryGSTRate = statutoryGSTRate ??
              _extractDouble(productDetails["statutory_gst_rate"] ??
                  productDetails["statutoryGSTRate"]) ??
              gstRate;

          gstRuleApplied = gstRuleApplied ??
              productDetails["gst_rule"]?.toString() ??
              productDetails["gstRule"]?.toString();

          print("📋 Extracted from product:");
          print("   HSN Code: $hsnCode");
          print("   GST Rate: $gstRate");
          print("   Statutory GST Rate: $statutoryGSTRate");
          print("   GST Rule Applied: $gstRuleApplied");
        }
      } else {
        print("❌ Failed to fetch product details from API");
      }

      hideLoading(); // Hide loading indicator
    } catch (e) {
      hideLoading();
      print("❌ Error fetching variant data: $e");
    }

    // ========================================
    // ✅ FINAL VALIDATION & DEFAULTS
    // ========================================

    // Set safe defaults if still missing
    hsnCode = hsnCode ?? "";
    gstRate = gstRate ?? 0.0;
    statutoryGSTRate = statutoryGSTRate ?? gstRate;
    gstRuleApplied = gstRuleApplied ?? "VALUE_BASED";

    print("==========================");
    print("📦 Final Values:");
    print("   Product ID: ${widget.productId}");
    print("   Variant ID: $variantId");
    print("   Price: ${productController.getDisplayPrice()}");
    print("   MRP: ${productController.getDisplayMrp()}");
    print("   HSN Code: $hsnCode");
    print("   GST Rate: $gstRate");
    print("   Statutory GST Rate: $statutoryGSTRate");
    print("   GST Rule Applied: $gstRuleApplied");
    print("==========================");

    // Show warning if GST data is still missing
    if (hsnCode.isEmpty || gstRate == 0) {
      print("⚠️ Warning: GST data is incomplete!");
      showAppSnackBar(
          'Tax information incomplete. Proceeding with available data.',
          type: SnackBarType.warning);
    }

    // ========================================
    // ✅ NAVIGATE TO REVIEW ORDER SCREEN
    // ========================================
    Get.to(() => ReviewOrderScreen(
          productId: widget.productId,
          variantId: variantId,
          title: _titleText(),
          brandName: _brandText(),
          imageUrl: firstImg,
          sizeLabel: sizeLabel,
          quantity: initialQuantity,
          price: productController.getDisplayPrice().toDouble(),
          mrp: productController.getDisplayMrp().toDouble(),
          maxStock: stock,
          initialAddress:
              _addressSelected ? _addressResult as Map<String, dynamic>? : null,
          hsnCode: hsnCode,
          gstRate: gstRate,
          statutoryGSTRate: statutoryGSTRate,
          gstRuleApplied: gstRuleApplied,
        ));
  }

// ========================================
// ✅ HELPER METHODS
// ========================================

// Add these if not already in your class
  void showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

// ========================================
// ✅ HELPER METHOD TO EXTRACT DOUBLE
// ========================================
  double? _extractDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
  // Razorpay callbacks

  Future<String> generateProductShareLink() async {
    final productId =
        productController.productDetails["id"] ?? widget.productId;
    final slug = productController.productDetails["slug"] ?? "";

    // Build your link with parameters
    final Uri link = Uri.https(
      "lafetch.onelink.me",
      "/rxDU",
      {
        "product_id": productId.toString(),
        "slug": slug.toString(),
        "af_dp": "productdetails",
        "af_channel": "product_share",
        "c": "product_share",
      },
    );

    return link.toString();
  }

  // ===================== /RAZORPAY FLOW =====================

  // ---------- IMAGES UI ----------

  List<Widget> getListForPageView() {
    final imagesOnly = _imagesOnly();

    if (imagesOnly.isEmpty) {
      return [Image.asset(dummyWishlistImage, fit: BoxFit.cover)];
    }

    final List<Widget> list = [];
    for (var i = 0; i < imagesOnly.length; i++) {
      final url = imagesOnly[i];

      list.add(
        GestureDetector(
          onTap: () {
            final imagesOnly = _imagesOnly();
            final gallery =
                imagesOnly.map((u) => {'name': u, 'isVideo': false}).toList();
            final safeIndex = (i >= 0 && i < gallery.length) ? i : 0;
            Get.to(() => ProductImage_Screen(curr: safeIndex, list: gallery));
          },
          child: Hero(
            tag: url,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0,
              color: colorSecondary,
              child: CachedNetworkImage(
                cacheManager: CacheManager(
                  Config(
                    "customCacheKey",
                    stalePeriod: Duration(days: 15),
                    maxNrOfCacheObjects: 100,
                  ),
                ),
                fit: BoxFit.cover, // ✅ Changed to cover
                imageUrl: url,
                width: double.infinity,
                height: double.infinity,
                progressIndicatorBuilder: (context, url, _) => DummyContainer(
                  height: MediaQuery.of(context).size.height * 0.54,
                  width: MediaQuery.of(context).size.width,
                ),
                errorWidget: (context, url, error) =>
                    Image.asset(downloadImage, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );
    }

    return list;
  }

  Widget getListForProductSize() {
    return Obx(() {
      final sizes = productController.sizeInventoryList;

      if (sizes.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gL, vertical: 6),
          child: Wrap(
            spacing: gM,
            runSpacing: gS,
            children: sizes.map((size) {
              final isSelected = productController.selectedSize.value == size;

              // Get stock count for this size across all colors
              final sizeStock = productController.selectedVariants
                  .where((v) => v["size"] == size)
                  .fold<int>(
                      0,
                      (sum, v) =>
                          sum +
                          (int.tryParse(v['stocks']?.toString() ?? '0') ?? 0));

              final isOutOfStock = sizeStock <= 0;
              final isFreeSize = size.toUpperCase() == 'FREE SIZE';

              return Opacity(
                opacity: isOutOfStock ? 0.4 : 1.0,
                child: IgnorePointer(
                  ignoring: isOutOfStock,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          productController.selectedSize.value = size;
                          productController.loadColorsForSize(size);
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(0);
                          }
                          setState(() {
                            _selectedQuantity =
                                1; // ✅ Reset quantity when size changes
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: widget.backgroundcolor == whiteColor
                                  ? btnTextColor
                                  : searchTextColor,
                              width: 1.sp,
                            ),
                            color: isSelected
                                ? (widget.backgroundcolor == whiteColor
                                    ? colorPrimary
                                    : lightPurpleColor)
                                : (widget.backgroundcolor == whiteColor
                                    ? whiteColor
                                    : homeAppBarColor),
                          ),
                          child: SizedBox(
                            width: isFreeSize ? 70.sp : 44.sp,
                            height: 42.sp,
                            child: Center(
                              child: AppSpacingText(
                                text: size.toUpperCase(),
                                fontFamily: "Clash Display Regular",
                                fontWeight: FontWeight.w400,
                                color: isSelected
                                    ? whiteColor
                                    : (widget.backgroundcolor == whiteColor
                                        ? btnTextColor
                                        : searchTextColor),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (sizeStock <= 2 && sizeStock > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 4.sp),
                          child: AppSpacingText(
                            text: 'Only $sizeStock left',
                            fontFamily: "Clash Display Regular",
                            fontWeight: FontWeight.w400,
                            color: redColor,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget getListForProductColor() {
    return Obx(() {
      final colors = productController.colorInventoryList;

      if (colors.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gL, vertical: 8.sp),
          child: Wrap(
            spacing: gM,
            runSpacing: gS,
            children: colors.map((color) {
              final isSelected = productController.selectedColor.value == color;

              // Get stock
              Map<String, dynamic>? variant;
              if (productController.sizeInventoryList.isEmpty) {
                variant = productController.selectedVariants
                    .firstWhereOrNull((v) => v["color"] == color);
              } else {
                variant = productController.selectedVariants.firstWhereOrNull(
                    (v) =>
                        v["size"] == productController.selectedSize.value &&
                        v["color"] == color);
              }

              final stock =
                  int.tryParse(variant?['stocks']?.toString() ?? '0') ?? 0;

              final isOutOfStock = stock <= 0;

              return Opacity(
                opacity: isOutOfStock ? 0.4 : 1.0,
                child: IgnorePointer(
                  ignoring: isOutOfStock,
                  child: GestureDetector(
                    onTap: () {
                      productController.selectedColor.value = color;
                      productController.updateImagesForSelectedColor();

                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }

                      setState(() {
                        _selectedQuantity =
                            1; // ✅ Reset quantity when color changes
                      });
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 40.sp,
                            width: 60.sp,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: widget.backgroundcolor == whiteColor
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.15),
                              border: Border.all(
                                color:
                                    isSelected ? colorPrimary : searchTextColor,
                                width: isSelected ? 2.sp : 1.sp,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                color.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9.sp,
                                  color: widget.backgroundcolor == whiteColor
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          if (stock <= 2 && stock > 0)
                            Text(
                              'Only $stock left',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: redColor,
                                fontFamily: "Clash Display",
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: widget.backgroundcolor == whiteColor
            ? statusBarColor
            : homeAppBarColor,
        statusBarIconBrightness: widget.backgroundcolor == whiteColor
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: widget.backgroundcolor == whiteColor
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: widget.backgroundcolor == whiteColor
            ? statusBarColor
            : homeAppBarColor,
      ),
    );
  }

  @override
  void initState() {
    setStatusBarColor();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.errorMsg.value = "";
      productController.errorSizeMsg.value = "";
      productController.errorColorMsg.value = "";
      productController.selectedSize.value = "";
      productController.selectedColor.value = "";
      productController.sizeInventoryList.clear();
      productController.colorInventoryList.clear();
      productController.selectedVariants.clear();

      // ✅ Reset quantity when loading new product
      setState(() {
        _selectedQuantity = 1;
      });

      print("🚀 Loading product ID: ${widget.productId}");

      productController.getProductById(widget.productId).then((_) {
        print("✅ Product loaded successfully");
        print(
            "📦 Product Details: ${productController.productDetails.keys.toList()}");
        print("🖼️ Image List: ${productController.imageList.length} images");
        print("📏 Sizes: ${productController.sizeInventoryList.toList()}");
        print("🎨 Colors: ${productController.colorInventoryList.toList()}");
        print("✅ Selected Size: ${productController.selectedSize.value}");
        print("✅ Selected Color: ${productController.selectedColor.value}");

        final productId =
            productController.productDetails["id"] as int? ?? widget.productId;

        wishlistController.checkIfWishlisted(productId);
        productController.getProductReviews(productId);
      });
    });

    // ... rest of init code
  }

  void _openSizeChartDialog() async {
    await productController.fetchSizeChart(
      brandId: productController.productDetails["brand"]?["id"] ?? 0,
      superCatId: productController.productDetails["superCatId"] ?? 0,
      catId: productController.productDetails["catId"] ?? 0,
      subCatId: productController.productDetails["subCatId"] ?? 0,
    );

    final chart = productController.sizeChart;
    final chartData = productController.sizeChartData;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.sp),
          backgroundColor: Colors.white, // ⭐ light purple color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Container(
            padding: EdgeInsets.all(16.sp),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- Title ----------
                  Text(
                    chart["title"]?.toString() ?? "Size Chart",
                    style: TextStyle(
                      fontFamily: "Clash Display",
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 14.sp),

                  /// ---------- Prefer Image ----------
                  if (chart["sizeGuideImage"] != null &&
                      chart["sizeGuideImage"].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: CachedNetworkImage(
                        imageUrl: chart["sizeGuideImage"],
                        width: double.infinity,
                        height: 300.sp,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    _buildSizeTable(chartData),

                  SizedBox(height: 18.sp),

                  /// Close Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // ⭐ Proper dark button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        minimumSize: Size(180.sp, 48.sp),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    try {
      _razorpay?.clear();
    } catch (_) {}
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 25.sp,
      width: 25.sp,
      opacity: 0.80,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: widget.backgroundcolor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: widget.backgroundcolor == whiteColor,
              child: ProductdetailsAppbar(
                productId:
                    productController.productDetails["id"] ?? widget.productId,
                type:
                    productController.productDetails["type"]?.toString() ?? "",
                brandName: productController.productDetails["brand_name"]
                        ?.toString() ??
                    "",
                slug:
                    productController.productDetails["slug"]?.toString() ?? "",
                dark: false,
                onPressedHeart: () async {
                  // ✅ Check if user is guest
                  final prefs = await SharedPreferences.getInstance();
                  final isGuest = prefs.getBool('skip') ?? false;

                  if (isGuest) {
                    showAppSnackBar("Please login to add to wishlist",
                        type: SnackBarType.error);
                    Get.toNamed('/login'); // or your login route
                    return;
                  }

                  final firstImg = productController.imageList.isNotEmpty
                      ? (productController.imageList.first['name']
                              ?.toString() ??
                          '')
                      : '';

                  final productId =
                      (productController.productDetails["id"] as int?) ??
                          widget.productId;

                  scaffoldKey.currentState?.showBottomSheet(
                    (context) => BottomWishlist(
                      controller: wishlistController,
                      wishlistList: wishlistController.wishlistList,
                      productImage: firstImg,
                      onPressedBoard: () {/* open create board screen */},
                      onPressed: (boardId) async {
                        await wishlistController.addProductToBoard(
                            boardId, productId);

                        Get.back();
                      },
                    ),
                  );
                },
                onPressedShare: () async {
                  // ✅ Share doesn't require authentication - safe for guests
                  final title = _titleText();
                  Share.share(title.isNotEmpty ? title : "Check this product");

                  await analytics.logEvent(
                    name: 'share_product',
                    parameters: <String, Object>{'page_name': 'share_product'},
                  );
                },
                onPressedCart: () async {
                  // ✅ Check if user is guest
                  final prefs = await SharedPreferences.getInstance();
                  final isGuest = prefs.getBool('skip') ?? false;

                  if (isGuest) {
                    showAppSnackBar("Please login to view cart",
                        type: SnackBarType.error);
                    Get.toNamed('/login');
                    return;
                  }

                  // Navigate to cart screen
                  Get.to(const CartScreen());
                },
              ),
            ),

            Visibility(
              visible: widget.backgroundcolor == blackColor,
              child: Container(height: 1.sp, color: dividerColor),
            ),

            // ================= BODY =================
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Stack(
                  children: [
                    Visibility(
                      visible: widget.backgroundcolor != whiteColor,
                      child: Positioned(
                        top: 0,
                        right: 0,
                        child: Image.asset(quickBackCircle,
                            height: 250.sp, width: 300.sp),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: widget.backgroundcolor != whiteColor,
                          child: Padding(
                            padding: EdgeInsets.only(left: 2.sp, top: 0.sp),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: SvgPicture.asset(
                                    arrowBack,
                                    color: whiteColor,
                                    height: 15.sp,
                                    width: 15.sp,
                                    fit: BoxFit.cover,
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 80.sp,
                                  child: AppSpacingText(
                                    text: widget.brandName.toUpperCase(),
                                    color: whiteColor,
                                    fontSize: 16,
                                    maxLines: 1,
                                    fontFamily: "Clash Display Semibold",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ---------- IMAGES ----------
                        Obx(
                          () => productController.isDetails.value
                              ? const DummyProductImage()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image Container with Rating Badge - FULL WIDTH
                                    Stack(
                                      children: [
                                        // PageView for Images - NO PADDING
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.54,
                                          child: PageView(
                                            controller: _pageController,
                                            allowImplicitScrolling: true,
                                            scrollDirection: Axis.horizontal,
                                            onPageChanged: (number) {
                                              _curr = number;
                                              setState(() {});
                                            },
                                            children: getListForPageView(),
                                          ),
                                        ),
                                        // Rating Badge - Bottom Right (positioned over image)
                                        Positioned(
                                          bottom: 12.sp,
                                          right: 12.sp,
                                          child: Obx(() {
                                            final avgRating = productController
                                                .averageRating.value;

                                            if (avgRating <= 0)
                                              return const SizedBox
                                                  .shrink(); // hide if no rating

                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.sp,
                                                  vertical: 5.sp),
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16.sp),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        const Color(0xFFFFA500),
                                                    size: 14.sp,
                                                  ),
                                                  SizedBox(width: 3.sp),
                                                  Text(
                                                    avgRating
                                                        .toStringAsFixed(1),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "Clash Display",
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: blackColor,
                                                      fontSize: 13.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    // Page Indicator Dots
                                    _imageCount() <= 1
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              left: gL,
                                              right: gL,
                                              top: gS,
                                            ),
                                            child: Center(
                                              child: PageIndicator(
                                                controller: _pageController,
                                                count: _imageCount(),
                                                size: 5.0.sp,
                                                activeColor:
                                                    widget.backgroundcolor ==
                                                            whiteColor
                                                        ? Colors.black
                                                        : whiteColor,
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? const Color(0xffE5E7EB)
                                                    : subtitleColor,
                                                layout:
                                                    PageIndicatorLayout.WARM,
                                                scale: 0.6,
                                                space: gS,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                        ),
                        // ---------- DETAILS ----------
                        Obx(() {
                          final loading = productController.isDetails.value;

                          if (loading) return const DummyProductDetails();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 12.sp),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Visibility(
                                        visible: _titleText().isNotEmpty,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.sp,
                                              vertical: 8.sp),
                                          child: AppSpacingText(
                                            text: _titleText(),
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w600,
                                            color: widget.backgroundcolor ==
                                                    whiteColor
                                                ? blackColor
                                                : productSubtitleColor,
                                            maxLines: 2,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    (productController.brandDetails != null &&
                                            productController.brandDetails !=
                                                "")
                                        ? GestureDetector(
                                            onTap: () async {
                                              final brandId = productController
                                                          .productDetails[
                                                      "brand"]?["id"] as int? ??
                                                  0;

                                              if (brandId > 0) {
                                                await analytics.logEvent(
                                                  name: 'view_brand',
                                                  parameters: <String, Object>{
                                                    'brand_id': brandId,
                                                  },
                                                );

                                                Get.to(() => AllBrandScreen(
                                                      id: brandId,
                                                      screen: 'brand',
                                                      slug:
                                                          '${productController.productDetails["brand"]?["slug"] ?? ''}',
                                                    ));
                                              }
                                            },
                                            child: Container(
                                              color: const Color(0xFFDFDBFF),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.sp, right: 8.sp),
                                                child: Row(
                                                  children: [
                                                    AppSpacingText(
                                                      text: 'View Brand \n'
                                                          .toUpperCase(),
                                                      fontFamily:
                                                          "Clash Display",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: homeAppBarColor,
                                                      maxLines: 1,
                                                      fontSize: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.sp),
                                                      child: ImageIcon(
                                                          AssetImage(
                                                              linkArrowImage),
                                                          size: 16.sp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(height: 0),
                                  ],
                                ),
                              ),

                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.sp, right: 12.sp),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: AppSpacingText(
                                        text: _brandText().isNotEmpty
                                            ? "${_brandText()}\n".toUpperCase()
                                            : "",
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w400,
                                        color:
                                            widget.backgroundcolor == whiteColor
                                                ? subtitleColor
                                                : whiteColor,
                                        maxLines: 1,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price Display Section
                              Obx(() {
                                final price =
                                    productController.getDisplayPrice();
                                final mrp = productController.getDisplayMrp();
                                final hasDiscount = mrp > price && mrp > 0;

                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 8.sp, left: 12.sp, right: 12.sp),
                                  child: Row(
                                    children: [
                                      // Selling Price
                                      Flexible(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(right: 10.sp),
                                          child: AppSpacingText(
                                            text: "₹$price", // ✅ exact value
                                            color: widget.backgroundcolor ==
                                                    whiteColor
                                                ? nameText
                                                : whiteColor,
                                            fontSize: 16,
                                            fontFamily: "Clash Display",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      // MRP (strikethrough)
                                      if (hasDiscount)
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.sp),
                                            child: Text(
                                              "₹$mrp", // ✅ exact value
                                              style: TextStyle(
                                                color: searchTextColor,
                                                letterSpacing: 0.65,
                                                fontSize: 16.sp,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    "Clash Display Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Discount Badge
                                      if (hasDiscount)
                                        Flexible(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xffA7F3D0),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.sp,
                                                vertical: 2.sp),
                                            child: AppSpacingText(
                                              text:
                                                  "${(((mrp - price) / mrp) * 100).toStringAsFixed(2)}% OFF",
                                              // ✅ exact percentage (2 decimals)
                                              color: widget.backgroundcolor ==
                                                      whiteColor
                                                  ? expressText
                                                  : homeAppBarColor,
                                              fontSize: 12,
                                              fontFamily: "Clash Display",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.sp, left: 12.sp, right: 16.sp),
                                child: AppSpacingText(
                                  text: "Price inclusive of all taxes",
                                  color: lightPurpleColor,
                                  fontSize: 12,
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // Inside your build method, replace the existing size/color section with:

// ---------- SIZES ----------
                              // ---------- SIZES ----------
                              Obx(() {
                                final hasSizes = productController
                                    .sizeInventoryList.isNotEmpty;

                                // ✅ Hide size section if no sizes
                                if (!hasSizes) return const SizedBox.shrink();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 16.sp,
                                          left: 12.sp,
                                          right: 12.sp),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: AppSpacingText(
                                              text: 'SELECT SIZE',
                                              fontFamily: "Clash Display",
                                              fontWeight: FontWeight.w500,
                                              color: widget.backgroundcolor ==
                                                      whiteColor
                                                  ? blackColor
                                                  : productSubtitleColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _openSizeChartDialog,
                                            child: Text(
                                              "View Size Chart",
                                              style: TextStyle(
                                                fontFamily: "Clash Display",
                                                fontWeight: FontWeight.w600,
                                                color: lightPurpleColor,
                                                fontSize: 13.sp,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (productController
                                        .errorSizeMsg.value.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.sp, left: 12.sp),
                                        child: AppSpacingText(
                                          text: productController
                                              .errorSizeMsg.value,
                                          fontFamily: "Clash Display Regular",
                                          fontWeight: FontWeight.w400,
                                          color: redColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    getListForProductSize(),
                                  ],
                                );
                              }),

// ---------- COLORS (Shows only after size selection) ----------
                              // ---------- COLORS ----------
                              Obx(() {
                                final hasColors = productController
                                    .colorInventoryList.isNotEmpty;
                                final hasSizes = productController
                                    .sizeInventoryList.isNotEmpty;
                                final sizeSelected = productController
                                    .selectedSize.value.isNotEmpty;

                                // ✅ For products with sizes: show colors only after size is selected
                                // ✅ For products without sizes: show colors immediately
                                if (!hasColors) return const SizedBox.shrink();
                                if (hasSizes && !sizeSelected)
                                  return const SizedBox.shrink();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ✅ Only show divider if there are sizes above
                                    if (hasSizes)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14.sp, horizontal: 12.sp),
                                        child: Divider(
                                          color: widget.backgroundcolor ==
                                                  whiteColor
                                              ? colorSecondary
                                              : titleColor,
                                        ),
                                      )
                                    else
                                      SizedBox(
                                          height: 16
                                              .sp), // Just spacing for color-only products

                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 12.sp, right: 12.sp),
                                      child: AppSpacingText(
                                        text: 'SELECT COLOR',
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            widget.backgroundcolor == whiteColor
                                                ? blackColor
                                                : productSubtitleColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (productController
                                        .errorColorMsg.value.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.sp, left: 12.sp),
                                        child: AppSpacingText(
                                          text: productController
                                              .errorColorMsg.value,
                                          fontFamily: "Clash Display Regular",
                                          fontWeight: FontWeight.w400,
                                          color: redColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    getListForProductColor(),
                                  ],
                                );
                              }),

                              // ===================== QUANTITY SELECTOR =====================
                              Obx(() {
                                final hasSizes = productController
                                    .sizeInventoryList.isNotEmpty;
                                final hasColors = productController
                                    .colorInventoryList.isNotEmpty;
                                final sizeSelected = productController
                                    .selectedSize.value.isNotEmpty;
                                final colorSelected = productController
                                    .selectedColor.value.isNotEmpty;

                                // ✅ Show quantity selector only when user has made valid selections
                                bool shouldShow = false;
                                if (hasSizes && hasColors) {
                                  // Both exist - need both selected
                                  shouldShow = sizeSelected && colorSelected;
                                } else if (hasSizes) {
                                  // Only sizes - need size selected
                                  shouldShow = sizeSelected;
                                } else if (hasColors) {
                                  // Only colors - need color selected
                                  shouldShow = colorSelected;
                                } else {
                                  // No sizes or colors - always show if product loaded
                                  shouldShow =
                                      !productController.isDetails.value;
                                }

                                if (!shouldShow) return const SizedBox.shrink();

                                // Get available stock for selected variant
                                final variant =
                                    productController.getSelectedVariant();
                                final maxStock = int.tryParse(
                                        variant?['stocks']?.toString() ??
                                            '0') ??
                                    0;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Divider
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 14.sp, horizontal: 12.sp),
                                      child: Divider(
                                        color:
                                            widget.backgroundcolor == whiteColor
                                                ? colorSecondary
                                                : titleColor,
                                      ),
                                    ),

                                    // Quantity Label
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 12.sp, right: 12.sp),
                                      child: AppSpacingText(
                                        text: 'SELECT QUANTITY',
                                        fontFamily: "Clash Display",
                                        fontWeight: FontWeight.w500,
                                        color:
                                            widget.backgroundcolor == whiteColor
                                                ? blackColor
                                                : productSubtitleColor,
                                        fontSize: 16,
                                      ),
                                    ),

                                    SizedBox(height: 12.sp),

                                    // Quantity Selector
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.sp),
                                      child: Row(
                                        children: [
                                          // Decrease Button
                                          GestureDetector(
                                            onTap: () {
                                              if (_selectedQuantity > 1) {
                                                setState(() {
                                                  _selectedQuantity--;
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: 36.sp,
                                              height: 36.sp,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      widget.backgroundcolor ==
                                                              whiteColor
                                                          ? btnTextColor
                                                          : searchTextColor,
                                                  width: 1.sp,
                                                ),
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? whiteColor
                                                    : homeAppBarColor,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.remove,
                                                  color: _selectedQuantity <= 1
                                                      ? searchTextColor
                                                      : (widget.backgroundcolor ==
                                                              whiteColor
                                                          ? btnTextColor
                                                          : searchTextColor),
                                                  size: 18.sp,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Quantity Display
                                          Container(
                                            width: 60.sp,
                                            height: 36.sp,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color:
                                                      widget.backgroundcolor ==
                                                              whiteColor
                                                          ? btnTextColor
                                                          : searchTextColor,
                                                  width: 1.sp,
                                                ),
                                                bottom: BorderSide(
                                                  color:
                                                      widget.backgroundcolor ==
                                                              whiteColor
                                                          ? btnTextColor
                                                          : searchTextColor,
                                                  width: 1.sp,
                                                ),
                                              ),
                                              color: widget.backgroundcolor ==
                                                      whiteColor
                                                  ? whiteColor
                                                  : homeAppBarColor,
                                            ),
                                            child: Center(
                                              child: AppSpacingText(
                                                text: _selectedQuantity
                                                    .toString(),
                                                fontFamily: "Clash Display",
                                                fontWeight: FontWeight.w600,
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? btnTextColor
                                                    : searchTextColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),

                                          // Increase Button
                                          GestureDetector(
                                            onTap: () {
                                              if (maxStock > 0 &&
                                                  _selectedQuantity <
                                                      maxStock) {
                                                setState(() {
                                                  _selectedQuantity++;
                                                });
                                              } else if (maxStock > 0) {
                                                showAppSnackBar(
                                                  'Maximum available quantity is $maxStock',
                                                  type: SnackBarType.warning,
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: 36.sp,
                                              height: 36.sp,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      widget.backgroundcolor ==
                                                              whiteColor
                                                          ? btnTextColor
                                                          : searchTextColor,
                                                  width: 1.sp,
                                                ),
                                                color: widget.backgroundcolor ==
                                                        whiteColor
                                                    ? whiteColor
                                                    : homeAppBarColor,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.add,
                                                  color: (maxStock > 0 &&
                                                          _selectedQuantity >=
                                                              maxStock)
                                                      ? searchTextColor
                                                      : (widget.backgroundcolor ==
                                                              whiteColor
                                                          ? btnTextColor
                                                          : searchTextColor),
                                                  size: 18.sp,
                                                ),
                                              ),
                                            ),
                                          ),

                                          SizedBox(width: 12.sp),

                                          // // Stock Info
                                          // if (maxStock > 0)
                                          //   Expanded(
                                          //     child: AppSpacingText(
                                          //       text: maxStock <= 10
                                          //           ? 'Only $maxStock left in stock'
                                          //           : '$maxStock available',
                                          //       fontFamily: "Clash Display Regular",
                                          //       fontWeight: FontWeight.w400,
                                          //       color: maxStock <= 5 ? redColor : subtitleColor,
                                          //       fontSize: 12,
                                          //       maxLines: 1,
                                          //     ),
                                          //   ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 8.sp),
                                  ],
                                );
                              }),

                              SizedBox(height: 0),
                            ],
                          );
                        }),

                        Visibility(
                          visible: widget.backgroundcolor == whiteColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.sp, top: 16.sp),
                                child: AppSpacingText(
                                  text: 'Delivery Options'.toUpperCase(),
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w600,
                                  color: appBarColor,
                                  fontSize: 12,
                                ),
                              ),

                              /// Pincode Field
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 12.sp, left: 12.sp, right: 12.sp),
                                child: SizedBox(
                                  height: 44.sp,
                                  child: TextField(
                                    controller:
                                        productController.pincodeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      filled: true,
                                      fillColor: whiteColor,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.sp),
                                      hintText: "Enter pincode",
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        color: textHintColor,
                                        fontFamily: "Clash Display",
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                      suffixIcon: Obx(
                                        () => TextButton(
                                          onPressed: () async {
                                            final pin = productController
                                                .pincodeController.text
                                                .trim();

                                            if (productController
                                                .checkPinvalidation(pin)) {
                                              productController
                                                  .serviceabilityMessage
                                                  .value = "";
                                              productController
                                                  .isServiceable.value = false;
                                              productController
                                                  .courierName.value = "";
                                              productController
                                                  .estimatedDate.value = "";
                                              productController
                                                  .estimatedDays.value = "";

                                              final result =
                                                  await productController
                                                      .checkServiceability(
                                                variantId: productController
                                                    .sizeInventoryId.value,
                                                deliveryPostalCode: pin,
                                              );

                                              if (result != null) {
                                                final data = result["data"];
                                                if (data != null &&
                                                    data is Map) {
                                                  final date =
                                                      data["estimatedDate"]
                                                              ?.toString() ??
                                                          "";
                                                  final days =
                                                      data["estimatedDays"]
                                                              ?.toString() ??
                                                          "";
                                                  final courier =
                                                      data["courier"]
                                                              ?.toString() ??
                                                          "";

                                                  productController.courierName
                                                      .value = courier;
                                                  productController
                                                      .estimatedDate
                                                      .value = date;
                                                  productController
                                                      .estimatedDays
                                                      .value = days;
                                                  productController
                                                      .isServiceable
                                                      .value = true;

                                                  // ✅ Show proper delivery info
                                                  productController
                                                          .serviceabilityMessage
                                                          .value =
                                                      "Delivery by $date ($days Days)";
                                                } else {
                                                  productController
                                                      .isServiceable
                                                      .value = false;
                                                  productController
                                                          .serviceabilityMessage
                                                          .value =
                                                      "Service not available for this pincode";
                                                }
                                              }

                                              FocusScope.of(context).unfocus();
                                              await analytics.logEvent(
                                                name:
                                                    'check_pincode_productdetails',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'check_pincode_productdetails'
                                                },
                                              );
                                            }
                                          },
                                          child: productController
                                                  .isEstimateDate.value
                                              ? const SizedBox(
                                                  height: 14,
                                                  width: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : Container(
                                                  color: blackColor,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                      vertical: 8.sp),
                                                  child: const AppSpacingText(
                                                    text: "CHECK",
                                                    textAlign: TextAlign.center,
                                                    fontFamily: "Clash Display",
                                                    fontWeight: FontWeight.w600,
                                                    color: whiteColor,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 16.sp,
                                      fontFamily: "Clash Display",
                                    ),
                                  ),
                                ),
                              ),

                              Obx(() {
                                final msg = productController
                                    .serviceabilityMessage.value;
                                final isOk =
                                    productController.isServiceable.value;

                                if (msg.isEmpty) return const SizedBox.shrink();

                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.sp, right: 12.sp, top: 10.sp),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isOk
                                            ? Icons.check_circle_outline
                                            : Icons.error_outline,
                                        color: isOk ? Colors.green : Colors.red,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 8.sp),
                                      Expanded(
                                        child: AppSpacingText(
                                          text: msg,
                                          fontFamily: "Clash Display Regular",
                                          fontWeight: FontWeight.w500,
                                          color: isOk
                                              ? Colors.green.shade700
                                              : Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                            ],
                          ),
                        ),

                        // ------- collapsibles (description / composition / returns / brand) -------
                        Obx(
                          () => productController.isDetails.value
                              ? const SizedBox(height: 0)
                              : _collapsiblesSection(),
                        ),

                        Obx(
                          () => productController.isDetails.value
                              ? const SizedBox(height: 0)
                              : _ratingsAndReviewsSection(), // <-- Add this call
                        ),

                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: Divider(
                              color: widget.backgroundcolor == whiteColor
                                  ? colorSecondary
                                  : titleColor),
                        ),

                        Obx(
                          () => productController.errorMsg.value.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 16.sp,
                                      right: 16.sp,
                                      top: 16.sp,
                                      bottom: 16.sp),
                                  child: AppSpacingText(
                                    text: productController.errorMsg.value,
                                    fontFamily: "Clash Display Regular",
                                    fontWeight: FontWeight.w400,
                                    color: deepRed,
                                    maxLines: 5,
                                    fontSize: 12,
                                  ),
                                )
                              : const SizedBox(height: 0),
                        ),
                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ================= BOTTOM BAR =================
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 2.sp),
              child: Obx(() {
                if (productController.isDetails.value) {
                  return const SizedBox(height: 0);
                }

                final isInCartFlow = productController.addToCart.value;

                return isInCartFlow
                    ? DoubleButtonIconNew(
                        lineColor: widget.backgroundcolor == whiteColor
                            ? dividerColor
                            : titleColor,
                        firstText: "Go to BAG".toUpperCase(),
                        secondText: "Buy Now".toUpperCase(),
                        onPressedFirst: () async {
                          final pid = (productController.productDetails["id"] ??
                                  widget.productId)
                              .toString();
                          final price = _displayPrice().toDouble();

                          Get.to(CartScreen(
                                  backgroundcolor: widget.backgroundcolor))
                              ?.then((_) {
                            productController.getProductById(widget.productId);
                          });

                          await analytics.logEvent(
                            name: 'productDetails_btnGotocart',
                            parameters: {
                              'page_name': 'productDetails_btnGotocart'
                            },
                          );

                          productController.addToCart.value = false;

                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        },
                        onPressedSecond: () async {
                          await _onBuyNowPressed(isCartFlow: true);
                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        },
                        controller: productController,
                      )
                    : DoubleButtonIconNew(
                        lineColor: widget.backgroundcolor == whiteColor
                            ? dividerColor
                            : titleColor,
                        firstText: widget.type == "add"
                            ? "Add to bag".toUpperCase()
                            : "Move to bag".toUpperCase(),
                        secondText: "Buy Now".toUpperCase(),
                        onPressedFirst: () async {
                          if (widget.type == "add") {
                            if (productController.checkDetailsValidation()) {
                              // ✅ Get selected variant ID properly
                              final variant =
                                  productController.getSelectedVariant();
                              if (variant == null) {
                                showAppSnackBar('Please select size and color',
                                    type: SnackBarType.error);
                                return;
                              }

                              final variantId = variant['id'] as int;

                              await cartController.addToCartUniversal(
                                quantity: 1,
                                page: "addproduct",
                                variantId: variantId,
                                productId: widget.productId,
                                expressValue: (widget.expressValue ?? 0),
                                type: 1,
                                backColor: widget.backgroundcolor,
                                oldInventoryId: variantId,
                              );

                              await analytics.logEvent(
                                name: 'productDetails_btnaddtocart',
                                parameters: {
                                  'page_name': 'productDetails_btnaddtocart'
                                },
                              );

                              // ✅ Navigate to cart screen immediately after adding
                              Get.to(CartScreen(
                                      backgroundcolor: widget.backgroundcolor))
                                  ?.then((_) {
                                productController
                                    .getProductById(widget.productId);
                              });
                            }
                          } else {
                            if (productController.checkDetailsValidation()) {
                              // ✅ Get selected variant ID for wishlist move
                              final variant =
                                  productController.getSelectedVariant();
                              if (variant == null) {
                                showAppSnackBar('Please select size and color',
                                    type: SnackBarType.error);
                                return;
                              }

                              final variantId = variant['id'] as int;

                              wishlistController.callMovetoCart(
                                widget.boardId.toString(),
                                widget.wishlistProductId.toString(),
                                variantId.toString(),
                                1,
                              );

                              await analytics.logEvent(
                                name: 'productDetails_btnaddtocart',
                                parameters: {
                                  'page_name': 'productDetails_btnaddtocart'
                                },
                              );

                              // ✅ Navigate to cart screen immediately after moving
                              Get.to(CartScreen(
                                      backgroundcolor: widget.backgroundcolor))
                                  ?.then((_) {
                                productController
                                    .getProductById(widget.productId);
                              });
                            }
                          }
                        },
                        onPressedSecond: () async {
                          await _onBuyNowPressed(isCartFlow: false);
                          _scrollController.animateTo(
                            MediaQuery.of(context).size.height / 2.sp + 150.sp,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        },
                        controller: productController,
                      );
              }),
            )
          ],
        ),
      ),
    );
  }

  // ---------- tiny helpers to keep build() tidy ----------

  Widget _collapsiblesSection() {
    final product = productController.productDetails;

    final returnPolicy = product["returnPolicy"];
    final brandData = product["brand"];

    return Padding(
      padding: EdgeInsets.only(top: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- More Details ----------
          Builder(
            builder: (_) {
              final desc = (product["description"] ?? "").toString().trim();

              if (desc.isEmpty) return const SizedBox.shrink();

              return _buildCollapsible(
                title: "More Details",
                content: desc,
              );
            },
          ),

          // ---------- Composition & Care ----------
          if (productController.compositionDetails != null &&
              productController.compositionDetails != "")
            _buildCollapsible(
              title: "Composition & Care",
              content:
                  (productController.compositionDetails["description"] ?? "")
                      .toString(),
            ),

          // ---------- Delivery & Return ----------
          _buildCollapsible(
            title: "Delivery & Return",
            content: returnPolicy != null
                ? (returnPolicy["description"] ?? "").toString().trim()
                : "No return policy available",
          ),

          // ---------- About Brand ----------
          _buildCollapsible(
            title: "About the Brand",
            content:
                (brandData?["description"] ?? "No brand description available")
                    .toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsible({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          child: Divider(
            color: widget.backgroundcolor == whiteColor
                ? colorSecondary
                : titleColor,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              collapsedIconColor: widget.backgroundcolor == whiteColor
                  ? appBarColor
                  : whiteColor,
              iconColor: widget.backgroundcolor == whiteColor
                  ? appBarColor
                  : whiteColor,
              title: AppSpacingText(
                text: title,
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w500,
                color: widget.backgroundcolor == whiteColor
                    ? colorPrimary
                    : productSubtitleColor,
                fontSize: 16,
              ),
              tilePadding: EdgeInsets.all(0.sp),
              childrenPadding: EdgeInsets.symmetric(vertical: 4.0.sp),
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: AppSpacingText(
                    text: content,
                    fontFamily: "Clash Display Regular",
                    maxLines: 20,
                    fontWeight: FontWeight.w500,
                    color: widget.backgroundcolor == whiteColor
                        ? colorPrimary
                        : productSubtitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget collapsibleSection(BuildContext context) {
    final product = productController.productDetails;

    final desc = product['description']?.toString().trim() ?? "";
    final returnPolicy = product['returnPolicy'];
    final brand = product['brand'];

    return Padding(
      padding: EdgeInsets.only(top: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// MORE DETAILS
          if (desc.isNotEmpty) ...[
            _divider(),
            _expansionTile(
              context,
              title: "More Details",
              content: desc,
            ),
          ],

          /// COMPOSITION AND CARE
          if (productController.compositionDetails != null &&
              productController.compositionDetails != "") ...[
            _divider(),
            _expansionTile(
              context,
              title: "Composition & Care",
              content: productController.compositionDetails["description"]
                      ?.toString()
                      .trim() ??
                  "",
            ),
          ],

          /// DELIVERY & RETURNS
          _divider(),
          _expansionTile(
            context,
            title: "Delivery & Returns",
            content: (returnPolicy != null)
                ? (returnPolicy["description"] ?? "No return policy available")
                : "No return policy available",
          ),

          /// ABOUT BRAND
          if (brand != null &&
              brand is Map &&
              (brand["description"]?.toString().isNotEmpty ?? false)) ...[
            _divider(),
            _expansionTile(
              context,
              title: "About the Brand",
              content: brand["description"]?.toString() ?? "",
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      child: Divider(color: colorSecondary),
    );
  }

  Widget _expansionTile(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: appBarColor,
          iconColor: appBarColor,
          title: AppSpacingText(
            text: title,
            fontFamily: "Clash Display Regular",
            fontWeight: FontWeight.w500,
            color: colorPrimary,
            fontSize: 16,
          ),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.symmetric(vertical: 4.sp),
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: AppSpacingText(
                text: content,
                maxLines: 20,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: productSubtitleColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSizeTable(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty)
      return Text("No size info", style: TextStyle(color: Colors.black));

    final headers = chartData.first.keys.toList();

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        /// ---------- Header Row ----------
        TableRow(
          decoration: BoxDecoration(color: Colors.white),
          children: headers.map((h) {
            return Padding(
              padding: EdgeInsets.all(8.sp),
              child: Text(
                h.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black, // ⭐ BLACK
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            );
          }).toList(),
        ),

        /// ---------- Values ----------
        ...chartData.map((row) {
          return TableRow(
            decoration: BoxDecoration(color: Colors.white),
            children: headers.map((h) {
              return Padding(
                padding: EdgeInsets.all(8.sp),
                child: Text(
                  row[h]?.toString() ?? "-",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black, // ⭐ BLACK
                    fontSize: 12.sp,
                  ),
                ),
              );
            }).toList(),
          );
        })
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Clash Display",
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Clash Display Regular",
          fontSize: 12.sp,
        ),
      ),
    );
  }

// Add this Widget method to your ProductDetailsScreenState class

  Widget _ratingsAndReviewsSection() {
    return Obx(() {
      final reviews = productController.reviewList;
      final totalReviews = productController.totalReview.value;
      final isLoading = productController.isFetchingReviews.value;

      // ✅ Compute average rating dynamically
      double avgRating = 0;
      if (reviews.isNotEmpty) {
        final sum = reviews.fold<double>(
          0.0,
          (prev, review) =>
              prev + ((review['rating'] as num?)?.toDouble() ?? 0),
        );
        avgRating = sum / reviews.length;
      }

      // ✅ If no reviews and not loading, only show ADD REVIEW button
      if (!isLoading && reviews.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: 16.sp, left: 12.sp, right: 12.sp, top: 16.sp),
          child: Center(
            child: InkWell(
              onTap: _showAddReviewModal,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 32.sp, vertical: 12.sp),
                decoration: BoxDecoration(
                  color: widget.backgroundcolor == whiteColor
                      ? blackColor
                      : whiteColor,
                ),
                child: Text(
                  'ADD REVIEW',
                  style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    color: widget.backgroundcolor == whiteColor
                        ? whiteColor
                        : blackColor,
                    fontSize: 13.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // ✅ If loading, show loader
      if (isLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.sp),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      // ✅ If reviews exist, show full section
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
            child: AppSpacingText(
              text: 'RATINGS & REVIEWS',
              fontFamily: "Clash Display",
              fontWeight: FontWeight.w600,
              color: widget.backgroundcolor == whiteColor
                  ? blackColor
                  : whiteColor,
              fontSize: 16,
            ),
          ),

          // ---------- Average Rating + Count ----------
          Padding(
            padding: EdgeInsets.only(left: 12.sp, right: 12.sp, bottom: 12.sp),
            child: Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B67A),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: whiteColor, size: 14.sp),
                      SizedBox(width: 4.sp),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: "Clash Display",
                          fontWeight: FontWeight.w700,
                          color: whiteColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    '$totalReviews ${totalReviews == 1 ? "Review" : "Reviews"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                      color: widget.backgroundcolor == whiteColor
                          ? subtitleColor
                          : searchTextColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Review List ----------
          ...reviews.take(3).map((review) {
            final user = review['user'] ?? {};
            final variant = review['product_variant'] ?? {};

            final userName =
                (user['fullName'] ?? user['name'] ?? 'Anonymous').toString();
            final comment = (review['comment'] ?? '').toString();
            final rating = (review['rating'] as num?)?.toInt() ?? 0;
            final createdAt = review['createdAt'] ?? '';
            final variantTitle = variant['title']?.toString();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem(
                  name: userName.toUpperCase(),
                  date: _formatReviewDate(createdAt),
                  rating: rating,
                  review: comment.isNotEmpty ? comment : "No comment provided",
                  variant: variantTitle != null ? "Size: $variantTitle" : null,
                ),
                if (review != reviews.take(3).last)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                    child: Divider(
                      color: widget.backgroundcolor == whiteColor
                          ? colorSecondary
                          : titleColor,
                      height: 1,
                    ),
                  ),
              ],
            );
          }).toList(),

          // ---------- See All ----------
          if (reviews.length > 3)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
              child: Center(
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to full review page
                    print('Navigate to all reviews - Total: $totalReviews');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.sp, vertical: 12.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.backgroundcolor == whiteColor
                            ? blackColor
                            : whiteColor,
                        width: 1.sp,
                      ),
                    ),
                    child: Text(
                      'SEE ALL REVIEWS ($totalReviews)',
                      style: TextStyle(
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500,
                        color: widget.backgroundcolor == whiteColor
                            ? blackColor
                            : whiteColor,
                        fontSize: 13.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required int rating,
    required String review,
    String? variant,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: nameText,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Text(
                date,
                style: TextStyle(
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  fontSize: 11.sp,
                  color: subtitleColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.sp),

          // Stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 14.sp,
                color: const Color(0xFFFFB800),
              ),
            ),
          ),

          SizedBox(height: 6.sp),

          // Variant info
          if (variant != null)
            Text(
              variant,
              style: TextStyle(
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: subtitleColor,
              ),
            ),

          SizedBox(height: 4.sp),

          // Review text
          Text(
            review,
            style: TextStyle(
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: nameText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(dynamic dateValue) {
    if (dateValue == null) return '';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return '';
      }

      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }
}
