import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../common/widget/lists/dummy_grid_list.dart';
import '../../../controllers/new_in_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import 'premium_product_card.dart';

/// Tunable motion/layout constants.
/// Keep these subtle so the section feels premium, not game-like.
class _NewInHangerTuning {
  static const double viewportFraction = 0.50;
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
  static const String _newDropTextureAsset =
      'assets/images/new_drop_text_texture.svg';
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
                      width: 185.sp,
                      height: 64.sp,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            _newDropBgAsset,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            _newDropTextureAsset,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            _newDropTextAsset,
                            // width: 118.sp,
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
    String normalize(String raw) {
      final value = raw.trim();
      if (value.isEmpty) return '';
      if (value.startsWith('//')) return 'https:$value';
      if (value.startsWith('/')) {
        final host = ApiConstants.baseUrl.replaceAll('/api', '');
        return '$host$value';
      }
      return value;
    }

    // Primary: exact payload shape you shared (List<String> imageUrls).
    final imageUrls = product['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      for (final entry in imageUrls) {
        final candidate = normalize(entry?.toString() ?? '');
        if (candidate.isNotEmpty) return candidate;
      }
    }

    // Secondary: list under `images`.
    final images = product['images'];
    if (images is List && images.isNotEmpty) {
      for (final entry in images) {
        if (entry is String) {
          final candidate = normalize(entry);
          if (candidate.isNotEmpty) return candidate;
        } else if (entry is Map) {
          for (final key in const ['url', 'imageUrl', 'image', 'src', 'name']) {
            final candidate = normalize(entry[key]?.toString() ?? '');
            if (candidate.isNotEmpty) return candidate;
          }
        }
      }
    }

    // Tertiary: direct keys.
    for (final key in const [
      'imageUrl',
      'image',
      'thumbnail',
      'coverImage',
      'primary_image',
      'primaryImage',
      'mobileImage',
    ]) {
      final candidate = normalize(product[key]?.toString() ?? '');
      if (candidate.isNotEmpty) return candidate;
    }

    return '';
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
    final num price = () {
      final raw = product['displayPrice'] ??
          product['basePrice'] ??
          product['price'] ??
          product['msp'] ??
          product['mrp'];
      if (raw is num) return raw;
      return num.tryParse(raw?.toString().replaceAll(',', '') ?? '') ?? 0;
    }();
    final num mrp = () {
      final raw = product['displayMrp'] ??
          product['mrp'] ??
          product['compareAtPrice'] ??
          product['manufacturingAmount'];
      if (raw is num) return raw;
      return num.tryParse(raw?.toString().replaceAll(',', '') ?? '') ?? 0;
    }();
    final int? discountPercent = () {
      final d = product['discountPercent'];
      if (d is int) return d > 0 ? d : null;
      if (d is num) {
        final v = d.round();
        return v > 0 ? v : null;
      }
      final parsed = int.tryParse(d?.toString() ?? '');
      return (parsed != null && parsed > 0) ? parsed : null;
    }();

    return RepaintBoundary(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 210.sp,
            height: 265.sp,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0.sp,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      hookAsset,
                      width: 26.sp,
                      height: 28.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 25.sp,
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
                  child: PremiumProductCard(
                    imageUrl: imageUrl,
                    title: title,
                    brand: brand,
                    price: price,
                    mrp: mrp,
                    discountPercent: discountPercent,
                    condensed: true,
                    theme: PremiumProductCardTheme.light,
                    showWishlist: false,
                    showAdd: false,
                    onTap: onTap,
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
                      width: 12.sp,
                      height: 12.sp,
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
