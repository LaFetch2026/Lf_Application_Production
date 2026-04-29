// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/wishlist_controller.dart';
import '../../core/utils/share_link_generator.dart';
import '../../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import '../models/swipe_product.dart';
import '../services/swipe_feed_service.dart';
import '../services/swipe_tracking_service.dart';

const kSwipeTutorialSeen = 'swipe_tutorial_seen';
const kSwipeBoardName = 'LF Swipes';

class SwipeFeedController extends GetxController {
  // ── Singleton access ──────────────────────────────────────────────────────
  static SwipeFeedController get instance => Get.find();

  // ── Dependencies ──────────────────────────────────────────────────────────
  late final WishlistController _wishlistCtrl;

  // ── Feed state ────────────────────────────────────────────────────────────
  final cards = <SwipeProduct>[].obs;
  final isFetching = false.obs;
  final hasError = false.obs;

  // ── Gender filter: 0=All, 1=Men, 2=Women ─────────────────────────────────
  final genderFilter = 0.obs;

  // ── Undo / rewind ─────────────────────────────────────────────────────────
  final Rx<SwipeProduct?> lastSwiped = Rx(null);

  // ── Tutorial ──────────────────────────────────────────────────────────────
  final showTutorial = false.obs;

  // ── Flash signals (observed by screen for animations) ────────────────────
  final wishlistFlash = false.obs;
  final cartFlash = false.obs;

  @override
  void onInit() {
    super.onInit();
    _wishlistCtrl = Get.find<WishlistController>();
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

  Future<void> fetchBatch() async {
    if (isFetching.value) return;
    final wasEmpty = cards.isEmpty;
    isFetching.value = true;
    hasError.value = false;

    try {
      final results = await SwipeFeedService.instance.fetchBatch(
        genderFilter: genderFilter.value,
      );
      cards.addAll(results);
      if (wasEmpty && results.isEmpty) hasError.value = true;
    } catch (_) {
      hasError.value = true;
    } finally {
      isFetching.value = false;
    }
  }

  void maybePrefetch() {
    if (cards.length <= 3 && !isFetching.value) fetchBatch();
  }

  // ── Gender filter ─────────────────────────────────────────────────────────

  void setGenderFilter(int gender) {
    if (genderFilter.value == gender) return;
    genderFilter.value = gender;
    cards.clear();
    hasError.value = false;
    fetchBatch();
  }

  // ── Swipe actions ─────────────────────────────────────────────────────────

  Future<void> onCardSwiped(SwipeAction action, SwipeProduct product) async {
    lastSwiped.value = product;
    SwipeTrackingService.track(action, product.id);

    switch (action) {
      case SwipeAction.likeProduct:
        _triggerWishlistFlash();
        cards.removeAt(0);
        _addToSwipesBoard(product);
        break;

      case SwipeAction.dislikeProduct:
        cards.removeAt(0);
        break;

      case SwipeAction.swipeUp:
        _triggerCartFlash();
        cards.removeAt(0);
        openPdp(product);
        break;

      case SwipeAction.swipeDown:
        // Card stays — just open PDP
        openPdp(product);
        return;
    }

    maybePrefetch();
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

  // ── Wishlist board ────────────────────────────────────────────────────────

  Future<void> _addToSwipesBoard(SwipeProduct product) async {
    try {
      if (_wishlistCtrl.wishlistList.isEmpty) {
        await _wishlistCtrl.fetchBoards();
      }

      final existing = _wishlistCtrl.wishlistList.firstWhereOrNull(
        (b) => (b['name'] as String?)?.toLowerCase() == kSwipeBoardName.toLowerCase(),
      );

      int boardId;
      if (existing != null) {
        boardId = existing['id'] as int;
      } else {
        await _wishlistCtrl.createBoard(kSwipeBoardName);
        await _wishlistCtrl.fetchBoards();
        final created = _wishlistCtrl.wishlistList.firstWhereOrNull(
          (b) => (b['name'] as String?)?.toLowerCase() == kSwipeBoardName.toLowerCase(),
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

  // ── Rewind ────────────────────────────────────────────────────────────────

  void rewind() {
    final prev = lastSwiped.value;
    if (prev == null) return;
    HapticFeedback.lightImpact();
    cards.insert(0, prev);
    lastSwiped.value = null;
  }

  // ── Flash helpers ─────────────────────────────────────────────────────────

  void _triggerWishlistFlash() {
    wishlistFlash.value = true;
    Future.delayed(const Duration(milliseconds: 900), () {
      wishlistFlash.value = false;
    });
  }

  void _triggerCartFlash() {
    cartFlash.value = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      cartFlash.value = false;
    });
  }
}
