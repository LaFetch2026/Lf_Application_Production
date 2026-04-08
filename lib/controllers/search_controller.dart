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

  // Race condition prevention: each search gets a unique ID;
  // responses from older requests are discarded.
  int _searchRequestId = 0;

  // Inactive brands cache (5-minute TTL)
  Set<String>? _inactiveBrandsCache;
  DateTime? _inactiveBrandsFetchedAt;
  static const _inactiveBrandsCacheDuration = Duration(minutes: 5);

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
    ++_searchRequestId; // invalidate any in-flight request
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
    ++_searchRequestId; // invalidate any in-flight request
    getSearchData();
  }

  /// filters reset(no api calls)
  void resetFilters() {
    filterBrands.clear();
    filterColors.clear();
    filterSizes.clear();
    filterMinPrice.value = "300";
    filterMaxPrice.value = "100000";
    sortOption.value = "recommended";
    currentPage.value = 0;
    hasMore.value = true;
  }

  // ---- API: POST /product-search?key=<query> --------------------------------

  /// Fetches inactive brand names (lowercase) with a 5-minute cache.
  /// Returns empty set on failure so search still works.
  Future<Set<String>> _getInactiveBrands() async {
    final now = DateTime.now();
    if (_inactiveBrandsCache != null &&
        _inactiveBrandsFetchedAt != null &&
        now.difference(_inactiveBrandsFetchedAt!) < _inactiveBrandsCacheDuration) {
      return _inactiveBrandsCache!;
    }
    try {
      final headers = await _headers();
      final uri = Uri.parse('${ApiConstants.baseUrl}/brands/inactive');
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && _isJson(response)) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        _inactiveBrandsCache = data
            .map((b) => (b['name'] as String?)?.toLowerCase().trim() ?? '')
            .where((n) => n.isNotEmpty)
            .toSet();
        _inactiveBrandsFetchedAt = now;
        print('[ALGOLIA] Inactive brands: ${_inactiveBrandsCache!.join(', ')}');
        return _inactiveBrandsCache!;
      }
    } catch (e) {
      print('[ALGOLIA] Failed to fetch inactive brands: $e');
    }
    return {};
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

    // For load-more, skip if already loading or nothing left
    if (loadMore && (!hasMore.value || isSearching.value)) return;
    if (!loadMore && !hasMore.value) return;

    // Claim this request's ID. If a newer request starts before this one
    // finishes, thisId will be stale and we discard the response.
    final thisId = ++_searchRequestId;

    isSearching.value = true;

    try {
      await _initAlgolia();
      if (_client == null) throw Exception("Algolia not configured");

      // Stale-check: a newer search was triggered while we were initialising
      if (thisId != _searchRequestId) return;

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
        hitsPerPage: 20,
        page: currentPage.value,
        facets: ['brand', 'category', 'gender', 'sizes'],
      );

      print('[ALGOLIA] Search page=${currentPage.value} filters=$filters');
      final response = await _client!.searchIndex(request: request);

      // Stale-check: discard if a newer request has already completed/started
      if (thisId != _searchRequestId) {
        print('[ALGOLIA] Discarding stale response for "$key" (id=$thisId)');
        return;
      }

      final hits = response.hits.map((h) => h.toJson()).toList();
      // Use raw hit count (before filtering) to determine if more pages exist
      final rawHitCount = hits.length;

      final inactiveBrands = await _getInactiveBrands();

      // Stale-check again after the async inactive-brands fetch
      if (thisId != _searchRequestId) {
        print('[ALGOLIA] Discarding stale response for "$key" (id=$thisId)');
        return;
      }

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
          .where((p) {
            if (inactiveBrands.isEmpty) return true;
            final brand = (p['brand_name'] ?? p['brand'] ?? '')
                .toString()
                .toLowerCase()
                .trim();
            return !inactiveBrands.contains(brand);
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

      if (rawHitCount < 20) {
        hasMore.value = false;
      } else {
        currentPage.value += 1;
      }
    } on TimeoutException {
      if (thisId != _searchRequestId) return;
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
    } catch (e) {
      if (thisId != _searchRequestId) return;
      print('[SEARCH] error: $e');
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
    } finally {
      // Only clear the loading flag if we're still the active request
      if (thisId == _searchRequestId) {
        isSearching.value = false;
      }
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
    ++_searchRequestId; // invalidate any in-flight request
  }
}
