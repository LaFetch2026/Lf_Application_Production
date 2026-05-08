// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';

class BrandController extends BaseController {
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

  /// ✅ Newly Launched Brands state
  RxList<Map<String, dynamic>> newlyLaunchedBrands = <Map<String, dynamic>>[].obs;
  RxBool isLoadingNewlyLaunched = false.obs;
  RxInt newlyLaunchedPage = 1.obs;
  RxInt newlyLaunchedTotalPages = 1.obs;
  RxBool hasMoreNewlyLaunched = true.obs;

  RxString brandName = "".obs;
  RxString brandlogo = "".obs;
  RxString brandbackground = "".obs;
  RxInt brandId = 0.obs;
  RxString text = "Expand All".obs;
  RxBool showAllBrand = false.obs;
  RxBool isDetails = false.obs;
  var brandDetails = <String, dynamic>{}.obs;

  // Track currently loaded brand to prevent duplicate API calls
  RxInt currentLoadedBrandId = 0.obs;
  RxBool isFetchingBrandDetails = false.obs;

  RxBool isCategory = false.obs;
  RxBool isProductBrand = false.obs;
  List categoryList = [].obs;
  List brand_category_List = [].obs;
  List brandProductDetailsList = [].obs;
  RxInt selectIndex = 0.obs;
  List<bool> selected = List.generate(50, (i) => false).obs;

  /// ✅ Map to store brand products by brandId for quick lookup
  RxMap<int, List<dynamic>> brandProductsMap = <int, List<dynamic>>{}.obs;

  // ✅ Track which genders have already loaded brand data
  final Set<String> _loadedBrandKeys = {};

  /// Check if brand data for a type/gender is already loaded
  bool isBrandLoaded(String type, int? gender) =>
      _loadedBrandKeys.contains('${type}_${gender ?? 'all'}');

  /// Mark brand data as loaded
  void markBrandLoaded(String type, int? gender) =>
      _loadedBrandKeys.add('${type}_${gender ?? 'all'}');

  /// Clear loaded tracking
  void clearLoadedTracking() => _loadedBrandKeys.clear();

  /// ✅ Raw brands cache (full list before any filtering)
  final List<Map<String, dynamic>> _allBrandsCache = [];

  /// ✅ Pre-computed lowercase brand names for fast filtering
  final List<String> _brandNamesLower = [];

  /// ✅ Last applied filter query — skip if same
  String _lastFilterQuery = '\x00'; // sentinel value, never matches user input

  /// ✅ Filter brands locally from cache (no API call needed)
  void filterBrandsLocally(String query) {
    final q = query.trim().toLowerCase();

    // Skip if query hasn't changed
    if (q == _lastFilterQuery) return;
    _lastFilterQuery = q;

    final filtered = q.isEmpty
        ? _allBrandsCache
        : [
            for (int i = 0; i < _allBrandsCache.length; i++)
              if (_brandNamesLower[i].contains(q)) _allBrandsCache[i],
          ];

    brandList.assignAll(filtered);
    update(); // ensure GetBuilder refreshes
    print("🔍 Local filter: '$q' → ${brandList.length} brands");
  }

  /// ================================================================
  /// ✅ Fetch Brands (Featured or All)
  /// ================================================================
  Future<void> getBrandData(String type,
      [int? gender, bool showLoader = true]) async {
    // ✅ Skip if already loaded AND no search query (search always re-filters)
    if (isBrandLoaded(type, gender) && _allBrandsCache.isNotEmpty && queryText.value.trim().isEmpty) {
      print('✅ Brand data already loaded for type: $type, gender: $gender, skipping API call');
      return;
    }

    if (showLoader) {
      isBrand.value = true;
    }
    final prefs = await SharedPreferences.getInstance();

    try {
      final base = ApiConstants.baseUrl;
      final baseUri = Uri.parse(base);

      // ✅ UPDATED: Always include status=true, and optionally isFeatured=true and gender
      final queryParams = <String, String>{
        'status': 'true', // ✅ Always fetch only active brands
      };

      if (type == "featured") {
        queryParams["isFeatured"] = "true";
      }

      // ✅ Add gender parameter if provided
      if (gender != null) {
        queryParams["gender"] = gender.toString();
      }

      final uri = baseUri.replace(
        path: baseUri.path.endsWith('/')
            ? '${baseUri.path}brands'
            : '${baseUri.path}/brands',
        queryParameters: queryParams,
      );

      final headers = {
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
      };

      print("➡️ Brand API URL: $uri");
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print("⬅️ Status Code: ${response.statusCode}");

      // Handle expired session
      if (response.statusCode == 401) {
        showAppSnackBar("Session expired. Please log in again.",
            type: SnackBarType.error);
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (response.statusCode != 200) {
        String msg = "Failed to fetch brands (${response.statusCode}).";
        try {
          final err = json.decode(response.body);
          if (err is Map && err["message"] is String) {
            msg = err["message"];
          }
        } catch (_) {}
        showAppSnackBar(msg, type: SnackBarType.error);
        return;
      }

      // Ensure JSON
      final contentType =
          (response.headers['content-type'] ?? '').toLowerCase();
      if (!contentType.contains('application/json')) {
        showAppSnackBar("Unexpected response while fetching brands.",
            type: SnackBarType.error);
        return;
      }

      final decoded = json.decode(response.body);
      final List<dynamic> allBrandsRaw =
          (decoded is Map && decoded['data'] is List)
              ? decoded['data'] as List
              : const [];

      // ✅ Build the full sorted cache from API response
      final allBrandsMapped = allBrandsRaw
          .whereType<Map>()
          .map((b) => b.map((k, v) => MapEntry(k.toString(), v)))
          .toList();

      allBrandsMapped.sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });

      // ✅ Save full list to cache + pre-compute lowercase names
      _allBrandsCache.clear();
      _allBrandsCache.addAll(allBrandsMapped);
      _brandNamesLower
        ..clear()
        ..addAll(_allBrandsCache.map((b) => (b['name'] ?? '').toString().toLowerCase()));
      _lastFilterQuery = '\x00'; // reset so next filter always runs

      // ✅ Apply any active search filter
      final q = queryText.value.trim().toLowerCase();
      final filtered = q.isEmpty
          ? _allBrandsCache
          : _allBrandsCache.where((b) {
              final name = (b['name'] ?? '').toString().toLowerCase();
              return name.contains(q);
            }).toList();

      // ✅ CRITICAL: Clear old data first, then add new data
      brandList.clear();
      brandList.addAll(filtered);

      // Update selection list length
      selected.clear();
      selected = List<bool>.generate(brandList.length, (_) => false);

      // ✅ Mark as loaded after successful API call
      markBrandLoaded(type, gender);

      print(
          "✅ Brands loaded: ${brandList.length} (type: $type${gender != null ? ', gender: $gender' : ''})");
      print(
          "🪪 Brand names: ${brandList.map((b) => b['name']).take(5).toList()}${brandList.length > 5 ? '...' : ''}");

      // 🔍 DEBUG: Log first brand's logo URL
      if (brandList.isNotEmpty) {
        final firstBrand = brandList[0];
        print("🔍 First brand logo check:");
        print("   Brand: ${firstBrand['name']}");
        print("   Logo URL: ${firstBrand['logo']}");
        print("   Logo is null: ${firstBrand['logo'] == null}");
        print("   Logo is empty: ${firstBrand['logo']?.toString().isEmpty}");
      }
    } on TimeoutException {
      if (_allBrandsCache.isNotEmpty) {
        // Silently use cached data — don't disturb the user
        print("⚠️ Brand fetch timed out, using cached data.");
        brandList.assignAll(_allBrandsCache);
      } else {
        showAppSnackBar("Brands request timed out. Please try again.",
            type: SnackBarType.error);
      }
    } on SocketException {
      if (_allBrandsCache.isNotEmpty) {
        // Silently use cached data — no internet but we have data
        print("⚠️ No internet, using cached brand data.");
        brandList.assignAll(_allBrandsCache);
      } else {
        showAppSnackBar("No internet connection. Please check your network.",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("❌ Error fetching brand data: $e");
      if (_allBrandsCache.isEmpty) {
        showAppSnackBar("Something went wrong while fetching brands.",
            type: SnackBarType.error);
      }
    } finally {
      if (showLoader) {
        isBrand.value = false;
      }
    }
  }

  /// ================================================================
  /// ✅ Fetch Brand Details by ID
  /// ================================================================
  Future<void> getBrandDetails(int id, String slug) async {
    // ✅ Prevent duplicate API calls
    if (isFetchingBrandDetails.value) {
      print("⏳ Already fetching brand details, skipping...");
      return;
    }

    // ✅ Check if brand data is already loaded and valid
    if (currentLoadedBrandId.value == id &&
        brandDetails.isNotEmpty &&
        brandDetails["brandInfo"] != null &&
        (brandDetails["products"] as List?)?.isNotEmpty == true) {
      print("✅ Brand $id already loaded, using cached data");
      return;
    }

    isFetchingBrandDetails.value = true;
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final token = prefs.getString('token') ?? '';
      final url = "${ApiConstants.baseUrl}/view-brand/$id";
      print("➡️ Fetching brand details: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("⬅️ Status Code: ${response.statusCode}");

      if (response.statusCode == 401) {
        showAppSnackBar("Session expired. Please log in again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (response.statusCode != 200) {
        showAppSnackBar("Failed to fetch brand details.");
        return;
      }

      final decoded = json.decode(response.body);
      final data = decoded["data"] ?? {};

      brandDetails.value = data;
      currentLoadedBrandId.value = id; // ✅ Mark this brand as loaded

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

      // 🔍 DEBUG: Log first product to check image data
      if (products.isNotEmpty) {
        print("🔍 First product structure:");
        print("   Product: ${products[0]}");
        if (products[0] is Map) {
          final p = products[0] as Map;
          print("   Has 'imageUrls': ${p.containsKey('imageUrls')}");
          print("   Has 'images': ${p.containsKey('images')}");
          print("   imageUrls value: ${p['imageUrls']}");
          print("   images value: ${p['images']}");
        }
      }
    } catch (e) {
      print("❌ Exception in getBrandDetails: $e");
      showAppSnackBar("Something went wrong while fetching brand details.");
    } finally {
      isDetails.value = false;
      isFetchingBrandDetails.value = false;
    }
  }

  /// ================================================================
  /// ✅ Clear cached brand details (call when navigating away)
  /// ================================================================
  void clearCachedBrandDetails() {
    currentLoadedBrandId.value = 0;
    brandDetails.clear();
    brandProductDetailsList.clear();
    brand_category_List.clear();
    print("🗑️ Cleared cached brand details");
  }

  /// ================================================================
  /// ✅ Fetch Brand Products (random products for a brand)
  /// ================================================================
  Future<void> getBrandProducts(int brandId, {bool showLoader = true}) async {
    if (showLoader) {
      isProductBrand.value = true;
    }
    final prefs = await SharedPreferences.getInstance();

    try {
      final token = prefs.getString('token') ?? '';
      final url = "${ApiConstants.baseUrl}/brand-products/$brandId";
      print("➡️ Fetching brand products: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      print("⬅️ Status Code: ${response.statusCode}");

      if (response.statusCode == 401) {
        showAppSnackBar("Session expired. Please log in again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (response.statusCode != 200) {
        String msg = "Failed to fetch brand products (${response.statusCode}).";
        try {
          final err = json.decode(response.body);
          if (err is Map && err["message"] is String) {
            msg = err["message"];
          }
        } catch (_) {}
        print("⚠️ $msg");
        // Don't show snackbar, just return empty list
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
    } on TimeoutException {
      print("⚠️ Brand products request timed out.");
      brandProductsMap[brandId] = [];
    } on SocketException {
      print("⚠️ No internet connection.");
      brandProductsMap[brandId] = [];
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
  /// ✅ Fetch Newly Launched Brands (with pagination)
  /// ================================================================
  Future<void> getNewlyLaunchedBrands(
      {int page = 1, int limit = 20, int? gender, bool showLoader = true}) async {
    if (showLoader) {
      isLoadingNewlyLaunched.value = true;
    }

    final prefs = await SharedPreferences.getInstance();

    try {
      final base = ApiConstants.baseUrl;
      final baseUri = Uri.parse(base);

      // ✅ Build query parameters: sort=new for newly launched, with pagination
      final queryParams = <String, String>{
        'status': 'true', // Only active brands
        'sort': 'new', // Sort by newly launched
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // ✅ Add gender parameter if provided
      if (gender != null) {
        queryParams["gender"] = gender.toString();
      }

      final uri = baseUri.replace(
        path: baseUri.path.endsWith('/')
            ? '${baseUri.path}brands'
            : '${baseUri.path}/brands',
        queryParameters: queryParams,
      );

      final headers = {
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
      };

      print("➡️ Newly Launched Brands API URL: $uri");
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print("⬅️ Status Code: ${response.statusCode}");

      // Handle expired session
      if (response.statusCode == 401) {
        showAppSnackBar("Session expired. Please log in again.",
            type: SnackBarType.error);
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (response.statusCode != 200) {
        String msg =
            "Failed to fetch newly launched brands (${response.statusCode}).";
        try {
          final err = json.decode(response.body);
          if (err is Map && err["message"] is String) {
            msg = err["message"];
          }
        } catch (_) {}
        print("⚠️ $msg");
        return;
      }

      // Ensure JSON
      final contentType =
          (response.headers['content-type'] ?? '').toLowerCase();
      if (!contentType.contains('application/json')) {
        print("⚠️ Unexpected response format for newly launched brands.");
        return;
      }

      final decoded = json.decode(response.body);
      final List<dynamic> brandsRaw =
          (decoded is Map && decoded['data'] is List)
              ? decoded['data'] as List
              : const [];

      // ✅ Map and validate brands
      final brandsMapped = brandsRaw
          .whereType<Map>()
          .map((b) => b.map((k, v) => MapEntry(k.toString(), v)))
          .toList();

      // ✅ If sort=new returned empty, retry without sort to get all brands
      if (brandsMapped.isEmpty && queryParams.containsKey('sort')) {
        print("⚠️ sort=new returned empty — retrying without sort param");
        final fallbackParams = Map<String, String>.from(queryParams)
          ..remove('sort');
        final fallbackUri = baseUri.replace(
          path: baseUri.path.endsWith('/')
              ? '${baseUri.path}brands'
              : '${baseUri.path}/brands',
          queryParameters: fallbackParams,
        );
        final fallbackResponse = await http
            .get(fallbackUri, headers: headers)
            .timeout(const Duration(seconds: 20));
        if (fallbackResponse.statusCode == 200) {
          final fallbackDecoded = json.decode(fallbackResponse.body);
          final List<dynamic> fallbackRaw =
              (fallbackDecoded is Map && fallbackDecoded['data'] is List)
                  ? fallbackDecoded['data'] as List
                  : const [];
          final fallbackMapped = fallbackRaw
              .whereType<Map>()
              .map((b) => b.map((k, v) => MapEntry(k.toString(), v)))
              .toList();
          if (fallbackMapped.isNotEmpty) {
            if (page == 1) {
              newlyLaunchedBrands.clear();
              newlyLaunchedBrands.addAll(fallbackMapped);
            } else {
              newlyLaunchedBrands.addAll(fallbackMapped);
            }
            newlyLaunchedPage.value = page;
            hasMoreNewlyLaunched.value = false;
            print("✅ Fallback: loaded ${fallbackMapped.length} brands");
            return;
          }
        }
      }

      // ✅ Extract pagination info from response
      final paginationData = decoded is Map ? decoded['pagination'] : null;
      if (paginationData is Map) {
        newlyLaunchedTotalPages.value =
            ((paginationData['totalPages'] ?? 1) as num).toInt();
        hasMoreNewlyLaunched.value =
            ((paginationData['hasNextPage'] ?? false) as bool);
      } else {
        // Fallback: assume pagination based on returned items
        newlyLaunchedTotalPages.value =
            (brandsMapped.length >= limit) ? page + 1 : page;
        hasMoreNewlyLaunched.value = brandsMapped.length >= limit;
      }

      // ✅ Update state
      if (page == 1) {
        // First page: replace all data
        newlyLaunchedBrands.clear();
        newlyLaunchedBrands.addAll(brandsMapped);
      } else {
        // Subsequent pages: append data
        newlyLaunchedBrands.addAll(brandsMapped);
      }

      newlyLaunchedPage.value = page;

      print(
          "✅ Newly launched brands loaded: ${brandsMapped.length} brands (page $page of ${newlyLaunchedTotalPages.value})");
      print(
          "🪪 Brand names: ${brandsMapped.map((b) => b['name']).take(5).toList()}${brandsMapped.length > 5 ? '...' : ''}");
    } on TimeoutException {
      print("⚠️ Newly launched brands fetch timed out.");
      showAppSnackBar("Request timed out. Please try again.",
          type: SnackBarType.error);
    } on SocketException {
      print("⚠️ No internet connection.");
      showAppSnackBar("No internet connection. Please check your network.",
          type: SnackBarType.error);
    } catch (e) {
      print("❌ Error fetching newly launched brands: $e");
      showAppSnackBar("Something went wrong while fetching brands.",
          type: SnackBarType.error);
    } finally {
      if (showLoader) {
        isLoadingNewlyLaunched.value = false;
      }
    }
  }

  /// ================================================================
  /// ✅ Navigate to next page of newly launched brands
  /// ================================================================
  Future<void> nextNewlyLaunchedPage() async {
    if (newlyLaunchedPage.value < newlyLaunchedTotalPages.value) {
      await getNewlyLaunchedBrands(
        page: newlyLaunchedPage.value + 1,
        showLoader: false,
      );
    }
  }

  /// ================================================================
  /// ✅ Navigate to previous page of newly launched brands
  /// ================================================================
  Future<void> prevNewlyLaunchedPage() async {
    if (newlyLaunchedPage.value > 1) {
      await getNewlyLaunchedBrands(
        page: newlyLaunchedPage.value - 1,
        showLoader: false,
      );
    }
  }

  /// ================================================================
  /// ✅ Dispose controllers when BrandController is closed
  /// ================================================================
  @override
  void onClose() {
    searchController.dispose();
    brandListController.dispose();
    super.onClose();
  }
}
