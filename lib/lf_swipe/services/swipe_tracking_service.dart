/// The four swipe directions and their semantic meaning.
enum SwipeAction {
  likeProduct,    // right → ADD_TO_WISHLIST
  dislikeProduct, // left  → REJECT_PRODUCT
  swipeUp,        // up    → ADD_TO_CART
  swipeDown,      // down  → OPEN_PDP
}

extension SwipeActionApi on SwipeAction {
  /// Maps to the backend action string for POST /swipe/action.
  String get apiValue => const {
    SwipeAction.likeProduct: 'ADD_TO_WISHLIST',
    SwipeAction.dislikeProduct: 'REJECT_PRODUCT',
    SwipeAction.swipeUp: 'ADD_TO_CART',
    SwipeAction.swipeDown: 'OPEN_PDP',
  }[this]!;
}

/// Tracking is now handled by the /swipe/action endpoint itself.
/// This class is kept as a no-op stub so existing call sites compile.
class SwipeTrackingService {
  SwipeTrackingService._();

  /// No-op — the new /swipe/action API records the event server-side.
  static Future<void> track(SwipeAction action, int productId) async {}
}
