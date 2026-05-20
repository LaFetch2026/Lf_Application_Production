import '../../models/analytics_models.dart';

class EventPayloadMapper {
  /// Maps an AnalyticsProduct to the payload required for "Product View", 
  /// "Add To Wishlist", and "Add To Cart" events.
  static Map<String, dynamic> mapProduct(AnalyticsProduct product) {
    return product.toMap();
  }

  /// Maps an AnalyticsUser and signup method to the "Signup" event payload.
  static Map<String, dynamic> mapSignup(AnalyticsUser user, {required String method}) {
    return {
      'source': 'app',
      'method': method,
      if (user.fullName != null) 'name': user.fullName,
      if (user.email != null) 'email': user.email,
    };
  }

  /// Maps a sign-in method to the "Signin" event payload.
  static Map<String, dynamic> mapSignin({required String method}) {
    return {
      'source': 'app',
      'method': method,
    };
  }

  /// Maps an AnalyticsOrder to the "Checkout" event payload.
  static Map<String, dynamic> mapCheckout(AnalyticsOrder order) {
    final map = order.toMap();
    // Remove fields not specified in the tracking sheet for Checkout if necessary
    // but the tracking sheet requirements for Checkout match AnalyticsOrder fairly well.
    map.remove('orderid');
    map.remove('fulfillment_mode');
    return map;
  }

  /// Maps an AnalyticsOrder to the "Product Purchase" event payload.
  static Map<String, dynamic> mapPurchase(AnalyticsOrder order) {
    return order.toMap();
  }

  /// Maps an AnalyticsOrder summary to the "Cart Items" event payload.
  static Map<String, dynamic> mapCartItems({required bool hasItems, required AnalyticsOrder cartSummary}) {
    final map = cartSummary.toMap();
    map['status'] = hasItems ? 'yes' : 'no';
    map.remove('orderid');
    map.remove('payment_mode');
    map.remove('coupon_code');
    map.remove('source');
    map.remove('fulfillment_mode');
    return map;
  }

  /// Maps coupon data to the "Coupon Applied" event payload.
  static Map<String, dynamic> mapCouponApplied({
    required String code,
    required String type,
    required double value,
    required double cartValue,
    required double discountAmt,
  }) {
    return {
      'coupon_code': code,
      'discount_type': type,
      'discount_value': value,
      'cart_value': cartValue,
      'discount_amt': discountAmt,
    };
  }
}
