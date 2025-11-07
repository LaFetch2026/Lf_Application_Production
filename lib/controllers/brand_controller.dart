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
  List brandList = [].obs;
  RxString brandName = "".obs;
  RxString brandlogo = "".obs;
  RxString brandbackground = "".obs;
  RxInt brandId = 0.obs;
  RxString text = "Expand All".obs;
  RxBool showAllBrand = false.obs;
  RxBool isDetails = false.obs;
  var brandDetails = <String, dynamic>{}.obs; // ✅ correct: reactive Map

  RxBool isCategory = false.obs;
  RxBool isProductBrand = false.obs;
  List categoryList = [].obs;
  List brand_category_List = [].obs;
  List brandProductDetailsList = [].obs;
  RxInt selectIndex = 0.obs;
  List<bool> selected = List.generate(50, (i) => false).obs;

  Future<void> getBrandData(String type) async {
    isBrand.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      // Build base = laFetchBaseUrl (your sample shows this host)
      final base = ApiConstants.baseUrl; // ← use laFetch here per your API
      final baseUri = Uri.parse(base);

      // Only append isFeatured (present in your payload). Avoid unknown params.
      final queryParams = <String, String>{};
      if (type == "featured") {
        queryParams["isFeatured"] = "true";
      }

      final uri = baseUri.replace(
        path: baseUri.path.endsWith('/')
            ? '${baseUri.path}brands'
            : '${baseUri.path}/brands',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final headers = <String, String>{
        'Accept': 'application/json; charset=UTF-8',
      };
      final token = prefs.getString('token');
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print("➡️ Brand API URL: $uri");
      print("⬅️ Status Code: ${response.statusCode}");

      // Handle non-200 early
      if (response.statusCode == 401) {
        getSnackBar("Session expired. Please log in again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return;
      }
      if (response.statusCode != 200) {
        // Try to parse the error payload to show message if any
        try {
          final err = json.decode(response.body);
          final msg = (err is Map && err["message"] is String)
              ? err["message"] as String
              : "Unknown error";
          getSnackBar("Failed to fetch brands: $msg");
        } catch (_) {
          getSnackBar("Failed to fetch brands (${response.statusCode}).");
        }
        return;
      }

      // Ensure JSON
      final contentType =
          (response.headers['content-type'] ?? '').toLowerCase();
      if (!contentType.contains('application/json')) {
        getSnackBar("Unexpected response while fetching brands.");
        return;
      }

      // Decode payload: { status, message, data: [ {...}, ... ] }
      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        print("❌ JSON decode error: $e");
        getSnackBar("Something went wrong while fetching brands.");
        return;
      }

      final List<dynamic> allBrandsRaw =
          (decoded is Map && decoded['data'] is List)
              ? decoded['data'] as List
              : const [];

      // Client-side search filter (API sample doesn't show ?q= support)
      final q = (queryText.value).trim().toLowerCase();
      final filtered = q.isEmpty
          ? allBrandsRaw
          : allBrandsRaw.where((b) {
              final name =
                  (b is Map && b['name'] != null) ? b['name'].toString() : '';
              return name.toLowerCase().contains(q);
            }).toList();

      // Group & sort alphabetically
      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (final item in filtered) {
        if (item is! Map) continue;
        final name = (item['name'] ?? '').toString().trim();
        // Fall back group key if name missing/empty
        final String key = name.isEmpty ? '#' : name[0].toUpperCase();
        (grouped[key] ??= <Map<String, dynamic>>[]).add(
          // make sure map has String keys
          item.map((k, v) => MapEntry(k.toString(), v)),
        );
      }

      // Sort groups by letter, and items inside by name
      final sortedGroups = grouped.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      brandList = []; // Clear and rebuild
      for (final entry in sortedGroups) {
        final letter = entry.key;
        final items = entry.value
          ..sort((a, b) => (a['name'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['name'] ?? '').toString().toLowerCase()));
        // Insert group heading followed by items
        brandList.add({"alphabet": letter});
        brandList.addAll(items);
      }

      // Selection states aligned to new length
      selected.clear();
      selected = List<bool>.generate(brandList.length, (_) => false);

      print(
          "✅ Brands loaded: ${filtered.length} | Groups: ${sortedGroups.length}");
    } on TimeoutException {
      print("⏳ Brand API timeout");
      getSnackBar("Brands request timed out. Please try again.");
    } catch (e) {
      print("❌ Error fetching brand data: $e");
      getSnackBar("Something went wrong while fetching brands.");
    } finally {
      isBrand.value = false;
    }
  }

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
      print("📦 Raw Response:\n${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonRes = json.decode(response.body);
        final data = jsonRes['data'] ?? {};

        brandDetails.value = data; // store entire response

        // Parse categories
        final brandInfo = data['brandInfo'] ?? {};
        final List<dynamic> categories = brandInfo['categories'] ?? [];

        brand_category_List
          ..clear()
          ..addAll(categories
              .whereType<Map>()
              .map((item) => item['id'])
              .whereType<int>()
              .toList());

        // Parse products
        final List<dynamic> products = data['products'] ?? [];
        brandProductDetailsList
          ..clear()
          ..addAll(products.whereType<Map>());

        print(
            "✅ Brand details fetched: ${brand_category_List.length} categories, ${brandProductDetailsList.length} products.");
      } else if (response.statusCode == 401) {
        getSnackBar("Session expired. Please log in again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
      } else {
        getSnackBar("Failed to fetch brand details.");
      }
    } catch (e) {
      print("❌ Exception in getBrandDetails: $e");
      getSnackBar("Something went wrong while fetching brand details.");
    } finally {
      isDetails.value = false;
    }
  }
}
