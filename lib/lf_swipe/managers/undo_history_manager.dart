import '../models/swipe_product.dart';

/// Represents the action direction for a swipe.
/// Mirrors the SwipeAction enum values used in the controller.
enum SwipeActionType {
  likeProduct, // right swipe
  dislikeProduct, // left swipe
  swipeUp, // add to cart
  swipeDown, // open PDP
}

/// Minimal undo entry storing only product ID and action direction.
/// This prevents memory bloat from storing full SwipeProduct objects.
class _UndoEntry {
  final int productId;
  final SwipeActionType action;

  const _UndoEntry({required this.productId, required this.action});
}

/// Manages session-based undo history with FIFO eviction.
///
/// Stores only lightweight (productId, action) pairs in history.
/// Full product data is kept in a separate [_productCache] Map for lookup
/// when undo is triggered. This design prevents:
///   - Duplicate full product objects per undo entry
///   - Memory bloat from storing rich product data (image URLs, etc.)
///   - OOM crashes when multiple swipe views are active
class UndoHistoryManager {
  /// Maximum number of undo entries to keep
  static const int maxHistorySize = 5;

  /// List of undo entries (most recent first)
  final List<_UndoEntry> _history = [];

  /// Cache of recently-removed products keyed by ID.
  /// This is a Map (not List) so we can efficiently look up by ID.
  /// Size is kept in sync with [_history] to prevent memory leaks.
  final Map<int, SwipeProduct> _productCache = {};

  /// Counter for generating unique keys
  int _keyCounter = 0;

  /// Add a product to undo history.
  ///
  /// Stores only the product ID and action direction in history.
  /// The full product is cached in [_productCache] for lookup on undo.
  /// If the history exceeds [maxHistorySize], the oldest entry is evicted
  /// and its product is also removed from the cache.
  ///
  /// Parameters:
  ///   - product: The SwipeProduct to add to history
  ///   - action: The swipe action direction (like, dislike, swipeUp, swipeDown)
  void addToHistory(SwipeProduct product, SwipeActionType action) {
    // Add lightweight entry to history
    _history.insert(0, _UndoEntry(productId: product.id, action: action));

    // Cache the full product data for lookup
    _productCache[product.id] = product;

    // FIFO eviction: remove oldest entry and its cached product
    if (_history.length > maxHistorySize) {
      final removed = _history.removeLast();
      _productCache.remove(removed.productId);
    }
  }

  /// Check if undo is available.
  ///
  /// Returns true if history is not empty, false otherwise.
  bool get canUndo => _history.isNotEmpty;

  /// Get the most recent undo entry for UI preview (without removing it).
  ///
  /// Returns a record of (productId, action) or null if history is empty.
  /// Use [restoreProduct] to actually perform the undo and get the full product.
  ({int productId, SwipeActionType action})? get nextUndoEntry {
    if (_history.isEmpty) return null;
    final entry = _history.first;
    return (productId: entry.productId, action: entry.action);
  }

  /// Restore the most recent product and return it.
  ///
  /// Removes the first entry from history, looks up the full product from
  /// [_productCache] using the stored ID, and removes it from the cache.
  /// Returns null if history is empty or product not found in cache.
  ///
  /// Returns:
  ///   - The most recent SwipeProduct from history, or null if empty/not found
  SwipeProduct? restoreProduct() {
    if (_history.isEmpty) return null;

    final entry = _history.removeAt(0);
    final product = _productCache.remove(entry.productId);

    return product;
  }

  /// Generate a unique key for a restored product.
  ///
  /// Combines counter + timestamp to ensure no collisions.
  /// Format: `undo_{counter}_{timestamp}_{productId}`
  ///
  /// The counter is incremented after each generation to ensure uniqueness.
  ///
  /// Returns:
  ///   - A unique key string in the format: undo_0_1699564800000_12345
  String generateUniqueKey(int productId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final key = 'undo_${_keyCounter}_${timestamp}_$productId';
    _keyCounter++;
    return key;
  }

  /// Clear the history and reset counters.
  ///
  /// Called when navigating away from the swipe feed to ensure
  /// the history is session-based and not persistent across app restarts.
  void clearHistory() {
    _history.clear();
    _productCache.clear();
    _keyCounter = 0;
  }
}
