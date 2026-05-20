import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../../models/analytics_models.dart';
import '../netcore_service.dart';
import '../../core/services/meta_event_service.dart';
import 'event_payload_mapper.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  // NetcoreService is a GetxService, we assume it's registered
  NetcoreService get _netcore => NetcoreService.instance;
  MetaEventService get _meta => MetaEventService.instance;

  /// Track User Signup
  Future<void> trackSignup(AnalyticsUser user, {required String method}) async {
    try {
      final payload = EventPayloadMapper.mapSignup(user, method: method);

      // Firebase Analytics
      await _fa.logEvent(
          name: 'Signup', parameters: payload.cast<String, Object>().cast<String, Object>());

      // User Attributes
      final attrs = user.toUserAttributes();
      for (var entry in attrs.entries) {
        await _fa.setUserProperty(name: entry.key, value: entry.value);
      }

      // Netcore
      _netcore.updateProfile(attrs);
      _netcore.trackEvent('Signup', payload);
      if (user.email != null) {
        _netcore.loginUser(user.email!);
      } else if (user.mobile != null) {
        _netcore.loginUser(user.mobile!);
      }
    } catch (e) {
      debugPrint('AnalyticsService trackSignup error: $e');
    }
  }

  /// Track User Signin
  Future<void> trackSignin({required String method}) async {
    try {
      final payload = EventPayloadMapper.mapSignin(method: method);

      await _fa.logEvent(name: 'Signin', parameters: payload.cast<String, Object>().cast<String, Object>());
      await _fa.setUserProperty(name: 'LAST_LOGIN_SOURCE', value: method);

      _netcore.updateProfile({'LAST_LOGIN_SOURCE': method});
      _netcore.trackEvent('Signin', payload);
    } catch (e) {
      debugPrint('AnalyticsService trackSignin error: $e');
    }
  }

  /// Track Product View
  Future<void> trackProductView(AnalyticsProduct product) async {
    try {
      final payload = EventPayloadMapper.mapProduct(product);

      await _fa.logEvent(name: 'Product View', parameters: payload.cast<String, Object>().cast<String, Object>());

      _netcore.trackEvent('Product View', payload);

      _meta.logViewContent(
        contentId: product.prid,
        contentType: 'product',
        price: product.sellingPrice,
      );
    } catch (e) {
      debugPrint('AnalyticsService trackProductView error: $e');
    }
  }

  /// Track Add To Wishlist
  Future<void> trackAddToWishlist(AnalyticsProduct product) async {
    try {
      final payload = EventPayloadMapper.mapProduct(product);

      await _fa.logEvent(name: 'Add To Wishlist', parameters: payload.cast<String, Object>().cast<String, Object>());

      _netcore.trackEvent('Add To Wishlist', payload);

      _meta.logAddToWishlist(
        contentId: product.prid,
        price: product.sellingPrice,
      );
    } catch (e) {
      debugPrint('AnalyticsService trackAddToWishlist error: $e');
    }
  }

  /// Track Add To Cart
  Future<void> trackAddToCart(AnalyticsProduct product) async {
    try {
      final payload = EventPayloadMapper.mapProduct(product);

      await _fa.logEvent(name: 'Add To Cart', parameters: payload.cast<String, Object>().cast<String, Object>());

      _netcore.trackEvent('Add To Cart', payload);

      _meta.logAddToCart(
        contentId: product.prid,
        price: product.sellingPrice,
      );
    } catch (e) {
      debugPrint('AnalyticsService trackAddToCart error: $e');
    }
  }

  /// Track Checkout Initiation
  Future<void> trackCheckout(AnalyticsOrder order) async {
    try {
      final payload = EventPayloadMapper.mapCheckout(order);

      await _fa.logEvent(name: 'Checkout', parameters: payload.cast<String, Object>().cast<String, Object>());

      _netcore.trackEvent('Checkout', payload);

      _meta.logInitiateCheckout(
        totalPrice: order.amount,
        numItems: order.totalPrqt,
      );
    } catch (e) {
      debugPrint('AnalyticsService trackCheckout error: $e');
    }
  }

  /// Track Successful Purchase
  Future<void> trackPurchase(AnalyticsOrder order, AnalyticsUser user) async {
    try {
      final payload = EventPayloadMapper.mapPurchase(order);

      await _fa.logEvent(name: 'Product Purchase', parameters: payload.cast<String, Object>().cast<String, Object>());

      // Attributes update
      final attrs = user.toUserAttributes();
      for (var entry in attrs.entries) {
        await _fa.setUserProperty(name: entry.key, value: entry.value);
      }

      _netcore.updateProfile(attrs);
      _netcore.trackEvent('Product Purchase', payload);

      _meta.logPurchase(amount: order.amount);
    } catch (e) {
      debugPrint('AnalyticsService trackPurchase error: $e');
    }
  }

  /// Track Cart Items (Current State)
  Future<void> trackCartItems(
      {required bool hasItems, required AnalyticsOrder cartSummary}) async {
    try {
      final payload = EventPayloadMapper.mapCartItems(
          hasItems: hasItems, cartSummary: cartSummary);

      await _fa.logEvent(name: 'Cart Items', parameters: payload.cast<String, Object>().cast<String, Object>());

      _netcore.trackEvent('Cart Items', payload);
    } catch (e) {
      debugPrint('AnalyticsService trackCartItems error: $e');
    }
  }

  /// Track Coupon Applied
  Future<void> trackCouponApplied({
    required String code,
    required String type,
    required double value,
    required double cartValue,
    required double discountAmt,
  }) async {
    try {
      final payload = EventPayloadMapper.mapCouponApplied(
        code: code,
        type: type,
        value: value,
        cartValue: cartValue,
        discountAmt: discountAmt,
      );

      await _fa.logEvent(name: 'Coupon Applied', parameters: payload.cast<String, Object>().cast<String, Object>());

      _netcore.trackEvent('Coupon Applied', payload);
    } catch (e) {
      debugPrint('AnalyticsService trackCouponApplied error: $e');
    }
  }

  /// Track Sign Out
  Future<void> trackSignOut() async {
    try {
      await _fa.logEvent(name: 'Sign Out');
      _netcore.trackEvent('Sign Out', {});
      _netcore.logoutUser();
    } catch (e) {
      debugPrint('AnalyticsService trackSignOut error: $e');
    }
  }

  /// Track generic events
  Future<void> trackEvent(String name,
      [Map<String, dynamic>? parameters]) async {
    try {
      await _fa.logEvent(
          name: name, parameters: parameters!.cast<String, Object>());
      _netcore.trackEvent(name, parameters ?? {});
    } catch (e) {
      debugPrint('AnalyticsService trackEvent ($name) error: $e');
    }
  }
}
