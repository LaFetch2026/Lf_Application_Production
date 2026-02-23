import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaEventService {
  MetaEventService._();
  static final MetaEventService instance = MetaEventService._();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

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
    if (!kReleaseMode) return;
    await _facebookAppEvents.logViewContent(
      id: contentId,
      type: contentType ?? 'product',
      currency: currency,
      price: price,
    );
  }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
  // 2. AddToWishlist — Clicking add-to-wishlist
  Future<void> logAddToWishlist({
    String contentId = '',
    double price = 0.0,
    String currency = 'INR',
  }) async {
    if (!kReleaseMode) return;
    await _facebookAppEvents.logAddToWishlist(
      id: contentId,
      type: 'product',
      currency: currency,
      price: price,
    );
  }

  // 3. AddToCart — Clicking add-to-cart
  Future<void> logAddToCart({
    String contentId = '',
    double price = 0.0,
    String currency = 'INR',
  }) async {
    if (!kReleaseMode) return;
    await _facebookAppEvents.logAddToCart(
      id: contentId,
      type: 'product',
      currency: currency,
      price: price,
    );
  }

  // 4. InitiateCheckout — Clicking Proceed to Checkout
  Future<void> logInitiateCheckout({
    double? totalPrice,
    int? numItems,
    String currency = 'INR',
  }) async {
    if (!kReleaseMode) return;
    await _facebookAppEvents.logInitiatedCheckout(
      totalPrice: totalPrice,
      currency: currency,
      numItems: numItems,
    );
  }

  // 5. AddPaymentInfo — Clicking Proceed to Pay (Razorpay opens)
  Future<void> logAddPaymentInfo() async {
    if (!kReleaseMode) return;
    await _facebookAppEvents.logEvent(
      name: 'fb_mobile_add_payment_info', 
    );
  }

  // 6. Purchase — Success page (Order Placed Successfully)
  Future<void> logPurchase({
    required double amount,
    String currency = 'INR',
  }) async {
    if (!kReleaseMode) return;
    await _facebookAppEvents.logPurchase(
      amount: amount,
      currency: currency,
    );
  }
}
