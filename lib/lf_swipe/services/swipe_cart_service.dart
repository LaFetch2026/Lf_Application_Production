import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/constants.dart';

// ── Variant model (used by size sheet) ───────────────────────────────────────

/// A single product variant returned by POST /swipe/action SELECT_VARIANT.
class SwipeVariant {
  final int id;
  final String size;
  final String color;
  final int stock; // always > 0 when returned by the new API
  final double? price;

  const SwipeVariant({
    required this.id,
    required this.size,
    required this.color,
    required this.stock,
    this.price,
  });

  bool get inStock => stock > 0;

  /// Parses a variant from the new /swipe/action SELECT_VARIANT response.
  /// Shape: { id, title, price, selectedOptions: [{name, value}], imageSrc }
  factory SwipeVariant.fromJson(Map<String, dynamic> json) {
    String size = '';
    String color = '';

    final opts = json['selectedOptions'];
    if (opts is List) {
      for (final opt in opts) {
        if (opt is Map) {
          final name = (opt['name'] ?? '').toString().toLowerCase();
          final value = (opt['value'] ?? '').toString();
          if (name == 'size') size = value;
          if (name == 'color' || name == 'colour') color = value;
        }
      }
    }

    // title fallback for size (e.g. "M", "L")
    if (size.isEmpty && json['title'] is String) {
      size = json['title'] as String;
    }

    final rawPrice = json['price'];
    final price = rawPrice is num ? rawPrice.toDouble() : null;

    return SwipeVariant(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      size: size,
      color: color,
      stock: 1, // new API only returns in-stock variants
      price: price,
    );
  }
}

// ── Result of POST /swipe/action ─────────────────────────────────────────────

class SwipeActionResult {
  final bool success;
  final bool needsVariantPick;
  final int? productId;
  final Map<String, List<String>>? options;
  final List<SwipeVariant>? variants;
  final int? cartItemId;

  const SwipeActionResult({
    required this.success,
    this.needsVariantPick = false,
    this.productId,
    this.options,
    this.variants,
    this.cartItemId,
  });

  factory SwipeActionResult.fromJson(Map<String, dynamic> data) {
    final needsPick = data['action'] == 'SELECT_VARIANT';
    return SwipeActionResult(
      success: !needsPick && (data['success'] as bool? ?? false),
      needsVariantPick: needsPick,
      productId: data['productId'] as int?,
      options: needsPick
          ? (data['options'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, List<String>.from(v as List)),
            )
          : null,
      variants: needsPick
          ? (data['variants'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(SwipeVariant.fromJson)
              .toList()
          : null,
      cartItemId: data['cartItemId'] as int?,
    );
  }
}

// ── SwipeCartService ──────────────────────────────────────────────────────────

/// Handles swipe action API calls:
///   POST /swipe/action        — record a swipe (may return SELECT_VARIANT)
///   POST /swipe/action/confirm — confirm a variant after size picker
///   POST /swipe/undo          — undo the last action
class SwipeCartService {
  SwipeCartService._();

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim() ?? '';
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// POST /swipe/action
  /// action values: ADD_TO_WISHLIST | ADD_TO_CART | REJECT_PRODUCT | OPEN_PDP
  static Future<SwipeActionResult> swipeAction({
    required int productId,
    required String action,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/swipe/action'),
            headers: headers,
            body: jsonEncode({'productId': productId, 'action': action}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        debugPrint('[SwipeCartService] swipeAction ${response.statusCode}: ${response.body}');
        return const SwipeActionResult(success: false);
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return const SwipeActionResult(success: false);
      return SwipeActionResult.fromJson(data);
    } catch (e) {
      debugPrint('[SwipeCartService] swipeAction error: $e');
      return const SwipeActionResult(success: false);
    }
  }

  /// POST /swipe/action/confirm
  /// Called after the user picks a variant from the size sheet.
  static Future<bool> confirmVariant({
    required int productId,
    required int variantId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/swipe/action/confirm'),
            headers: headers,
            body: jsonEncode({'productId': productId, 'variantId': variantId}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        debugPrint('[SwipeCartService] confirmVariant ${response.statusCode}');
        return false;
      }

      final data = body['data'] as Map<String, dynamic>?;
      return data?['success'] == true;
    } catch (e) {
      debugPrint('[SwipeCartService] confirmVariant error: $e');
      return false;
    }
  }

  /// POST /swipe/undo
  /// Returns the reversed action string (e.g. "ADD_TO_CART") or null.
  static Future<String?> undoLastSwipe() async {
    try {
      final headers = await _headers();
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/swipe/undo'),
            headers: headers,
            body: '{}',
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) return null;

      final data = body['data'] as Map<String, dynamic>?;
      if (data?['success'] == true) {
        return data?['reversed'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('[SwipeCartService] undoLastSwipe error: $e');
      return null;
    }
  }

  // ── Legacy compat: kept so swipe_size_sheet.dart can call fetchVariants ──
  // The new flow doesn't need this — variants come from SELECT_VARIANT response.
  // Kept as a no-op stub to avoid breaking the size sheet during transition.
  static Future<List<SwipeVariant>> fetchVariants(int productId) async => [];
}
