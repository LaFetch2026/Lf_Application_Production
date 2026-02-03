// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import 'base_controller.dart';
import 'product_controller.dart';

class SearchScreenController extends BaseController {
  final TextEditingController searchController = TextEditingController();

  // Search state
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> searchList = <Map<String, dynamic>>[].obs;
  final RxString searchText = "Search for products".obs;

  // Suggestions state
  final RxBool isSuggesting = false.obs;
  final RxList<String> suggestions = <String>[].obs;

  // ---- helpers --------------------------------------------------------------

  Uri _buildUri(String base, String path, Map<String, String> params) {
    final baseUri = Uri.parse(base);
    final normalizedPath = baseUri.path.endsWith('/')
        ? '${baseUri.path}$path'
        : '${baseUri.path}/$path';
    return baseUri.replace(path: normalizedPath, queryParameters: params);
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final h = <String, String>{'Accept': 'application/json; charset=UTF-8'};
    final token = prefs.getString('token');
    if (token != null && token.trim().isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  bool _isJson(http.Response r) => (r.headers['content-type'] ?? '')
      .toLowerCase()
      .contains('application/json');

  // ---- lifecycle ------------------------------------------------------------

  @override
  void onClose() {
    try {
      if (searchController.hasListeners) {
        searchController.dispose();
      }
    } catch (e) {
      debugPrint('⚠️ searchController already disposed: $e');
    }
    super.onClose();
  }

  // ---- API: POST /product-search?key=<query> --------------------------------
  Future<void> getSearchData() async {
    final key = searchController.text.trim();

    if (key.isEmpty) {
      searchList.clear();
      searchText.value = "Type to search";
      return;
    }

    isSearching.value = true;

    try {
      final headers = await _headers();
      final uri =
          _buildUri(ApiConstants.baseUrl, 'filter-products', {'key': key, 'status': 'true'});

      final response = await http
          .post(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print('[SEARCH] ${response.statusCode} $uri');

      if (response.statusCode != 200 || !_isJson(response)) {
        searchList.clear();
        searchText.value = "No product found";
        return;
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        print('[SEARCH] JSON decode error: $e');
        searchList.clear();
        searchText.value = "No product found";
        return;
      }

      final List<Map<String, dynamic>> items =
          (decoded is Map &&
           decoded['data'] is Map &&
           decoded['data']['products'] is List)
              ? (decoded['data']['products'] as List)
                  .whereType<Map>()
                  .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
                  .toList()
              : <Map<String, dynamic>>[];

      // Transform products to add display prices
      final transformed = items.map((p) {
        return ProductController.calculateDisplayPrices(p);
      }).toList();

      searchList.assignAll(transformed);
      searchText.value =
          items.isEmpty ? "No product found" : "Search for products";
    } on TimeoutException {
      print('[SEARCH] timeout');
      searchList.clear();
      searchText.value = "No product found";
    } catch (e) {
      print('[SEARCH] error: $e');
      searchList.clear();
      searchText.value = "No product found";
    } finally {
      isSearching.value = false;
    }
  }

  // ---- API: POST /product-suggestion?key=<query> ----------------------------
  Future<void> getProductSuggestions() async {
    final key = searchController.text.trim();
    if (key.isEmpty) {
      suggestions.clear();
      return;
    }

    isSuggesting.value = true;
    try {
      final headers = await _headers();
      final uri =
          _buildUri(ApiConstants.baseUrl, 'product-suggestion', {'key': key});

      final response = await http
          .post(uri, headers: headers)
          .timeout(const Duration(seconds: 12));

      print('[SUGGEST] ${response.statusCode} $uri');

      if (response.statusCode != 200 || !_isJson(response)) {
        suggestions.clear();
        return;
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (_) {
        suggestions.clear();
        return;
      }

      final List<String> items = (decoded is Map && decoded['data'] is List)
          ? (decoded['data'] as List).whereType<String>().toList()
          : <String>[];

      suggestions.assignAll(items);
    } on TimeoutException {
      print('[SUGGEST] timeout');
      suggestions.clear();
    } catch (e) {
      print('[SUGGEST] error: $e');
      suggestions.clear();
    } finally {
      isSuggesting.value = false;
    }
  }

  // ---- utilities ------------------------------------------------------------

  void applySuggestion(String value) {
    searchController.text = value;
    getSearchData();
  }

  void clearSearch() {
    searchController.clear();
    searchList.clear();
    suggestions.clear();
    searchText.value = "Search for products";
  }
}
