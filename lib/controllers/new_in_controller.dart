// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/core/constant/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_controller.dart';

class NewInController extends BaseController {
  // ─── State ────────────────────────────────────────────────────────────────

  /// True only on the very first load (shows full shimmer).
  RxBool isLoading = true.obs;

  /// True when fetching the next server page (shows a subtle bottom spinner).
  RxBool isLoadingMore = false.obs;

  /// True when the server has no further pages to give us.
  RxBool hasReachedEnd = false.obs;

  /// Full accumulated list — never mutated by sort.
  final RxList<Map<String, dynamic>> _allProducts =
      <Map<String, dynamic>>[].obs;

  /// Sorted + displayed list (public).
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  RxString sortMode = 'default'.obs;
  RxInt currentPage = 0.obs;

  static const int pageSize = 4;

  // ─── Internal tracking ────────────────────────────────────────────────────

  bool _isFetchInProgress = false;
  int _currentGender = -1;

  /// The last server page we successfully received results for.
  int _lastServerPage = 0;

  // ─── Per-gender cache ─────────────────────────────────────────────────────
  // Structure: { gender: { serverPage: [products] } }
  // Lets us restore all previously fetched pages on a tab-switch without
  // hitting the network again.

  final Map<int, Map<int, List<Map<String, dynamic>>>> _cache = {};

  /// Whether we already know a gender has no more pages.
  final Map<int, bool> _genderReachedEnd = {};

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Call this when the gender tab changes (or on screen init).
  Future<void> fetchProducts(int gender, {bool forceRefresh = false}) async {
    if (_isFetchInProgress) return;

    // ── Force refresh: wipe this gender's cache and restart ──
    if (forceRefresh) {
      _cache.remove(gender);
      _genderReachedEnd.remove(gender);
    }

    // ── Same gender, already have data, nothing to do ──
    if (!forceRefresh && _currentGender == gender && _allProducts.isNotEmpty) {
      return;
    }

    // ── Gender switch: restore from cache if available ──
    if (!forceRefresh &&
        _currentGender != gender &&
        (_cache[gender]?.isNotEmpty ?? false)) {
      _currentGender = gender;
      _restoreFromCache(gender);
      isLoading.value = false;
      return;
    }

    // ── Fresh fetch ──
    _currentGender = gender;
    _lastServerPage = 0;
    hasReachedEnd.value = _genderReachedEnd[gender] ?? false;
    _allProducts.clear();
    products.clear();
    currentPage.value = 0;

    _isFetchInProgress = true;
    isLoading.value = true;

    await _fetchServerPage(gender, page: 1);

    isLoading.value = false;
    _isFetchInProgress = false;
  }

  // ─── Pagination ───────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get pagedProducts {
    final start = currentPage.value * pageSize;
    final end = (start + pageSize).clamp(0, products.length);
    if (start >= products.length) return [];
    return products.sublist(start, end);
  }

  int get totalPages =>
      products.isEmpty ? 0 : (products.length / pageSize).ceil();

  bool get _isOnLastLocalPage => currentPage.value >= totalPages - 1;

  /// Move forward one client page; fetches the next server page on demand
  /// when the user reaches the end of locally available data.
  Future<void> nextPage() async {
    if (!_isOnLastLocalPage) {
      // Still have local pages — no network call needed.
      currentPage.value++;
      return;
    }

    // On the last local page — try fetching the next server page.
    if (hasReachedEnd.value || _isFetchInProgress) return;

    _isFetchInProgress = true;
    isLoadingMore.value = true;

    final nextServerPage = _lastServerPage + 1;
    await _fetchServerPage(_currentGender, page: nextServerPage);

    isLoadingMore.value = false;
    _isFetchInProgress = false;

    // Advance only if new products were actually appended.
    if (!_isOnLastLocalPage) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 0) currentPage.value--;
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) currentPage.value = page;
  }

  // ─── Sorting ──────────────────────────────────────────────────────────────

  void applySort(String mode) {
    sortMode.value = mode;
    _applySort();
  }

  // ─── Cache ────────────────────────────────────────────────────────────────

  void clearCache() {
    _cache.clear();
    _genderReachedEnd.clear();
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Fetches a single server page and appends results to [_allProducts].
  Future<void> _fetchServerPage(int gender, {required int page}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = (prefs.getString('token') ?? '').trim();

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/products?status=1&gender=$gender&page=$page',
      );

      print('📤 NewInController → GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 NewInController status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> raw =
            (decoded['data']?['products'] as List?) ?? const [];
        final parsed = raw.whereType<Map<String, dynamic>>().toList();

        if (parsed.isEmpty) {
          // Server returned nothing — we've reached the end.
          hasReachedEnd.value = true;
          _genderReachedEnd[gender] = true;
          print('⚠️  NewInController: no more products at page $page');
        } else {
          // Cache and append.
          _cache.putIfAbsent(gender, () => {});
          _cache[gender]![page] =
              List<Map<String, dynamic>>.unmodifiable(parsed);

          _lastServerPage = page;
          _allProducts.addAll(parsed);
          _applySort();

          print(
            '✅ NewInController: +${parsed.length} products '
            '(gender=$gender, serverPage=$page, total=${_allProducts.length})',
          );
        }
      } else {
        print('❌ NewInController non-200: ${response.statusCode}');
        hasReachedEnd.value = true; // stop hammering on errors
      }
    } on TimeoutException {
      print('❌ NewInController: request timed out (page=$page)');
      hasReachedEnd.value = true;
    } catch (e, st) {
      print('❌ NewInController error: $e\n$st');
      hasReachedEnd.value = true;
    }
  }

  /// Rebuilds [_allProducts] + [products] from the cache for [gender].
  void _restoreFromCache(int gender) {
    final pages = _cache[gender] ?? {};
    final sortedPageNumbers = pages.keys.toList()..sort();

    _allProducts.clear();
    for (final pageNum in sortedPageNumbers) {
      _allProducts.addAll(pages[pageNum]!);
    }

    _lastServerPage = sortedPageNumbers.isNotEmpty ? sortedPageNumbers.last : 0;
    hasReachedEnd.value = _genderReachedEnd[gender] ?? false;

    _applySort();
    currentPage.value = 0;

    print(
      '🗄️  NewInController: restored ${_allProducts.length} products '
      'from cache (gender=$gender, pages=${sortedPageNumbers.length})',
    );
  }

  /// Sorts a copy of [_allProducts] and assigns to [products].
  void _applySort() {
    final copy = List<Map<String, dynamic>>.from(_allProducts);

    switch (sortMode.value) {
      case 'low_to_high':
        copy.sort(
          (a, b) =>
              ((a['mrp'] as num?) ?? 0).compareTo((b['mrp'] as num?) ?? 0),
        );

      case 'high_to_low':
        copy.sort(
          (a, b) =>
              ((b['mrp'] as num?) ?? 0).compareTo((a['mrp'] as num?) ?? 0),
        );

      case 'discount':
        copy.sort((a, b) {
          double discount(Map<String, dynamic> p) {
            final mrp = (p['mrp'] as num?)?.toDouble() ?? 0.0;
            final price =
                ((p['basePrice'] ?? p['mrp']) as num?)?.toDouble() ?? mrp;
            return mrp > 0 ? (mrp - price) / mrp : 0.0;
          }

          return discount(b).compareTo(discount(a)); // descending
        });

      default: // 'default' — preserve original API order
        break;
    }

    products.assignAll(copy);
    // Don't reset currentPage here — callers manage it.
  }
}
