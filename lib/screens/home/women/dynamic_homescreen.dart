// ignore_for_file: avoid_print
//
// DynamicHomeScreen
// -----------------
// Replaces the hardcoded gender tabs (MEN / WOMEN / ESSENTIALS) with tabs
// driven by GET /api/menu-v2.
//
// Key fix for the race condition:
//   We do NOT render HomeScreen until we have a definitive answer from the
//   menu API (success OR failure). This guarantees that when HomeScreen mounts
//   and its initState calls getGenderTabs(), the menuTabsInjected flag is
//   already true and genderTabs is already populated — so the old
//   /category-hierarchy call is skipped entirely.
//
//   States:
//     _MenuState.waiting  → show a minimal loading indicator
//     _MenuState.ready    → tabs injected, render HomeScreen
//     _MenuState.fallback → API failed, render HomeScreen without injection
//                           (HomeScreen falls back to /category-hierarchy)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';
import 'package:video_player/video_player.dart';

import '../../../controllers/brand_controller.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/menu_controller.dart' as mc;
import '../../../controllers/product_controller.dart';
import '../../../models/menu_item_model.dart';
import 'homescreen.dart';

// ---------------------------------------------------------------------------
// Hardcoded video URLs for the three known sections (same as HomeScreen)
// ---------------------------------------------------------------------------
const Map<String, String> _kSlugVideoUrls = {
  'men':
      "https://la-fetch.s3.ap-south-1.amazonaws.com/Application_Banners/Lafetch-Men's.mp4",
  'women':
      "https://la-fetch.s3.ap-south-1.amazonaws.com/Application_Banners/Lafetch-Women.mp4",
  'accessories':
      "https://la-fetch.s3.ap-south-1.amazonaws.com/Application_Banners/accessories-banner.mp4",
};

enum _MenuState { waiting, ready, fallback }

// ---------------------------------------------------------------------------
// DynamicHomeScreen
// ---------------------------------------------------------------------------
class DynamicHomeScreen extends StatefulWidget {
  final Function(int)? onPressed;

  const DynamicHomeScreen({this.onPressed, super.key});

  @override
  State<DynamicHomeScreen> createState() => _DynamicHomeScreenState();
}

class _DynamicHomeScreenState extends State<DynamicHomeScreen>
    with TickerProviderStateMixin {
  late final mc.MenuController _menuController;
  final HomeController _homeController = Get.find<HomeController>();
  final ProductController _productController = Get.find<ProductController>();
  final CatalogController _catalogController = Get.find<CatalogController>();
  final BrandController _brandController = Get.find<BrandController>();

  _MenuState _state = _MenuState.waiting;

  // Video controllers keyed by slug
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    // Use Get.put with permanent:false so it re-fetches if the controller
    // was previously disposed. If already registered, Get.put returns the
    // existing instance.
    _menuController = Get.put(mc.MenuController());

    // Watch for loading → false transition
    ever(_menuController.isLoading, (bool loading) {
      if (!loading) _onLoadingFinished();
    });

    // If the controller finished loading before we registered the listener
    // (e.g. instant cache hit), handle it now.
    if (!_menuController.isLoading.value) {
      // Post-frame so setState is safe
      WidgetsBinding.instance.addPostFrameCallback((_) => _onLoadingFinished());
    }
  }

  // -------------------------------------------------------------------------
  // Called once when isLoading flips to false
  // -------------------------------------------------------------------------
  void _onLoadingFinished() {
    if (!mounted) return;
    final items = _menuController.menuItems;

    if (items.isEmpty || _menuController.hasError.value) {
      print('⚠️ DynamicHomeScreen: menu empty/error → fallback');
      setState(() => _state = _MenuState.fallback);
      return;
    }

    _injectTabs(items);
    setState(() => _state = _MenuState.ready);
  }

  void _injectTabs(List<MenuItem> items) {
    final dynamicTabs = items
        .map((item) => <String, dynamic>{
              'id': item.genderValue,
              'name': item.label,
              'slug': item.shopSlug ?? '',
            })
        .toList();

    // Set flag BEFORE assigning tabs so HomeScreen's initState sees it
    _homeController.menuTabsInjected = true;
    _homeController.genderTabs.assignAll(dynamicTabs);

    print('✅ DynamicHomeScreen: injected ${items.length} tabs → '
        '${dynamicTabs.map((t) => t['name']).join(', ')}');

    // Pre-init video controllers for known slugs
    for (final item in items) {
      final slug = item.shopSlug?.toLowerCase();
      if (slug != null &&
          _kSlugVideoUrls.containsKey(slug) &&
          !_videoControllers.containsKey(slug)) {
        _initVideo(slug, _kSlugVideoUrls[slug]!);
      }
    }
  }

  Future<void> _initVideo(String slug, String url) async {
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      ctrl
        ..setLooping(true)
        ..setVolume(0.0)
        ..play();
      _videoControllers[slug] = ctrl;
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ DynamicHomeScreen video init error ($slug): $e');
    }
  }

  @override
  void dispose() {
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _MenuState.waiting:
        // Hold HomeScreen back until we know what tabs to show.
        // Show a minimal black-on-white spinner that matches the app's style.
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
              // child: CircularProgressIndicator(
              //   strokeWidth: 2,
              //   color: Colors.black,
              // ),
              child: Center(child: LfLogoLoader(size: 28))),
        );

      case _MenuState.ready:
      case _MenuState.fallback:
        // Tabs are already injected (ready) or we're falling back to the old
        // /category-hierarchy path (fallback). Either way HomeScreen handles it.
        return HomeScreen(onPressed: widget.onPressed);
    }
  }
}
