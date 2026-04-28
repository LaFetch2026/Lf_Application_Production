import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';
import 'session_manager.dart';

enum SwipeAction {
  likeProduct,
  dislikeProduct,
  swipeUp,
  swipeDown,
}

class EventTrackingService extends GetxService {
  static EventTrackingService get instance => Get.find();

  final http.Client _client;

  EventTrackingService({http.Client? client}) : _client = client ?? http.Client();

  final _queue = <UserEvent>[];
  final _impressedIds = <int>{};
  Timer? _flushTimer;

  static const _batchSize = 10;
  static const _flushInterval = Duration(seconds: 5);

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  @override
  void onClose() {
    flushNow();
    _flushTimer?.cancel();
    super.onClose();
  }

  void trackView(int productId) {
    _enqueue(UserEvent(
      type: 'view_product',
      productId: productId,
      sessionId: _sessionId(),
    ));
  }

  void trackAddToCart(int productId, int variantId) {
    _enqueue(UserEvent(
      type: 'add_to_cart',
      productId: productId,
      variantId: variantId,
      sessionId: _sessionId(),
    ));
  }

  void trackPurchase(int productId, String orderId) {
    _enqueue(UserEvent(
      type: 'purchase',
      productId: productId,
      orderId: orderId,
      sessionId: _sessionId(),
    ));
  }

  Future<void> trackImpression(int productId, int position) async {
    if (_impressedIds.contains(productId)) return;
    _impressedIds.add(productId);

    try {
      final token = await _token();
      final event = ImpressionEvent(
        productId: productId,
        position: position,
        sessionId: _sessionId(),
      );
      await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/recommendations/batch-track'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'events': [event.toJson()]
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[EventTrackingService] trackImpression error: $e');
    }
  }

  Future<void> trackClick(int productId, int position) async {
    try {
      final token = await _token();
      final event = ClickEvent(
        productId: productId,
        position: position,
        sessionId: _sessionId(),
      );
      await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/recommendations/track'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(event.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[EventTrackingService] trackClick error: $e');
    }
  }

  Future<void> trackSwipe(SwipeAction action, int productId) async {
    const _actionMap = {
      SwipeAction.likeProduct: ('LIKE_PRODUCT', 3),
      SwipeAction.dislikeProduct: ('DISLIKE_PRODUCT', -6),
      SwipeAction.swipeUp: ('SWIPE_UP', 8),
      SwipeAction.swipeDown: ('SWIPE_DOWN', 4),
    };

    final (eventType, weight) = _actionMap[action]!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final token = prefs.getString('token')?.trim() ?? '';

      await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/events/track'),
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
      debugPrint('[EventTrackingService] trackSwipe error: $e');
    }
  }

  Future<void> flushNow() async {
    if (_queue.isEmpty) return;
    final snapshot = List<UserEvent>.from(_queue);
    _queue.clear();

    try {
      final token = await _token();
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/events/batch-track'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'events': snapshot.map((e) => e.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[EventTrackingService] Flushed ${snapshot.length} events');
      } else {
        debugPrint(
            '[EventTrackingService] Flush failed (${response.statusCode}), re-queuing');
        _queue.insertAll(0, snapshot);
      }
    } catch (e) {
      debugPrint('[EventTrackingService] Flush error: $e — re-queuing');
      _queue.insertAll(0, snapshot);
    }
  }

  void _enqueue(UserEvent event) {
    _queue.add(event);
    if (_queue.length >= _batchSize) flushNow();
  }

  void _startTimer() {
    _flushTimer = Timer.periodic(_flushInterval, (_) {
      if (_queue.isNotEmpty) flushNow();
    });
  }

  String _sessionId() {
    try {
      return SessionManager.instance.getSessionId();
    } catch (_) {
      return '';
    }
  }

  Future<String> _token() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') ?? '';
    } catch (_) {
      return '';
    }
  }
}
