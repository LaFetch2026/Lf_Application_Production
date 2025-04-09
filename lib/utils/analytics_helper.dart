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
  static void logContentView({required String productId, required double value}) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_content_view',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'currency': 'USD',
        'value': value,
      },
    );
  }

  /// Search - When search submitted
  static void logSearch(String searchQuery) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_search',
      parameters: {
        'search_string': searchQuery,
        'success': true,
      },
    );
  }

  /// Add to Wishlist - User saves product
  static void logAddToWishlist({required String productId, required double value}) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_to_wishlist',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'currency': 'USD',
        'value': value,
      },
    );
  }

  /// Add to Cart - User adds product to cart
  static void logAddToCart({required String productId, required double totalProductValue}) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_to_cart',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'currency': 'USD',
        'value': totalProductValue,
      },
    );
  }

  /// Initiate Checkout - Checkout started
  static void logInitiateCheckout({
    required List<String> productId,
    required double totalProductValue,
    bool paymentInfoAvailable = false,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_initiated_checkout',
      parameters: {
        'content_type': 'product',
        'content_id': productId.join(','),
        'num_items': productId.length,
        'payment_info_available': paymentInfoAvailable,
        'currency': 'USD',
        'value': totalProductValue,
      },
    );
  }

  /// Purchase - After successful order
  static void logPurchase({required String productId, required double totalProductValue}) {
    facebookAppEvents.logPurchase(
      amount: totalProductValue,
      currency: 'USD',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
      },
    );
  }

  /// Scroll / Engagement - Track scrolling behavior
  static void logScrollEvent(String scrollDepth) {
    facebookAppEvents.logEvent(
      name: 'scroll',
      parameters: {
        'scroll_depth': scrollDepth, // e.g. '25%', '50%', '100%'
      },
    );
  }
}
