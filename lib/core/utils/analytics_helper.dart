import 'package:facebook_app_events/facebook_app_events.dart';

final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

class AnalyticsHelper {
  /// App Install - Called once post-install (optional, often auto-tracked)
  static void logAppInstall() {
    facebookAppEvents.logEvent(name: 'fb_mobile_install');
  }

  /// App Launch - Called at app startup
  static void logAppLaunch() {
    facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
  }

  /// View Content - e.g. Product page opened
  static void logContentView({
    required productId,
    required double value,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_content_view',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'currency': 'USD',
        'valueToSum': value,
      },
    );
  }

  /// Search - When search submitted
  static void logSearch({
    required productId,
    required String contentType,
    required double value,
  }) {
    print("Logging fb_mobile_search: $productId, $contentType, $value");

    facebookAppEvents.logEvent(
      name: 'Search',
      parameters: {
        'content_type': 'search_action',
        'content_id': 'search_tap',
        'currency': 'USD',
        'valueToSum': 0.0,
      },
    );
  }

  /// Add to Wishlist - User saves product
  static void logAddToWishlist({
    required String productId,
    required String contentType,
    required double value,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_to_wishlist',
      parameters: {
        'content_type': contentType,
        'content_id': productId,
        'currency': 'USD',
        'valueToSum': value,
      },
    );
  }

  /// Add to Cart - User adds product to cart
  static void logAddToCart({
    required String productId,
    required double value,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_to_cart',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'currency': 'USD',
        'valueToSum': value,
      },
    );
  }

  /// Initiate Checkout - Checkout started

  static void logInitiateCheckout({
    required String productId,
    required double value,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_initiated_checkout',
      parameters: {
        'content_type': 'product',
        'content_id': productId, // or use List<String> if multiple items
        'currency': 'USD',
        'valueToSum': value,
      },
    );
  }

  /// Add Payment Info - Called after entering payment method
// Add Payment Info event
  static void logAddPaymentInfo({bool success = true}) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_payment_info',
      parameters: {
        'success': success,
      },
    );
  }

// Purchase event
  static void logPurchase({
    required String productId,
    required double value,
  }) {
    facebookAppEvents.logPurchase(
      amount: value,
      currency: 'USD',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'valueToSum': value,
      },
    );
  }

  /// Start Trial - Placeholder
  static void logStartTrial() {
    facebookAppEvents.logEvent(name: 'StartTrial');
  }

  /// Subscribe - Placeholder
  static void logSubscribe() {
    facebookAppEvents.logEvent(name: 'Subscribe');
  }

  /// Rate - e.g. user rates a product or app
  static void logRate({
    required double value,
    double maxRatingValue = 5.0,
  }) {
    facebookAppEvents.logEvent(
      name: 'Rate',
      parameters: {
        'max_rating_value': maxRatingValue,
        'valueToSum': value,
        'content_type': 'product',
      },
    );
  }

  /// Scroll / Engagement - Track scrolling behavior
  static void logScrollEvent(String scrollDepth) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_scroll',
      parameters: {
        'scroll_depth': scrollDepth,
      },
    );
  }
}
