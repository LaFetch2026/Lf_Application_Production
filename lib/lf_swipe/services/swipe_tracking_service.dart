import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constant/constants.dart';

/// The four swipe directions and their semantic meaning.
enum SwipeAction {
  likeProduct,
  dislikeProduct,
  swipeUp,
  swipeDown,
}

/// Fires immediate (non-queued) swipe tracking events to the backend.
///
/// Swipe events must land before the next fetchBatch call so the backend
/// can invalidate the preference cache and return updated recommendations.
/// They are therefore never batched — each swipe fires its own POST.
class SwipeTrackingService {
  SwipeTrackingService._();

  static const _endpoint = '${ApiConstants.baseUrl}/events/track';

  static const _actionMap = {
    SwipeAction.likeProduct: ('LIKE_PRODUCT', 3),
    SwipeAction.dislikeProduct: ('DISLIKE_PRODUCT', -6),
    SwipeAction.swipeUp: ('SWIPE_UP', 8),
    SwipeAction.swipeDown: ('SWIPE_DOWN', 4),
  };

  /// Fires a single swipe event immediately. Fire-and-forget — errors are
  /// logged but never rethrown so they never block the swipe UI.
  static Future<void> track(SwipeAction action, int productId) async {
    final (eventType, weight) = _actionMap[action]!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final token = prefs.getString('token')?.trim() ?? '';

      await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'userId': userId,
              'productId': productId,
              'eventType': eventType,
              'weight': weight,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[SwipeTrackingService] track error: $e');
    }
  }
}
