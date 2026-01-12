// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../services/api_service.dart';
import 'base_controller.dart';

/// ================================================================
/// Optimized Brand Controller for Production
/// - Uses ApiService with retry logic
/// - Better error handling
/// - Improved caching
/// - Memory efficient
/// ================================================================
class BrandController extends BaseController {
  // Get ApiService instance
  final ApiService _apiService = Get.find<ApiService>();

  TextEditingController searchController = TextEditingController();
  RxInt page = 1.obs;
  RxBool isMuted = false.obs;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  ScrollController brandListController = ScrollController();
  RxString queryText = "".obs;
  RxBool isBrand = false.obs;

  /// ✅ Reactive list of brands
  RxList<Map<String, dynamic>> brandList = <Map<String, dynamic>>[].obs;

  RxString brandName = "".obs;
  RxString brandlogo = "".obs;
  RxString brandbackground = "".obs;
  RxInt brandId = 0.obs;
  RxString text = "Expand All".obs;
  RxBool showAllBrand = false.obs;
  RxBool isDetails = false.obs;
  var brandDetails = <String, dynamic>{}.obs;

  RxBool isCategory = false.obs;
  RxBool isProductBrand = false.obs;
  List categoryList = [].obs;
  List brand_category_List = [].obs;
  List brandProductDetailsList = [].obs;
  RxInt selectIndex = 0.obs;
  List<bool> selected = List.generate(50, (i) => false).obs;

  /// ✅ Map to store brand products by brandId for quick lookup
  RxMap<int, List<dynamic>> brandProductsMap = <int, List<dynamic>>{}.obs;

  // Debounce timer for search
  Timer? _searchDebounce;

  /// ================================================================
  /// ✅ Fetch Brands (Featured or All) - OPTIMIZED
  /// ================================================================
  Future<void> getBrandData(String type,
      [int? gender, bool showLoader = true]) async {
    if (showLoader) {
      isBrand.value = true;
    }

    try {
      final base = ApiConstants.baseUrl;
      final baseUri = Uri.parse(base);

      // Build query parameters
      final queryParams = <String, String>{
        'status': 'true', // Only active brands
      };

      if (type == "featured") {
        queryParams["isFeatured"] = "true";
      }

      if (gender != null) {
        queryParams["gender"] = gender.toString();
      }

      final uri = baseUri.replace(
        path: baseUri.path.endsWith('/')
            ? '${baseUri.path}brands'
            : '${baseUri.path}/brands',
      );

      // Use ApiService with retry logic and caching
      final response = await _apiService.get(
        uri.toString(),
        queryParams: queryParams,
        useCache: true, // Enable caching for brand list
        showErrorSnackbar: true,
      );

      // Check if request failed
      if (response == null || response.statusCode != 200) {
        return;
      }

      // Parse response
      final decoded = json.decode(response.body);
      final List<dynamic> allBrandsRaw =
          (decoded is Map && decoded['data'] is List)
              ? decoded['data'] as List
              : const [];

      // Filter by query text if user searched
      final q = queryText.value.trim().toLowerCase();
      final filtered = q.isEmpty
          ? allBrandsRaw
          : allBrandsRaw.where((b) {
              final name = (b is Map && b['name'] != null)
                  ? b['name'].toString().toLowerCase()
                  : '';
              return name.contains(q);
            }).toList();

      // Sort alphabetically by brand name
      filtered.sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });

      // Update brand list
      brandList.clear();
      brandList.addAll(
        filtered
            .whereType<Map<String, dynamic>>()
            .map((b) => b.map((k, v) => MapEntry(k.toString(), v)))
            .toList(),
      );

      // Update selection list length
      selected.clear();
      selected = List<bool>.generate(brandList.length, (_) => false);

      print(
          "✅ Brands loaded: ${brandList.length} (type: $type${gender != null ? ', gender: $gender' : ''})");
    } catch (e) {
      print("❌ Error fetching brand data: $e");
      showAppSnackBar("Something went wrong while fetching brands.");
    } finally {
      if (showLoader) {
        isBrand.value = false;
      }
    }
  }

  /// ================================================================
  /// ✅ Fetch Brand Details by ID - OPTIMIZED
  /// ================================================================
  Future<void> getBrandDetails(int id, String slug) async {
    isDetails.value = true;

    try {
      final url = "${ApiConstants.baseUrl}/view-brand/$id";
      print("➡️ Fetching brand details: $url");

      // Use ApiService with retry logic
      final response = await _apiService.get(
        url,
        useCache: true, // Cache brand details
        showErrorSnackbar: true,
      );

      // Check if request failed
      if (response == null || response.statusCode != 200) {
        return;
      }

      final decoded = json.decode(response.body);
      final data = decoded["data"] ?? {};

      brandDetails.value = data;

      // Extract categories
      final brandInfo = data["brandInfo"] ?? {};
      final List<dynamic> categories = brandInfo["categories"] ?? [];
      brand_category_List
        ..clear()
        ..addAll(
          categories
              .whereType<Map>()
              .map((item) => item["id"])
              .whereType<int>()
              .toList(),
        );

      // Extract products
      final List<dynamic> products = data["products"] ?? [];
      brandProductDetailsList
        ..clear()
        ..addAll(products.whereType<Map>());

      print(
          "✅ Brand details fetched: ${brand_category_List.length} categories, ${brandProductDetailsList.length} products.");
    } catch (e) {
      print("❌ Exception in getBrandDetails: $e");
      showAppSnackBar("Something went wrong while fetching brand details.");
    } finally {
      isDetails.value = false;
    }
  }

  /// ================================================================
  /// ✅ Fetch Brand Products - OPTIMIZED
  /// ================================================================
  Future<void> getBrandProducts(int brandId, {bool showLoader = true}) async {
    if (showLoader) {
      isProductBrand.value = true;
    }

    try {
      final url = "${ApiConstants.baseUrl}/brand-products/$brandId";
      print("➡️ Fetching brand products: $url");

      // Use ApiService with retry logic
      final response = await _apiService.get(
        url,
        useCache: true,
        showErrorSnackbar: false, // Don't show error for optional data
      );

      // Check if request failed
      if (response == null || response.statusCode != 200) {
        brandProductsMap[brandId] = [];
        return;
      }

      final decoded = json.decode(response.body);
      final List<dynamic> productsRaw =
          (decoded is Map && decoded['data'] is List)
              ? decoded['data'] as List
              : [];

      // Store products in the map
      brandProductsMap[brandId] = productsRaw.whereType<Map>().toList();

      print(
          "✅ Brand products loaded for brand $brandId: ${brandProductsMap[brandId]?.length ?? 0} products");
    } catch (e) {
      print("❌ Exception in getBrandProducts: $e");
      brandProductsMap[brandId] = [];
    } finally {
      if (showLoader) {
        isProductBrand.value = false;
      }
    }
  }

  /// ================================================================
  /// ✅ Search Brands with Debouncing - NEW
  /// ================================================================
  void searchBrands(String query) {
    // Cancel previous timer
    _searchDebounce?.cancel();

    // Update query text
    queryText.value = query;

    // Debounce search by 500ms
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      // Trigger brand data refresh
      getBrandData("all");
    });
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    queryText.value = "";
    getBrandData("all");
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    brandListController.dispose();
    super.onClose();
  }
}
