import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../common/widget/lists/dummy_grid_list.dart';
import '../../../controllers/new_in_controller.dart';
import '../../../core/utils/image_helper.dart';
import '../../../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';

/// Tunable motion/layout constants.
/// Keep these subtle so the section feels premium, not game-like.
class _NewInHangerTuning {
  static const double viewportFraction = 0.42;
  static const double focusedScale = 1.04;
  static const double sideScale = 0.84;
  static const double maxSideRotationDeg = 2.2;
  static const double maxVerticalDrop = 16.0;

  static const Duration autoPlayInterval = Duration(milliseconds: 3600);
  static const Duration autoPlaySnapDuration = Duration(milliseconds: 520);
  static const Duration resumeAfterInactivity = Duration(seconds: 5);
}

/// NEW IN section with a premium rotating-hanger carousel.
class NewInSection extends StatelessWidget {
  final NewInController newInController;

  const NewInSection({
    super.key,
    required this.newInController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (newInController.isLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.sp, bottom: 12.sp),
                child: Container(
                  height: 20.sp,
                  width: 90.sp,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                ),
              ),
              const DummyGridList(size: 2),
            ],
          ),
        );
      }

      if (newInController.products.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.sp),
        child: _NewInRotatingHangerCarousel(
          products: newInController.products,
        ),
      );
    });
  }
}

class _NewInRotatingHangerCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const _NewInRotatingHangerCarousel({
    required this.products,
  });

  @override
  State<_NewInRotatingHangerCarousel> createState() =>
      _NewInRotatingHangerCarouselState();
}

class _NewInRotatingHangerCarouselState
    extends State<_NewInRotatingHangerCarousel> {
  static const int _infiniteMultiplier = 1000;
  static const String _bgAsset = 'assets/images/new_in_bg.png';
  static const String _hookAsset = 'assets/images/new_in_hook.png';
  static const String _newDropBgAsset = 'assets/images/new_drop_text_bg.svg';
  static const String _newDropTextAsset =
      'assets/images/new_drop_friday_text.svg';
  static const Color _punchColor = Color(0xFF2E2F35);

  late PageController _pageController;
  Timer? _autoPlayTimer;
  Timer? _resumeTimer;
  int _currentPage = 0;

  int get _seedPage => widget.products.length * _infiniteMultiplier;
  int get _virtualCount => widget.products.isEmpty
      ? 0
      : widget.products.length * _infiniteMultiplier * 2;

  @override
  void initState() {
    super.initState();
    _configureControllerAndAutoplay(shouldJumpToSeed: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheVisibleProductImages();
  }

  @override
  void didUpdateWidget(covariant _NewInRotatingHangerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _configureControllerAndAutoplay(shouldJumpToSeed: true);
      _precacheVisibleProductImages();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _configureControllerAndAutoplay({required bool shouldJumpToSeed}) {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();

    if (!_isControllerUsable()) {
      _pageController = PageController(
        viewportFraction: _NewInHangerTuning.viewportFraction,
      );
    }

    if (widget.products.isEmpty) {
      return;
    }

    if (shouldJumpToSeed) {
      _pageController = PageController(
        initialPage: _seedPage,
        viewportFraction: _NewInHangerTuning.viewportFraction,
      );
      _currentPage = _seedPage;
    }

    _startAutoplay();
  }

  bool _isControllerUsable() {
    try {
      return _pageController.hasClients || _pageController.initialPage >= 0;
    } catch (_) {
      return false;
    }
  }

  void _startAutoplay() {
    _autoPlayTimer?.cancel();
    if (widget.products.length <= 1) return;

    _autoPlayTimer = Timer.periodic(_NewInHangerTuning.autoPlayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: _NewInHangerTuning.autoPlaySnapDuration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _stopAutoplayImmediately() {
    _autoPlayTimer?.cancel();
    _resumeTimer?.cancel();
  }

  void _scheduleResumeAutoplay() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_NewInHangerTuning.resumeAfterInactivity, () {
      if (!mounted) return;
      _startAutoplay();
    });
  }

  void _precacheVisibleProductImages() {
    if (!mounted || widget.products.isEmpty) return;

    // Precache only the first few images used by initial visible cards.
    // This improves first swipe smoothness without over-consuming memory.
    final int count = math.min(widget.products.length, 6);
    for (int i = 0; i < count; i++) {
      final imageUrl = _extractImageUrl(widget.products[i]);
      if (imageUrl.isEmpty) continue;
      precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: const Text(
              "NEW IN",
              style: TextStyle(
                fontFamily: "Clash Display Semibold",
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10.sp),
          Container(
            height: 370.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              image: const DecorationImage(
                image: AssetImage(_bgAsset),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 14.sp,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 165.sp,
                      height: 44.sp,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            _newDropBgAsset,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            _newDropTextAsset,
                            width: 118.sp,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 78.sp),
                  child: Listener(
                    onPointerDown: (_) => _stopAutoplayImmediately(),
                    onPointerUp: (_) => _scheduleResumeAutoplay(),
                    onPointerCancel: (_) => _scheduleResumeAutoplay(),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _virtualCount,
                      padEnds: true,
                      clipBehavior: Clip.none,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      onPageChanged: (index) => _currentPage = index,
                      itemBuilder: (context, index) {
                        final int realIndex = index % widget.products.length;
                        final product = widget.products[realIndex];

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            final double page = _pageController.hasClients
                                ? (_pageController.page ??
                                    _currentPage.toDouble())
                                : _currentPage.toDouble();

                            // Distance from center page:
                            // 0 -> focused card, 1 -> immediate side card.
                            final double distance =
                                (index - page).abs().clamp(0.0, 1.0);
                            final double t = Curves.easeOut.transform(distance);

                            final double scale = lerpDouble(
                                  _NewInHangerTuning.focusedScale,
                                  _NewInHangerTuning.sideScale,
                                  t,
                                ) ??
                                _NewInHangerTuning.sideScale;

                            final double translateY = lerpDouble(
                                  0.0,
                                  _NewInHangerTuning.maxVerticalDrop,
                                  t,
                                ) ??
                                0.0;

                            final double signedDirection = (index - page).sign;
                            final double rotationRad = (signedDirection *
                                    _NewInHangerTuning.maxSideRotationDeg *
                                    (math.pi / 180.0)) *
                                t;

                            return Align(
                              child: Transform(
                                alignment: Alignment.topCenter,
                                transform: Matrix4.identity()
                                  ..translate(0.0, translateY)
                                  ..rotateZ(rotationRad)
                                  ..scale(scale),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.sp),
                            child: _NewInCarouselItem(
                              product: product,
                              imageUrl: _extractImageUrl(product),
                              hookAsset: _hookAsset,
                              punchColor: _punchColor,
                              onTap: () => _openProduct(product),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openProduct(Map<String, dynamic> product) {
    final productIdRaw = product['id'];
    final productId = productIdRaw is int
        ? productIdRaw
        : int.tryParse(productIdRaw?.toString() ?? '') ?? 0;
    if (productId <= 0) return;

    final brand = (product['brand'] as Map?)?['name'] as String? ?? '';
    Get.to(() => ProductDetailsScreenV2(
          productId: productId,
          type: "add",
          brandName: brand,
        ));
  }

  String _extractImageUrl(Map<String, dynamic> product) {
    // Keep old NEW IN behavior as the primary source since it previously worked.
    final legacyUrls = product['imageUrls'] as List?;
    final legacyUrl = legacyUrls
            ?.map((e) => e?.toString().trim() ?? '')
            .firstWhere((e) => e.isNotEmpty, orElse: () => '') ??
        '';
    if (legacyUrl.isNotEmpty) {
      return legacyUrl.startsWith('//') ? 'https:$legacyUrl' : legacyUrl;
    }

    String normalize(dynamic raw) {
      final value = raw?.toString().trim() ?? '';
      if (value.isEmpty) return '';
      if (value.startsWith('//')) return 'https:$value';
      return value;
    }

    String pickFirstFromList(List<dynamic> list) {
      for (final item in list) {
        if (item is String) {
          final normalized = normalize(item);
          if (normalized.isNotEmpty) return normalized;
        } else if (item is Map) {
          final normalized = normalize(
            item['url'] ??
                item['imageUrl'] ??
                item['image'] ??
                item['src'] ??
                item['name'] ??
                item['mobileImage'],
          );
          if (normalized.isNotEmpty) return normalized;
        }
      }
      return '';
    }

    final imageUrls = product['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      final fromImageUrls = pickFirstFromList(imageUrls);
      if (fromImageUrls.isNotEmpty) return fromImageUrls;
    }

    final images = product['images'];
    if (images is List && images.isNotEmpty) {
      final fromImages = pickFirstFromList(images);
      if (fromImages.isNotEmpty) return fromImages;
    }

    final fallback = normalize(
      product['imageUrl'] ??
          product['image'] ??
          product['thumbnail'] ??
          product['mobileImage'] ??
          product['primaryImage'],
    );
    return fallback;
  }
}

class _NewInCarouselItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final String imageUrl;
  final String hookAsset;
  final Color punchColor;
  final VoidCallback onTap;

  const _NewInCarouselItem({
    required this.product,
    required this.imageUrl,
    required this.hookAsset,
    required this.punchColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = (product['title'] as String? ?? '').toUpperCase();
    final String brand =
        ((product['brand'] as Map?)?['name'] as String? ?? '').toUpperCase();
    final num mrp = (product['mrp'] as num?) ?? 0;
    final num price = ((product['basePrice'] ?? product['mrp']) as num?) ?? mrp;

    return RepaintBoundary(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 188.sp,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 10.sp,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      hookAsset,
                      width: 22.sp,
                      height: 24.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 30.sp,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 1.6.sp,
                      height: 14.sp,
                      color: const Color(0xFF141414),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 36.sp),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.sp),
                            child: SizedBox(
                              height: 146.sp,
                              width: double.infinity,
                              child: _CardImage(imageUrl: imageUrl),
                            ),
                          ),
                          SizedBox(height: 8.sp),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Clash Display Semibold",
                              fontSize: 12.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 2.sp),
                          Text(
                            brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Clash Display Regular",
                              fontSize: 10.sp,
                              color: const Color(0xFF727272),
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Row(
                            children: [
                              Text(
                                "₹${price.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontFamily: "Clash Display Semibold",
                                  fontSize: 13.sp,
                                  color: Colors.black,
                                ),
                              ),
                              if (mrp > price) ...[
                                SizedBox(width: 6.sp),
                                Text(
                                  "₹${mrp.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontFamily: "Clash Display Regular",
                                    fontSize: 10.sp,
                                    color: const Color(0xFF9A9A9A),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 46.sp,
                  left: 0,
                  right: 0,
                  child: Center(
                    // Punch hole aligned to the hook center to create
                    // the hanging-card illusion over the dark background.
                    child: Container(
                      width: 10.sp,
                      height: 10.sp,
                      decoration: BoxDecoration(
                        color: punchColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String imageUrl;
  const _CardImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.black.withOpacity(0.04),
        child: Icon(
          Icons.image_outlined,
          size: 28.sp,
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: ImageHelper.toWebP(imageUrl),
      fit: BoxFit.cover,
      memCacheWidth: 420,
      memCacheHeight: 420,
      maxWidthDiskCache: 420,
      maxHeightDiskCache: 420,
      cacheManager: CacheManager(
        Config(
          "newInCarouselCache",
          stalePeriod: const Duration(days: 10),
          maxNrOfCacheObjects: 80,
        ),
      ),
      placeholder: (_, __) => Container(color: Colors.black.withOpacity(0.04)),
      errorWidget: (_, __, ___) => Container(
        color: Colors.black.withOpacity(0.05),
        child: Icon(
          Icons.broken_image_outlined,
          size: 24.sp,
          color: Colors.grey.withOpacity(0.6),
        ),
      ),
    );
  }
}
