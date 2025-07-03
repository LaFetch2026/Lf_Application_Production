import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

class AnalyticsHelper {
  /// App Install - Called once post-install
  static void logAppInstall() {
    facebookAppEvents.logEvent(name: 'fb_mobile_install');
  }

  Future<void> logInstallOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLoggedInstall = prefs.getBool('has_logged_fb_install') ?? false;

    if (!hasLoggedInstall) {
      AnalyticsHelper.logAppInstall();
      await prefs.setBool('has_logged_fb_install', true);
    }
  }

  /// App Launch
  static void logAppLaunch() {
    facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
  }

  /// View Content
  static void logContentView({
    required String productId,
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

  /// Search
  static void logSearch({
    required String searchQuery,
    required String contentType,
    required double value,
    required String productId,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_search',
      parameters: {
        'content_type': contentType,
        'content_id': productId,
        'currency': 'USD',
        'valueToSum': value,
        'search_string': searchQuery,
      },
    );
  }

  /// Add to Wishlist
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

  /// Add to Cart
  static void logAddToCart({
    required String productId,
    required String contentType, required double value,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_to_cart',
      parameters: {
        'content_type': contentType,
        'content_id': productId,
        'currency': 'USD',
      },
    );
  }

  /// Initiate Checkout
  static void logInitiateCheckout({
    required String productId,
  }) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_initiated_checkout',
      parameters: {
        'content_type': 'product',
        'content_id': productId,
        'currency': 'USD',
      },
    );
  }

  /// Add Payment Info
  static void logAddPaymentInfo({bool success = true}) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_add_payment_info',
      parameters: {
        'success': success,
      },
    );
  }

  /// Purchase
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

  /// Start Trial
  static void logStartTrial() {
    facebookAppEvents.logEvent(name: 'StartTrial');
  }

  /// Subscribe
  static void logSubscribe() {
    facebookAppEvents.logEvent(name: 'Subscribe');
  }

  /// Rate
  static void logRate({
    required double value,
    double maxRatingValue = 5.0,
  }) {
    facebookAppEvents.logEvent(
      name: 'Rate',
      parameters: {
        'max_rating_value': maxRatingValue,
        'content_type': 'product',
        'valueToSum': value,
      },
    );
  }

  /// Scroll (custom engagement event)
  static void logScrollEvent(String scrollDepth) {
    facebookAppEvents.logEvent(
      name: 'fb_mobile_scroll',
      parameters: {
        'scroll_depth': scrollDepth,
      },
    );
  }
}
