// ignore_for_file: deprecated_member_use
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../common/widget/cards/product_card.dart';
import '../common/widget/other/pounce_wrapper.dart';
import '../controllers/product_controller.dart';
import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';
import '../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import '../screens/search_results_screen.dart';
import '../services/event_tracking_service.dart';
import '../services/recommendation_service.dart';
import 'nudge_badge_row.dart';

// ── Pure helpers (top-level for testability) ───────────────────────────────

String deriveGender(int superCatId) {
  if (superCatId == 1) return 'men';
  if (superCatId == 2) return 'women';
  return 'accessories';
}

// ── Data model for a tab ───────────────────────────────────────────────────

class _Tab {
  final String id; // always a string; "all" or stringified subCatId
  final String name;
  const _Tab(this.id, this.name);
}

// ── Widget ─────────────────────────────────────────────────────────────────

class TrendingNowSection extends StatefulWidget {
  final int productId;
  final VoidCallback? onNavigating;

  const TrendingNowSection({
    super.key,
    required this.productId,
    this.onNavigating,
  });

  @override
  State<TrendingNowSection> createState() => _TrendingNowSectionState();
}

class _TrendingNowSectionState extends State<TrendingNowSection> {
  // Raw API data
  List<_Tab> _allTabs = [];
  Map<String, List<Map<String, dynamic>>> _productsByCategory = {};

  String _activeTabId = 'all';
  bool _loading = true;
  String _gender = 'accessories';

  static const int _maxPerTab = 12;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ctrl = Get.find<ProductController>();

      // Wait for product details to be populated
      int superCatId =
          (ctrl.productDetails['superCatId'] as num?)?.toInt() ?? 0;
      if (superCatId == 0) {
        for (var i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          superCatId =
              (ctrl.productDetails['superCatId'] as num?)?.toInt() ?? 0;
          if (superCatId != 0) break;
        }
      }
      _gender = deriveGender(superCatId);

      final data =
          await RecommendationService.instance.fetchTrendingByCategory(_gender);

      if (!mounted) return;

      // Parse tabs — mirrors web: data.tabs is [{id, name}]
      final rawTabs = data['tabs'];
      final tabs = <_Tab>[];
      if (rawTabs is List) {
        for (final t in rawTabs) {
          if (t is Map) {
            final id = t['id']?.toString() ?? '';
            final name = t['name']?.toString() ?? '';
            if (id.isNotEmpty && name.isNotEmpty) {
              tabs.add(_Tab(id, name));
            }
          }
        }
      }

      // Parse productsByCategory — keyed by subCatId string
      final rawByCategory = data['productsByCategory'];
      final byCategory = <String, List<Map<String, dynamic>>>{};
      if (rawByCategory is Map) {
        for (final entry in rawByCategory.entries) {
          final key = entry.key.toString();
          final list = entry.value;
          if (list is List) {
            byCategory[key] = list.whereType<Map<String, dynamic>>().toList();
          }
        }
      }

      setState(() {
        _allTabs = tabs;
        _productsByCategory = byCategory;
        _activeTabId = 'all';
        _loading = false;
      });
    } catch (e) {
      debugPrint('[TrendingNowSection] load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // Mirrors web: visibleTabs = tabs that have in-stock products
  // (we skip out-of-stock check for simplicity — just check non-empty)
  List<_Tab> get _visibleTabs {
    return _allTabs.where((tab) {
      if (tab.id == 'all') {
        // "all" is visible if any other tab has products
        return _allTabs.any((t) =>
            t.id != 'all' && (_productsByCategory[t.id] ?? []).isNotEmpty);
      }
      return (_productsByCategory[tab.id] ?? []).isNotEmpty;
    }).toList();
  }

  // Mirrors web: visibleProducts = productsByCategory[activeTab] or [] for "all"
  List<Map<String, dynamic>> get _visibleProducts {
    if (_activeTabId == 'all') {
      // Aggregate all products across all categories, deduplicated by id
      final seen = <dynamic>{};
      final all = <Map<String, dynamic>>[];
      for (final tab in _allTabs) {
        if (tab.id == 'all') continue;
        for (final p in (_productsByCategory[tab.id] ?? [])) {
          final id = p['id'];
          if (seen.add(id)) all.add(p);
          if (all.length >= _maxPerTab) break;
        }
        if (all.length >= _maxPerTab) break;
      }
      return all;
    }
    return (_productsByCategory[_activeTabId] ?? []).take(_maxPerTab).toList();
  }

  RecommendationProduct _mapProduct(Map<String, dynamic> p) {
    final rawPrice = p['basePrice'] ?? p['price'] ?? 0;
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice.toString()) ?? 0.0;
    final rawMrp = p['mrp'] ?? p['compareAtPrice'] ?? rawPrice;
    final mrp = rawMrp is num
        ? rawMrp.toDouble()
        : double.tryParse(rawMrp.toString()) ?? price;

    String imageUrl = '';
    final imageUrls = p['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      imageUrl = imageUrls.first.toString();
    } else if (p['image'] is String) {
      imageUrl = p['image'] as String;
    }

    final brand = p['brand'];
    final brandName = brand is Map
        ? (brand['name']?.toString() ?? '')
        : (brand?.toString() ?? '');

    return RecommendationProduct(
      id: (p['id'] as num?)?.toInt() ?? 0,
      slug: p['slug']?.toString() ?? '',
      brandName: brandName,
      productName: p['title']?.toString() ?? p['name']?.toString() ?? '',
      sellingPrice: price,
      imageUrl: imageUrl,
      nudges: RecommendationProduct.fromJson(p).nudges,
    );
  }

  void _navigate(RecommendationProduct product, int index) {
    EventTrackingService.instance.trackClick(product.id, index);

    final ctrl = Get.find<ProductController>();
    final savedDetails = Map<String, dynamic>.from(ctrl.productDetails);
    final savedImages = List.from(ctrl.imageList);
    final savedDisplay = List<String>.from(ctrl.currentDisplayImages);
    final savedSize = ctrl.selectedSize.value;
    final savedColor = ctrl.selectedColor.value;

    double savedScroll = 0;
    try {
      savedScroll = Scrollable.maybeOf(context)?.position.pixels ?? 0;
    } catch (_) {}

    ctrl.isDetails.value = false;
    widget.onNavigating?.call();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => ProductDetailsScreenV2(
          productId: product.id,
          brandName: product.brandName,
          type: 'add',
        ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        ),
      ),
    ).then((_) {
      ctrl.productDetails = savedDetails;
      ctrl.imageList.assignAll(savedImages);
      ctrl.currentDisplayImages.assignAll(savedDisplay);
      ctrl.selectedSize.value = savedSize;
      ctrl.selectedColor.value = savedColor;
      ctrl.isDetails.value = false;
      ctrl.update();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Scrollable.maybeOf(context)?.position.jumpTo(savedScroll);
        } catch (_) {}
      });
    });
  }

  void _navigateToListing() {
    final activeTab =
        _visibleTabs.firstWhereOrNull((t) => t.id == _activeTabId);
    Get.to(() => SearchResultsScreen(
          searchQuery: activeTab?.name ?? _activeTabId,
          searchResults: const [],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildShimmer();

    final visibleTabs = _visibleTabs;
    if (visibleTabs.isEmpty) return const SizedBox.shrink();

    // Ensure active tab is still valid — mirrors web useEffect
    if (!visibleTabs.any((t) => t.id == _activeTabId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _activeTabId = visibleTabs.first.id);
      });
    }

    final products = _visibleProducts;
    final activeTabMeta =
        visibleTabs.firstWhereOrNull((t) => t.id == _activeTabId);
    final showViewAll = _activeTabId != 'all' && activeTabMeta != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED FOR YOU',
                    style: TextStyle(
                      fontFamily: 'Clash Display Regular',
                      fontWeight: FontWeight.w400,
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    'LAFETCH RECOMMENDATIONS',
                    style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Container(height: 2, width: 40.sp, color: blackColor),
                ],
              ),
              // if (showViewAll)
              //   GestureDetector(
              //     onTap: _navigateToListing,
              //     child: Padding(
              //       padding: EdgeInsets.only(bottom: 2.sp),
              //       child: Text(
              //         'view all',
              //         style: TextStyle(
              //           fontFamily: 'Clash Display Regular',
              //           fontSize: 11.sp,
              //           color: Colors.grey.shade500,
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),

          SizedBox(height: 12.sp),

          // Tab chips — mirrors web TabPills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: visibleTabs.asMap().entries.map((entry) {
                final tab = entry.value;
                final isFirst = entry.key == 0;
                final isActive = tab.id == _activeTabId;
                return Padding(
                  padding: EdgeInsets.only(left: isFirst ? 0 : 8.sp),
                  child: _CategoryChip(
                    label: tab.name,
                    isActive: isActive,
                    onTap: () => setState(() => _activeTabId = tab.id),
                  ),
                );
              }).toList(),
            ),
          ),

          // SizedBox(height: 8.sp),

          // Product grid
          if (products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.sp),
              child: Center(
                child: Text(
                  'No trending products right now.',
                  style: TextStyle(
                    fontFamily: 'Clash Display Regular',
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.sp,
                childAspectRatio: 0.62,
              ),
              itemCount: min(products.length, _maxPerTab),
              itemBuilder: (_, i) {
                final raw = products[i];
                final product = _mapProduct(raw);
                return Listener(
                  onPointerDown: (_) {
                    Get.find<ProductController>().isDetails.value = false;
                  },
                  child: ProductGridCard(
                    imageUrl: product.imageUrl,
                    title: product.productName,
                    brandName: product.brandName,
                    price: product.sellingPrice,
                    nudges: product.nudges,
                    onTap: () => _navigate(product, i),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120.sp,
              height: 12.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.sp),
              ),
            ),
            SizedBox(height: 4.sp),
            Container(
              width: 200.sp,
              height: 16.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.sp),
              ),
            ),
            SizedBox(height: 4.sp),
            Container(width: 40.sp, height: 2, color: Colors.white),
            SizedBox(height: 12.sp),
            Row(
              children: [
                _shimmerChip(50.sp),
                SizedBox(width: 8.sp),
                _shimmerChip(80.sp),
                SizedBox(width: 8.sp),
                _shimmerChip(65.sp),
                SizedBox(width: 8.sp),
                _shimmerChip(70.sp),
              ],
            ),
            SizedBox(height: 12.sp),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8.sp,
              crossAxisSpacing: 8.sp,
              childAspectRatio: 0.62,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerChip(double width) => Container(
        width: width,
        height: 28.sp,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.sp),
        ),
      );
}

// ── Category Chip — mirrors web TabPills pill style ────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 7.sp),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(
            color: isActive ? Colors.black : const Color(0xFFE7E5E4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Clash Display Semibold',
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
            letterSpacing: 0.5,
            color: isActive ? Colors.white : const Color(0xFF44403C),
          ),
        ),
      ),
    );
  }
}
