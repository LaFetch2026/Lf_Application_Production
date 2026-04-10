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

  final _cache = <int, _CacheEntry>{};
  static const _maxEntries = 50;
  static const _ttl = Duration(minutes: 5);

  /// Fetch similar products for [productId]. Returns [] on any error.
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

  List<RecommendationProduct>? _getCached(int productId) {
    final entry = _cache[productId];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.createdAt) >= _ttl) {
      _cache.remove(productId);
      return null;
    }
    return entry.products;
  }

  void _putCache(int productId, List<RecommendationProduct> products) {
    if (_cache.length >= _maxEntries) _evictOldest();
    _cache[productId] = _CacheEntry(products);
  }

  void _evictOldest() {
    if (_cache.isEmpty) return;
    final oldest = _cache.entries.reduce(
        (a, b) => a.value.createdAt.isBefore(b.value.createdAt) ? a : b);
    _cache.remove(oldest.key);
  }
}
