import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/constants.dart';
import '../models/swipe_product.dart';

/// Fetches batches of swipe-feed products from the recommendations API.
/// Registered as a permanent GetX service in main.dart.
class SwipeFeedService extends GetxService {
  static SwipeFeedService get instance => Get.find();

  final http.Client _client;

  SwipeFeedService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches up to 15 unseen products for the swipe feed.
  ///
  /// [genderFilter]: 0 = All, 1 = Men, 2 = Women
  ///
  /// Response shape expected from backend:
  /// `{ success: true, data: { products: [...], ... } }`
  Future<List<SwipeProduct>> fetchBatch({int genderFilter = 0, bool skipSeenFilter = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final token = prefs.getString('token')?.trim() ?? '';

      debugPrint('[SwipeFeedService] fetchBatch — userId=$userId, skipSeenFilter=$skipSeenFilter, token=${token.isNotEmpty ? "present" : "MISSING"}, baseUrl=${ApiConstants.baseUrl}');

      final params = <String, String>{
        'type': 'swipe',
        'limit': '15',
        'skipCache': 'true',
      };
      // Send userId for personalization, but omit it when skipSeenFilter=true
      // so the backend skips the seen-product exclusion (feed reset mode).
      if (userId > 0 && !skipSeenFilter) params['userId'] = '$userId';
      if (genderFilter == 1) params['gender'] = 'men';
      if (genderFilter == 2) params['gender'] = 'women';

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations')
          .replace(queryParameters: params);

      debugPrint('[SwipeFeedService] GET $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[SwipeFeedService] response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[SwipeFeedService] fetchBatch failed (${response.statusCode}): ${response.body}');
        throw Exception('Failed to fetch swipe feed (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      if (decoded == null) {
        debugPrint('[SwipeFeedService] Null response body');
        return [];
      }

      final data = decoded['data'];
      List<dynamic>? items;

      if (data is Map) {
        items = data['products'] as List?;
        items ??= data['items'] as List?;
        items ??= data['data'] as List?;
      } else if (data is List) {
        items = data;
      } else if (decoded['products'] is List) {
        items = decoded['products'] as List;
      }

      debugPrint('[SwipeFeedService] parsed ${items?.length ?? 0} products from response');

      if (items == null || items.isEmpty) {
        debugPrint('[SwipeFeedService] No products in response.');
        return [];
      }

      var parsed = items
          .whereType<Map<String, dynamic>>()
          .map(SwipeProduct.fromJson)
          .toList();

      // Client-side gender filter — backend ignores the gender param,
      // so we filter here. Products with empty gender[] are unisex and
      // always included.
      if (genderFilter == 1) {
        // Men: keep products tagged "men" or untagged (unisex)
        parsed = parsed.where((p) =>
          p.gender.isEmpty || p.gender.any((g) => g == 'men')
        ).toList();
      } else if (genderFilter == 2) {
        // Women: keep products tagged "women" or untagged (unisex)
        parsed = parsed.where((p) =>
          p.gender.isEmpty || p.gender.any((g) => g == 'women')
        ).toList();
      }

      debugPrint('[SwipeFeedService] after gender filter ($genderFilter): ${parsed.length} products');
      return parsed;
    } catch (e, stack) {
      debugPrint('[SwipeFeedService] fetchBatch error: $e');
      debugPrint('[SwipeFeedService] stack: $stack');
      rethrow;
    }
  }
}
