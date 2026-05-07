// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/utils/share_link_generator.dart';
import '../../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import '../managers/swipe_overlay_manager.dart';
import '../managers/undo_history_manager.dart';
import '../models/swipe_product.dart';
import '../services/swipe_cart_service.dart';
import '../services/swipe_feed_service.dart';
import '../services/swipe_tracking_service.dart';
import '../widgets/swipe_size_sheet.dart';

const kSwipeTutorialSeen = 'swipe_tutorial_seen';
const kSwipeBoardName = 'LF Swipes';

class SwipeFeedController extends GetxController {
  // ── Singleton access ──────────────────────────────────────────────────────
  static SwipeFeedController get instance => Get.find();

  // ── Dependencies ──────────────────────────────────────────────────────────
  late final WishlistController _wishlistCtrl;
  late final SwipeOverlayManager _overlayManager;
  late final UndoHistoryManager _undoManager;

  // ── Feed state ────────────────────────────────────────────────────────────
  final cards = <SwipeProduct>[].obs;
  final isFetching = false.obs;
  final hasError = false.obs;

  /// True once the backend returns an empty batch — feed is genuinely exhausted.
  final isExhausted = false.obs;

  // ── Gender filter: 0=All, 1=Men, 2=Women ─────────────────────────────────
  final genderFilter = 0.obs;

  // ── Undo / rewind ─────────────────────────────────────────────────────────
  /// The last swiped product — used for local rewind (re-insert at top).
  final Rx<SwipeProduct?> lastSwiped = Rx(null);

  /// Observable for undo button visibility (true when history is not empty)
  final canUndo = false.obs;

  // ── Tutorial ──────────────────────────────────────────────────────────────
  final showTutorial = false.obs;

  // ── Flash signals (observed by screen for animations) ────────────────────
  final wishlistFlash = false.obs;
  final cartFlash = false.obs;

  // ── Swipe-up card animation callbacks (set by SwipeFeedScreen) ───────────
  VoidCallback? onSwipeUpFlyUp;
  VoidCallback? onSwipeUpReset;

  /// Callback to display overlay on the top card (set by SwipeFeedScreen)
  void Function(OverlayType, OverlayConfig)? onShowOverlay;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[SwipeFeedController] onInit — starting fetch');
    _wishlistCtrl = Get.find<WishlistController>();
    _overlayManager = SwipeOverlayManager();
    _overlayManager.resetSession();
    _undoManager = UndoHistoryManager();
    fetchBatch();
    _checkTutorial();
  }

  // ── Tutorial ──────────────────────────────────────────────────────────────

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(kSwipeTutorialSeen) ?? false;
    if (!seen) showTutorial.value = true;
  }

  Future<void> dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kSwipeTutorialSeen, true);
    showTutorial.value = false;
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  // Whether the current fetch cycle is running without the seen-product filter
  // (feed-reset mode — triggered when the personalized feed is exhausted).
  bool _skipSeenFilter = false;

  Future<void> fetchBatch() async {
    debugPrint(
        '[SwipeFeedController] fetchBatch called — isFetching=${isFetching.value}, isExhausted=${isExhausted.value}, cards=${cards.length}, skipSeenFilter=$_skipSeenFilter');
    if (isFetching.value || isExhausted.value) {
      debugPrint('[SwipeFeedController] fetchBatch SKIPPED');
      return;
    }

    isFetching.value = true;
    hasError.value = false;

    try {
      var results = await SwipeFeedService.instance.fetchBatch(
        genderFilter: genderFilter.value,
        skipSeenFilter: _skipSeenFilter,
      );

      // If personalized feed returned nothing, retry without seen-product filter
      // (the user has seen everything — show fresh products from the full catalog).
      if (results.isEmpty && !_skipSeenFilter) {
        debugPrint(
            '[SwipeFeedController] Personalized feed empty — retrying without seen filter');
        _skipSeenFilter = true;
        results = await SwipeFeedService.instance.fetchBatch(
          genderFilter: genderFilter.value,
          skipSeenFilter: true,
        );
      }

      debugPrint(
          '[SwipeFeedController] fetchBatch got ${results.length} products');

      if (results.isEmpty) {
        isExhausted.value = true;
      } else {
        cards.addAll(results);
      }
    } catch (e) {
      debugPrint('[SwipeFeedController] fetchBatch error: $e');
      hasError.value = true;
    } finally {
      isFetching.value = false;
    }
  }

  /// Force-resets exhausted/error state and re-fetches. Used by the Retry button.
  Future<void> retryFetch() async {
    isExhausted.value = false;
    hasError.value = false;
    _skipSeenFilter = false; // try personalized first on manual retry
    await fetchBatch();
  }

  void maybePrefetch() {
    if (cards.length <= 3 && !isFetching.value && !isExhausted.value) {
      fetchBatch();
    }
  }

  // ── Gender filter ─────────────────────────────────────────────────────────

  void setGenderFilter(int gender) {
    if (genderFilter.value == gender) return;
    genderFilter.value = gender;
    cards.clear();
    hasError.value = false;
    isExhausted.value = false;
    _skipSeenFilter = false; // reset so personalized feed is tried first
    fetchBatch();
  }

  // ── Swipe actions ─────────────────────────────────────────────────────────

  Future<void> onCardSwiped(SwipeAction action, SwipeProduct product) async {
    switch (action) {
      case SwipeAction.likeProduct:
        // Get overlay type and config
        final overlayType = _overlayManager.getOverlayType(action);
        final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
        onShowOverlay?.call(overlayType, overlayConfig);

        // Add to undo history (lightweight: only ID + action)
        _undoManager.addToHistory(product, SwipeActionType.likeProduct);
        canUndo.value = _undoManager.canUndo;

        // Instant removal — don't wait for API
        lastSwiped.value = product;
        _removeTopCard(product);
        _triggerWishlistFlash();
        maybePrefetch();
        // Fire API + local wishlist board update in background
        SwipeCartService.swipeAction(
          productId: product.id,
          action: action.apiValue,
        );
        _addToSwipesBoard(product);
        break;

      case SwipeAction.dislikeProduct:
        // Get overlay type and config
        final overlayType = _overlayManager.getOverlayType(action);
        final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
        onShowOverlay?.call(overlayType, overlayConfig);

        // Add to undo history (lightweight: only ID + action)
        _undoManager.addToHistory(product, SwipeActionType.dislikeProduct);
        canUndo.value = _undoManager.canUndo;

        // Instant removal
        lastSwiped.value = product;
        _removeTopCard(product);
        maybePrefetch();
        SwipeCartService.swipeAction(
          productId: product.id,
          action: action.apiValue,
        );
        break;

      case SwipeAction.swipeUp:
        // ADD_TO_CART — call API first; may return SELECT_VARIANT
        _showSizeSheet(product);
        return;

      case SwipeAction.swipeDown:
        // Get overlay type and config
        final overlayType = _overlayManager.getOverlayType(action);
        final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
        onShowOverlay?.call(overlayType, overlayConfig);

        // Add to undo history (lightweight: only ID + action)
        _undoManager.addToHistory(product, SwipeActionType.swipeDown);
        canUndo.value = _undoManager.canUndo;

        // OPEN_PDP — fire event, navigate, card stays
        SwipeCartService.swipeAction(
          productId: product.id,
          action: action.apiValue,
        );
        openPdp(product);
        return;
    }
  }

  Future<void> _showSizeSheet(SwipeProduct product) async {
    final context = Get.context;
    if (context == null) {
      onSwipeUpReset?.call();
      return;
    }

    // Call /swipe/action with ADD_TO_CART first
    final actionResult = await SwipeCartService.swipeAction(
      productId: product.id,
      action: 'ADD_TO_CART',
    );

    if (actionResult.success) {
      // No variant needed — added directly
      // Get overlay type and config
      final overlayType = _overlayManager.getOverlayType(SwipeAction.swipeUp);
      final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
      onShowOverlay?.call(overlayType, overlayConfig);

      // Add to undo history (lightweight: only ID + action)
      _undoManager.addToHistory(product, SwipeActionType.swipeUp);
      canUndo.value = _undoManager.canUndo;

      lastSwiped.value = product;
      onSwipeUpFlyUp?.call();
      _triggerCartFlash();
      try {
        Get.find<CartController>().getCartData(forceRefresh: true);
      } catch (_) {}
      _removeTopCard(product);
      maybePrefetch();
      return;
    }

    if (actionResult.needsVariantPick) {
      // Backend wants us to show a size picker
      if (!context.mounted) {
        onSwipeUpReset?.call();
        return;
      }

      final result = await showSwipeSizeSheet(
        context,
        product,
        variants: actionResult.variants ?? [],
        options: actionResult.options ?? {},
      );

      switch (result) {
        case SwipeSizeResult.added:
          // confirmVariant was called inside the sheet and succeeded
          // Get overlay type and config
          final overlayType =
              _overlayManager.getOverlayType(SwipeAction.swipeUp);
          final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
          onShowOverlay?.call(overlayType, overlayConfig);

          // Add to undo history (lightweight: only ID + action)
          _undoManager.addToHistory(product, SwipeActionType.swipeUp);
          canUndo.value = _undoManager.canUndo;

          lastSwiped.value = product;
          onSwipeUpFlyUp?.call();
          _triggerCartFlash();
          try {
            Get.find<CartController>().getCartData(forceRefresh: true);
          } catch (_) {}
          _removeTopCard(product);
          maybePrefetch();
          break;

        case SwipeSizeResult.wishlisted:
          // User added to wishlist from the out-of-stock sheet — remove card
          // Get overlay type and config
          final overlayType =
              _overlayManager.getOverlayType(SwipeAction.likeProduct);
          final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
          onShowOverlay?.call(overlayType, overlayConfig);

          // Add to undo history (lightweight: only ID + action)
          _undoManager.addToHistory(product, SwipeActionType.likeProduct);
          canUndo.value = _undoManager.canUndo;

          lastSwiped.value = product;
          onSwipeUpFlyUp?.call();
          _triggerWishlistFlash();
          _removeTopCard(product);
          maybePrefetch();
          break;

        case SwipeSizeResult.dismissed:
        case SwipeSizeResult.error:
        case SwipeSizeResult.noSizes:
          onSwipeUpReset?.call();
          break;
      }
      return;
    }

    // OUT_OF_STOCK or any other failure — silently fly the card off and remove it.
    // No message needed; the product just disappears like a dislike.
    if (actionResult.isOutOfStock) {
      onSwipeUpFlyUp?.call();
      _removeTopCard(product);
      maybePrefetch();
      return;
    }

    // Single-size product or auto-added product
    // If success is false but needsVariantPick and isOutOfStock are also false,
    // this is likely a single-size product that was successfully added
    if (!actionResult.success &&
        !actionResult.needsVariantPick &&
        !actionResult.isOutOfStock) {
      debugPrint(
          '[SwipeFeedController] Single-size product added to cart (no variant needed)');

      // Treat as success
      final overlayType = _overlayManager.getOverlayType(SwipeAction.swipeUp);
      final overlayConfig = _overlayManager.getOverlayConfig(overlayType);
      onShowOverlay?.call(overlayType, overlayConfig);

      // Add to undo history (lightweight: only ID + action)
      _undoManager.addToHistory(product, SwipeActionType.swipeUp);
      canUndo.value = _undoManager.canUndo;

      lastSwiped.value = product;
      onSwipeUpFlyUp?.call();
      _triggerCartFlash();
      try {
        Get.find<CartController>().getCartData(forceRefresh: true);
      } catch (_) {}
      _removeTopCard(product);
      maybePrefetch();
      return;
    }

    // Any other API failure — spring back
    onSwipeUpReset?.call();
  }

  void _removeTopCard(SwipeProduct product) {
    if (cards.isNotEmpty && cards.first.id == product.id) {
      cards.removeAt(0);
    }
  }

  void openPdp(SwipeProduct product) {
    Get.to(
      () => ProductDetailsScreenV2(
        productId: product.id,
        brandName: product.brandName,
        type: 'add',
        Slug: product.slug,
      ),
    );
  }

  // ── Undo ──────────────────────────────────────────────────────────────────

  Future<void> rewind() async {
    HapticFeedback.lightImpact();

    // Get the most recent product from undo history
    final product = _undoManager.restoreProduct();
    if (product != null) {
      // Re-insert at top of cards list
      cards.insert(0, product);

      // Update undo button visibility
      canUndo.value = _undoManager.canUndo;

      // Update lastSwiped for consistency
      lastSwiped.value = product;
    }

    // DO NOT call SwipeCartService.undoLastSwipe()
    // Product stays in cart/wishlist if it was added
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> shareProduct(SwipeProduct product) async {
    final link = await ShareLinkGenerator.generateProductShareLink(
      productId: product.id,
      slug: product.slug,
      brandName: product.brandName,
      type: 'add',
    );
    Share.share('Check out ${product.productName} on LaFetch!\n$link');
  }

  // ── Wishlist board (kept for right-swipe ADD_TO_WISHLIST) ─────────────────

  Future<void> _addToSwipesBoard(SwipeProduct product) async {
    try {
      if (_wishlistCtrl.wishlistList.isEmpty) {
        await _wishlistCtrl.fetchBoards();
      }

      final existing = _wishlistCtrl.wishlistList.firstWhereOrNull(
        (b) =>
            (b['name'] as String?)?.toLowerCase() ==
            kSwipeBoardName.toLowerCase(),
      );

      int boardId;
      if (existing != null) {
        boardId = existing['id'] as int;
      } else {
        await _wishlistCtrl.createBoard(kSwipeBoardName);
        await _wishlistCtrl.fetchBoards();
        final created = _wishlistCtrl.wishlistList.firstWhereOrNull(
          (b) =>
              (b['name'] as String?)?.toLowerCase() ==
              kSwipeBoardName.toLowerCase(),
        );
        if (created == null) return;
        boardId = created['id'] as int;
      }

      await _wishlistCtrl.addProductToBoard(boardId, product.id,
          price: product.sellingPrice);
    } catch (e) {
      print('[SwipeFeedController] _addToSwipesBoard error: $e');
    }
  }

  // ── Flash helpers ─────────────────────────────────────────────────────────

  void _triggerWishlistFlash() {
    wishlistFlash.value = true;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (isClosed) return; // ✅ FIXED: Check if controller is closed
      wishlistFlash.value = false;
    }).catchError((e) {
      print('⚠️ Error in _triggerWishlistFlash: $e');
    });
  }

  void _triggerCartFlash() {
    cartFlash.value = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (isClosed) return; // ✅ FIXED: Check if controller is closed
      cartFlash.value = false;
    }).catchError((e) {
      print('⚠️ Error in _triggerCartFlash: $e');
    });
  }

  @override
  void onClose() {
    _overlayManager.resetSession();
    _undoManager.clearHistory();
    super.onClose();
  }
}
