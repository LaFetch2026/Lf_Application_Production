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
import 'base_controller.dart';

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
  Future<void> getCatalogData(int gender) async {
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
          // ✅ CRITICAL: Clear old data first, then assign new data
          catalogList.clear();
          catalogList.assignAll(responseData["data"]);

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
          final base = p["basePrice"] ?? 0;
          final mrp = p["mrp"] ?? 0;

          bool hideMrp = (mrp == 0 || mrp == base);

          return {
            ...p,
            "displayPrice": base,
            "displayMrp": hideMrp ? null : mrp,
          };
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

  // /// 🆕 Fetch Sorted Products [DEPRECATED - Use getFilterAndSortProducts instead]
  // /// sort options:
  // /// price_asc = Price Low to High
  // /// price_desc = Price High to Low
  // /// rating = Rating
  // /// discount = Discount
  // /// whats_new = What's New
  // Future<void> getSortedProducts({
  //   required String sortOption,
  //   int? catId,
  //   int? brandId,
  //   int? collectionId,
  // }) async {
  //   isSorting.value = true;
  //   final prefs = await SharedPreferences.getInstance();

  //   try {
  //     // ✅ Build query params dynamically
  //     final queryParams = {
  //       "sort": sortOption,
  //       if (catId != null) "catId": catId.toString(),
  //       if (brandId != null) "brandId": brandId.toString(),
  //       if (collectionId != null) "collectionID": collectionId.toString(),
  //     };

  //     final uri = Uri.parse("${ApiConstants.baseUrl}/sort-products")
  //         .replace(queryParameters: queryParams);

  //     // ✅ Debug prints
  //     print("🔹 Sorting products with:");
  //     print("   • sortOption   → $sortOption");
  //     print("   • catId        → ${catId ?? 'null'}");
  //     print("   • brandId      → ${bandId ?? 'null'}");
  //     print("   • collectionId → ${collectionId ?? 'null'}");
  //     print("   • Final URL    → $uri");

  //     final response = await http.get(
  //       uri,
  //       headers: {
  //         'Accept': 'application/json; charset=UTF-8',
  //         'Authorization': 'Bearer ${prefs.getString('token')}',
  //       },
  //     );

  //     final decoded = json.decode(response.body);

  //     if (response.statusCode == 200 && decoded["data"] != null) {
  //       sortedProductList.assignAll(decoded["data"]);
  //       print("✅ Sorted products fetched: ${sortedProductList.length}");
  //     } else if (response.statusCode == 401) {
  //       Get.offAll(() => const LoginScreen(initialTab: 0));
  //       getSnackBar("Authentication failed");
  //     } else if (response.statusCode == 500) {
  //       getSnackBar("Server error, please try again later");
  //     } else {
  //       getSnackBar(decoded["message"] ?? "Failed to fetch sorted products");
  //       print("❌ API Error: ${decoded["message"]}");
  //     }
  //   } catch (e) {
  //     print("🚨 getSortedProducts error: $e");
  //   } finally {
  //     isSorting.value = false;
  //   }
  // }

  // /// 🆕 Filter Products API [DEPRECATED - Use getFilterAndSortProducts instead]
  // /// Filters products by brands, price range, category, brand, and collection
  // /// Add this method to your CatalogController class
  // Future<void> getFilteredProducts({
  //   required List<int> brandIds,
  //   required String minPrice,
  //   required String maxPrice,
  //   int? catId,
  //   int? brandId,
  //   int? collectionId,
  // }) async {
  //   isCategory.value = true;
  //   final prefs = await SharedPreferences.getInstance();

  //   try {
  //     final uri = Uri.parse("${ApiConstants.baseUrl}/filter-products");

  //     // ✅ Build request body
  //     final body = {
  //       "brandIds": brandIds,
  //       "minPrice": minPrice,
  //       "maxPrice": maxPrice,
  //       if (catId != null) "catId": catId,
  //       if (brandId != null) "brandId": brandId,
  //       if (collectionId != null) "collectionId": collectionId,
  //     };

  //     // ✅ Debug prints
  //     print("🔹 Filtering products with:");
  //     print("   • brandIds     → $brandIds");
  //     print("   • price range  → ₹$minPrice - ₹$maxPrice");
  //     print("   • catId        → ${catId ?? 'null'}");
  //     print("   • brandId      → ${brandId ?? 'null'}");
  //     print("   • collectionId → ${collectionId ?? 'null'}");
  //     print("   • API URL      → $uri");
  //     print("   • Request Body → ${json.encode(body)}");

  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         'Accept': 'application/json; charset=UTF-8',
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': 'Bearer ${prefs.getString('token')}',
  //       },
  //       body: json.encode(body),
  //     );

  //     final decoded = json.decode(response.body);

  //     if (response.statusCode == 200 && decoded["data"] != null) {
  //       categoryProductList.assignAll(decoded["data"]);
  //       print("✅ Filtered products fetched: ${categoryProductList.length}");
  //     } else if (response.statusCode == 401) {
  //       Get.offAll(() => const LoginScreen(initialTab: 0));
  //       getSnackBar("Authentication failed");
  //     } else if (response.statusCode == 500) {
  //       getSnackBar("Server error, please try again later");
  //     } else {
  //       getSnackBar(decoded["message"] ?? "Failed to filter products");
  //       print("❌ API Error: ${decoded["message"]}");
  //     }
  //   } catch (e) {
  //     print("🚨 getFilteredProducts error: $e");
  //     getSnackBar("Something went wrong while filtering");
  //   } finally {
  //     isCategory.value = false;
  //   }
  // }

  /// 🆕 Unified Filter & Sort Products API
  /// Handles filtering, sorting, or both in a single API call
  ///
  /// Filter options:
  /// - brandIds: List of brand IDs to filter by
  /// - minPrice: Minimum price filter
  /// - maxPrice: Maximum price filter
  ///
  /// Sort options:
  /// - price_asc = Price Low to High
  /// - price_desc = Price High to Low
  /// - rating = Rating
  /// - discount = Discount
  /// - whats_new = What's New
  /// - recommended = Default/Recommended (no sort applied)
  ///
  /// Additional filters:
  /// - catId: Category ID
  /// - brandId: Single brand ID
  /// - collectionId: Collection ID
  ///
  /// Usage:
  /// - Filter only: Pass brandIds, minPrice, maxPrice
  /// - Sort only: Pass sortOption
  /// - Both: Pass all parameters
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
  }) async {
    isSorting.value = true;
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      // ✅ Build query parameters for POST request (params in URL, not body)
      final Map<String, String> queryParams = {};

      // Add filter parameters
      if (brandIds != null && brandIds.isNotEmpty) {
        queryParams['brandIds'] = brandIds.join(','); // Comma-separated string
      }
      if (colors != null && colors.isNotEmpty) {
        queryParams['colors'] = colors.join(','); // Comma-separated string
      }
      if (sizes != null && sizes.isNotEmpty) {
        queryParams['sizes'] = sizes.join(','); // Comma-separated string
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

      // Add additional filters (skip if 0 or negative)
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

      final uri = Uri.parse("${ApiConstants.baseUrl}/filter-products").replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      // ✅ Debug prints
      print("🔹 Filter & Sort API Request (POST with query params):");
      print("   📝 Raw Parameters:");
      print("      brandIds     → $brandIds");
      print("      minPrice     → $minPrice");
      print("      maxPrice     → $maxPrice");
      print("      key          → $key");
      print("      sortOption   → $sortOption");
      print("      superCatId   → $superCatId");
      print("      catId        → $catId");
      print("      subCatId     → $subCatId");
      print("      brandId      → $brandId");
      print("      collectionId → $collectionId");
      print("   🌐 Final URL    → $uri");

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

      // Check if response is HTML instead of JSON
      print(
          "📥 Filter API Response [${response.statusCode}]: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}");

      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print("❌ Filter API returned HTML instead of JSON");
        getSnackBar("Server error: Invalid response format");
        return;
      }

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        List<dynamic> products = List<dynamic>.from(decoded["data"]);
        final originalCount = products.length;

        // 📊 Analyze price distribution BEFORE filtering
        if (products.isNotEmpty && (minPrice != null || maxPrice != null)) {
          final prices = products
              .map((p) => (p['basePrice'] ?? p['displayPrice'] ?? 0) as num)
              .toList();
          prices.sort();
          print(
              "   📊 API returned products - Price range: ₹${prices.first} to ₹${prices.last}");
          print(
              "   📊 Requested filter: ₹${minPrice ?? '0'} to ₹${maxPrice ?? '∞'}");
        }

        // ✅ Client-side filtering as safety net (in case backend filtering is incomplete)
        // Filter by price range
        if (minPrice != null || maxPrice != null) {
          final minPriceNum = double.tryParse(minPrice ?? '0') ?? 0;
          final maxPriceNum = double.tryParse(maxPrice ?? '999999') ?? 999999;

          int excludedCount = 0;
          products = products.where((product) {
            final price =
                (product['basePrice'] ?? product['displayPrice'] ?? 0) as num;
            final isInRange = price >= minPriceNum && price <= maxPriceNum;
            if (!isInRange) {
              excludedCount++;
              if (excludedCount <= 5) {
                // Show first 5 excluded products
                print(
                    "   ❌ EXCLUDED: ID:${product['id']} Price:₹$price (outside ₹$minPrice-₹$maxPrice)");
              }
            }
            return isInRange;
          }).toList();

          if (excludedCount > 0) {
            print(
                "   🔧 Client-side price filter: REMOVED $excludedCount products outside range");
            print(
                "   📉 Reduced from $originalCount to ${products.length} products");
          } else {
            print(
                "   ✅ All ${products.length} products are within price range ₹$minPrice-₹$maxPrice");
          }

          // Show price range of filtered products
          if (products.isNotEmpty) {
            final filteredPrices = products
                .map((p) => (p['basePrice'] ?? p['displayPrice'] ?? 0) as num)
                .toList();
            filteredPrices.sort();
            print(
                "   📊 After filter - Price range: ₹${filteredPrices.first} to ₹${filteredPrices.last}");
          }
        }

        // Filter by brand IDs
        if (brandIds != null && brandIds.isNotEmpty) {
          final beforeBrandFilter = products.length;
          products = products.where((product) {
            final productBrandId =
                int.tryParse(product['brandId']?.toString() ?? '0') ?? 0;
            final isMatch = brandIds.contains(productBrandId);
            if (!isMatch && beforeBrandFilter <= 10) {
              // Only log first few for debugging
              print(
                  "   ⚠️ Excluding product ID:${product['id']} Brand:$productBrandId (not in ${brandIds.take(5).join(',')})");
            }
            return isMatch;
          }).toList();

          if (products.length != beforeBrandFilter) {
            print(
                "   🔧 Client-side brand filter applied: ${brandIds.length} brand(s)");
            print(
                "   📉 Reduced from $beforeBrandFilter to ${products.length} products");
          }
        }

        // ✅ Transform products to add displayPrice and displayMrp
        final transformed = products.map<Map<String, dynamic>>((p) {
          final base = p["basePrice"] ?? 0;
          final mrp = p["mrp"] ?? 0;

          bool hideMrp = (mrp == 0 || mrp == base);

          return {
            ...p,
            "displayPrice": base,
            "displayMrp": hideMrp ? null : mrp,
          };
        }).toList();

        // ✅ Update both lists to maintain backward compatibility
        categoryProductList.assignAll(transformed);
        sortedProductList.assignAll(transformed);
        print(
            "✅ Filtered/Sorted products fetched: ${categoryProductList.length}");

        // 🔍 Debug: Show first 5 products to verify sorting/filtering
        if (categoryProductList.isNotEmpty) {
          final sample = categoryProductList.take(5).map((p) {
            return "ID:${p['id']} ₹${p['basePrice'] ?? p['displayPrice']} Brand:${p['brandId']}";
          }).join(", ");
          print("🔍 Sample products: $sample");
        }
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(decoded["message"] ?? "Failed to fetch products");
        print("❌ API Error: ${decoded["message"]}");
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
