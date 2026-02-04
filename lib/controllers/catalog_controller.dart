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

  // ✅ Track which genders have already loaded catalog data
  final Set<int> _loadedCatalogGenders = {};

  /// Check if catalog for a gender is already loaded
  bool isCatalogLoaded(int gender) => _loadedCatalogGenders.contains(gender);

  /// Mark catalog for gender as loaded
  void markCatalogLoaded(int gender) => _loadedCatalogGenders.add(gender);

  /// Clear loaded tracking
  void clearLoadedTracking() => _loadedCatalogGenders.clear();

  /// Fetch catalog by gender
  Future<void> getCatalogData(int gender, {bool forceRefresh = false}) async {
    // ✅ Skip if already loaded (unless force refresh)
    if (!forceRefresh && isCatalogLoaded(gender) && catalogList.isNotEmpty) {
      print('✅ Catalog already loaded for gender: $gender, skipping API call');
      return;
    }

    final cacheKey = 'catalog_$gender';

    // Try to load from cache first
    if (!forceRefresh) {
      final cached = await CacheManager.get(key: cacheKey);
      if (cached != null && cached is List) {
        catalogList.clear();
        catalogList.assignAll(cached);
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
    String? sortOption,
    int? superCatId,
    int? catId,
    int? subCatId,
    int? brandId,
    int? collectionId,
    String? key,
    int page = 1,
    int limit = 20,
    bool appendResults = false,
  }) async {
    isSorting.value = true;
    isCategory.value = true;

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
}
