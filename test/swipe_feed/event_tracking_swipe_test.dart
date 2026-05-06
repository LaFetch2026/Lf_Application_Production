// Feature: swipe-feed, Property 9: Swipe action serialization
// Feature: swipe-feed, Property 10: Immediate tracking (no queuing)

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafetch/services/event_tracking_service.dart';
import 'package:lafetch/core/constant/constants.dart';

@GenerateMocks([http.Client])
import 'event_tracking_swipe_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper to build a service with a mock client and preset prefs
  Future<EventTrackingService> makeService(
    MockClient client, {
    int userId = 123,
    String token = 'test-token-abc',
  }) async {
    SharedPreferences.setMockInitialValues({
      'userId': userId,
      'token': token,
    });
    return EventTrackingService(client: client);
  }

  // Stub the mock to return 200 by default
  void stubSuccess(MockClient client) {
    when(client.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('{}', 200));
  }

  group('Property 9: Swipe action serialization', () {
    // Validates: Requirements 9.2, 10.1, 10.2, 10.3, 10.4
    //
    // For any SwipeAction value and productId, trackSwipe SHALL construct a
    // POST body containing the correct eventType string and weight integer.

    test('likeProduct → LIKE_PRODUCT with weight 3', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      await service.trackSwipe(SwipeAction.likeProduct, 456);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final body = jsonDecode(captured[2] as String) as Map<String, dynamic>;
      expect(body['eventType'], equals('LIKE_PRODUCT'));
      expect(body['weight'], equals(3));
      expect(body['userId'], equals(123));
      expect(body['productId'], equals(456));
    });

    test('dislikeProduct → DISLIKE_PRODUCT with weight -6', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      await service.trackSwipe(SwipeAction.dislikeProduct, 789);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final body = jsonDecode(captured[2] as String) as Map<String, dynamic>;
      expect(body['eventType'], equals('DISLIKE_PRODUCT'));
      expect(body['weight'], equals(-6));
      expect(body['userId'], equals(123));
      expect(body['productId'], equals(789));
    });

    test('swipeUp → SWIPE_UP with weight 8', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      await service.trackSwipe(SwipeAction.swipeUp, 111);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final body = jsonDecode(captured[2] as String) as Map<String, dynamic>;
      expect(body['eventType'], equals('SWIPE_UP'));
      expect(body['weight'], equals(8));
      expect(body['userId'], equals(123));
      expect(body['productId'], equals(111));
    });

    test('swipeDown → SWIPE_DOWN with weight 4', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      await service.trackSwipe(SwipeAction.swipeDown, 222);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final body = jsonDecode(captured[2] as String) as Map<String, dynamic>;
      expect(body['eventType'], equals('SWIPE_DOWN'));
      expect(body['weight'], equals(4));
      expect(body['userId'], equals(123));
      expect(body['productId'], equals(222));
    });

    test('includes Authorization header when token is non-empty', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client, token: 'my-bearer-token');

      await service.trackSwipe(SwipeAction.likeProduct, 999);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final headers = captured[1] as Map<String, String>;
      expect(headers['Authorization'], equals('Bearer my-bearer-token'));
    });

    test('omits Authorization header when token is empty', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client, token: '');

      await service.trackSwipe(SwipeAction.likeProduct, 999);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final headers = captured[1] as Map<String, String>;
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('posts to correct endpoint', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      await service.trackSwipe(SwipeAction.likeProduct, 123);

      final captured = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      final uri = captured[0] as Uri;
      expect(uri.toString(), equals('${ApiConstants.baseUrl}/events/track'));
    });

    test('property: all four actions map to correct eventType and weight', () async {
      // Validates: Requirements 10.1, 10.2, 10.3, 10.4
      // Runs all four enum values to verify the full mapping table
      const mapping = {
        SwipeAction.likeProduct: ('LIKE_PRODUCT', 3),
        SwipeAction.dislikeProduct: ('DISLIKE_PRODUCT', -6),
        SwipeAction.swipeUp: ('SWIPE_UP', 8),
        SwipeAction.swipeDown: ('SWIPE_DOWN', 4),
      };

      for (final entry in mapping.entries) {
        final action = entry.key;
        final (expectedType, expectedWeight) = entry.value;

        final client = MockClient();
        stubSuccess(client);
        final service = await makeService(client);

        await service.trackSwipe(action, 1);

        final captured = verify(client.post(
          captureAny,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        )).captured;

        final body = jsonDecode(captured[2] as String) as Map<String, dynamic>;
        expect(body['eventType'], equals(expectedType),
            reason: 'action=$action should map to eventType=$expectedType');
        expect(body['weight'], equals(expectedWeight),
            reason: 'action=$action should map to weight=$expectedWeight');
      }
    });
  });

  group('Property 10: Immediate tracking (no queuing)', () {
    // Validates: Requirements 9.1
    //
    // For any swipe action, trackSwipe SHALL fire exactly one HTTP POST
    // immediately and SHALL NOT add the event to the existing _queue.

    test('trackSwipe fires exactly one POST immediately', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      await service.trackSwipe(SwipeAction.likeProduct, 456);

      verify(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('trackSwipe does not trigger a batch flush (queue stays empty)', () async {
      final client = MockClient();
      stubSuccess(client);
      final service = await makeService(client);

      // trackSwipe should fire its own POST — not go through the queue
      await service.trackSwipe(SwipeAction.likeProduct, 200);

      // Only one POST should have been made (the immediate trackSwipe call)
      // If it had used the queue, flushNow would have fired a batch-track POST
      final calls = verify(client.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;

      // The single POST should be to /events/track, not /events/batch-track
      final uri = calls[0] as Uri;
      expect(uri.path, endsWith('/events/track'));
      expect(uri.path, isNot(endsWith('/events/batch-track')));
    });

    test('trackSwipe logs error on failure without retrying', () async {
      final client = MockClient();
      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      final service = await makeService(client);

      // Should not throw — fire-and-forget with error logging
      await expectLater(
        service.trackSwipe(SwipeAction.likeProduct, 456),
        completes,
      );

      // Verify it was called exactly once (no retry)
      verify(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('property: trackSwipe always fires exactly one POST for any action and productId', () async {
      // Validates: Requirements 9.1
      // Simulates property testing by iterating over all actions and several productIds
      final actions = SwipeAction.values;
      final productIds = [0, 1, 42, 999, 1000000];

      for (final action in actions) {
        for (final productId in productIds) {
          final client = MockClient();
          stubSuccess(client);
          final service = await makeService(client);

          await service.trackSwipe(action, productId);

          verify(client.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).called(1);
        }
      }
    });
  });
}
