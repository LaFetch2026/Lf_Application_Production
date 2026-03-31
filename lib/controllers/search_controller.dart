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
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;

  //pagination
  final RxInt currentPage = 0.obs;
  final RxBool hasMore = true.obs;
  String _lastQuery = "";

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

  Future<void> getSearchData({bool loadMore = false}) async {
    final key = searchController.text.trim();

    if (key.isEmpty) {
      searchList.clear();
      searchText.value = "Type to search";
      currentPage.value = 0;
      hasMore.value = true;
      _lastQuery = "";
      return;
    }

    // new query -> reset pagination
    if (!loadMore && key != _lastQuery) {
      currentPage.value = 0;
      hasMore.value = true;
      searchList.clear();
      _lastQuery = key;
    }

    if (!hasMore.value || isSearching.value) return;

    isSearching.value = true;

    try {
      final headers = await _headers();
      final uri = _buildUri(ApiConstants.baseUrl, 'search', {
        'q': key,
        'hitsPerPage': '20',
        'page': currentPage.value.toString(),
      });

      print('[SEARCH] uri: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      print('[SEARCH] status: ${response.statusCode}');
      print('[SEARCH] body: ${response.body}');

      if (response.statusCode != 200 || !_isJson(response)) {
        if (!loadMore) searchList.clear();
        searchText.value = "No product found";
        hasMore.value = false;
        return;
      }

      final decoded = json.decode(response.body);
      final hits = (decoded['data']?['hits'] as List?) ?? [];

      final items = hits
          .whereType<Map>()
          .map((p) => <String, dynamic>{
                'id': int.tryParse(p['objectID'].toString()) ?? 0,
                'product_name': p['title'],
                'product_image': p['image'],
                'price': p['price'],
                'mrp': p['mrp'] ?? p['price'],
                'slug': p['slug'],
                'brand_name': p['brand'],
                'category_name': p['category'],
                'available': p['available'] ?? true,
                'rating': p['rating'] ?? 0,
                ...Map<String, dynamic>.from(p),
              })
          .toList();

      if (loadMore) {
        searchList.addAll(items);
      } else {
        searchList.assignAll(items);
      }

      searchText.value =
          searchList.isEmpty ? "No product found" : "Search for products";

      // if API returned fewer than requested, assume no more pages
      if (items.length < 20) {
        hasMore.value = false;
      } else {
        currentPage.value += 1;
      }
    } on TimeoutException {
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
    } catch (e) {
      print('[SEARCH] error: $e');
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
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

      // Parse response - data is array of objects with 'keyword' and 'count'
      final List<Map<String, dynamic>> items =
          (decoded is Map && decoded['data'] is List)
              ? (decoded['data'] as List)
                  .whereType<Map>()
                  .map((item) => {
                        'keyword': item['keyword']?.toString() ?? '',
                        'count': item['count'] ?? 0,
                      })
                  .where((item) => (item['keyword'] as String).isNotEmpty)
                  .toList()
              : <Map<String, dynamic>>[];

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
    currentPage.value = 0;
    hasMore.value = true;
    _lastQuery = value;
    getSearchData();
  }

  void clearSearch() {
    searchController.clear();
    searchList.clear();
    suggestions.clear();
    searchText.value = "Search for products";
    currentPage.value = 0;
    hasMore.value = true;
    _lastQuery = "";
  }
}
