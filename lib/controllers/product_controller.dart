// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/cartscreen.dart';

import '../screens/loginscreen.dart';
import '../services/cache_manager.dart';
import '../models/collection_model.dart';
import '../models/collection_extensions.dart';
import '../models/collection_banner_model.dart';
import 'base_controller.dart';

class ProductController extends BaseController {
  RxBool isProduct = false.obs;
  RxBool isFilter = false.obs;
  RxBool isMostSearch = false.obs;
  RxBool isHomeProduct = false.obs;

  // ✅ Request deduplication flags - prevents concurrent duplicate API calls
  bool _isHomeProductRequestInProgress = false;
  bool _isCollectionBannersRequestInProgress = false;

  // ✅ Track which genders have already loaded home products (to avoid duplicate API calls)
  final Set<int> _loadedHomeProductGenders = {};
  bool _collectionBannersLoaded = false;

  /// Check if home products for a gender are already loaded
  bool isHomeProductLoaded(int gender) =>
      _loadedHomeProductGenders.contains(gender);

  /// Mark home products for gender as loaded
  void markHomeProductLoaded(int gender) =>
      _loadedHomeProductGenders.add(gender);

  /// Check if collection banners are loaded
  bool isCollectionBannersLoaded() => _collectionBannersLoaded;

  /// Clear loaded tracking (useful for force refresh)
  void clearLoadedTracking() {
    _loadedHomeProductGenders.clear();
    _collectionBannersLoaded = false;
  }

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
  RxInt collectionId = 0.obs;
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
  RxList<CollectionModel> homeProductList = <CollectionModel>[].obs;
  RxList<StandaloneCollectionBanner> collectionBanners =
      <StandaloneCollectionBanner>[].obs;
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
  // ---- BREADCRUMB ----
  RxBool isBreadcrumbLoading = false.obs;
  RxList<Map<String, dynamic>> breadcrumbList = <Map<String, dynamic>>[].obs;
// Add this observable for tracking current display images
  RxList<String> currentDisplayImages = <String>[].obs;

  //collections

  RxBool isProductCollectionsLoading = false.obs;
  RxList<Map<String, dynamic>> productCollections =
      <Map<String, dynamic>>[].obs;

  // Filter metadata
  RxBool isFilterMetadata = false.obs;
  RxList<Map<String, dynamic>> filterBrands = <Map<String, dynamic>>[].obs;
  RxList<String> filterColors = <String>[].obs;
  RxList<String> filterSizes = <String>[].obs;

  // shake animation trigger
  RxInt sizeShakeTrigger = 0.obs;
  RxInt colorShakeTrigger = 0.obs;

// Method to update images based on selected color
  void updateImagesForSelectedColor() {
    final pd = productDetails;
    final color = selectedColor.value.trim().toLowerCase();
    final size = selectedSize.value.trim().toLowerCase();

    print("🎨 Updating images for Color=$color | Size=$size");

    final variants = (pd["variants"] ?? []) as List;

    // FIND VARIANT MATCHING COLOR + SIZE (prefer exact match)
    Map? variant = variants.firstWhereOrNull((v) {
      // Handle selectedOptions that might be a JSON string or a List
      dynamic selectedOptions = v["selectedOptions"];

      // If it's a JSON string, parse it first
      if (selectedOptions is String && selectedOptions.isNotEmpty) {
        try {
          selectedOptions = json.decode(selectedOptions);
        } catch (e) {
          print("⚠️ Failed to parse selectedOptions JSON: $e");
          selectedOptions = [];
        }
      }

      final opts = (selectedOptions is List) ? selectedOptions : [];

      final hasColor = opts.any((o) =>
          o["name"].toString().toLowerCase() == "color" &&
          o["value"].toString().toLowerCase() == color);

      final hasSize = opts.any((o) =>
          o["name"].toString().toLowerCase() == "size" &&
          o["value"].toString().toLowerCase() == size);

      if (size.isEmpty) return hasColor;
      return hasColor && hasSize;
    });

    if (variant == null) {
      print("⚠ No variant matched color/size. Showing default images.");
      if (pd["imageUrls"] is List) {
        currentDisplayImages.assignAll(
          (pd["imageUrls"] as List).map((e) => e.toString()).toList(),
        );
      }
      update();
      return;
    }

    // Shopify Variant IMAGES (Correct)
    final variantMedia = variant["images"] ??
        variant["media"] ??
        []; // some APIs return "media" instead of "images"

    List<String> images = [];

    if (variantMedia is List) {
      images = variantMedia
          .map((e) =>
              e["src"]?.toString() ?? e["url"]?.toString() ?? e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (images.isEmpty) {
      // fallback to imageSrc fallback
      final fallbackImg = variant["imageSrc"]?.toString() ?? "";
      if (fallbackImg.isNotEmpty && fallbackImg != "null") {
        images.add(fallbackImg);
      }
    }

    // if still empty → main product images
    if (images.isEmpty && pd["imageUrls"] is List) {
      images = (pd["imageUrls"] as List).map((e) => e.toString()).toList();
    }

    currentDisplayImages.assignAll(images);
    print("🖼 Final images loaded (${images.length}): $images");

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

// Get display price from selected variant or minimum variant price
  num getDisplayPrice() {
    final variant = getSelectedVariant();

    // If a variant is selected, use its price
    if (variant != null) {
      final price = variant['price'];
      if (price is num && price > 0) return price;
    }

    // If no variant selected but variants exist, use minimum variant price
    if (selectedVariants.isNotEmpty) {
      num minPrice = double.infinity;
      for (final v in selectedVariants) {
        final vPrice = v['price'] as num? ?? 0;
        if (vPrice > 0 && vPrice < minPrice) {
          minPrice = vPrice;
        }
      }
      if (minPrice != double.infinity && minPrice > 0) return minPrice;
    }

    // Fallback to product details
    final pd = productDetails;
    final price =
        pd['price'] ?? pd['basePrice'] ?? pd['netAmount'] ?? pd['msp'];
    if (price is num && price > 0) return price;

    return num.tryParse(price?.toString() ?? '0') ?? 0;
  }

// Get MRP from selected variant or maximum variant MRP
  num getDisplayMrp() {
    final variant = getSelectedVariant();

    // If a variant is selected, use its compareAtPrice
    if (variant != null) {
      final compareAt = variant['compareAtPrice'];
      if (compareAt is num && compareAt > 0) return compareAt;
    }

    // If no variant selected but variants exist, use maximum compareAtPrice
    if (selectedVariants.isNotEmpty) {
      num maxMrp = 0;
      for (final v in selectedVariants) {
        final vMrp = v['compareAtPrice'] as num? ?? 0;
        if (vMrp > maxMrp) {
          maxMrp = vMrp;
        }
      }
      if (maxMrp > 0) return maxMrp;
    }

    // Fallback to product MRP
    final mrp = productDetails['mrp'] ?? productDetails['manufacturingAmount'];
    if (mrp is num && mrp > 0) return mrp;

    return num.tryParse(mrp?.toString() ?? '0') ?? 0;
  }

// Get stock for selected variant
  int getSelectedStock() {
    final variant = getSelectedVariant();
    if (variant == null) return 0;

    final stocks = variant['inventories']?[0]?['availableStock'] ??
        variant['availableStock'] ??
        variant['stocks'] ??
        variant['stock'];
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

    // ✅ Auto-select if only ONE color is available
    if (colors.length == 1) {
      selectedColor.value = colors.first;
      print("✅ Auto-selected single color: ${colors.first}");
      updateImagesForSelectedColor();
    } else {
      // Reset selected color when size changes (multiple colors available)
      selectedColor.value = '';
      print("⚠️ Multiple colors available - user must choose color");
    }

    if (colors.isEmpty) {
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
      sizeShakeTrigger.value++;
      return false;
    }

    // ✅ If product has colors, validate color selection
    if (hasColors && selectedColor.value.isEmpty) {
      errorColorMsg.value = "Please select a color";
      colorShakeTrigger.value++;
      return false;
    }

    if (!hasColors) {
      errorColorMsg.value = "";
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
    final stock = int.tryParse((variant['inventories']?[0]?['availableStock'] ??
                    variant['availableStock'] ??
                    variant['stocks'] ??
                    variant['stock'])
                ?.toString() ??
            '0') ??
        0;
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

  /// ----------------------------------------------------------
  /// FETCH BREADCRUMB (productId + optional fallback name/slug)
  /// ----------------------------------------------------------
  Future<void> fetchBreadcrumb(int productId, {
    String fallbackName = '',
    String fallbackSlug = '',
  }) async {
    isBreadcrumbLoading.value = true;
    breadcrumbList.clear();
    final url = '${ApiConstants.baseUrl}/product/$productId/breadcrumb';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          final data = body['data'];
          final crumbs = (data['breadcrumbs'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ?? [];
          if (crumbs.isNotEmpty) {
            breadcrumbList.assignAll(crumbs);
            return;
          }
        }
      }
    } catch (_) {
      // fall through to fallback
    } finally {
      isBreadcrumbLoading.value = false;
    }
    // Fallback
    breadcrumbList.assignAll([
      {'name': 'Home'},
      if (fallbackName.isNotEmpty) {'name': fallbackName},
      if (fallbackSlug.isNotEmpty) {'name': fallbackSlug},
    ]);
  }

  int _activeGenderRequest = -1;

  Future<void> getHomeProduct(
    int gender, {
    bool withLimit = true,
    bool forceRefresh = false,
  }) async {
    _activeGenderRequest = gender; // ✅ mark latest request

    final displayFor = gender == 1
        ? 'men'
        : gender == 2
            ? 'women'
            : 'accessories';

    final cacheKey =
        'home_products_v8_${displayFor}_${withLimit ? "limited" : "all"}';

    // ✅ Skip API call if data already loaded for this gender (unless force refresh)
    if (!forceRefresh && isHomeProductLoaded(gender)) {
      print(
          '✅ Home products already loaded for gender: $gender, skipping API call');
      isHomeProduct.value = false;
      final cached = await CacheManager.get(key: cacheKey);
      if (cached != null && cached is List) {
        final collections = cached
            .whereType<Map<String, dynamic>>()
            .map((e) => CollectionModel.fromJson(e))
            .toList();
        homeProductList.assignAll(collections);
        tagname.value = collections.isNotEmpty ? collections.first.name : '';
      }
      return;
    }

    /// ---------------- CACHE ----------------
    if (!forceRefresh) {
      final cached = await CacheManager.get(key: cacheKey);
      if (cached != null && cached is List) {
        if (_activeGenderRequest != gender) return;

        final collections = cached
            .whereType<Map<String, dynamic>>()
            .map((e) => CollectionModel.fromJson(e))
            .toList();
        homeProductList.assignAll(collections);
        tagname.value = collections.isNotEmpty ? collections.first.name : '';
        markHomeProductLoaded(gender);
        return;
      }
    }

    // ✅ CRITICAL: Only set loading and clear if we're actually going to fetch
    // Don't clear if we have existing data unless force refresh
    if (forceRefresh) {
      isHomeProduct.value = true;
      homeProductList.clear();
    } else if (homeProductList.isEmpty) {
      isHomeProduct.value = true;
      // List is already empty, no need to clear
    } else {
      // ✅ We have data but checks failed - shouldn't reach here
      // Reset loading state and try to use cached data
      isHomeProduct.value = false;
      print("⚠️ Unexpected state: attempting to load but data exists");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse(
            "${ApiConstants.baseUrl}/product-collection/collection-with-products")
        .replace(queryParameters: {
      'displayFor': 'homepage',
      'gender': gender.toString(),
      if (withLimit) 'limit': 'true',
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      // ❌ ignore old response
      if (_activeGenderRequest != gender) {
        print("⛔ Ignored outdated response for gender=$gender");
        return;
      }

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        // final collections = CollectionUtils.parseCollections(body['data']);
        final rawData = body['data'];
        final collectionsList =
            rawData is Map ? rawData['collections'] : rawData;
        final collections = CollectionUtils.parseCollections(collectionsList);

        homeProductList.assignAll(collections);
        tagname.value = collections.isNotEmpty ? collections.first.name : '';
        await CacheManager.save(
          key: cacheKey,
          data: collections.map((e) => e.toJson()).toList(),
        );

        // ✅ Mark as loaded after successful API call
        markHomeProductLoaded(gender);
        print("✅ UI updated for gender=$gender");
      } else {
        print("⚠️ getHomeProduct API error: Status ${response.statusCode}");
        print(
            "⚠️ Response: ${response.body.substring(0, min(response.body.length, 200))}");
      }
    } catch (e) {
      if (_activeGenderRequest == gender) {
        // ✅ Only clear if we were doing a force refresh
        // Otherwise keep existing data to avoid showing empty screen
        if (forceRefresh) {
          homeProductList.clear();
        }
        print("❌ Error loading home products: $e");
      }
    } finally {
      if (_activeGenderRequest == gender) {
        isHomeProduct.value = false;
      }
    }
  }

  /// Fetch collection banners from the API
  Future<void> getCollectionBanners({bool forceRefresh = false}) async {
    // ✅ Skip if already loaded (unless force refresh)
    if (!forceRefresh &&
        _collectionBannersLoaded &&
        collectionBanners.isNotEmpty) {
      print('✅ Collection banners already loaded, skipping API call');
      return;
    }

    // ✅ Prevent duplicate concurrent requests
    if (_isCollectionBannersRequestInProgress) {
      print("⏳ Collection banners request already in progress, skipping...");
      return;
    }

    final cacheKey = 'collection_banners_v1';

    // Try to load from cache first
    if (!forceRefresh) {
      final cached = await CacheManager.get(key: cacheKey);
      if (cached != null && cached is List) {
        try {
          final banners = CollectionBannerUtils.parseBanners(cached);
          collectionBanners.assignAll(banners);
          _collectionBannersLoaded = true; // ✅ Mark as loaded
          print("✅ Loaded ${banners.length} collection banners from cache");
          return;
        } catch (e) {
          print("⚠️ Error parsing cached banners: $e");
        }
      }
    }

    _isCollectionBannersRequestInProgress = true;
    final base = ApiConstants.baseUrl;
    final uri = Uri.parse("$base/collection-banners").replace(
      queryParameters: {'status': 'true'},
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final banners = CollectionBannerUtils.parseBanners(body['data']);

        collectionBanners.assignAll(banners);

        // Cache the banners
        await CacheManager.save(
          key: cacheKey,
          data: body['data'],
        );

        _collectionBannersLoaded = true; // ✅ Mark as loaded
        print("✅ Loaded ${banners.length} collection banners from API");
      } else {
        collectionBanners.clear();
        print("❌ Banner API Error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("❌ Error loading collection banners: $e");
      print("Stack trace: $stackTrace");
      collectionBanners.clear();
    } finally {
      _isCollectionBannersRequestInProgress = false; // ✅ Reset request flag
    }
  }

  /// Get banners for a specific collection and display type
  List<StandaloneCollectionBanner> getBannersForCollection(
    int collectionId,
    String displayType,
  ) {
    return CollectionBannerUtils.filterBannersForCollection(
      collectionBanners,
      collectionId,
      displayType,
    );
  }

  /// Calculate minimum variant price and MRP for display in product lists
  static Map<String, dynamic> calculateDisplayPrices(
      Map<String, dynamic> product) {
    final variants = product['variants'] as List?;

    num minPrice = double.infinity;
    num maxCompareAtPrice = 0;

    if (variants != null && variants.isNotEmpty) {
      for (final v in variants) {
        if (v is! Map) continue;

        // Get variant price (selling price)
        final vPrice = v['price'] as num? ?? 0;
        if (vPrice > 0 && vPrice < minPrice) {
          minPrice = vPrice;
        }

        // Get variant MRP (compare at price)
        final vMrp = v['compareAtPrice'] as num? ?? 0;
        if (vMrp > maxCompareAtPrice) {
          maxCompareAtPrice = vMrp;
        }
      }
    }

    // Fallback to product-level prices
    if (minPrice == double.infinity) {
      minPrice = (product['basePrice'] ??
          product['price'] ??
          product['netAmount'] ??
          0) as num;
    }

    if (maxCompareAtPrice == 0) {
      maxCompareAtPrice =
          (product['mrp'] ?? product['manufacturingAmount'] ?? 0) as num;
    }

    // Calculate discount percentage
    int? discountPercent;
    if (minPrice > 0 && maxCompareAtPrice > minPrice) {
      discountPercent =
          (((maxCompareAtPrice - minPrice) / maxCompareAtPrice) * 100).round();
    }

    return {
      ...product,
      'displayPrice': minPrice,
      'displayMrp': maxCompareAtPrice > minPrice ? maxCompareAtPrice : null,
      'discountPercent': discountPercent,
    };
  }

  Future<void> getProductById(int id, {String? slug}) async {
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

      // Use slug if provided, otherwise use numeric ID
      final pathSegment = (slug != null && slug.isNotEmpty) ? slug : id.toString();
      final uri = Uri.parse('${ApiConstants.baseUrl}/product/$pathSegment');
      print("🔗 Fetching product: $uri");
      final resp = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token'
      });

      if (resp.statusCode != 200) {
        print("❌ Product fetch failed: ${resp.statusCode} for $uri");
        errorMsg.value = "Failed to load product";
        return;
      }

      final decoded = json.decode(resp.body);
      final data = decoded["data"];

      // ✅ Store complete product details
      productDetails = Map<String, dynamic>.from(data);

      // ✅ Extract all product information
      print("📦 Product ID: ${data['id']}");
      print("📦 Product Title: ${data['title']}");
      print("📦 Product Type: ${data['type']}");
      print("📦 Short Description: ${data['shortDescription']}");
      print("📦 Description: ${data['description']}");
      print("📦 Base Price: ${data['basePrice']}");
      print("📦 Net Amount: ${data['netAmount']}");
      print("📦 MRP: ${data['mrp']}");
      print("📦 Super Category ID: ${data['superCatId']}");
      print("📦 Category ID: ${data['catId']}");
      print("📦 Sub Category ID: ${data['subCatId']}");
      print("📦 Brand ID: ${data['brandId']}");
      print("📦 Tags: ${data['tags']}");
      print("📦 Target Genders: ${data['targetGenders']}");
      print("📦 Shopify Handle: ${data['shopifyHandle']}");
      print("📦 Status: ${data['status']}");
      print("📦 Is Featured: ${data['isFeatured']}");
      print("📦 Rating: ${data['rating']}");
      print("📦 Number of Reviews: ${data['numReviews']}");

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
        print("🏷️ Brand Name: ${data['brand']['name']}");
        print("🏷️ Brand Description: ${data['brand']['description']}");
        print("🏷️ Brand Logo: ${data['brand']['logo']}");
        print("🏷️ Brand Video: ${data['brand']['video']}");
        print("🏷️ Brand Website: ${data['brand']['websiteLink']}");
        print("🏷️ Brand Commission: ${data['brand']['commission']}%");
        print("🏷️ COD Available: ${data['brand']['codAvailable']}");
        print("🏷️ Is Featured Brand: ${data['brand']['isFeatured']}");
      }

      // ✅ Store category details
      if (data["category"] != null) {
        print("📂 Category Name: ${data['category']['name']}");
        print("📂 Category Type: ${data['category']['type']}");
      }

      // ✅ Store HSN Code details
      if (data["hsnCodeDetails"] != null) {
        print("🔢 HSN Code: ${data['hsnCodeDetails']['hsnCode']}");
        print(
            "🔢 GST Rate Higher: ${data['hsnCodeDetails']['gstRateHigher']}%");
        print("🔢 GST Rate Lower: ${data['hsnCodeDetails']['gstRateLower']}%");
        print(
            "🔢 Price Threshold: ₹${data['hsnCodeDetails']['priceThreshold']}");
      }

      // ✅ Store Return Policy
      if (data["returnPolicy"] != null) {
        print("↩️ Return Policy: ${data['returnPolicy']['name']}");
        print(
            "↩️ Return Policy Description: ${data['returnPolicy']['description']}");
      }

      // ✅ Process variants with complete details
      final variants =
          List<Map<String, dynamic>>.from(data["variants"].whereType<Map>());

      final List<Map<String, dynamic>> parsedVariants = [];
      bool hasSize = false;
      bool hasColor = false;

      for (final v in variants) {
        String size = "";
        String color = "";

        // ✅ Parse selectedOptions - handle both List and JSON String
        dynamic selectedOptions = v["selectedOptions"];

        // If it's a JSON string, parse it first
        if (selectedOptions is String && selectedOptions.isNotEmpty) {
          try {
            selectedOptions = json.decode(selectedOptions);
          } catch (e) {
            print("⚠️ Failed to parse selectedOptions JSON: $e");
            selectedOptions = null;
          }
        }

        if (selectedOptions is List) {
          for (final opt in selectedOptions) {
            if (opt == null || opt is! Map) continue;

            final optName = opt["name"]?.toString().toLowerCase() ?? "";
            final optValue = opt["value"]?.toString() ?? "";

            if (optValue.isEmpty) continue;

            if (optName == "size") {
              size = optValue;
              hasSize = true;
            }
            if (optName == "color" || optName == "colour") {
              color = optValue;
              hasColor = true;
            }
          }
        }

        final inventory = v["inventories"]?[0];
        final stock =
            inventory != null ? (inventory["availableStock"] ?? 0) : 0;
        final reservedStock =
            inventory != null ? (inventory["reservedStock"] ?? 0) : 0;

        // ✅ Extract variant price (use 'price' field which includes GST)
        final variantPrice = v["price"];
        final validPrice =
            (variantPrice is num && variantPrice > 0) ? variantPrice : 0;

        // ✅ Extract base price and GST details
        final basePrice = v["basePrice"] ?? 0;
        final gstRate = v["gstRate"] ?? 0;
        final gstAmount = v["gstAmount"] ?? 0;
        final hsnCode = v["hsnCode"] ?? "";

        parsedVariants.add({
          "id": v["id"],
          "size": size,
          "color": color,
          "price": validPrice, // Price including GST
          "basePrice": basePrice, // Base price without GST
          "gstRate": gstRate,
          "gstAmount": gstAmount,
          "hsnCode": hsnCode,
          "compareAtPrice": v["compareAtPrice"] ?? 0,
          "stocks": stock,
          "reservedStock": reservedStock,
          "variant": v,
          "imageSrc": v["imageSrc"],
          "imageAlt": v["imageAlt"],
          "title": v["title"],
          "shopifyVariantId": v["shopifyVariantId"],
        });

        print(
            "📦 Variant ${v['id']}: Size=$size, Color=$color, Price=₹$validPrice, Base=₹$basePrice, GST=$gstRate%, Stock=$stock");
      }

      selectedVariants.assignAll(parsedVariants);

      print("🔍 Product Type Detection:");
      print("   Has Size: $hasSize");
      print("   Has Color: $hasColor");
      print("   Total Variants: ${parsedVariants.length}");

      // ✅ Handle products with ONLY COLOR (no size)
      if (!hasSize && hasColor) {
        print("📦 Product Type: COLOR ONLY (Accessory)");

        final List<String> uniqueColors = parsedVariants
            .map((e) => e["color"].toString())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();

        colorInventoryList.assignAll(uniqueColors);
        print("✅ Colors available: $uniqueColors");

        // ✅ Auto-select if only ONE color is available
        if (uniqueColors.length == 1) {
          selectedColor.value = uniqueColors.first;
          print("✅ Auto-selected single color: ${uniqueColors.first}");
          updateImagesForSelectedColor();
        } else {
          print("⚠️ Multiple colors - user must choose color");
        }
      }
      // ✅ Handle products with SIZE + COLOR (clothing)
      else if (hasSize && hasColor) {
        print("📦 Product Type: SIZE + COLOR (Clothing)");

        final List<String> uniqueSizes = parsedVariants
            .map((e) => e["size"].toString())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();

        final sizeOrder = [
          'XXS',
          'XS',
          'S',
          'M',
          'L',
          'XL',
          'XXL',
          '2XL',
          '3XL',
          'XXXL'
        ];
        uniqueSizes.sort((a, b) {
          // Try numeric comparison first (for jeans sizes like "28", "30", "32")
          final aNum = int.tryParse(a);
          final bNum = int.tryParse(b);

          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }

          // If one is numeric and the other isn't, numeric comes first
          if (aNum != null) return -1;
          if (bNum != null) return 1;

          // Fall back to standard size order for letter sizes
          final aIndex = sizeOrder.indexOf(a.toUpperCase());
          final bIndex = sizeOrder.indexOf(b.toUpperCase());
          if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });

        sizeInventoryList.assignAll(uniqueSizes);

        final List<String> uniqueColors = parsedVariants
            .map((e) => e["color"].toString())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();

        colorInventoryList.assignAll(uniqueColors);

        print("✅ Sizes available: $uniqueSizes");
        print("✅ Colors available: $uniqueColors");
        print("⚠️ No auto-selection - user must choose size and color");
      }
      // ✅ Handle products with ONLY SIZE (no color)
      else if (hasSize && !hasColor) {
        print("📦 Product Type: SIZE ONLY");

        final List<String> uniqueSizes = parsedVariants
            .map((e) => e["size"].toString())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();

        final sizeOrder = [
          'XXS',
          'XS',
          'S',
          'M',
          'L',
          'XL',
          'XXL',
          '2XL',
          '3XL',
          'XXXL'
        ];
        uniqueSizes.sort((a, b) {
          // Try numeric comparison first (for jeans sizes like "28", "30", "32")
          final aNum = int.tryParse(a);
          final bNum = int.tryParse(b);

          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }

          // If one is numeric and the other isn't, numeric comes first
          if (aNum != null) return -1;
          if (bNum != null) return 1;

          // Fall back to standard size order for letter sizes
          final aIndex = sizeOrder.indexOf(a.toUpperCase());
          final bIndex = sizeOrder.indexOf(b.toUpperCase());
          if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });

        sizeInventoryList.assignAll(uniqueSizes);
        print("✅ Sizes available: $uniqueSizes");
        print("⚠️ No auto-selection - user must choose size");
      }
      // ✅ Handle products with NO SIZE and NO COLOR (one-size-fits-all)
      else {
        print("📦 Product Type: ONE SIZE FITS ALL (No variants)");
        if (parsedVariants.isNotEmpty) {
          // Auto-select the only variant
          final onlyVariant = parsedVariants.first;
          selectedSize.value = onlyVariant["size"] ?? "";
          selectedColor.value = onlyVariant["color"] ?? "";
          print("✅ Auto-selected variant: ${onlyVariant['id']}");
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

  /// Fetch product by slug — delegates to getProductById after resolving the slug
  Future<void> getProductBySlug(String slug) async {
    return getProductById(0, slug: slug);
  }

  Future<Map<String, dynamic>?> fetchProductDetails(int productId) async {
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/product/$productId");

      print("🌐 Fetching product details from: $uri");

      final res = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      print("📥 API Response Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        // ========================================
        // 🔍 DEBUG: Print the entire response
        // ========================================
        print("📦 Full API Response:");
        print(json.encode(data));

        // ========================================
        // 🔍 DEBUG: Check variants structure
        // ========================================
        if (data["variants"] != null) {
          final variants = data["variants"];
          print(
              "📦 Variants found: ${variants is List ? variants.length : 'Not a list'}");

          if (variants is List && variants.isNotEmpty) {
            print("📦 First variant structure:");
            print(json.encode(variants.first));

            // Check if GST fields exist
            final firstVariant = variants.first;
            print("🔍 Checking GST fields in first variant:");
            print("   hsn_code: ${firstVariant["hsn_code"]}");
            print("   hsnCode: ${firstVariant["hsnCode"]}");
            print("   gst_rate: ${firstVariant["gst_rate"]}");
            print("   gstRate: ${firstVariant["gstRate"]}");
            print(
                "   statutory_gst_rate: ${firstVariant["statutory_gst_rate"]}");
            print("   statutoryGSTRate: ${firstVariant["statutoryGSTRate"]}");
            print("   gst_rule: ${firstVariant["gst_rule"]}");
            print("   gstRule: ${firstVariant["gstRule"]}");
          }
        } else {
          print("⚠️ No variants field in response");
        }

        // ========================================
        // 🔍 DEBUG: Check product-level GST fields
        // ========================================
        print("🔍 Checking product-level GST fields:");
        print("   hsn_code: ${data["hsn_code"]}");
        print("   hsnCode: ${data["hsnCode"]}");
        print("   gst_rate: ${data["gst_rate"]}");
        print("   gstRate: ${data["gstRate"]}");
        print("   statutory_gst_rate: ${data["statutory_gst_rate"]}");
        print("   statutoryGSTRate: ${data["statutoryGSTRate"]}");
        print("   gst_rule: ${data["gst_rule"]}");
        print("   gstRule: ${data["gstRule"]}");

        return data;
      } else {
        print("❌ API Error: ${res.statusCode} - ${res.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception fetching product details: $e");
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
    required int productId,
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
        "productId": productId,
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
    final userId = prefs.getInt('userId') ?? 0;

    try {
      final queryParams = {
        'productId': productId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
        if (userId > 0) 'userId': userId.toString(),
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
      getSnackBar("check your network connection");
    } finally {
      isCoupons.value = false;
    }
  }

  /// ✅ Validate promo code via API
  Future<Map<String, dynamic>?> validatePromoCode({
    required String code,
    required num cartTotal,
  }) async {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🎟️ VALIDATING PROMO CODE");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("   Code: $code");
    print("   Cart Total: ₹$cartTotal");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse("${ApiConstants.baseUrl}/promo/validate");

    try {
      final body = {
        "code": code,
        "cartTotal": cartTotal,
      };

      print("   Request Body: $body");

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

      print("   Response Status: ${response.statusCode}");
      print("   Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded['data'] is Map) {
          final data = Map<String, dynamic>.from(decoded['data']);

          print("   ✅ Promo Valid");
          print("   Promo Type: ${data['promoType']}");
          print("   Discount Value: ${data['discountValue']}");
          print("   Max Discount Cap: ${data['maxDiscountCap']}");
          print("   Min Cart Value: ${data['minCartValue']}");
          print("   Free Shipping: ${data['freeShipping']}");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

          return data;
        } else {
          print("   ❌ Unexpected response structure");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
          return null;
        }
      } else if (response.statusCode == 400) {
        final decoded = json.decode(response.body);
        final message = decoded['message'] ?? 'Invalid promo code';
        print("   ❌ Validation Failed: $message");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        getSnackBar(message);
        return null;
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
        return null;
      } else if (response.statusCode == 404) {
        print("   ❌ Promo code not found");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        getSnackBar("Invalid or expired promo code");
        return null;
      } else if (response.statusCode == 500) {
        print("   ❌ Server error");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        getSnackBar("Server error. Please try again.");
        return null;
      } else {
        print("   ❌ Unexpected status: ${response.statusCode}");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        getSnackBar("Failed to validate promo code");
        return null;
      }
    } on TimeoutException {
      print("   ❌ Request timeout");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
      getSnackBar("Request timed out. Please try again.");
      return null;
    } catch (e, stacktrace) {
      print("   ❌ Error: $e");
      print("   Stack trace: $stacktrace");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
      getSnackBar("Error validating promo code");
      return null;
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

      // ✅ PRINT PAYLOAD
      print("📦 Serviceability Payload:");
      print(json.encode(body));

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

          final courier = delivery['courier']?.toString() ?? "";
          final date = delivery['estimatedDate']?.toString() ?? "";
          final days = delivery['estimatedDays']?.toString() ?? "";

          courierName.value = courier;
          estimatedDate.value = date;
          estimatedDays.value = days;
          isServiceable.value = true;

          serviceabilityMessage.value = "Delivery by $date ($days Days)";

          print("✅ Courier: $courier");
          print("✅ Showing: ${serviceabilityMessage.value}");
          return data;
        } else {
          isServiceable.value = false;
          courierName.value = "";
          estimatedDate.value = "";
          estimatedDays.value = "";
          serviceabilityMessage.value =
              "Service not available for this pincode";
        }
      } else {
        isServiceable.value = false;
        courierName.value = "";
        estimatedDate.value = "";
        estimatedDays.value = "";
        serviceabilityMessage.value = "Failed to check serviceability";
      }
    } catch (e) {
      print("💥 checkServiceability error: $e");
      isServiceable.value = false;
      courierName.value = "";
      estimatedDate.value = "";
      estimatedDays.value = "";
      serviceabilityMessage.value = "Error checking serviceability";
    } finally {
      isEstimateDate.value = false;
    }

    return null;
  }

  Future<void> getProductCollections() async {
    isProductCollectionsLoading.value = true;
    productCollections.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse("${ApiConstants.baseUrl}/product-collections");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      print("📦 Product Collections → ${response.statusCode}");
      print("📦 Response Body → ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded['data'] is List) {
          productCollections.assignAll(
            List<Map<String, dynamic>>.from(decoded['data']),
          );
          print("✅ Collections loaded: ${productCollections.length}");
        } else {
          print("⚠ Unexpected response structure");
        }
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("Failed to load product collections");
      }
    } on TimeoutException {
      getSnackBar("Request timed out");
    } catch (e, s) {
      print("❌ getProductCollections error: $e\n$s");
      getSnackBar("Something went wrong");
    } finally {
      isProductCollectionsLoading.value = false;
    }
  }

  /// ✅ Fetch filter metadata (brands, colors, sizes) for a super category or brand
  Future<void> getFilterMetadata({
    required int superCatId,
    int? catId,
    int? subCatId,
    int? collectionId,
    int? brandId,
  }) async {
    isFilterMetadata.value = true;
    filterBrands.clear();
    filterColors.clear();
    filterSizes.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    /// 🔹 Only include params with actual values (not null/0)
    final Map<String, String> queryParams = {
      'superCatId': superCatId.toString(),
      if (catId != null && catId > 0) 'catId': catId.toString(),
      if (subCatId != null && subCatId > 0) 'subCatId': subCatId.toString(),
      if (collectionId != null && collectionId > 0)
        'collectionId': collectionId.toString(),
      if (brandId != null && brandId > 0) 'brandId': brandId.toString(),
    };

    final uri = Uri.parse("${ApiConstants.baseUrl}/filter-metadata")
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      print("🔍 Filter Metadata URL → $uri");
      print("🔍 Status → ${response.statusCode}");
      print("🔍 Body → ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded['data'] is Map) {
          final data = decoded['data'];

          if (data['brands'] is List) {
            filterBrands.assignAll(
              List<Map<String, dynamic>>.from(data['brands']),
            );
          }

          if (data['colors'] is List) {
            filterColors.assignAll(List<String>.from(data['colors']));
          }

          if (data['sizes'] is List) {
            filterSizes.assignAll(List<String>.from(data['sizes']));
          }
        }
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      }
    } on TimeoutException {
      print("❌ Filter metadata request timed out");
    } catch (e, s) {
      print("❌ getFilterMetadata error: $e\n$s");
    } finally {
      isFilterMetadata.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose all ScrollController instances
    listController.dispose();
    handpickedController.dispose();
    brandProductController.dispose();
    recentListController.dispose();
    expressListController.dispose();
    categoryProductController.dispose();
    brandDetailsController.dispose();
    brandExpressProductController.dispose();
    tagsProductController.dispose();
    mostViewController.dispose();
    bannerTagController.dispose();
    frequentlyBoughtController.dispose();
    recommendedController.dispose();
    bestSellerController.dispose();
    tagsController.dispose();
    quickProductListController.dispose();
    
    // Dispose all TextEditingController instances
    brandController.dispose();
    branddetailsSearchController.dispose();
    
    super.onClose();
  }
}
