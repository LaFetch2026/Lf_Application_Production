// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/cartscreen.dart';

import '../screens/loginscreen.dart';
import 'base_controller.dart';

class ProductController extends BaseController {
  RxBool isProduct = false.obs;
  RxBool isFilter = false.obs;
  RxBool isMostSearch = false.obs;
  RxBool isHomeProduct = false.obs;
  RxBool istags = false.obs;
  RxString errorMsg = "".obs;
  RxBool isCategoryProduct = false.obs;
  RxBool istagsProduct = false.obs;
  RxBool isBannerTag = false.obs;
  RxBool isBrandExpressProduct = false.obs;
  RxBool isExpress = false.obs;
  RxBool isHandPicked = false.obs;
  RxBool isDetails = false.obs;
  RxBool isReview = false.obs;
  RxBool isPincode = false.obs;
  RxBool isReorder = false.obs;
  RxBool showSizeList = true.obs;
  RxBool isBestSeller = false.obs;
  RxBool isFrequentlyBought = false.obs;
  RxInt currentpage = 0.obs;
  RxInt inventoryId = 0.obs;
  RxInt tagId = 0.obs;
  RxInt sizeInventoryId = 0.obs;
  RxInt colorInventoryId = 0.obs;
  RxInt fabricInventoryId = 0.obs;
  Map<String, dynamic> productDetails = {};

  dynamic selectedProductSize = {}.obs;
  dynamic selectedProductColor = {}.obs;
  dynamic brandDetails = "".obs;
  dynamic compositionDetails = "".obs;
  RxString returnPolicyDetails = "".obs;
  RxBool isRecommendations = false.obs;
  List tagsList = [].obs;
  List homeProductList = [].obs;
  List handPickedProductList = [].obs;
  List frequentlyProductList = [].obs;
  List tagProductList = [].obs;
  List productList = [].obs;
  List filterList = [].obs;
  RxString tagname = "We think you might also like".obs;
  List mostSeachList = [].obs;
  List expressProductList = [].obs;
  List productCategoryList = [].obs;
  List productExpressBrandList = [].obs;
  RxInt total = 0.obs;
  RxInt curr = 0.obs;
  RxInt index = 0.obs;
  RxInt current = 50.obs;
  RxInt totalExpress = 0.obs;
  List inventoryList = [].obs;
  RxList<Map<String, dynamic>> selectedVariants = <Map<String, dynamic>>[].obs;

  RxList<String> colorInventoryList = <String>[].obs;

  List fabricInventoryList = [].obs;
  List reviewList = [].obs;
  List recommendedList = [].obs;
  List bestSellerList = [].obs;
  RxInt totalProductValue = 0.obs;
  final pincodeController = TextEditingController();
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxBool homeTagsloadMore = false.obs;
  RxBool homeTagshasnextpage = true.obs;
  RxInt homeTagsPage = 1.obs;
  RxInt categoryFilter = 0.obs;
  RxInt categoryProductGender = 0.obs;
  RxBool filterEnable = false.obs;
  RxBool filterExpressEnable = false.obs;
  RxBool filterProductEnable = false.obs;
  RxInt page = 1.obs;
  RxInt lowPrice = 500.obs;
  RxInt highPrice = 500000.obs;
  ScrollController listController = ScrollController();
  ScrollController handpickedController = ScrollController();
  ScrollController brandProductController = ScrollController();
  ScrollController recentListController = ScrollController();
  RxBool expressLoadMore = false.obs;
  RxBool expressHasnextpage = true.obs;
  RxInt expressPage = 1.obs;
  RxBool handpickedLoadMore = false.obs;
  RxBool handpickedHasnextpage = true.obs;
  RxInt handpickedPage = 1.obs;
  ScrollController expressListController = ScrollController();
  ScrollController categoryProductController = ScrollController();
  ScrollController brandDetailsController = ScrollController();
  RxInt brandDetailsId = 0.obs;
  RxString brandDetailsScreen = "".obs;
  RxBool categoryProductLoadMore = false.obs;
  RxBool categoryProductHasnextpage = true.obs;
  RxInt categoryProductPage = 1.obs;
  ScrollController brandExpressProductController = ScrollController();
  RxBool brandExpressLoadMore = false.obs;
  RxBool brandExpressHasnextpage = true.obs;
  RxInt brandExpressPage = 1.obs;
  ScrollController tagsProductController = ScrollController();
  RxBool tagsLoadMore = false.obs;
  RxBool tagsHasnextpage = true.obs;
  RxInt tagsPage = 1.obs;
  ScrollController mostViewController = ScrollController();
  RxBool mostViewLoadMore = false.obs;
  RxBool mostViewHasnextpage = true.obs;
  RxInt mostViewPage = 1.obs;
  ScrollController bannerTagController = ScrollController();
  RxBool bannerTagLoadMore = false.obs;
  RxBool bannerTagHasnextpage = true.obs;
  RxInt bannerTagPage = 1.obs;
  ScrollController frequentlyBoughtController = ScrollController();
  RxBool frequentlyBoughtLoadMore = false.obs;
  RxBool frequentlyBoughtHasnextpage = true.obs;
  RxInt frequentlyBoughtPage = 1.obs;
  ScrollController recommendedController = ScrollController();
  RxBool recommendedLoadMore = false.obs;
  RxBool recommendedHasnextpage = true.obs;
  RxInt recommendedPage = 1.obs;
  ScrollController bestSellerController = ScrollController();
  ScrollController tagsController = ScrollController();
  RxBool bestSellerLoadMore = false.obs;
  RxBool bestSellerHasnextpage = true.obs;
  RxInt bestSellerPage = 1.obs;
  RxBool brandProductLoadMore = false.obs;
  RxBool brandProductHasnextpage = true.obs;
  RxInt brandProductPage = 1.obs;
  List brandProductDetailsList = [].obs;
  RxBool isProductBrand = false.obs;
  RxBool isVideoPlaying = true.obs;
  RxString sortBy = "".obs;
  RxString expressSortBy = "".obs;
  RxString productSortBy = "".obs;
  List brand_ids = [].obs;
  List color_ids = [].obs;
  List size_ids = [].obs;
  List addressList = [].obs;
  List pricelist = [100, 5000].obs;
  RxBool isPrice = true.obs;
  RxInt category_id = 0.obs;
  RxInt totalReview = 0.obs;
  RxInt productImageindex = 0.obs;
  RxInt catalogIndex = 0.obs;
  RxInt brand_id = 0.obs;
  RxBool isEstimateDate = false.obs;
  dynamic getItBy = "".obs;
  RxBool isAddress = false.obs;
  dynamic defaultAddress = "".obs;
  RxBool addToCart = false.obs;
  RxBool isColorimage = false.obs;
  List imageList = [].obs;
  RxBool isExpressDelivery = false.obs;
  RxInt expressValue = 0.obs;
  List productCategory = [].obs;
  List productTags = [].obs;
  List brandProductList = [].obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxBool isBrandProduct = false.obs;
  RxBool isBrand = false.obs;
  RxInt id = 0.obs;
  RxInt selectedTabCategory = 0.obs;
  RxBool showAddressList = false.obs;
  RxString addressText = "".obs;
  RxString selectedCategoryGender = "".obs;
  RxString addressTypeValue = "".obs;
  RxString errorSizeMsg = "".obs;
  RxString errorColorMsg = "".obs;
  List<bool> reorderSelected = List.generate(50, (i) => false).obs;
  TextEditingController brandController = TextEditingController();
  TextEditingController branddetailsSearchController = TextEditingController();
  RxInt quickProductPage = 1.obs;
  RxBool quickProductLoadMore = false.obs;
  RxBool quickProductHasnextpage = true.obs;
  ScrollController quickProductListController = ScrollController();
  RxBool isExpressBrand = false.obs;
  List expressBrandList = [].obs;
  RxString locationText = "check".obs;
  RxString enableLocationText = "".obs;
  dynamic brandProductdetails = "".obs;
  RxBool isSubmittingReview = false.obs;
  RxBool isFetchingReviews = false.obs;
  int? productsShuffleSeed;

  RxList<dynamic> lafetchexclusiveList = <dynamic>[].obs;
  RxList<dynamic> premiumList = <dynamic>[].obs;
  RxList<dynamic> luxuriousList = <dynamic>[].obs;
  RxList<dynamic> standardList = <dynamic>[].obs;
  final RxBool isCatProducts = false.obs;
  final RxList<Map<String, dynamic>> catProductList =
      <Map<String, dynamic>>[].obs;
  RxBool isCoupons = false.obs;
  RxList<Map<String, dynamic>> couponList = <Map<String, dynamic>>[].obs;
  RxString serviceabilityMessage = "".obs;
  RxBool isServiceable = false.obs;
  RxString courierName = "".obs;
  RxString estimatedDate = "".obs;
  RxString estimatedDays = "".obs;
  final RxDouble averageRating = 0.0.obs;
  // ---- SIZE CHART ----
  RxBool isSizeChartLoading = false.obs;
  RxMap sizeChart = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> sizeChartData = <Map<String, dynamic>>[].obs;
  RxList<String> sizeInventoryList = <String>[].obs;
  RxString selectedColor = "".obs;
  RxString selectedSize = "".obs;
// Add this observable for tracking current display images
  RxList<String> currentDisplayImages = <String>[].obs;

// Method to update images based on selected color
  void updateImagesForSelectedColor() {
    // ✅ For COLOR ONLY products
    if (sizeInventoryList.isEmpty && selectedColor.value.isNotEmpty) {
      final variant = selectedVariants
          .firstWhereOrNull((v) => v["color"] == selectedColor.value);

      if (variant != null && variant['imageSrc'] != null) {
        final variantImage = variant['imageSrc'].toString();

        if (variantImage.isNotEmpty && variantImage != 'null') {
          final allImages = productDetails['imageUrls'] is List
              ? List<String>.from((productDetails['imageUrls'] as List)
                  .map((url) => url.toString()))
              : <String>[];

          allImages.remove(variantImage);
          currentDisplayImages.assignAll([variantImage, ...allImages]);

          print("🎨 Updated images for color ${selectedColor.value}");
          print("🖼️ First image: $variantImage");
          update();
          return;
        }
      }
    }

    // ✅ For SIZE + COLOR products
    if (selectedColor.value.isEmpty || selectedSize.value.isEmpty) {
      if (productDetails['imageUrls'] is List) {
        currentDisplayImages.assignAll((productDetails['imageUrls'] as List)
            .map((url) => url.toString())
            .toList());
      }
      update();
      return;
    }

    final variant = selectedVariants.firstWhereOrNull((v) =>
        v["size"] == selectedSize.value && v["color"] == selectedColor.value);

    if (variant != null && variant['imageSrc'] != null) {
      final variantImage = variant['imageSrc'].toString();

      if (variantImage.isNotEmpty && variantImage != 'null') {
        final allImages = productDetails['imageUrls'] is List
            ? List<String>.from((productDetails['imageUrls'] as List)
                .map((url) => url.toString()))
            : <String>[];

        allImages.remove(variantImage);
        currentDisplayImages.assignAll([variantImage, ...allImages]);

        print(
            "🎨 Updated images for size ${selectedSize.value}, color ${selectedColor.value}");
      } else {
        if (productDetails['imageUrls'] is List) {
          currentDisplayImages.assignAll((productDetails['imageUrls'] as List)
              .map((url) => url.toString())
              .toList());
        }
      }
    } else {
      if (productDetails['imageUrls'] is List) {
        currentDisplayImages.assignAll((productDetails['imageUrls'] as List)
            .map((url) => url.toString())
            .toList());
      }
    }

    update();
  }

// Get selected variant based on size + color
  Map<String, dynamic>? getSelectedVariant() {
    print("🔍 Finding variant for:");
    print("   Size: ${selectedSize.value}");
    print("   Color: ${selectedColor.value}");

    // ✅ COLOR ONLY products (accessories)
    if (sizeInventoryList.isEmpty && colorInventoryList.isNotEmpty) {
      final variant = selectedVariants
          .firstWhereOrNull((v) => v["color"] == selectedColor.value);

      if (variant != null) {
        print("✅ Found color-only variant: ${variant['id']}");
      }
      return variant;
    }

    // ✅ SIZE + COLOR products (clothing)
    if (sizeInventoryList.isNotEmpty && colorInventoryList.isNotEmpty) {
      final variant = selectedVariants.firstWhereOrNull((v) =>
          v["size"] == selectedSize.value && v["color"] == selectedColor.value);

      if (variant != null) {
        print("✅ Found size+color variant: ${variant['id']}");
      }
      return variant;
    }

    // ✅ SIZE ONLY products
    if (sizeInventoryList.isNotEmpty && colorInventoryList.isEmpty) {
      final variant = selectedVariants
          .firstWhereOrNull((v) => v["size"] == selectedSize.value);

      if (variant != null) {
        print("✅ Found size-only variant: ${variant['id']}");
      }
      return variant;
    }

    // ✅ Single variant products (no size, no color)
    if (selectedVariants.isNotEmpty) {
      print("✅ Using single variant: ${selectedVariants.first['id']}");
      return selectedVariants.first;
    }

    print("❌ No variant found");
    return null;
  }

// Get display price from selected variant or product details
  num getDisplayPrice() {
    final variant = getSelectedVariant();

    if (variant != null) {
      final price = variant['price'];
      if (price is num && price > 0) return price;
    }

    // Fallback to product details
    final pd = productDetails;
    final price =
        pd['price'] ?? pd['basePrice'] ?? pd['netAmount'] ?? pd['msp'];
    if (price is num && price > 0) return price;

    return num.tryParse(price?.toString() ?? '0') ?? 0;
  }

// Get MRP
  num getDisplayMrp() {
    final variant = getSelectedVariant();

    // Try to get compareAtPrice from variant
    final compareAt = variant?['compareAtPrice'];
    if (compareAt is num && compareAt > 0) return compareAt;

    // Fallback to product MRP
    final mrp = productDetails['mrp'] ?? productDetails['manufacturingAmount'];
    if (mrp is num && mrp > 0) return mrp;

    return num.tryParse(mrp?.toString() ?? '0') ?? 0;
  }

// Get stock for selected variant
  int getSelectedStock() {
    final variant = getSelectedVariant();
    if (variant == null) return 0;

    final stocks = variant['stocks'];
    return int.tryParse(stocks?.toString() ?? '0') ?? 0;
  }

  void loadColorsForSize(String size) {
    print("🎨 Loading colors for size: $size");

    final colors = selectedVariants
        .where((v) => v["size"] == size)
        .map((v) => v["color"].toString())
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList();

    print("🎨 Found colors: $colors");

    colorInventoryList.assignAll(colors);

    // Auto-select first color if available
    if (colors.isNotEmpty) {
      selectedColor.value = colors.first;
      print("✅ Auto-selected color: ${colors.first}");

      // ✅ Update images for selected color
      updateImagesForSelectedColor();
    } else {
      selectedColor.value = '';
      print("⚠️ No colors available for size $size");
    }

    update();
  }

  bool checkPinvalidation(String pin) {
    if (pin.isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      return false;
    }
    if (pin.length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      return false;
    }
    return true;
  }

// Validation method
  bool checkDetailsValidation() {
    errorSizeMsg.value = "";
    errorColorMsg.value = "";
    errorMsg.value = "";

    final hasSizes = sizeInventoryList.isNotEmpty;
    final hasColors = colorInventoryList.isNotEmpty;

    print("🔍 Validation Check:");
    print("   Has Sizes: $hasSizes");
    print("   Has Colors: $hasColors");
    print("   Selected Size: ${selectedSize.value}");
    print("   Selected Color: ${selectedColor.value}");

    // ✅ If product has sizes, validate size selection
    if (hasSizes && selectedSize.value.isEmpty) {
      errorSizeMsg.value = "Please select a size";
      return false;
    }

    // ✅ If product has colors, validate color selection
    if (hasColors && selectedColor.value.isEmpty) {
      errorColorMsg.value = "Please select a color";
      return false;
    }

    // ✅ Get selected variant
    final variant = getSelectedVariant();
    if (variant == null) {
      errorMsg.value = "Selected combination is not available";
      print(
          "❌ No variant found for: Size=${selectedSize.value}, Color=${selectedColor.value}");
      return false;
    }

    // ✅ Check stock
    final stock = int.tryParse(variant['stocks']?.toString() ?? '0') ?? 0;
    if (stock <= 0) {
      errorMsg.value = "Selected variant is out of stock";
      return false;
    }

    print("✅ Validation passed!");
    return true;
  }

  /// ----------------------------------------------------------
  /// FETCH SIZE CHART (brandId + superCatId + catId + subCatId)
  /// ----------------------------------------------------------
  Future<void> fetchSizeChart({
    required int brandId,
    required int superCatId,
    required int catId,
    required int subCatId,
  }) async {
    print("=== SIZE CHART PARAMS ===");
    print("brandId     → $brandId");
    print("superCatId  → $superCatId");
    print("catId       → $catId");
    print("subCatId    → $subCatId");
    print("==========================");

    isSizeChartLoading.value = true;
    sizeChart.clear();
    sizeChartData.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url =
        "${ApiConstants.baseUrl}/fetch-size-chart?brandId=$brandId&superCatId=$superCatId&catId=$catId&subCatId=$subCatId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json; charset=UTF-8",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 20));

      print("FULL SIZE CHART RESPONSE → ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded["data"];

        if (data == null) {
          print("⚠️ Size chart data is NULL from API");
          return;
        }

        sizeChart.assignAll(Map<String, dynamic>.from(data));

        final rawImg = data["sizeGuideImage"];
        if (rawImg != null && rawImg.toString().trim().isNotEmpty) {
          print("✓ Using sizeGuideImage");
        }

        final raw = data["sizeChartData"];
        if (raw == null || raw.toString().trim().isEmpty) {
          print("⚠️ sizeChartData is empty");
          return;
        }

        dynamic parsed;
        try {
          parsed = json.decode(raw);
        } catch (e) {
          print("⚠️ JSON parse error: $e");
          return;
        }

        if (parsed is List) {
          sizeChartData.assignAll(
            List<Map<String, dynamic>>.from(parsed),
          );
        } else if (parsed is Map) {
          sizeChartData.assignAll([Map<String, dynamic>.from(parsed)]);
        }

        print("✓ Final sizeChartData length = ${sizeChartData.length}");
      } else {
        print("✗ Size chart API failed: ${response.statusCode}");
      }
    } catch (e) {
      print("✗ Size Chart Error: $e");
    } finally {
      isSizeChartLoading.value = false;
    }
  }

  Future<void> getHomeProduct(int gender) async {
    isHomeProduct.value = true;
    homeProductList.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // Use laFetch base for this API
    final base = ApiConstants.baseUrl; // << make sure this exists
    final uri = Uri.parse("$base/collection-with-products").replace(
      // Keep this only if backend supports gender filtering here.
      // Remove the queryParameters line if it doesn't.
      queryParameters: {'status': '$gender'},
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        // Expect: { status, message, data: [ { id, name, desc?, products: [] }, ... ] }
        final List<Map<String, dynamic>> data =
            (body is Map && body['data'] is List)
                ? List<Map<String, dynamic>>.from(
                    (body['data'] as List).whereType<Map>())
                : <Map<String, dynamic>>[];

        // Ensure products is always a List for the UI
        for (final c in data) {
          if (c['products'] is! List) c['products'] = <dynamic>[];
        }

        // Update reactive list
        homeProductList.assignAll(data);

        // Optional tagname for your loading stub
        tagname.value =
            data.isNotEmpty ? (data.first['name']?.toString() ?? '') : '';

        // Stable shuffle seed for session (declare: int? productsShuffleSeed; in controller)
        productsShuffleSeed ??= DateTime.now().millisecondsSinceEpoch;

        print("Ã¢Å“â€¦ collections loaded: ${homeProductList.length}");
      } else {
        homeProductList.clear();
        print(
            "Ã¢ÂÅ’ collections load failed: ${response.statusCode} ${response.reasonPhrase}");
        // print(response.body); // uncomment to debug server message
      }
    } on TimeoutException {
      homeProductList.clear();
      print("Ã¢ÂÅ’ Request timed out for $uri");
    } catch (e) {
      homeProductList.clear();
      print("Ã¢ÂÅ’ Error fetching collections: $e");
    } finally {
      isHomeProduct.value = false;
    }
  }

  Future<void> getProductById(int id) async {
    isDetails.value = true;

    try {
      errorMsg.value = "";
      productDetails.clear();
      imageList.clear();
      sizeInventoryList.clear();
      colorInventoryList.clear();
      selectedVariants.clear();
      selectedSize.value = "";
      selectedColor.value = "";
      currentDisplayImages.clear();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('${ApiConstants.baseUrl}/product/$id');
      final resp = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token'
      });

      if (resp.statusCode != 200) {
        errorMsg.value = "Failed to load product";
        return;
      }

      final decoded = json.decode(resp.body);
      final data = decoded["data"];

      // ✅ Store complete product details
      productDetails = Map<String, dynamic>.from(data);

      // ✅ Process imageUrls
      if (data["imageUrls"] is List) {
        imageList.assignAll((data["imageUrls"] as List)
            .map((url) => {"name": url.toString()})
            .toList());

        currentDisplayImages.assignAll(
            (data["imageUrls"] as List).map((url) => url.toString()).toList());
      }

      // ✅ Store brand details
      if (data["brand"] != null) {
        brandDetails = data["brand"];
      }

      // ✅ Process variants
      final variants =
          List<Map<String, dynamic>>.from(data["variants"].whereType<Map>());

      final List<Map<String, dynamic>> parsedVariants = [];
      bool hasSize = false;
      bool hasColor = false;

      for (final v in variants) {
        String size = "";
        String color = "";

        if (v["selectedOptions"] is List) {
          for (final opt in v["selectedOptions"]) {
            final optName = opt["name"].toString().toLowerCase();
            if (optName == "size") {
              size = opt["value"].toString();
              hasSize = true;
            }
            if (optName == "color" || optName == "colour") {
              color = opt["value"].toString();
              hasColor = true;
            }
          }
        }

        final inventory = v["inventory"];
        final stock =
            inventory != null ? (inventory["availableStock"] ?? 0) : 0;

        parsedVariants.add({
          "id": v["id"],
          "size": size,
          "color": color,
          "price": v["price"],
          "stocks": stock,
          "variant": v,
          "imageSrc": v["imageSrc"],
        });
      }

      selectedVariants.assignAll(parsedVariants);

      print("🔍 Product Type Detection:");
      print("   Has Size: $hasSize");
      print("   Has Color: $hasColor");

      // ✅ Handle products with ONLY COLOR (no size)
      if (!hasSize && hasColor) {
        print("📦 Product Type: COLOR ONLY (Accessory)");

        // Get unique colors
        final List<String> uniqueColors = parsedVariants
            .map((e) => e["color"].toString())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();

        colorInventoryList.assignAll(uniqueColors);

        // Auto-select first color
        if (uniqueColors.isNotEmpty) {
          selectedColor.value = uniqueColors.first;
          updateImagesForSelectedColor();

          print("✅ Colors available: $uniqueColors");
          print("✅ Auto-selected color: ${uniqueColors.first}");
        }
      }
      // ✅ Handle products with SIZE + COLOR (clothing)
      else if (hasSize) {
        print("📦 Product Type: SIZE + COLOR (Clothing)");

        final List<String> uniqueSizes = parsedVariants
            .map((e) => e["size"].toString())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();

        final sizeOrder = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
        uniqueSizes.sort((a, b) {
          final aIndex = sizeOrder.indexOf(a.toUpperCase());
          final bIndex = sizeOrder.indexOf(b.toUpperCase());
          if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });

        sizeInventoryList.assignAll(uniqueSizes);

        if (uniqueSizes.isNotEmpty) {
          final firstSize = uniqueSizes.first;
          selectedSize.value = firstSize;

          loadColorsForSize(firstSize);
          updateImagesForSelectedColor();

          print("✅ Sizes available: $uniqueSizes");
          print("✅ Colors for $firstSize: ${colorInventoryList.toList()}");
        }
      }
      // ✅ Handle products with ONLY SIZE (no color)
      else if (hasSize && !hasColor) {
        print("📦 Product Type: SIZE ONLY");

        final List<String> uniqueSizes = parsedVariants
            .map((e) => e["size"].toString())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();

        sizeInventoryList.assignAll(uniqueSizes);

        if (uniqueSizes.isNotEmpty) {
          selectedSize.value = uniqueSizes.first;
          print("✅ Auto-selected size: ${uniqueSizes.first}");
        }
      }

      print("🖼️ Display images count: ${currentDisplayImages.length}");
    } catch (e, stackTrace) {
      errorMsg.value = "Error fetching product: $e";
      print("❌ getProductById error: $e");
      print("Stack trace: $stackTrace");
    } finally {
      isDetails.value = false;
      update();
    }
  }

  Future<Map<String, dynamic>?> fetchProductDetails(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('${ApiConstants.baseUrl}/product/$id');
      final resp = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token'
      });

      if (resp.statusCode != 200) {
        print("❌ Product fetch failed: ${resp.statusCode}");
        return null;
      }

      final decoded = json.decode(resp.body);

      return Map<String, dynamic>.from(decoded["data"]);
    } catch (e) {
      print("❌ fetchProductDetails error: $e");
      return null;
    }
  }

  Future<void> getProductData(int gender) async {
    isProduct.value = true;
    final prefs = await SharedPreferences.getInstance();

    productList.clear(); // Ã¢Å“â€¦ Clear previous products

    final List<String> section = [
      'lafetch-exclusive',
      'premium',
      'luxurious',
      'standard',
    ];

    try {
      for (String collectionType in section) {
        final response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?gender=$gender&collectionType=$collectionType?status=1"),
          headers: {
            'Accept': 'application/json; charset=UTF-8',
            'Authorization': "Bearer ${prefs.getString('token') ?? ''}",
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData["data"] != null) {
            productList.addAll(responseData["data"]);
          }
        } else if (response.statusCode == 500) {
          getSnackBar("Server error, please try again");
        } else if (response.statusCode == 401) {
          Get.offAll(() => const LoginScreen(initialTab: 0));
          getSnackBar("Authentication failed");
          break;
        } else {
          getSnackBar("Failed to load products for $collectionType");
        }
      }

      hasnextpage.value = true;
      loadMore.value = false;
      page.value = 1;
    } catch (e) {
      print("Error fetching products: $e");
      getSnackBar("Something went wrong.");
    } finally {
      isProduct.value = false;
    }
  }

  getFilterData(String type) async {
    isFilter.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products-filter-paramters?type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          filterList = responseData;
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get filter failed");
      }
    } catch (e) {
      print("error$e");
    }
    isFilter.value = false;
  }

  getEstimateDate(int id, String zip) async {
    isEstimateDate.value = true;
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/$id/estimated-delivery?zip=$zip"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        getItBy = responseData;
      } else if (response.statusCode == 400) {
        if (responseData["errors"]["zip"].isNotEmpty) {
          getSnackBar("Invalid Pincode");
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get estimate delivery failed");
      }
    } catch (e) {
      print("error$e");
    }
    isEstimateDate.value = false;
    isDetails.value = false;
  }

  callAddtoCart(int quantity, String type, Color background, int productId,
      bool showloader) async {
    if (showloader) {
      showLoading();
    }
    isReorder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "quantity": quantity,
        "inventory_id": sizeInventoryId.value,
        "express_delivery": expressValue.value,
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/orders"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 200) {
        addToCart.value = true;
        errorColorMsg.value = "";
        errorSizeMsg.value = "";
        if (type == "reorder") {
          Get.to(CartScreen());
          reorderSelected.clear();
          reorderSelected = List.generate(50, (i) => false).obs;
        }
        /*  else {
          getSnackBar("Product added to cart");
        } */
        if (type == "buy now") {
          Get.to(CartScreen(
            backgroundcolor: background,
          ))?.then(
            (value) {
              addToCart.value = false;
            },
          );
        }
      } else if (response.statusCode == 201) {
      } else if (response.statusCode == 400) {
        var responseData = json.decode(response.body);
        errorMsg.value = responseData["message"];
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
    isReorder.value = false;
  }

  callAddProductToWishlist(
      int wishlistId,
      String type,
      int id,
      int categoryId,
      int brandId,
      List list,
      List categoryList,
      int existId,
      int genderType,
      int catalogId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$id/wishlist/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("abc$type");
        if (responseData["wishlisted"]) {
          Get.close(1);
          // getSnackBar("product added to the wishlist");
        } else {
          //  getSnackBar("product removed from the wishlist");
        }
        if (type == "product") {
          final prefs = await SharedPreferences.getInstance();
          int gender = prefs.getInt("gender") ?? 3;
          getProductData(gender);
        } else if (type == "category") {
          /*  getProductByCategoryData(categoryId, brandId, "", [], sortBy.value,
              genderType, filterEnable.value, catalogId, false, "catalog"); */
        } else if (type == "handpicked") {
          /* categoryFilter.value = genderType;
          getHandPickedProduct(
              productSortBy.value, filterProductEnable.value, false); */
        } else if (type == "category product") {
          /*   getProductByCategoryData(categoryId, brandId, "", [], sortBy.value,
              genderType, filterEnable.value, catalogId, false, ""); */
        } else if (type == "tags") {
          // getBestSellerProductData(brandId);
        } else if (type == "brand") {
          /*  getBrandExpressProductData(
              brandId, expressSortBy.value, filterExpressEnable.value); */
        } else if (type == "bannerTag") {
          /*  getTagsBannerData(list, categoryList, genderType, sortBy.value,
              filterEnable.value, false); */
        } else if (type == "frequently") {
          // getProductRecommendations(existId);
        } else if (type == "seller") {
        } else {
          // getProductRecommendations(existId);
        }
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("item add failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callSaveAddress(
      String screenType,
      int addressId,
      String name,
      String phone,
      String city,
      String type,
      String address,
      String zip,
      String locality,
      String state,
      double lat,
      double lng,
      BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": name,
        "phone": phone,
        "city": city,
        "type": type,
        "address": address,
        "zip": zip,
        "locality": locality,
        "state": state,
        "default_shipping": 1,
        "latitude": lat,
        "longitude": lng
      };
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/addresses/$addressId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (screenType == "change address") {
          Get.back();
          /* getBrandExpressProductData(
              brand_id.value, expressSortBy.value, filterExpressEnable.value); */

          FocusScope.of(context).unfocus();
        }
        if (screenType == "express") {
          // getBrandExpressProductData(
          //     brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "") {
          Get.back();
        }
      } else if (response.statusCode == 201) {
        print(responseData);
        if (screenType == "change address") {
          Get.back();
          // getBrandExpressProductData(
          //     brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "express") {
          // getBrandExpressProductData(
          //     brand_id.value, expressSortBy.value, filterExpressEnable.value);
        }
        if (screenType == "") {
          Get.back();
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
      } else if (response.statusCode == 401) {
        // getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> submitProductReview({
    required int userId,
    required int orderItemId,
    required int variantId,
    required int rating,
    required String comment,
  }) async {
    isSubmittingReview.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      getSnackBar("Please login to submit a review");
      isSubmittingReview.value = false;
      return false;
    }

    try {
      final Map<String, dynamic> sendData = {
        "userId": userId,
        "orderItemId": orderItemId,
        "variantId": variantId,
        "rating": rating,
        "comment": comment,
      };

      final response = await http
          .post(
            Uri.parse("${ApiConstants.baseUrl}/review"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json;charset=UTF-8',
              "Authorization": "Bearer $token",
            },
            body: json.encode(sendData),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("✓ Review submitted successfully: $responseData");
        getSnackBar(responseData["message"] ?? "Review submitted successfully");

        // Optionally refresh product reviews
        final variant = responseData["data"]?["product_variant"];
        if (variant != null && variant["productId"] != null) {
          await getProductReviews(variant["productId"]);
        }

        return true;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final errorMessage = responseData["message"] ?? "Invalid review data";
        getSnackBar(errorMessage);
        print("✗ Review submission failed: $errorMessage");
        return false;
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
        return false;
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
        return false;
      } else {
        getSnackBar("Failed to submit review (${response.statusCode})");
        print("✗ Review submission failed: ${response.statusCode}");
        return false;
      }
    } on TimeoutException {
      getSnackBar("Request timeout. Please try again.");
      print("✗ Review submission timeout");
      return false;
    } catch (e, s) {
      getSnackBar("Error submitting review");
      print("✗ Error submitting review: $e\n$s");
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<void> getProductReviews(
    int productId, {
    int page = 1,
    int limit = 10,
  }) async {
    isFetchingReviews.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final queryParams = {
        'productId': productId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse("${ApiConstants.baseUrl}/reviews")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': "Bearer $token",
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is! Map || responseData['data'] == null) {
          reviewList.clear();
          totalReview.value = 0;
          averageRating.value = 0.0;
          print("✓ No reviews found for product $productId");
          return;
        }

        final List<dynamic> reviews = responseData['data'] as List<dynamic>;

        // ✅ Update review list
        reviewList.assignAll(reviews);
        totalReview.value = reviews.length;

        // ✅ Calculate average rating
        if (reviews.isNotEmpty) {
          final totalRating = reviews.fold<double>(
            0.0,
            (sum, review) =>
                sum + ((review['rating'] as num?)?.toDouble() ?? 0.0),
          );
          averageRating.value = totalRating / reviews.length;
        } else {
          averageRating.value = 0.0;
        }

        print(
            "✓ Reviews loaded: ${reviews.length} | Avg Rating: ${averageRating.value.toStringAsFixed(1)}");
      } else if (response.statusCode == 404) {
        reviewList.clear();
        totalReview.value = 0;
        averageRating.value = 0.0;
        print("✓ No reviews found (404) for product $productId");
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Session expired. Please log in again.");
      } else if (response.statusCode >= 500) {
        getSnackBar("Server error. Please try again later.");
        print("✗ Server error fetching reviews: ${response.statusCode}");
      } else {
        getSnackBar("Failed to load reviews (${response.statusCode})");
        print("✗ Unexpected response: ${response.statusCode}");
      }
    } on TimeoutException {
      getSnackBar("Request timed out. Please try again.");
      print("✗ Reviews fetch timeout");
    } catch (e, s) {
      print("✗ Error fetching reviews: $e\n$s");
      getSnackBar("Error loading reviews");
    } finally {
      isFetchingReviews.value = false;
    }
  }

  Future<void> loadMoreReviews(int productId, int currentPage) async {
    if (isFetchingReviews.value) return;

    final nextPage = currentPage + 1;

    isFetchingReviews.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final queryParams = {
        'productId': productId.toString(),
        'page': nextPage.toString(),
        'limit': '10',
      };

      final uri = Uri.parse("${ApiConstants.baseUrl}/reviews")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': "Bearer $token",
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null) {
          List newReviews = [];

          if (responseData is Map) {
            if (responseData["data"] != null) {
              newReviews = responseData["data"];
            } else if (responseData["reviews"] != null) {
              newReviews = responseData["reviews"];
            }
          } else if (responseData is List) {
            newReviews = responseData;
          }

          if (newReviews.isNotEmpty) {
            reviewList.addAll(newReviews);
            print("✓ Loaded ${newReviews.length} more reviews");
          } else {
            print("✓ No more reviews to load");
          }
        }
      }
    } on TimeoutException {
      print("✗ Load more reviews timeout");
    } catch (e) {
      print("✗ Error loading more reviews: $e");
    } finally {
      isFetchingReviews.value = false;
    }
  }

  /// ✅ Fetch available coupons from API
  Future<void> getCoupons() async {
    isCoupons.value = true;
    couponList.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse("${ApiConstants.baseUrl}/coupons");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      print("Response: ${response.statusCode} => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded['data'] is List) {
          final List<Map<String, dynamic>> data =
              List<Map<String, dynamic>>.from(decoded['data']);
          couponList.assignAll(data);
          print("✓ Coupons loaded: ${couponList.length}");
        } else {
          print("✗ Unexpected response: ${response.body}");
          getSnackBar("Unexpected response from coupons API");
        }
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 404) {
        couponList.clear();
        getSnackBar("No coupons available");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error while fetching coupons");
      } else {
        getSnackBar("Unexpected error: ${response.statusCode}");
      }
    } on TimeoutException {
      getSnackBar("Request timed out while fetching coupons");
    } catch (e, stacktrace) {
      print("✗ Error fetching coupons: $e\n$stacktrace");
      getSnackBar("Error loading coupons");
    } finally {
      isCoupons.value = false;
    }
  }

  Future<Map?> checkServiceability({
    required int variantId,
    required String deliveryPostalCode,
  }) async {
    isEstimateDate.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final uri = Uri.parse("${ApiConstants.baseUrl}/check-serviceability");

    try {
      final body = {
        "variantId": variantId,
        "deliveryPostalCode": deliveryPostalCode,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json; charset=UTF-8',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data['data'] != null && data['data'] is Map) {
          final delivery = data['data'];
          final date = delivery['estimatedDate']?.toString() ?? "";
          final days = delivery['estimatedDays']?.toString() ?? "";

          estimatedDate.value = date;
          estimatedDays.value = days;
          isServiceable.value = true;

          // ✅ Only show delivery info
          serviceabilityMessage.value = "Delivery by $date ($days Days)";

          print("✅ Showing: ${serviceabilityMessage.value}");
          return data;
        } else {
          isServiceable.value = false;
          serviceabilityMessage.value =
              "Service not available for this pincode";
        }
      } else {
        isServiceable.value = false;
        serviceabilityMessage.value = "Failed to check serviceability";
      }
    } catch (e) {
      print("💥 checkServiceability error: $e");
      isServiceable.value = false;
      serviceabilityMessage.value = "Error checking serviceability";
    } finally {
      isEstimateDate.value = false;
    }

    return null;
  }
}
