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
  Future<List<SwipeProduct>> fetchBatch({int genderFilter = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final token = prefs.getString('token')?.trim() ?? '';

      final params = <String, String>{
        'type': 'swipe',
        'userId': '$userId',
        'limit': '15',
      };
      if (genderFilter == 1) params['gender'] = 'men';
      if (genderFilter == 2) params['gender'] = 'women';

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations')
          .replace(queryParameters: params);

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint(
            '[SwipeFeedService] fetchBatch failed (${response.statusCode})');
        throw Exception(
            'Failed to fetch swipe feed (${response.statusCode})');
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
      } else if (data is List) {
        items = data;
      } else if (decoded['products'] is List) {
        items = decoded['products'] as List;
      }

      if (items == null) {
        debugPrint('[SwipeFeedService] No products array in response');
        return [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(SwipeProduct.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[SwipeFeedService] fetchBatch error: $e');
      rethrow; // let the controller handle the error state
    }
  }
}
