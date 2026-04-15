// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/core/constant/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_controller.dart';

class NewInController extends BaseController {
  // ─── State ───────────────────────────────────────────────────────────────
  // Start as true so the shimmer shows immediately on first render —
  // prevents the section from appearing empty before fetchProducts is called.
  RxBool isLoading = true.obs;

  /// Full fetched list (private — never mutated by sort)
  final RxList<Map<String, dynamic>> _allProducts =
      <Map<String, dynamic>>[].obs;

  /// Sorted + displayed list (public)
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  RxString sortMode = 'default'.obs;
  RxInt currentPage = 0.obs;

  static const int pageSize = 8;

  /// Prevents concurrent duplicate requests
  bool _isFetchInProgress = false;

  /// Per-gender in-memory cache — avoids repeat API calls on tab switch
  final Map<int, List<Map<String, dynamic>>> _genderCache = {};

  // ─── API ─────────────────────────────────────────────────────────────────

  Future<void> fetchProducts(int gender, {bool forceRefresh = false}) async {
    // Deduplication guard
    if (_isFetchInProgress) return;

    // Serve from cache when available and not forcing a refresh
    if (!forceRefresh && _genderCache.containsKey(gender)) {
      _allProducts.assignAll(_genderCache[gender]!);
      _applySort();
      currentPage.value = 0;
      isLoading.value = false; // ensure shimmer clears on cache hit
      return;
    }

    _isFetchInProgress = true;
    _allProducts.clear();
    products.clear();
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = (prefs.getString('token') ?? '').trim();

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/products?status=1&gender=$gender&page=1',
      );

      print('📤 NewInController → GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      print('📥 NewInController status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> raw =
            (decoded['data']?['products'] as List?) ?? const [];

        final parsed = raw.whereType<Map<String, dynamic>>().toList();

        _allProducts.assignAll(parsed);
        _genderCache[gender] = List<Map<String, dynamic>>.from(parsed);

        _applySort();
        currentPage.value = 0;

        print(
            '✅ NewInController loaded ${parsed.length} products for gender $gender');
      } else {
        print('❌ NewInController non-200: ${response.statusCode}');
        _allProducts.clear();
        products.clear();
      }
    } catch (e, st) {
      print('❌ NewInController error: $e\n$st');
      _allProducts.clear();
      products.clear();
    } finally {
      isLoading.value = false;
      _isFetchInProgress = false;
    }
  }

  // ─── Sorting ─────────────────────────────────────────────────────────────

  /// Internal — sorts a copy of `_allProducts` and assigns to `products`.
  /// Uses the current `sortMode` value.
  void _applySort() {
    final copy = List<Map<String, dynamic>>.from(_allProducts);

    switch (sortMode.value) {
      case 'low_to_high':
        copy.sort(
          (a, b) =>
              ((a['mrp'] as num?) ?? 0).compareTo((b['mrp'] as num?) ?? 0),
        );
        break;

      case 'high_to_low':
        copy.sort(
          (a, b) =>
              ((b['mrp'] as num?) ?? 0).compareTo((a['mrp'] as num?) ?? 0),
        );
        break;

      case 'discount':
        copy.sort((a, b) {
          final aMrp = (a['mrp'] as num?)?.toDouble() ?? 0.0;
          final aPrice =
              ((a['basePrice'] ?? a['mrp']) as num?)?.toDouble() ?? aMrp;
          final aDiscount = aMrp > 0 ? (aMrp - aPrice) / aMrp : 0.0;

          final bMrp = (b['mrp'] as num?)?.toDouble() ?? 0.0;
          final bPrice =
              ((b['basePrice'] ?? b['mrp']) as num?)?.toDouble() ?? bMrp;
          final bDiscount = bMrp > 0 ? (bMrp - bPrice) / bMrp : 0.0;

          return bDiscount.compareTo(aDiscount); // descending
        });
        break;

      default: // 'default' — preserve original API order
        break;
    }

    products.assignAll(copy);
    currentPage.value = 0;
  }

  /// Public — update sort mode and re-sort.
  void applySort(String mode) {
    sortMode.value = mode;
    _applySort();
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

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  // ─── Cache ────────────────────────────────────────────────────────────────

  void clearCache() => _genderCache.clear();
}
