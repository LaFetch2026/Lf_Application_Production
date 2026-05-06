import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';
import 'session_manager.dart';

class _CacheEntry {
  final List<RecommendationProduct> products;
  final DateTime createdAt;
  _CacheEntry(this.products) : createdAt = DateTime.now();
}

class RecommendationService extends GetxService {
  static RecommendationService get instance => Get.find();

  final _cache = <dynamic, _CacheEntry>{};
  static const _maxEntries = 50;
  static const _ttl = Duration(minutes: 5);

  /// Fetch trending products. Returns [] on any error.
  Future<List<RecommendationProduct>> fetchTrending({int limit = 12, String? gender}) async {
    final cacheKey = gender != null ? 'trending_$gender' : 'trending_all';
    final cached = _getCached(cacheKey);
    if (cached != null) return cached;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('userId');
      final sessionId = SessionManager.instance.getSessionId();

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations')
          .replace(queryParameters: {
        'type': 'trending',
        'limit': limit.toString(),
        'sessionId': sessionId,
        if (userId != null) 'userId': userId.toString(),
        if (gender != null) 'gender': gender,
      });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == false) return [];
        final rawList = body is Map
            ? (body['data'] is Map ? body['data']['products'] : body['data'])
            : body;
        if (rawList is! List) return [];
        final products = rawList.whereType<Map<String, dynamic>>().map((item) {
          if (rawList.indexOf(item) == 0) {
            debugPrint('[TrendingService] First item keys: ${item.keys.toList()}');
            debugPrint('[TrendingService] First item: $item');
          }
          return RecommendationProduct.fromJson(item);
        }).toList();
        debugPrint('[TrendingService] gender=$gender → ${products.length} products, categories: ${products.map((p) => p.category).toSet()}');
        _putCache(cacheKey, products);
        return products;
      }
      return [];
    } catch (e) {
      debugPrint('[RecommendationService] Error fetching trending: $e');
      return [];
    }
  }

  /// Fetch trending products grouped by subcategory.
  /// Endpoint: /trending-products?category=men|women|accessories
  /// Returns data.tabs + data.productsByCategory keyed by subCatId string.
  Future<Map<String, dynamic>> fetchTrendingByCategory(String gender) async {
    final cacheKey = 'trending_by_cat_$gender';
    final entry = _cache[cacheKey];
    if (entry != null && DateTime.now().difference(entry.createdAt) < _ttl) {
      return entry.products.first as dynamic;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('${ApiConstants.baseUrl}/trending-products')
          .replace(queryParameters: {'category': gender});

      debugPrint('[TrendingService] GET $uri');

      final response = await http.get(uri, headers: {
        'Accept': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      debugPrint('[TrendingService] status=${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == false) return _emptyTrendingResult();
        final data = body is Map ? (body['data'] ?? {}) : {};
        return data is Map ? Map<String, dynamic>.from(data as Map) : _emptyTrendingResult();
      }
      debugPrint('[TrendingService] error body: ${response.body.substring(0, response.body.length.clamp(0, 200))}');
      return _emptyTrendingResult();
    } catch (e) {
      debugPrint('[TrendingService] fetchTrendingByCategory error: $e');
      return _emptyTrendingResult();
    }
  }

  Map<String, dynamic> _emptyTrendingResult() => {'tabs': [], 'productsByCategory': {}};


  Future<List<RecommendationProduct>> fetchSimilar(int productId) async {
    final cached = _getCached(productId);
    if (cached != null) return cached;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('userId');
      final sessionId = SessionManager.instance.getSessionId();

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations')
          .replace(queryParameters: {
        'type': 'similar',
        'limit': '12',
        'productId': productId.toString(),
        'sessionId': sessionId,
        if (userId != null) 'userId': userId.toString(),
      });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Check for backend-level error even on 200
        if (body is Map && body['success'] == false) {
          debugPrint(
              '[RecommendationService] Backend error: ${body['message']}');
          return [];
        }

        final rawList = body is Map
            ? (body['data'] is Map ? body['data']['products'] : body['data'])
            : body;

        debugPrint(
            '[RecommendationService] Raw response: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

        if (rawList is! List) {
          debugPrint(
              '[RecommendationService] Unexpected data shape: ${rawList.runtimeType}');
          return [];
        }

        final products = rawList.whereType<Map<String, dynamic>>().map((item) {
          // Log first item fully to see all available fields
          if (rawList.indexOf(item) == 0) {
            debugPrint('[RecommendationService] First item keys: ${item.keys.toList()}');
            debugPrint('[RecommendationService] First item: $item');
          }
          final p = RecommendationProduct.fromJson(item);
          debugPrint(
              '[RecommendationService] Parsed: id=${p.id} slug=${p.slug} name=${p.productName}');
          return p;
        }).toList();

        _putCache(productId, products);
        debugPrint(
            '[RecommendationService] Fetched ${products.length} similar products for $productId');
        return products;
      } else {
        debugPrint(
            '[RecommendationService] Non-200 (${response.statusCode}) for product $productId');
        return [];
      }
    } catch (e) {
      debugPrint('[RecommendationService] Error fetching similar products: $e');
      return [];
    }
  }

  List<RecommendationProduct>? _getCached(dynamic key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.createdAt) >= _ttl) {
      _cache.remove(key);
      return null;
    }
    return entry.products;
  }

  void _putCache(dynamic key, List<RecommendationProduct> products) {
    if (_cache.length >= _maxEntries) _evictOldest();
    _cache[key] = _CacheEntry(products);
  }

  void _evictOldest() {
    if (_cache.isEmpty) return;
    final oldest = _cache.entries.reduce(
        (a, b) => a.value.createdAt.isBefore(b.value.createdAt) ? a : b);
    _cache.remove(oldest.key);
  }
}
