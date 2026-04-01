import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:algoliasearch/algoliasearch.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/constants.dart';
import 'base_controller.dart';

class SearchScreenController extends BaseController {
  final TextEditingController searchController = TextEditingController();

  // Search state
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> searchList = <Map<String, dynamic>>[].obs;
  final RxString searchText = "Search for products".obs;

  // Algolia state
  SearchClient? _client;
  String _indexName = "products";

  // Suggestions state
  final RxBool isSuggesting = false.obs;
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;

  //pagination
  final RxInt currentPage = 0.obs;
  final RxBool hasMore = true.obs;
  String _lastQuery = "";

  //filters

  final RxList<String> filterBrands = <String>[].obs;
  final RxList<String> filterColors = <String>[].obs;
  final RxList<String> filterSizes = <String>[].obs;
  final RxString filterMinPrice = "300".obs;
  final RxString filterMaxPrice = "100000".obs;
  final RxString sortOption = "recommended".obs;

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

  Future<void> _initAlgolia() async {
    if (_client != null) return;
    try {
      final headers = await _headers();
      final uri = Uri.parse('${ApiConstants.baseUrl}/search/config');
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        dynamic decoded = json.decode(response.body);
        if (decoded['data'] != null) {
          final data = decoded['data'];
          _client = SearchClient(
            appId: data['appId'],
            apiKey: data['searchKey'],
          );
          _indexName = data['indexName'] ?? 'products';
          print('[ALGOLIA] Configured successfully');
        }
      } else {
        print('[ALGOLIA] Failed config: ${response.statusCode}');
      }
    } catch (e) {
      print('[ALGOLIA] Init error: $e');
    }
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

  //filters

  void applyFilters({
    List<String> brands = const [],
    List<String> colors = const [],
    List<String> sizes = const [],
    String minPrice = "300",
    String maxPrice = "100000",
    String sort = "recommended",
  }) {
    filterBrands.assignAll(brands);
    filterColors.assignAll(colors);
    filterSizes.assignAll(sizes);
    filterMinPrice.value = minPrice;
    filterMaxPrice.value = maxPrice;
    sortOption.value = sort;
    currentPage.value = 0;
    hasMore.value = true;
    searchList.clear();
    getSearchData();
  }

  void clearFilters() {
    filterBrands.clear();
    filterColors.clear();
    filterSizes.clear();
    filterMinPrice.value = "300";
    filterMaxPrice.value = "100000";
    sortOption.value = "recommended";
    currentPage.value = 0;
    hasMore.value = true;
    searchList.clear();
    getSearchData();
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

    if (!loadMore && key != _lastQuery) {
      currentPage.value = 0;
      hasMore.value = true;
      searchList.clear();
      _lastQuery = key;
    }

    if (!hasMore.value || isSearching.value) return;

    isSearching.value = true;

    try {
      await _initAlgolia();
      if (_client == null) throw Exception("Algolia not configured");

      List<String> filterParts = ['available:true'];

      if (filterBrands.isNotEmpty) {
        final brandFilters = filterBrands.map((b) => 'brand:"$b"').join(' OR ');
        filterParts.add('($brandFilters)');
      }
      if (filterColors.isNotEmpty) {
        final colorFilters = filterColors.map((c) => 'color:"$c"').join(' OR ');
        filterParts.add('($colorFilters)');
      }
      if (filterSizes.isNotEmpty) {
        final sizeFilters = filterSizes.map((s) => 'sizes:"$s"').join(' OR ');
        filterParts.add('($sizeFilters)');
      }

      final minP = int.tryParse(filterMinPrice.value) ?? 300;
      final maxP = int.tryParse(filterMaxPrice.value) ?? 100000;
      if (minP > 300 || maxP < 100000) {
        filterParts.add('price:$minP TO $maxP');
      }

      final filters = filterParts.isNotEmpty ? filterParts.join(' AND ') : null;

      final request = SearchForHits(
        indexName: _indexName,
        query: key,
        filters: filters,
        hitsPerPage: 60,
        page: currentPage.value,
        facets: ['brand', 'category', 'gender', 'sizes'],
      );

      print('[ALGOLIA] Search request filters: $filters');
      final response = await _client!.searchIndex(request: request);
      final hits = response.hits.map((h) => h.toJson()).toList();

      final items = hits
          .map((p) => <String, dynamic>{
                'id':
                    int.tryParse((p['objectID'] ?? p['id'] ?? '').toString()) ??
                        0,
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

      _applyLocalSort();

      searchText.value =
          searchList.isEmpty ? "No product found" : "Search for products";

      if (items.length < 60) {
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

  void _applyLocalSort() {
    if (sortOption.value == 'recommended' || searchList.isEmpty) return;

    final list = searchList.toList();
    list.sort((a, b) {
      final pA = double.tryParse((a['price'] ?? 0).toString()) ?? 0.0;
      final pB = double.tryParse((b['price'] ?? 0).toString()) ?? 0.0;
      final rA = double.tryParse((a['rating'] ?? 0).toString()) ?? 0.0;
      final rB = double.tryParse((b['rating'] ?? 0).toString()) ?? 0.0;

      switch (sortOption.value) {
        case 'price_asc':
          return pA.compareTo(pB);
        case 'price_desc':
          return pB.compareTo(pA);
        case 'whats_new':
          final idA = int.tryParse((a['id'] ?? 0).toString()) ?? 0;
          final idB = int.tryParse((b['id'] ?? 0).toString()) ?? 0;
          return idB.compareTo(idA);
        case 'rating':
          return rB.compareTo(rA);
        case 'discount':
          final mrpA = double.tryParse((a['mrp'] ?? pA).toString()) ?? pA;
          final mrpB = double.tryParse((b['mrp'] ?? pB).toString()) ?? pB;
          final dA = mrpA > 0 ? ((mrpA - pA) / mrpA) : 0.0;
          final dB = mrpB > 0 ? ((mrpB - pB) / mrpB) : 0.0;
          return dB.compareTo(dA);
        default:
          return 0;
      }
    });

    searchList.assignAll(list);
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
