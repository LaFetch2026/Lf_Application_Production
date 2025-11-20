// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
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
    final prefs = await SharedPreferences.getInstance();

    try {
      final url = Uri.parse(
        "${ApiConstants.baseUrl}/categories?gender=$gender&type=category",
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': "Bearer ${prefs.getString('token')}",
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["data"] != null) {
        catalogList.assignAll(responseData["data"]);
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(responseData["message"] ?? "Failed to fetch categories");
      }
    } catch (e) {
      print("getCatalogData error: $e");
    } finally {
      isCatalog.value = false;
    }
  }

  /// Fetch catalog categories
  Future<void> getCatagoryData(int type) async {
    isCatalogCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri =
          Uri.parse("${ApiConstants.baseUrl}/catalogs?gender_type=$type");
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["data"] != null) {
        catagoryList.assignAll(responseData["data"]);
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

  /// 🆕 Fetch Sorted Products
  /// sort options:
  /// price_asc = Price Low to High
  /// price_desc = Price High to Low
  /// rating = Rating
  /// discount = Discount
  /// whats_new = What's New
  Future<void> getSortedProducts({
    required String sortOption,
    int? catId,
    int? brandId,
    int? collectionId,
  }) async {
    isSorting.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      // ✅ Build query params dynamically
      final queryParams = {
        "sort": sortOption,
        if (catId != null) "catId": catId.toString(),
        if (brandId != null) "brandId": brandId.toString(),
        if (collectionId != null) "collectionID": collectionId.toString(),
      };

      final uri = Uri.parse("${ApiConstants.baseUrl}/sort-products")
          .replace(queryParameters: queryParams);

      // ✅ Debug prints
      print("🔹 Sorting products with:");
      print("   • sortOption   → $sortOption");
      print("   • catId        → ${catId ?? 'null'}");
      print("   • brandId      → ${brandId ?? 'null'}");
      print("   • collectionId → ${collectionId ?? 'null'}");
      print("   • Final URL    → $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        sortedProductList.assignAll(decoded["data"]);
        print("✅ Sorted products fetched: ${sortedProductList.length}");
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(decoded["message"] ?? "Failed to fetch sorted products");
        print("❌ API Error: ${decoded["message"]}");
      }
    } catch (e) {
      print("🚨 getSortedProducts error: $e");
    } finally {
      isSorting.value = false;
    }
  }

  /// 🆕 Filter Products API
  /// Filters products by brands, price range, category, brand, and collection
  /// Add this method to your CatalogController class
  Future<void> getFilteredProducts({
    required List<int> brandIds,
    required String minPrice,
    required String maxPrice,
    int? catId,
    int? brandId,
    int? collectionId,
  }) async {
    isCategory.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/filter-products");

      // ✅ Build request body
      final body = {
        "brandIds": brandIds,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
        if (catId != null) "catId": catId,
        if (brandId != null) "brandId": brandId,
        if (collectionId != null) "collectionId": collectionId,
      };

      // ✅ Debug prints
      print("🔹 Filtering products with:");
      print("   • brandIds     → $brandIds");
      print("   • price range  → ₹$minPrice - ₹$maxPrice");
      print("   • catId        → ${catId ?? 'null'}");
      print("   • brandId      → ${brandId ?? 'null'}");
      print("   • collectionId → ${collectionId ?? 'null'}");
      print("   • API URL      → $uri");
      print("   • Request Body → ${json.encode(body)}");

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
        body: json.encode(body),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        categoryProductList.assignAll(decoded["data"]);
        print("✅ Filtered products fetched: ${categoryProductList.length}");
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen(initialTab: 0));
        getSnackBar("Authentication failed");
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again later");
      } else {
        getSnackBar(decoded["message"] ?? "Failed to filter products");
        print("❌ API Error: ${decoded["message"]}");
      }
    } catch (e) {
      print("🚨 getFilteredProducts error: $e");
      getSnackBar("Something went wrong while filtering");
    } finally {
      isCategory.value = false;
    }
  }
}
