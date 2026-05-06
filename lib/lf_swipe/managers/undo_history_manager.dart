import '../models/swipe_product.dart';

/// Manages session-based undo history with FIFO eviction and unique key generation.
///
/// This manager maintains a list of the last 5 swiped products, allowing users
/// to undo their actions. When the history exceeds 5 items, the oldest item is
/// removed (FIFO - First In, First Out).
///
/// The manager also generates unique keys for restored products to prevent
/// duplicate key errors in Flutter widgets.
class UndoHistoryManager {
  /// Maximum number of products to keep in undo history
  static const int maxHistorySize = 5;

  /// List of products that can be undone (most recent first)
  final List<SwipeProduct> _history = [];

  /// Counter for generating unique keys
  int _keyCounter = 0;

  /// Add a product to undo history.
  ///
  /// Inserts the product at the front of the list (most recent first).
  /// If the list exceeds [maxHistorySize], removes the last item (FIFO eviction).
  ///
  /// Parameters:
  ///   - product: The SwipeProduct to add to history
  void addToHistory(SwipeProduct product) {
    _history.insert(0, product); // Most recent at front
    if (_history.length > maxHistorySize) {
      _history.removeLast(); // FIFO: remove oldest
    }
  }

  /// Check if undo is available.
  ///
  /// Returns true if history is not empty, false otherwise.
  bool get canUndo => _history.isNotEmpty;

  /// Get the most recent product for undo preview.
  ///
  /// Returns the first product in history (most recent) or null if empty.
  /// This getter does not remove the product from history.
  SwipeProduct? get nextUndoProduct =>
      _history.isNotEmpty ? _history.first : null;

  /// Restore the most recent product and return it.
  ///
  /// Removes and returns the first product from history.
  /// Returns null if history is empty.
  ///
  /// Returns:
  ///   - The most recent SwipeProduct from history, or null if empty
  SwipeProduct? restoreProduct() {
    if (_history.isEmpty) return null;
    return _history.removeAt(0);
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
  String _generateUniqueKey(int productId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final key = 'undo_${_keyCounter}_${timestamp}_$productId';
    _keyCounter++;
    return key;
  }

  /// Clear the history and reset the counter.
  ///
  /// Called when navigating away from the swipe feed to ensure
  /// the history is session-based and not persistent across app restarts.
  void clearHistory() {
    _history.clear();
    _keyCounter = 0;
  }
}
