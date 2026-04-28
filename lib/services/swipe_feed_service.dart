import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';

class SwipeFeedService extends GetxService {
  static SwipeFeedService get instance => Get.find();

  final http.Client _client;

  SwipeFeedService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a batch of up to 15 swipe-feed products.
  /// Returns [] on any non-200 response or exception.
  Future<List<RecommendationProduct>> fetchBatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final token = prefs.getString('token')?.trim() ?? '';

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/recommendations?type=swipe&userId=$userId&limit=15',
      );

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[SwipeFeedService] fetchBatch failed (${response.statusCode}): ${response.body}');
        throw Exception('Failed to fetch swipe feed (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      if (decoded == null) {
        debugPrint('[SwipeFeedService] Null response body');
        return [];
      }

      // Response shape: { success: true, data: { products: [...], ... } }
      final data = decoded['data'];
      List<dynamic>? items;

      if (data is Map) {
        // Standard backend shape: data.products
        items = data['products'] as List?;
      } else if (data is List) {
        items = data;
      } else if (decoded['products'] is List) {
        items = decoded['products'] as List;
      }

      if (items == null) {
        debugPrint('[SwipeFeedService] No products array found in response: ${response.body.substring(0, 200)}');
        return [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(RecommendationProduct.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[SwipeFeedService] fetchBatch error: $e');
      return [];
    }
  }
}
