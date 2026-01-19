// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
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
  RxInt selectCategoryGender = 2.obs;

  /// Lists
  RxList<dynamic> catalogList = <dynamic>[].obs;
  RxList<dynamic> catagoryList = <dynamic>[].obs;
  RxList<dynamic> categoryProductList = <dynamic>[].obs;
  RxList<dynamic> sortedProductList = <dynamic>[].obs;

  /// Fetch catalog by gender
  Future<void> getCatalogData(int gender, {bool forceRefresh = false}) async {
    final cacheKey = 'catalog_$gender';

    // Try to load from cache first
    if (!forceRefresh) {
      final cached = await CacheManager.get(key: cacheKey);
      if (cached != null && cached is List) {
        catalogList.clear();
        catalogList.assignAll(cached);
        update();
        print(
            "✅ Catalog loaded from cache for gender: $gender (${catalogList.length} items)");
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
    String? sortOption,
    int? superCatId,
    int? catId,
    int? subCatId,
    int? brandId,
    int? collectionId,
    String? key,
    int page = 1, // ✅ Page number for pagination
    int limit = 20, // ✅ Items per page
    bool appendResults =
        false, // ✅ If true, append to existing list instead of replacing
  }) async {
    isSorting.value = true;
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      // Build query parameters
      final Map<String, String> queryParams = {};

      // Add filter parameters
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
      if (key != null && key.isNotEmpty) {
        queryParams['key'] = key;
      }

      // Add sort parameter (skip if "recommended")
      if (sortOption != null &&
          sortOption.isNotEmpty &&
          sortOption != 'recommended') {
        queryParams['sort'] = sortOption;
      }

      // Add category filters
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

      // ✅ Add pagination parameters
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse("${ApiConstants.baseUrl}/filter-products").replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print("🔹 Filter & Sort Request → $uri (Page: $page, Limit: $limit)");

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      // Validate response is JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print("❌ Filter API returned HTML instead of JSON");
        getSnackBar("Server error: Invalid response format");
        return;
      }

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        // ✅ FIX: Extract products from nested structure
        final data = decoded["data"];
        List<dynamic> products = [];

        // Handle both response formats: {"data": [...]} or {"data": {"products": [...]}}
        if (data is List) {
          products = List<dynamic>.from(data);
        } else if (data is Map && data["products"] != null) {
          products = List<dynamic>.from(data["products"]);
        } else {
          print("❌ Unexpected response format: $data");
          getSnackBar("Invalid response format");
          return;
        }

        print("✅ Received ${products.length} products from API");

        // ✅ Transform products to add displayPrice and displayMrp
        final transformed = products.map<Map<String, dynamic>>((p) {
          if (p is! Map<String, dynamic>) return p;
          return ProductController.calculateDisplayPrices(p);
        }).toList();

        // ✅ Update lists - append if pagination, replace otherwise
        if (appendResults && page > 1) {
          categoryProductList.addAll(transformed);
          sortedProductList.addAll(transformed);
          print(
              "✅ Appended ${transformed.length} products (Total: ${categoryProductList.length})");
        } else {
          categoryProductList.assignAll(transformed);
          sortedProductList.assignAll(transformed);
          print("✅ Loaded ${categoryProductList.length} products");
        }
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        HomeScreenState.clearCache();
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Session expired, please login again");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(decoded["message"] ?? "Failed to fetch products");
        print("❌ API Error [${response.statusCode}]: ${decoded["message"]}");
      }
    } on SocketException {
      getSnackBar("No internet connection");
    } on TimeoutException {
      getSnackBar("Request timeout, please try again");
    } on FormatException {
      getSnackBar("Invalid response format");
    } catch (e) {
      print("🚨 getFilterAndSortProducts error: $e");
      getSnackBar("Something went wrong, please try again");
    } finally {
      isSorting.value = false;
      isCategory.value = false;
    }
  }
}
