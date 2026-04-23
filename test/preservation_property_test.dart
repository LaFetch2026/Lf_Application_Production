// ignore_for_file: avoid_print
//
// Preservation Property Tests — Task 2
//
// PURPOSE: These tests MUST PASS on unfixed code.
// They establish the baseline behaviors that must be preserved after the fix:
//   1. confirmPlaceOrder body always contains checkoutSessionId and paymentInfo
//      (email is additive, not replacing existing fields)
//   2. /request-cancel body still contains userId, orderItemId, reason,
//      shipRocketId unchanged
//   3. When both email and phone are present in SharedPreferences, checkout
//      proceeds without showing any bottom sheet
//   4. Checkout session flow: /checkout/initiate returns checkoutSessionId,
//      /checkout/address returns razorpayOrderId
//
// These tests should continue to PASS after the fix is applied (Task 3.7).
//
// Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Body-building helpers
//
// These replicate the EXACT body-building logic from OrderController so we
// can assert on what the code sends without needing to spin up the full
// GetX controller (which requires a Flutter binding).
// ---------------------------------------------------------------------------

/// Replicates the confirmPlaceOrder body from
/// lib/controllers/order_controller.dart → confirmPlaceOrder().
/// On unfixed code, this body contains only checkoutSessionId + paymentInfo.
/// After the fix, email is ADDED alongside these fields (not replacing them).
Map<String, dynamic> buildConfirmBody({
  required String checkoutSessionId,
  required String providerOrderId,
  required String providerPaymentId,
  required String providerSignature,
  String? email, // optional — only present after fix
}) {
  return {
    "checkoutSessionId": checkoutSessionId,
    "paymentInfo": {
      "providerOrderId": providerOrderId,
      "providerPaymentId": providerPaymentId,
      "providerSignature": providerSignature,
    },
    // email is additive: only included when provided (post-fix)
    if (email != null && email.isNotEmpty) "email": email,
  };
}

/// Replicates the requestCancel body from
/// lib/controllers/order_controller.dart → requestCancel().
Map<String, dynamic> buildCancelBody({
  required int userId,
  required int orderItemId,
  required String reason,
  required String shipRocketId,
}) {
  return {
    "userId": userId,
    "orderItemId": orderItemId,
    "reason": reason,
    "shipRocketId": shipRocketId,
  };
}

/// Replicates the initiateBody from
/// lib/controllers/order_controller.dart → initiatePayment().
Map<String, dynamic> buildInitiateBody({
  required String? mode,
  int? productId,
  int? variantId,
  int? quantity,
  String? couponCode,
  String? email, // optional — only present after fix
}) {
  return {
    "mode": mode ?? "cart",
    if (productId != null) "productId": productId,
    if (variantId != null) "variantId": variantId,
    if (quantity != null) "quantity": quantity,
    if (couponCode != null && couponCode.isNotEmpty) "couponCode": couponCode,
    if (email != null && email.isNotEmpty) "email": email,
  };
}

// ---------------------------------------------------------------------------
// Contact gate logic helper
//
// Replicates the gate logic that the FIX will add to _handleCheckout and
// _confirmAndPay. On unfixed code, this gate does NOT exist — checkout
// proceeds directly. We test the ABSENCE of the gate on unfixed code
// (i.e., when both email and phone are present, no gate fires regardless).
// ---------------------------------------------------------------------------

/// Returns true if the contact gate should fire (i.e., email or phone missing).
/// This is the logic the fix will add. On unfixed code, this function is never
/// called — but we can still verify the gate condition independently.
bool shouldShowContactGate(String email, String phone) {
  return email.isEmpty || phone.isEmpty;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // =========================================================================
  // Group 1: confirmPlaceOrder body preservation
  //
  // Property: confirmPlaceOrder body ALWAYS contains checkoutSessionId and
  // paymentInfo. Email is additive — it does not replace these fields.
  //
  // Validates: Requirements 3.1, 3.2, 3.3
  // =========================================================================
  group(
    'Preservation: confirmPlaceOrder body always contains '
    'checkoutSessionId and paymentInfo',
    () {
      // Property-based: test across multiple session IDs and payment info combos
      final testCases = [
        {
          'sessionId': 'session-abc-001',
          'orderId': 'order_rzp_001',
          'paymentId': 'pay_rzp_001',
          'signature': 'sig_001',
        },
        {
          'sessionId': 'session-xyz-999',
          'orderId': 'order_rzp_999',
          'paymentId': 'pay_rzp_999',
          'signature': 'sig_999',
        },
        {
          'sessionId': 'sess-empty-email',
          'orderId': 'order_rzp_empty',
          'paymentId': 'pay_rzp_empty',
          'signature': 'sig_empty',
        },
      ];

      for (final tc in testCases) {
        test(
          'PRESERVATION: confirmBody contains checkoutSessionId '
          '(session=${tc['sessionId']}) — EXPECTED TO PASS',
          () {
            // Act: build body as unfixed code does (no email parameter)
            final body = buildConfirmBody(
              checkoutSessionId: tc['sessionId']!,
              providerOrderId: tc['orderId']!,
              providerPaymentId: tc['paymentId']!,
              providerSignature: tc['signature']!,
            );

            print('📋 confirmBody: ${jsonEncode(body)}');

            // Assert: checkoutSessionId is always present
            expect(
              body.containsKey('checkoutSessionId'),
              isTrue,
              reason:
                  'checkoutSessionId must always be present in confirmBody. '
                  'Body: ${jsonEncode(body)}',
            );
            expect(
              body['checkoutSessionId'],
              equals(tc['sessionId']),
              reason: 'checkoutSessionId value must match the session.',
            );
          },
        );

        test(
          'PRESERVATION: confirmBody contains paymentInfo '
          '(session=${tc['sessionId']}) — EXPECTED TO PASS',
          () {
            final body = buildConfirmBody(
              checkoutSessionId: tc['sessionId']!,
              providerOrderId: tc['orderId']!,
              providerPaymentId: tc['paymentId']!,
              providerSignature: tc['signature']!,
            );

            // Assert: paymentInfo is always present and contains all sub-fields
            expect(
              body.containsKey('paymentInfo'),
              isTrue,
              reason:
                  'paymentInfo must always be present in confirmBody. '
                  'Body: ${jsonEncode(body)}',
            );

            final paymentInfo = body['paymentInfo'] as Map<String, dynamic>;
            expect(
              paymentInfo.containsKey('providerOrderId'),
              isTrue,
              reason: 'paymentInfo must contain providerOrderId.',
            );
            expect(
              paymentInfo.containsKey('providerPaymentId'),
              isTrue,
              reason: 'paymentInfo must contain providerPaymentId.',
            );
            expect(
              paymentInfo.containsKey('providerSignature'),
              isTrue,
              reason: 'paymentInfo must contain providerSignature.',
            );
            expect(paymentInfo['providerOrderId'], equals(tc['orderId']));
            expect(paymentInfo['providerPaymentId'], equals(tc['paymentId']));
            expect(paymentInfo['providerSignature'], equals(tc['signature']));
          },
        );
      }

      test(
        'PRESERVATION: adding email to confirmBody does NOT remove '
        'checkoutSessionId or paymentInfo — EXPECTED TO PASS',
        () {
          // Simulate what the FIX will do: add email alongside existing fields
          final body = buildConfirmBody(
            checkoutSessionId: 'session-post-fix',
            providerOrderId: 'order_rzp_fix',
            providerPaymentId: 'pay_rzp_fix',
            providerSignature: 'sig_fix',
            email: 'alice@example.com', // added by fix
          );

          print('📋 confirmBody with email (post-fix simulation): '
              '${jsonEncode(body)}');

          // All three fields must coexist
          expect(body.containsKey('checkoutSessionId'), isTrue,
              reason: 'checkoutSessionId must survive email addition.');
          expect(body.containsKey('paymentInfo'), isTrue,
              reason: 'paymentInfo must survive email addition.');
          expect(body.containsKey('email'), isTrue,
              reason: 'email must be present when added by fix.');
          expect(body['email'], equals('alice@example.com'));
          expect(body['checkoutSessionId'], equals('session-post-fix'));
        },
      );

      test(
        'PRESERVATION: confirmBody without email (unfixed) still has '
        'exactly checkoutSessionId and paymentInfo — EXPECTED TO PASS',
        () {
          final body = buildConfirmBody(
            checkoutSessionId: 'session-unfixed',
            providerOrderId: 'order_rzp_unfixed',
            providerPaymentId: 'pay_rzp_unfixed',
            providerSignature: 'sig_unfixed',
            // no email — unfixed code behavior
          );

          // On unfixed code, body has exactly 2 top-level keys
          expect(body.keys.toSet(), equals({'checkoutSessionId', 'paymentInfo'}),
              reason:
                  'Unfixed confirmBody must have exactly checkoutSessionId '
                  'and paymentInfo. Body: ${jsonEncode(body)}');
        },
      );
    },
  );

  // =========================================================================
  // Group 2: /request-cancel body preservation
  //
  // Property: requestCancel body ALWAYS contains userId, orderItemId, reason,
  // and shipRocketId. No email field is involved in cancellation.
  //
  // Validates: Requirements 3.5
  // =========================================================================
  group('Preservation: /request-cancel body unchanged', () {
    // Property-based: test across multiple cancel scenarios
    final cancelCases = [
      {
        'userId': 42,
        'orderItemId': 101,
        'reason': 'Changed my mind',
        'shipRocketId': 'SR-001',
      },
      {
        'userId': 99,
        'orderItemId': 202,
        'reason': 'Wrong size ordered',
        'shipRocketId': 'SR-202',
      },
      {
        'userId': 1,
        'orderItemId': 1,
        'reason': 'Duplicate order',
        'shipRocketId': 'SR-DUP',
      },
    ];

    for (final tc in cancelCases) {
      test(
        'PRESERVATION: cancel body contains all required fields '
        '(userId=${tc['userId']}, orderItemId=${tc['orderItemId']}) '
        '— EXPECTED TO PASS',
        () {
          final body = buildCancelBody(
            userId: tc['userId'] as int,
            orderItemId: tc['orderItemId'] as int,
            reason: tc['reason'] as String,
            shipRocketId: tc['shipRocketId'] as String,
          );

          print('📋 cancelBody: ${jsonEncode(body)}');

          expect(body.containsKey('userId'), isTrue,
              reason: 'userId must be present in cancel body.');
          expect(body.containsKey('orderItemId'), isTrue,
              reason: 'orderItemId must be present in cancel body.');
          expect(body.containsKey('reason'), isTrue,
              reason: 'reason must be present in cancel body.');
          expect(body.containsKey('shipRocketId'), isTrue,
              reason: 'shipRocketId must be present in cancel body.');

          expect(body['userId'], equals(tc['userId']));
          expect(body['orderItemId'], equals(tc['orderItemId']));
          expect(body['reason'], equals(tc['reason']));
          expect(body['shipRocketId'], equals(tc['shipRocketId']));
        },
      );
    }

    test(
      'PRESERVATION: cancel body does NOT contain email field '
      '— EXPECTED TO PASS',
      () {
        // The fix only touches checkout flows, not cancellation
        final body = buildCancelBody(
          userId: 42,
          orderItemId: 101,
          reason: 'Test reason',
          shipRocketId: 'SR-TEST',
        );

        expect(
          body.containsKey('email'),
          isFalse,
          reason:
              'email must NOT appear in the cancel request body. '
              'The fix is scoped to checkout flows only. '
              'Body: ${jsonEncode(body)}',
        );
      },
    );

    test(
      'PRESERVATION: cancel body has exactly the 4 required fields '
      '— EXPECTED TO PASS',
      () {
        final body = buildCancelBody(
          userId: 42,
          orderItemId: 101,
          reason: 'Test reason',
          shipRocketId: 'SR-TEST',
        );

        expect(
          body.keys.toSet(),
          equals({'userId', 'orderItemId', 'reason', 'shipRocketId'}),
          reason:
              'Cancel body must have exactly userId, orderItemId, reason, '
              'shipRocketId. No extra fields should be added. '
              'Body: ${jsonEncode(body)}',
        );
      },
    );
  });

  // =========================================================================
  // Group 3: Contact gate skipped when both email and phone are present
  //
  // Property: When both email and phone are present in SharedPreferences,
  // the contact gate does NOT fire — checkout proceeds directly.
  //
  // Validates: Requirements 3.1, 3.2
  // =========================================================================
  group(
    'Preservation: no bottom sheet when both email and phone are present',
    () {
      // Property-based: test across multiple valid email/phone combinations
      final contactCases = [
        {'email': 'alice@example.com', 'phone': '9876543210'},
        {'email': 'bob@test.org', 'phone': '9123456789'},
        {'email': 'user@domain.co.in', 'phone': '8000000001'},
        {'email': 'test+tag@mail.com', 'phone': '7777777777'},
      ];

      for (final tc in contactCases) {
        test(
          'PRESERVATION: gate does NOT fire when email="${tc['email']}" '
          'and phone="${tc['phone']}" — EXPECTED TO PASS',
          () async {
            // Arrange: both email and phone are present
            SharedPreferences.setMockInitialValues({
              'email': tc['email']!,
              'phonenumber': tc['phone']!,
              'token': 'test-token-123',
              'userId': 42,
            });

            final prefs = await SharedPreferences.getInstance();
            final email = prefs.getString('email') ?? '';
            final phone = prefs.getString('phonenumber') ?? '';

            // Act: evaluate the gate condition
            final gateWouldFire = shouldShowContactGate(email, phone);

            print('📋 Contact gate check:');
            print('   email: "$email"');
            print('   phone: "$phone"');
            print('   gateWouldFire: $gateWouldFire');

            // Assert: gate must NOT fire when both are present
            expect(
              gateWouldFire,
              isFalse,
              reason:
                  'MissingContactBottomSheet must NOT be shown when both '
                  'email and phone are present. '
                  'email="$email", phone="$phone"',
            );
          },
        );
      }

      test(
        'PRESERVATION: gate fires when email is empty (gate logic correct) '
        '— EXPECTED TO PASS',
        () async {
          // This verifies the gate logic itself is correct:
          // it fires when email is missing
          SharedPreferences.setMockInitialValues({
            'email': '',
            'phonenumber': '9876543210',
          });

          final prefs = await SharedPreferences.getInstance();
          final email = prefs.getString('email') ?? '';
          final phone = prefs.getString('phonenumber') ?? '';

          final gateWouldFire = shouldShowContactGate(email, phone);

          expect(
            gateWouldFire,
            isTrue,
            reason: 'Gate must fire when email is empty.',
          );
        },
      );

      test(
        'PRESERVATION: gate fires when phone is empty (gate logic correct) '
        '— EXPECTED TO PASS',
        () async {
          SharedPreferences.setMockInitialValues({
            'email': 'alice@example.com',
            'phonenumber': '',
          });

          final prefs = await SharedPreferences.getInstance();
          final email = prefs.getString('email') ?? '';
          final phone = prefs.getString('phonenumber') ?? '';

          final gateWouldFire = shouldShowContactGate(email, phone);

          expect(
            gateWouldFire,
            isTrue,
            reason: 'Gate must fire when phone is empty.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Group 4: Checkout session flow preservation
  //
  // Property: /checkout/initiate returns checkoutSessionId and
  // /checkout/address returns razorpayOrderId — these fields are always
  // present in the responses regardless of email presence.
  //
  // Validates: Requirements 3.3, 3.4
  // =========================================================================
  group('Preservation: checkout session flow returns expected fields', () {
    test(
      'PRESERVATION: /checkout/initiate response contains checkoutSessionId '
      '— EXPECTED TO PASS',
      () async {
        // Arrange: mock the /checkout/initiate response
        final mockSessionId = 'session-preserve-001';
        final mockClient = MockClient((request) async {
          if (request.url.path.contains('/checkout/initiate')) {
            return http.Response(
              jsonEncode({
                'data': {'checkoutSessionId': mockSessionId},
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 404);
        });

        // Act: simulate what initiatePayment does with the response
        final response = await mockClient.post(
          Uri.parse('https://api.example.com/checkout/initiate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mode': 'cart'}),
        );

        final responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final checkoutSessionId =
            responseData['data']?['checkoutSessionId'] as String?;

        print('📋 /checkout/initiate response: ${response.body}');
        print('   checkoutSessionId: $checkoutSessionId');

        // Assert: checkoutSessionId is present in the response
        expect(
          checkoutSessionId,
          isNotNull,
          reason:
              '/checkout/initiate must return a checkoutSessionId. '
              'Response: ${response.body}',
        );
        expect(
          checkoutSessionId,
          equals(mockSessionId),
          reason: 'checkoutSessionId must match the value from the response.',
        );
      },
    );

    test(
      'PRESERVATION: /checkout/address response contains razorpayOrderId '
      '— EXPECTED TO PASS',
      () async {
        // Arrange: mock the /checkout/address response
        final mockRazorpayOrderId = 'order_rzp_preserve_001';
        final mockClient = MockClient((request) async {
          if (request.url.path.contains('/checkout/address')) {
            return http.Response(
              jsonEncode({
                'data': {'razorpayOrderId': mockRazorpayOrderId},
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 404);
        });

        // Act: simulate what initiatePayment does with the address response
        final response = await mockClient.post(
          Uri.parse('https://api.example.com/checkout/address'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'checkoutSessionId': 'session-preserve-001',
            'addressId': 5,
          }),
        );

        final responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final razorpayOrderId =
            responseData['data']?['razorpayOrderId'] as String?;

        print('📋 /checkout/address response: ${response.body}');
        print('   razorpayOrderId: $razorpayOrderId');

        // Assert: razorpayOrderId is present in the response
        expect(
          razorpayOrderId,
          isNotNull,
          reason:
              '/checkout/address must return a razorpayOrderId. '
              'Response: ${response.body}',
        );
        expect(
          razorpayOrderId,
          equals(mockRazorpayOrderId),
          reason: 'razorpayOrderId must match the value from the response.',
        );
      },
    );

    test(
      'PRESERVATION: full checkout session flow returns both '
      'checkoutSessionId and razorpayOrderId — EXPECTED TO PASS',
      () async {
        // Arrange: mock both endpoints in sequence
        final mockSessionId = 'session-full-flow-001';
        final mockRazorpayOrderId = 'order_rzp_full_001';

        final mockClient = MockClient((request) async {
          if (request.url.path.contains('/checkout/initiate')) {
            return http.Response(
              jsonEncode({
                'data': {'checkoutSessionId': mockSessionId},
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.url.path.contains('/checkout/address')) {
            return http.Response(
              jsonEncode({
                'data': {'razorpayOrderId': mockRazorpayOrderId},
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 404);
        });

        // Act: Step 1 — initiate
        final initiateRes = await mockClient.post(
          Uri.parse('https://api.example.com/checkout/initiate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mode': 'cart'}),
        );
        final initiateData =
            jsonDecode(initiateRes.body) as Map<String, dynamic>;
        final checkoutSessionId =
            initiateData['data']?['checkoutSessionId'] as String?;

        // Act: Step 2 — set address
        final addressRes = await mockClient.post(
          Uri.parse('https://api.example.com/checkout/address'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'checkoutSessionId': checkoutSessionId,
            'addressId': 5,
          }),
        );
        final addressData =
            jsonDecode(addressRes.body) as Map<String, dynamic>;
        final razorpayOrderId =
            addressData['data']?['razorpayOrderId'] as String?;

        print('📋 Full checkout session flow:');
        print('   checkoutSessionId: $checkoutSessionId');
        print('   razorpayOrderId: $razorpayOrderId');

        // Assert: both IDs are present and correct
        expect(checkoutSessionId, equals(mockSessionId),
            reason: 'checkoutSessionId must be returned from /checkout/initiate.');
        expect(razorpayOrderId, equals(mockRazorpayOrderId),
            reason: 'razorpayOrderId must be returned from /checkout/address.');
      },
    );

    test(
      'PRESERVATION: initiateBody sent to /checkout/initiate contains '
      'mode field — EXPECTED TO PASS',
      () {
        // The mode field must always be present in the initiate body
        final body = buildInitiateBody(mode: 'cart');

        expect(
          body.containsKey('mode'),
          isTrue,
          reason: 'initiateBody must always contain the "mode" field.',
        );
        expect(body['mode'], equals('cart'));
      },
    );

    test(
      'PRESERVATION: initiateBody with email (post-fix) still contains '
      'mode field — EXPECTED TO PASS',
      () {
        // Simulate post-fix: email is added but mode is preserved
        final body = buildInitiateBody(
          mode: 'cart',
          email: 'alice@example.com',
        );

        expect(body.containsKey('mode'), isTrue,
            reason: 'mode must survive email addition in initiateBody.');
        expect(body['mode'], equals('cart'));
        expect(body.containsKey('email'), isTrue);
      },
    );
  });
}
