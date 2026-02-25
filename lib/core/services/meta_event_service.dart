import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaEventService {
  MetaEventService._();
  static final MetaEventService instance = MetaEventService._();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// Set this to a Meta test event code (e.g. 'TEST81951') to send events
  /// in debug mode to Meta's Test Events tab. Set to null in production.
  static String? testEventCode;

  /// Returns true if we should send events (release mode OR test mode active).
  bool get _shouldLog => kReleaseMode || testEventCode != null;

  /// Extra parameters to attach when testEventCode is set.
  Map<String, dynamic> get _testParams =>
      testEventCode != null ? {'_appEventsTestEventCode': testEventCode!} : {};

  /// Call once at app startup (e.g. in main.dart or app init)
  Future<void> init() async {
    await _facebookAppEvents.setAdvertiserTracking(enabled: true);
  }

  // 1. ViewContent — Product page opened
  Future<void> logViewContent({
    String? contentId,
    String? contentType,
    double? price,
    String currency = 'INR',
  }) async {
    if (!_shouldLog) return;
    await _facebookAppEvents.logEvent(
      name: FacebookAppEvents.eventNameViewedContent,
      parameters: {
        FacebookAppEvents.paramNameContentId: contentId,
        FacebookAppEvents.paramNameContentType: contentType ?? 'product',
        FacebookAppEvents.paramNameCurrency: currency,
        ..._testParams,
      },
      valueToSum: price,
    );
  }

  // 2. AddToWishlist — Clicking add-to-wishlist
  Future<void> logAddToWishlist({
    String contentId = '',
    double price = 0.0,
    String currency = 'INR',
  }) async {
    if (!_shouldLog) return;
    await _facebookAppEvents.logEvent(
      name: FacebookAppEvents.eventNameAddedToWishlist,
      parameters: {
        FacebookAppEvents.paramNameContentId: contentId,
        FacebookAppEvents.paramNameContentType: 'product',
        FacebookAppEvents.paramNameCurrency: currency,
        ..._testParams,
      },
      valueToSum: price,
    );
  }

  // 3. AddToCart — Clicking add-to-cart
  Future<void> logAddToCart({
    String contentId = '',
    double price = 0.0,
    String currency = 'INR',
  }) async {
    if (!_shouldLog) return;
    await _facebookAppEvents.logEvent(
      name: FacebookAppEvents.eventNameAddedToCart,
      parameters: {
        FacebookAppEvents.paramNameContentId: contentId,
        FacebookAppEvents.paramNameContentType: 'product',
        FacebookAppEvents.paramNameCurrency: currency,
        ..._testParams,
      },
      valueToSum: price,
    );
  }

  // 4. InitiateCheckout — Clicking Proceed to Checkout
  Future<void> logInitiateCheckout({
    double? totalPrice,
    int? numItems,
    String currency = 'INR',
  }) async {
    if (!_shouldLog) return;
    await _facebookAppEvents.logEvent(
      name: FacebookAppEvents.eventNameInitiatedCheckout,
      parameters: {
        FacebookAppEvents.paramNameNumItems: numItems,
        FacebookAppEvents.paramNameCurrency: currency,
        ..._testParams,
      },
      valueToSum: totalPrice,
    );
  }

  // 5. AddPaymentInfo — Clicking Proceed to Pay (Razorpay opens)
  Future<void> logAddPaymentInfo() async {
    if (!_shouldLog) return;
    await _facebookAppEvents.logEvent(
      name: 'fb_mobile_add_payment_info',
      parameters: {
        ..._testParams,
      },
    );
  }

  // 6. Purchase — Success page (Order Placed Successfully)
  Future<void> logPurchase({
    required double amount,
    String currency = 'INR',
  }) async {
    if (!_shouldLog) return;
    await _facebookAppEvents.logPurchase(
      amount: amount,
      currency: currency,
      parameters: testEventCode != null
          ? {'_appEventsTestEventCode': testEventCode!}
          : null,
    );
  }
}
