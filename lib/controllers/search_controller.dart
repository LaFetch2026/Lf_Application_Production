import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:algoliasearch/algoliasearch.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/constants.dart';
import '../models/filter_chip_item.dart';
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

  // ── Filter Chips ──────────────────────────────────────────────────────────
  /// Chips returned by the last fresh /filter-products call for this search.
  RxList<FilterChipItem> chips = <FilterChipItem>[].obs;

  /// The set of IDs of currently selected chips (set by [onSearchChipTap]).
  final RxSet<int> selectedChipIds = <int>{}.obs;

  /// Cache of selected chip objects so they can be shown as pills.
  final Map<int, FilterChipItem> _selectedChipObjects = {};

  /// The last chip list returned by the server (fetchChipsForSearch).
  List<FilterChipItem> _lastServerChips = [];

  /// Returns the currently selected chip objects.
  final RxList<FilterChipItem> selectedChips = <FilterChipItem>[].obs;

  void _syncSelectedChips() {
    selectedChips.assignAll(
      selectedChipIds.map((id) => _selectedChipObjects[id]).whereType<FilterChipItem>().toList(),
    );
  }

  /// Clears all chip selections. Call this when the screen is disposed.
  void clearChipSelection() {
    selectedChipIds.clear();
    _selectedChipObjects.clear();
    selectedChips.clear();
  }

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
  final RxInt filterMinDiscount = 0.obs;
  final RxInt filterMaxDiscount = 100.obs;
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
    int minDiscount = 0,
    int maxDiscount = 100,
    String sort = "recommended",
  }) {
    filterBrands.assignAll(brands);
    filterColors.assignAll(colors);
    filterSizes.assignAll(sizes);
    filterMinPrice.value = minPrice;
    filterMaxPrice.value = maxPrice;
    filterMinDiscount.value = minDiscount;
    filterMaxDiscount.value = maxDiscount;
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
    filterMinDiscount.value = 0;
    filterMaxDiscount.value = 100;
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
    filterMinDiscount.value = 0;
    filterMaxDiscount.value = 100;
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

    final minD = filterMinDiscount.value;
    final maxD = filterMaxDiscount.value;
    final hasDiscountFilter = minD > 0 || maxD < 100;

    // When a discount filter is active, use the backend /filter-products API
    // (same as the website: ?key=...&minDiscount=X&maxDiscount=Y).
    // Algolia does not have a discountPercentage numeric attribute indexed.
    if (hasDiscountFilter) {
      await _getSearchDataFromBackend(loadMore: loadMore);
      return;
    }

    await _getSearchDataFromAlgolia(loadMore: loadMore);
  }

  /// Backend /filter-products search — used when discount filter is active.
  Future<void> _getSearchDataFromBackend({bool loadMore = false}) async {
    final key = searchController.text.trim();
    final thisId = ++_searchRequestId;
    isSearching.value = true;

    try {
      final headers = await _headers();
      final minD = filterMinDiscount.value;
      final maxD = filterMaxDiscount.value;
      final page = loadMore ? currentPage.value + 1 : 1;

      final params = <String, String>{
        'key': key,
        'status': 'true',
        'page': page.toString(),
        'limit': '20',
      };

      if (minD > 0) params['minDiscount'] = minD.toString();
      if (maxD < 100) params['maxDiscount'] = maxD.toString();

      final minP = int.tryParse(filterMinPrice.value) ?? 300;
      final maxP = int.tryParse(filterMaxPrice.value) ?? 100000;
      if (minP > 300) params['minPrice'] = minP.toString();
      if (maxP < 100000) params['maxPrice'] = maxP.toString();

      if (filterBrands.isNotEmpty) params['brands'] = filterBrands.join(',');
      if (filterColors.isNotEmpty) params['colors'] = filterColors.join(',');
      if (filterSizes.isNotEmpty) params['sizes'] = filterSizes.join(',');

      final uri = Uri.parse('${ApiConstants.baseUrl}/filter-products')
          .replace(queryParameters: params);

      print('[BACKEND SEARCH] $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (thisId != _searchRequestId) return;

      if (response.statusCode != 200 || !_isJson(response)) {
        if (!loadMore) searchList.clear();
        searchText.value = "No product found";
        hasMore.value = false;
        return;
      }

      final decoded = json.decode(response.body);
      final data = decoded['data'];
      final rawProducts =
          data is Map ? (data['products'] as List?) ?? [] : <dynamic>[];

      final inactiveBrands = await _getInactiveBrands();
      if (thisId != _searchRequestId) return;

      final items = rawProducts
          .whereType<Map<String, dynamic>>()
          .map((p) {
            // Safely extract numeric price — backend may return a Map like
            // {"amount": 500} or a plain num. Fall back to 0.
            num _safeNum(dynamic v) {
              if (v is num) return v;
              if (v is Map) {
                final amt = v['amount'] ?? v['value'] ?? v['price'];
                if (amt is num) return amt;
                return num.tryParse(amt?.toString() ?? '') ?? 0;
              }
              return num.tryParse(v?.toString() ?? '') ?? 0;
            }

            final rawPrice = p['displayPrice'] ?? p['price'] ?? p['basePrice'];
            final rawMrp = p['displayMrp'] ?? p['mrp'] ?? rawPrice;
            final price = _safeNum(rawPrice);
            final mrp = _safeNum(rawMrp);

            return <String, dynamic>{
              // Spread raw fields first so our safe values below override them
              ...Map<String, dynamic>.from(p),
              'id': int.tryParse((p['id'] ?? '').toString()) ?? 0,
              'product_name': p['title'],
              'product_image': (p['imageUrls'] is List &&
                      (p['imageUrls'] as List).isNotEmpty)
                  ? (p['imageUrls'] as List).first.toString()
                  : (p['image'] ?? ''),
              // Always store as plain num so ProductGridCard never sees a Map
              'price': price,
              'mrp': mrp,
              'displayPrice': price,
              'displayMrp': mrp,
              'imageUrls': p['imageUrls'] ?? [],
              'slug': p['slug'],
              'brand_name': p['brandName'] ??
                  (p['brand'] is Map ? p['brand']['name'] : null) ??
                  '',
              'title': p['title'] ?? '',
              'available': p['available'] ?? true,
              'rating': p['rating'] ?? 0,
              'nudges': p['nudges'],
            };
          })
          .where((p) {
            if (inactiveBrands.isEmpty) return true;
            final brand =
                (p['brand_name'] ?? '').toString().toLowerCase().trim();
            return !inactiveBrands.contains(brand);
          })
          .toList();

      if (loadMore) {
        searchList.addAll(items);
        if (items.isNotEmpty) currentPage.value = page;
      } else {
        searchList.assignAll(items);
        currentPage.value = 1;
      }

      _applyLocalSort();

      if (!loadMore) fetchChipsForSearch();

      searchText.value =
          searchList.isEmpty ? "No product found" : "Search for products";
      hasMore.value = items.length >= 20;
    } on TimeoutException {
      if (thisId != _searchRequestId) return;
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
    } catch (e) {
      if (thisId != _searchRequestId) return;
      print('[BACKEND SEARCH] error: $e');
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
    } finally {
      if (thisId == _searchRequestId) isSearching.value = false;
    }
  }

  /// Algolia search — used for all queries without a discount filter.
  Future<void> _getSearchDataFromAlgolia({bool loadMore = false}) async {
    final key = searchController.text.trim();
    final thisId = ++_searchRequestId;
    isSearching.value = true;

    try {
      await _initAlgolia();
      if (_client == null) throw Exception("Algolia not configured");

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

      final mappedItems = hits
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

      // Client-side discount post-filter removed — discount now routes to
      // _getSearchDataFromBackend which calls /filter-products directly.
      if (loadMore) {
        searchList.addAll(mappedItems);
      } else {
        searchList.assignAll(mappedItems);
      }

      _applyLocalSort();

      // Refresh chips on fresh queries only
      if (!loadMore) {
        fetchChipsForSearch();
      }

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
      print('[ALGOLIA] error: $e');
      if (!loadMore) searchList.clear();
      searchText.value = "No product found";
      hasMore.value = false;
    } finally {
      if (thisId == _searchRequestId) isSearching.value = false;
    }
  }

  // ── Chip methods ────────────────────────────────────────────────────────

  /// Fetches chips from /filter-products using the current search query.
  /// Extracts the most common subCatId from search results to give the
  /// backend enough context to return relevant chips.
  Future<void> fetchChipsForSearch() async {
    final key = searchController.text.trim();
    print('[CHIPS] fetchChipsForSearch called, key="$key"');
    if (key.isEmpty) {
      chips.clear();
      return;
    }

    try {
      final headers = await _headers();
      final params = <String, String>{
        'key': key,
        'status': 'true',
        'page': '1',
        'limit': '1',
      };

      // Extract the most common subCatId / categoryId from current results
      // so the backend has category context to return relevant chips
      final currentItems = searchList.toList();
      if (currentItems.isNotEmpty) {
        final catIdCounts = <int, int>{};
        for (final item in currentItems) {
          // Try various field names Algolia might use
          final rawId = item['subCatId'] ??
              item['sub_cat_id'] ??
              item['categoryId'] ??
              item['category_id'] ??
              item['subcat_id'];
          final id = rawId is int
              ? rawId
              : int.tryParse(rawId?.toString() ?? '');
          if (id != null && id > 0) {
            catIdCounts[id] = (catIdCounts[id] ?? 0) + 1;
          }
        }
        if (catIdCounts.isNotEmpty) {
          final topCatId = catIdCounts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
          params['subCatId'] = topCatId.toString();
          print('[CHIPS] Using subCatId=$topCatId from search results');
        }
      }

      if (filterBrands.isNotEmpty) {
        params['brandIds'] = filterBrands.join(',');
      }
      if (filterColors.isNotEmpty) {
        params['colors'] = filterColors.join(',');
      }
      if (filterSizes.isNotEmpty) {
        params['sizes'] = filterSizes.join(',');
      }
      if (filterMinDiscount.value > 0) {
        params['minDiscount'] = filterMinDiscount.value.toString();
      }
      if (filterMaxDiscount.value < 100) {
        params['maxDiscount'] = filterMaxDiscount.value.toString();
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/filter-products')
          .replace(queryParameters: params);

      print('[CHIPS] Fetching: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('[CHIPS] Response status: ${response.statusCode}');
      print('[CHIPS] Response body (first 500): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      if (response.statusCode == 200 && _isJson(response)) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        final rawChips =
            data is Map ? (data['chips'] as List?) ?? [] : <dynamic>[];
        print('[CHIPS] Raw chips count: ${rawChips.length}');
        final parsed = rawChips
            .whereType<Map<String, dynamic>>()
            .map((c) => FilterChipItem.fromJson(c))
            .toList();
        _lastServerChips = parsed;
        chips.assignAll(parsed);
        print('[CHIPS] Assigned ${parsed.length} chips');
      } else {
        print('[CHIPS] Non-200 or non-JSON response, clearing chips');
        chips.clear();
      }
    } catch (e) {
      print('[CHIPS] fetchChipsForSearch error: $e');
      chips.clear();
    }
  }

  /// Called when the user taps a chip on the search results page.
  /// Resets pagination and re-runs the search with the chip's category context.
  void onSearchChipTap(FilterChipItem chip) {
    if (selectedChipIds.contains(chip.id)) {
      selectedChipIds.remove(chip.id);
      _selectedChipObjects.remove(chip.id);
    } else {
      selectedChipIds.add(chip.id);
      _selectedChipObjects[chip.id] = chip;
    }
    _syncSelectedChips();
    currentPage.value = 0;
    hasMore.value = true;
    searchList.clear();
    ++_searchRequestId;
    getSearchData();
  }

  void _applyLocalSort() {    if (sortOption.value == 'recommended' || searchList.isEmpty) return;

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
