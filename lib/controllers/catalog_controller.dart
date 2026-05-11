// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../models/filter_chip_item.dart';
import '../screens/loginscreen.dart';
import '../screens/home/women/homescreen.dart';
import '../services/cache_manager.dart';
import 'base_controller.dart';
import 'product_controller.dart';

class CatalogController extends BaseController {
  RxBool isCatalog = false.obs;
  RxBool isCatalogCategory = false.obs;
  RxBool isCategory = false.obs;
  RxBool isSorting = false.obs;

  RxString categoryName = "Men".obs;
  RxInt selectCategoryGender = 0.obs;

  /// Lists
  /// [catalogList] is used by the Category screen — holds the currently-selected
  /// gender's categories and is replaced when the user switches tabs there.
  RxList<dynamic> catalogList = <dynamic>[].obs;

  /// [catalogByGender] is used by the Home screen's "Shop by Category" section.
  /// Keyed by gender ID so switching tabs in the Category screen never
  /// overwrites another gender's data shown on the Home screen.
  final RxMap<int, List<dynamic>> catalogByGender = <int, List<dynamic>>{}.obs;

  RxList<dynamic> catagoryList = <dynamic>[].obs;
  RxList<dynamic> categoryProductList = <dynamic>[].obs;
  RxList<dynamic> sortedProductList = <dynamic>[].obs;

  // ── Filter Chips ──────────────────────────────────────────────────────────
  /// Chips returned by the last fresh /filter-products call (page = 1).
  /// Cleared and replaced on every fresh query; never updated on load-more.
  RxList<FilterChipItem> chips = <FilterChipItem>[].obs;

  /// The set of IDs of currently selected chips (set by [onChipTap]).
  final RxSet<int> selectedChipIds = <int>{}.obs;

  /// Cache of selected chip objects so they can be shown as pills even after
  /// the server stops returning them in the chip list.
  final Map<int, FilterChipItem> _selectedChipObjects = {};

  /// The last chip list returned by the server (page = 1).
  /// Used to restore server order when the active chip is deselected.
  // ignore: unused_field
  List<FilterChipItem> _lastServerChips = [];

  /// Reactive list of currently selected chip objects (shown as pills).
  final RxList<FilterChipItem> selectedChips = <FilterChipItem>[].obs;

  void _syncSelectedChips() {
    selectedChips.assignAll(
      selectedChipIds
          .map((id) => _selectedChipObjects[id])
          .whereType<FilterChipItem>()
          .toList(),
    );
    print(
        '🔹 _syncSelectedChips: selectedChips=${selectedChips.map((c) => c.label).toList()}');
  }

  /// Clears all chip selections. Call this when the screen is disposed.
  void clearChipSelection() {
    selectedChipIds.clear();
    _selectedChipObjects.clear();
    selectedChips.clear();
  }

  // Stored filter state so [onChipTap] can re-issue the query while
  // preserving all active filters the user has selected.
  // ignore: unused_field
  List<int>? _lastBrandIds;
  // ignore: unused_field
  List<String>? _lastColors;
  // ignore: unused_field
  List<String>? _lastSizes;
  // ignore: unused_field
  String? _lastMinPrice;
  // ignore: unused_field
  String? _lastMaxPrice;
  // ignore: unused_field
  String? _lastMinDiscount;
  // ignore: unused_field
  String? _lastMaxDiscount;
  // ignore: unused_field
  String? _lastSortOption;
  // ignore: unused_field
  int? _lastSuperCatId;
  // ignore: unused_field
  int? _lastCatId;
  // ignore: unused_field
  int? _lastSubCatId;
  // ignore: unused_field
  int? _lastBrandId;
  // ignore: unused_field
  int? _lastCollectionId;
  // ignore: unused_field
  int? _lastContextualCategoryId;
  // ignore: unused_field
  String? _lastKey;
  int _lastLimit = 20;

  // ── Pagination ────────────────────────────────────────────────────────────
  /// Total pages from the last /filter-products response
  RxInt totalPages = 1.obs;

  /// Total product count from the last /filter-products response
  RxInt totalProductCount = 0.obs;

  /// Current page being displayed (for pagination UI)
  RxInt currentDisplayedPage = 1.obs;

  // ✅ Track which genders have already loaded catalog data
  final Set<int> _loadedCatalogGenders = {};

  /// Check if catalog for a gender is already loaded
  bool isCatalogLoaded(int gender) => _loadedCatalogGenders.contains(gender);

  /// Mark catalog for gender as loaded
  void markCatalogLoaded(int gender) => _loadedCatalogGenders.add(gender);

  /// Clear loaded tracking
  void clearLoadedTracking() {
    _loadedCatalogGenders.clear();
    catalogByGender.clear();
  }

  /// Fetch catalog by gender
  Future<void> getCatalogData(int gender, {bool forceRefresh = false}) async {
    // ✅ Skip if already loaded for this specific gender (unless force refresh)
    if (!forceRefresh &&
        isCatalogLoaded(gender) &&
        (catalogByGender[gender]?.isNotEmpty ?? false)) {
      print('✅ Catalog already loaded for gender: $gender, skipping API call');
      // Sync catalogList so the Category screen tab also shows correct data
      catalogList.assignAll(catalogByGender[gender]!);
      return;
    }

    final cacheKey = 'catalog_$gender';

    // Try to load from cache first
    if (!forceRefresh) {
      final cached = await CacheManager.get(key: cacheKey);
      if (cached != null && cached is List) {
        catalogList.clear();
        catalogList.assignAll(cached);
        catalogByGender[gender] = List<dynamic>.from(cached);
        markCatalogLoaded(gender); // ✅ Mark as loaded
        update();
        print(
            "✅ Catalog loaded from cache for gender: $gender (${catalogList.length} items)");
        isCatalog.value =
            false; // ✅ Reset loading state when returning from cache
        return;
      }
    }

    isCatalog.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        "${ApiConstants.baseUrl}/categories?type=category&status=true&gender=$gender",
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': "Bearer $token",
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData["data"] != null && responseData["data"] is List) {
          final data = responseData["data"] as List;

          // ✅ Cache the data
          await CacheManager.save(key: cacheKey, data: data);

          // ✅ CRITICAL: Clear old data first, then assign new data
          catalogList.clear();
          catalogList.assignAll(data);

          // ✅ Also store per-gender so Home screen is unaffected by tab switches
          catalogByGender[gender] = List<dynamic>.from(data);

          // ✅ Mark as loaded after successful API call
          markCatalogLoaded(gender);

          // ✅ Force UI update
          update();

          print(
              "✅ Shop by Category loaded: ${catalogList.length} items for gender: $gender");
        } else {
          catalogList.clear();
          getSnackBar("No categories available");
        }
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        HomeScreenState.clearCache(); // ✅ Clear cache on session expiration
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Session expired, please login again");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(responseData["message"] ?? "Failed to fetch categories");
      }
    } on SocketException {
      getSnackBar("No internet connection");
    } on TimeoutException {
      getSnackBar("Request timeout, please try again");
    } on FormatException {
      getSnackBar("Invalid response format");
    } catch (e) {
      print("getCatalogData error: $e");
      getSnackBar("Something went wrong, please try again");
    } finally {
      isCatalog.value = false;
    }
  }

  /// Fetch catalog categories
  Future<void> getCatagoryData(int type) async {
    isCatalogCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse(
          "${ApiConstants.baseUrl}/categories?type=category&status=true&gender=$type");
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );

      print(
          "📥 Catalogs Response [${response.statusCode}]: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print("❌ Catalogs API returned HTML instead of JSON");
        getSnackBar("Server returned invalid response");
        return;
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["data"] != null) {
        // ✅ CRITICAL FIX: Clear old data first, then assign new data
        catagoryList.clear();
        catagoryList.assignAll(responseData["data"]);

        // ✅ Force UI update
        update();

        print("✅ Categories loaded: ${catagoryList.length} items");
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar("Failed to fetch catalog categories");
      }
    } catch (e) {
      print("getCatagoryData error: $e");
    } finally {
      isCatalogCategory.value = false;
    }
  }

  Future<void> getCategoryProductData(int categoryId, int type) async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/products")
          .replace(queryParameters: {
        "catId": categoryId.toString(),
        "status": "true",
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        final data = decoded["data"];

        final List rawProducts = data["products"] ?? [];

        /// -----------------------------
        /// Transform Products
        /// -----------------------------
        final transformed = rawProducts.map<Map<String, dynamic>>((p) {
          if (p is! Map<String, dynamic>) return p;
          return ProductController.calculateDisplayPrices(p);
        }).toList();

        categoryProductList.assignAll(transformed);
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar("Failed to load products");
      }
    } catch (e) {
      print("getCategoryProductData error: $e");
    } finally {
      isCategory.value = false;
    }
  }

  /// Fetch products by sub-category ID using /sub-category-products API
  Future<void> getSubCategoryProducts(int catId) async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse(
          "${ApiConstants.baseUrl}/sub-category-products?catId=$catId");

      print("🔹 Sub-Category Products API → $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')}",
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("Request timeout");
        },
      );

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print("❌ Sub-Category Products API returned HTML instead of JSON");
        getSnackBar("Server returned invalid response");
        return;
      }

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        final data = decoded["data"];
        List<dynamic> rawProducts = [];

        print("🔍 Data type: ${data.runtimeType}");

        // Handle response structure: data.children[].products
        if (data is Map<String, dynamic>) {
          final childrenRaw = data["children"];
          print(
              "🔍 Children type: ${childrenRaw.runtimeType}, value: ${childrenRaw != null ? 'exists' : 'null'}");

          if (childrenRaw is List) {
            for (int i = 0; i < childrenRaw.length; i++) {
              final child = childrenRaw[i];
              print("🔍 Child $i type: ${child.runtimeType}");

              if (child is Map<String, dynamic>) {
                final productsRaw = child["products"];
                print(
                    "🔍 Child $i products type: ${productsRaw?.runtimeType}, count: ${productsRaw is List ? productsRaw.length : 'not a list'}");

                if (productsRaw is List) {
                  rawProducts.addAll(productsRaw);
                  print(
                      "✅ Added ${productsRaw.length} products from child $i (${child['name']})");
                }
              }
            }
          }

          // Also check for direct products array (fallback)
          if (rawProducts.isEmpty && data["products"] is List) {
            rawProducts = data["products"] as List;
            print("🔍 Using direct products array: ${rawProducts.length}");
          }
        } else if (data is List) {
          rawProducts = data;
          print("🔍 Data is direct list: ${rawProducts.length}");
        }

        print("🔍 Total raw products collected: ${rawProducts.length}");

        /// Transform Products
        final transformed = rawProducts
            .map<Map<String, dynamic>>((p) {
              if (p is! Map<String, dynamic>) {
                print(
                    "⚠️ Product is not Map<String, dynamic>: ${p.runtimeType}");
                return <String, dynamic>{};
              }
              return ProductController.calculateDisplayPrices(p);
            })
            .where((p) => p.isNotEmpty)
            .toList();

        categoryProductList.assignAll(transformed);
        print(
            "✅ Sub-Category Products loaded: ${transformed.length} items for catId: $catId");
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        HomeScreenState.clearCache();
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Session expired, please login again");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        print(
            "❌ Sub-Category Products API ${response.statusCode}: ${decoded["message"]}");
        getSnackBar(decoded["message"] ?? "Failed to load products");
      }
    } on SocketException {
      getSnackBar("No internet connection");
    } on TimeoutException {
      getSnackBar("Request timeout, please try again");
    } catch (e) {
      print("getSubCategoryProducts error: $e");
      getSnackBar("Something went wrong, please try again");
    } finally {
      isCategory.value = false;
    }
  }

  /// Add/remove product from wishlist
  Future<void> callAddProductToWishlist(int wishlistId, int id) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse(
          "${ApiConstants.baseUrl}/products/$id/wishlist/$wishlistId");

      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData["wishlisted"] == true) {
          Get.close(1);
        }
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar("Item add failed");
      }
    } catch (e) {
      print("callAddProductToWishlist error: $e");
    }
  }

  Future<void> getFilterAndSortProducts({
    List<int>? brandIds,
    List<String>? colors,
    List<String>? sizes,
    String? minPrice,
    String? maxPrice,
    String? minDiscount,
    String? maxDiscount,
    String? sortOption,
    int? superCatId,
    int? catId,
    int? subCatId,
    int? brandId,
    int? collectionId,
    int? contextualCategoryId,
    String? key,
    int page = 1,
    int limit = 20,
    bool appendResults = false,
  }) async {
    isSorting.value = true;
    isCategory.value = true;

    // ── Persist filter state for onChipTap re-use ──────────────────────────
    if (page == 1) {
      _lastBrandIds = brandIds;
      _lastColors = colors;
      _lastSizes = sizes;
      _lastMinPrice = minPrice;
      _lastMaxPrice = maxPrice;
      _lastMinDiscount = minDiscount;
      _lastMaxDiscount = maxDiscount;
      _lastSortOption = sortOption;
      _lastSuperCatId = superCatId;
      _lastCatId = catId;
      _lastSubCatId = subCatId;
      _lastBrandId = brandId;
      _lastCollectionId = collectionId;
      _lastContextualCategoryId = contextualCategoryId;
      _lastKey = key;
      _lastLimit = limit;
    }

    final prefs = await SharedPreferences.getInstance();

    try {
      final Map<String, String> queryParams = {};

      /// ---------------- FILTERS ----------------

      if (brandIds != null && brandIds.isNotEmpty) {
        queryParams['brandIds'] = brandIds.join(',');
      }

      if (colors != null && colors.isNotEmpty) {
        queryParams['colors'] = colors.join(',');
      }

      if (sizes != null && sizes.isNotEmpty) {
        queryParams['sizes'] = sizes.join(',');
      }

      if (minPrice != null && minPrice.isNotEmpty) {
        queryParams['minPrice'] = minPrice;
      }

      if (maxPrice != null && maxPrice.isNotEmpty) {
        queryParams['maxPrice'] = maxPrice;
      }

      // Add discount params with defensive guard for invalid ranges
      if (minDiscount != null &&
          minDiscount.isNotEmpty &&
          maxDiscount != null &&
          maxDiscount.isNotEmpty) {
        final minDiscountInt = int.tryParse(minDiscount);
        final maxDiscountInt = int.tryParse(maxDiscount);

        // Only include if valid and minDiscount <= maxDiscount
        if (minDiscountInt != null &&
            maxDiscountInt != null &&
            minDiscountInt <= maxDiscountInt) {
          queryParams['minDiscount'] = minDiscount;
          queryParams['maxDiscount'] = maxDiscount;
        }
      } else {
        // Include individual params if only one is provided
        if (minDiscount != null && minDiscount.isNotEmpty) {
          queryParams['minDiscount'] = minDiscount;
        }
        if (maxDiscount != null && maxDiscount.isNotEmpty) {
          queryParams['maxDiscount'] = maxDiscount;
        }
      }

      if (key != null && key.isNotEmpty) {
        queryParams['key'] = key;
      }

      /// ---------------- SORT ----------------

      if (sortOption != null &&
          sortOption.isNotEmpty &&
          sortOption != 'recommended') {
        queryParams['sort'] = sortOption;
      }

      /// ---------------- CATEGORY ----------------

      if (superCatId != null && superCatId > 0) {
        queryParams['superCatId'] = superCatId.toString();
      }

      if (catId != null && catId > 0) {
        queryParams['catId'] = catId.toString();
      }

      if (subCatId != null && subCatId > 0) {
        queryParams['subCatId'] = subCatId.toString();
      }

      if (brandId != null && brandId > 0) {
        queryParams['brandId'] = brandId.toString();
      }

      if (collectionId != null && collectionId > 0) {
        queryParams['collectionId'] = collectionId.toString();
      }

      if (contextualCategoryId != null && contextualCategoryId > 0) {
        queryParams['contextualCategoryId'] = contextualCategoryId.toString();
      }

      /// ---------------- REQUIRED BY API ----------------

      queryParams['status'] = 'true';

      /// ---------------- PAGINATION ----------------

      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/filter-products",
      ).replace(queryParameters: queryParams);

      print("🔹 Filter API → $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("Request timeout");
        },
      );

      /// ---------------- RESPONSE ----------------

      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        // Silent fail - screen will use fallback data from brandDetails
        print("❌ Server returned HTML instead of JSON");
        return;
      }

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        final data = decoded["data"];
        List<dynamic> products = [];

        if (data is List) {
          products = List<dynamic>.from(data);
        } else if (data is Map && data["products"] != null) {
          products = List<dynamic>.from(data["products"]);
        } else {
          // Empty or unexpected format - just return empty list silently
          print("⚠️ Unexpected data format, returning empty list");
          return;
        }

        final transformed = products.map<Map<String, dynamic>>((p) {
          if (p is! Map<String, dynamic>) return {};
          return ProductController.calculateDisplayPrices(p);
        }).toList();

        if (appendResults && page > 1) {
          categoryProductList.addAll(transformed);
          sortedProductList.addAll(transformed);
        } else {
          categoryProductList.assignAll(transformed);
          sortedProductList.assignAll(transformed);
        }

        // ── Parse chips (fresh queries only) ──────────────────────────────
        if (page == 1 && data is Map) {
          final rawChips = (data['chips'] as List?) ?? [];
          final parsedChips = rawChips
              .whereType<Map<String, dynamic>>()
              .map((c) => FilterChipItem.fromJson(c))
              .toList();
          _lastServerChips = parsedChips;
          chips.assignAll(parsedChips);
        }

        // ── Parse pagination data ────────────────────────────────────────
        if (data is Map) {
          final pagination = data['pagination'] as Map<String, dynamic>?;
          if (pagination != null) {
            totalPages.value = pagination['totalPages'] ?? 1;
            totalProductCount.value = pagination['totalCount'] ?? 0;
            currentDisplayedPage.value = pagination['currentPage'] ?? page;
            print(
                "📄 Pagination: page ${currentDisplayedPage.value} of ${totalPages.value}, total: ${totalProductCount.value}");
          }
        }

        print("✅ Products loaded: ${transformed.length}");
      }

      /// ---------------- AUTH ----------------
      else if (response.statusCode == 401) {
        await prefs.remove('token');
        HomeScreenState.clearCache();
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Session expired");
      } else {
        // Don't show snackbar for filter/sort failures - just log and show empty state
        print("❌ API ${response.statusCode}: ${decoded["message"]}");
      }
    } on SocketException {
      print("❌ No internet connection");
    } on TimeoutException {
      print("❌ Request timeout");
    } catch (e) {
      print("🚨 Filter error: $e");
    } finally {
      isSorting.value = false;
      isCategory.value = false;
    }
  }

  /// Fetches chips for a category/subcategory page without replacing the
  /// existing product list. Call this after the initial product load so chips
  /// appear even when products were loaded via a non-filter-products endpoint.
  Future<void> fetchChipsForCategory({
    int? catId,
    int? subCatId,
    int? superCatId,
    int? collectionId,
    int? brandId,
    String? segment,
  }) async {
    print(
        '🔹 fetchChipsForCategory called with: catId=$catId, subCatId=$subCatId, superCatId=$superCatId, collectionId=$collectionId, segment=$segment');
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> params = {
        'status': 'true',
        'page': '1',
        'limit': '8', // Backend needs limit >= 8 to return chips
      };

      if (superCatId != null && superCatId > 0) {
        params['superCatId'] = superCatId.toString();
      }
      if (catId != null && catId > 0) {
        params['catId'] = catId.toString();
      }
      if (subCatId != null && subCatId > 0) {
        params['subCatId'] = subCatId.toString();
      }
      if (collectionId != null && collectionId > 0) {
        params['collectionId'] = collectionId.toString();
      }
      if (brandId != null && brandId > 0) {
        params['brandId'] = brandId.toString();
      }
      if (segment != null && segment.isNotEmpty) {
        params['segment'] = segment;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/filter-products')
          .replace(queryParameters: params);

      print('🔹 Chips fetch → $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔹 Chips response: ${response.statusCode}');
      print(
          '🔹 Chips body (first 500): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data is Map) {
          final rawChips = (data['chips'] as List?) ?? [];
          print('🔹 Raw chips: ${rawChips.length}');
          final parsed = rawChips
              .whereType<Map<String, dynamic>>()
              .map((c) => FilterChipItem.fromJson(c))
              .toList();
          _lastServerChips = parsed;
          chips.assignAll(parsed);
          print('✅ Chips loaded: ${parsed.length}');
          print(
              '✅ chips.value is now: ${chips.value.map((c) => c.label).toList()}');
        } else {
          print('⚠️ data is not a Map: ${data.runtimeType}');
        }
      } else {
        print('⚠️ Chips fetch ${response.statusCode} — skipping');
      }
    } catch (e) {
      print('⚠️ fetchChipsForCategory error: $e');
      // Non-fatal — chips row just stays empty
    }
  }

  /// Called when the user taps a chip on a category/subcategory listing page.
  ///
  /// Sets the relevant category ID (subCatId or contextualCategoryId) and
  /// clears the other, then re-issues the product query while preserving all
  /// other active filter parameters.
  void onChipTap(FilterChipItem chip) {
    if (selectedChipIds.contains(chip.id)) {
      // Deselect
      selectedChipIds.remove(chip.id);
      _selectedChipObjects.remove(chip.id);
      _syncSelectedChips();

      // Re-fetch with no subCat/contextual filter (or remaining selection)
      int? newSubCatId;
      int? newContextualCategoryId;
      if (selectedChipIds.isNotEmpty) {
        final remaining = _selectedChipObjects[selectedChipIds.last];
        if (remaining != null) {
          if (remaining.type == ChipType.category) {
            newSubCatId = remaining.id;
          } else {
            newContextualCategoryId = remaining.id;
          }
        }
      }

      getFilterAndSortProducts(
        brandIds: _lastBrandIds,
        colors: _lastColors,
        sizes: _lastSizes,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        minDiscount: _lastMinDiscount,
        maxDiscount: _lastMaxDiscount,
        sortOption: _lastSortOption,
        superCatId: _lastSuperCatId,
        catId: _lastCatId,
        subCatId: newSubCatId,
        brandId: _lastBrandId,
        collectionId: _lastCollectionId,
        contextualCategoryId: newContextualCategoryId,
        key: _lastKey,
        page: 1,
        limit: _lastLimit,
        appendResults: false,
      );
      return;
    }

    // Select
    selectedChipIds.add(chip.id);
    _selectedChipObjects[chip.id] = chip;
    _syncSelectedChips();

    int? newSubCatId;
    int? newContextualCategoryId;
    if (chip.type == ChipType.category) {
      newSubCatId = chip.id;
    } else {
      newContextualCategoryId = chip.id;
    }

    getFilterAndSortProducts(
      brandIds: _lastBrandIds,
      colors: _lastColors,
      sizes: _lastSizes,
      minPrice: _lastMinPrice,
      maxPrice: _lastMaxPrice,
      minDiscount: _lastMinDiscount,
      maxDiscount: _lastMaxDiscount,
      sortOption: _lastSortOption,
      superCatId: _lastSuperCatId,
      catId: _lastCatId,
      subCatId: newSubCatId,
      brandId: _lastBrandId,
      collectionId: _lastCollectionId,
      contextualCategoryId: newContextualCategoryId,
      key: _lastKey,
      page: 1,
      limit: _lastLimit,
      appendResults: false,
    );
  }

  /// Sets the stored filter parameters directly.
  ///
  /// This method exists solely to support unit tests that need to pre-populate
  /// the `_last*` fields without making a real HTTP call.
  @visibleForTesting
  void setLastParamsForTest({
    List<int>? brandIds,
    List<String>? colors,
    List<String>? sizes,
    String? minPrice,
    String? maxPrice,
    String? minDiscount,
    String? maxDiscount,
    String? sortOption,
    int? superCatId,
    int? catId,
    int? subCatId,
    int? brandId,
    int? collectionId,
    int? contextualCategoryId,
    String? key,
    int limit = 20,
  }) {
    _lastBrandIds = brandIds;
    _lastColors = colors;
    _lastSizes = sizes;
    _lastMinPrice = minPrice;
    _lastMaxPrice = maxPrice;
    _lastMinDiscount = minDiscount;
    _lastMaxDiscount = maxDiscount;
    _lastSortOption = sortOption;
    _lastSuperCatId = superCatId;
    _lastCatId = catId;
    _lastSubCatId = subCatId;
    _lastBrandId = brandId;
    _lastCollectionId = collectionId;
    _lastContextualCategoryId = contextualCategoryId;
    _lastKey = key;
    _lastLimit = limit;
  }
}
