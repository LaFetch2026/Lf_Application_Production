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

  /// ================================================================
  /// ✅ Fetch Brands (Featured or All)
  /// ================================================================
  Future<void> getBrandData(String type,
      [int? gender, bool showLoader = true]) async {
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
        getSnackBar("Session expired. Please log in again.");
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
        getSnackBar(msg);
        return;
      }

      // Ensure JSON
      final contentType =
          (response.headers['content-type'] ?? '').toLowerCase();
      if (!contentType.contains('application/json')) {
        getSnackBar("Unexpected response while fetching brands.");
        return;
      }

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

      // ✅ Sort alphabetically by brand name
      filtered.sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });

      // ✅ CRITICAL: Clear old data first, then add new data
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
      print(
          "🪪 Brand names: ${brandList.map((b) => b['name']).take(5).toList()}${brandList.length > 5 ? '...' : ''}");
    } on TimeoutException {
      getSnackBar("Brands request timed out. Please try again.");
    } on SocketException {
      getSnackBar("No internet connection. Please check your network.");
    } catch (e) {
      print("❌ Error fetching brand data: $e");
      getSnackBar("Something went wrong while fetching brands.");
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
      );

      print("⬅️ Status Code: ${response.statusCode}");

      if (response.statusCode == 401) {
        getSnackBar("Session expired. Please log in again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }

      if (response.statusCode != 200) {
        getSnackBar("Failed to fetch brand details.");
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
      getSnackBar("Something went wrong while fetching brand details.");
    } finally {
      isDetails.value = false;
    }
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
        getSnackBar("Session expired. Please log in again.");
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
}
