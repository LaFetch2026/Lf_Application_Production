import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../common/widget/other/pounce_wrapper.dart';
import '../controllers/product_controller.dart';
import '../core/constant/constants.dart';
import '../models/recommendation_event.dart';
import '../screens/catalog/productlist/productdetailsscreen_v2.dart';
import '../services/event_tracking_service.dart';
import '../services/recommendation_service.dart';

class SimilarProductsCarousel extends StatefulWidget {
  final int productId;
  final VoidCallback? onNavigating;
  const SimilarProductsCarousel({super.key, required this.productId, this.onNavigating});

  @override
  State<SimilarProductsCarousel> createState() =>
      _SimilarProductsCarouselState();
}

class _SimilarProductsCarouselState extends State<SimilarProductsCarousel> {
  List<RecommendationProduct> _similar = [];
  List<RecommendationProduct> _trending = [];
  bool _loadingSimilar = true;
  bool _loadingTrending = true;

  @override
  void initState() {
    super.initState();
    _loadSimilar();
    _loadTrending();
  }

  Future<void> _loadSimilar() async {
    try {
      final products =
          await RecommendationService.instance.fetchSimilar(widget.productId);
      if (mounted) {
        setState(() {
          _similar = products;
          _loadingSimilar = false;
        });
        for (var i = 0; i < products.length; i++) {
          EventTrackingService.instance.trackImpression(products[i].id, i);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSimilar = false);
    }
  }

  Future<void> _loadTrending() async {
    try {
      final products = await RecommendationService.instance.fetchTrending();
      if (mounted)
        setState(() {
          _trending = products;
          _loadingTrending = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingTrending = false);
    }
  }

  void _navigate(
      RecommendationProduct product,
      int index,
      Map<String, dynamic> savedDetails,
      List savedImages,
      List<String> savedDisplay,
      String savedSize,
      String savedColor) {
    EventTrackingService.instance.trackClick(product.id, index);

    final ctrl = Get.find<ProductController>();

    // Save scroll position of the parent PDP
    double savedScroll = 0;
    try {
      final scrollable = Scrollable.maybeOf(context);
      savedScroll = scrollable?.position.pixels ?? 0;
    } catch (_) {}

    // Freeze isDetails so the current PDP doesn't rebuild during transition
    ctrl.isDetails.value = false;

    // Tell parent PDP it's going to background — prevents isDetails rebuild
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
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            )),
            child: child,
          );
        },
      ),
    ).then((_) {
      // Restore snapshot so current PDP shows correct data
      ctrl.productDetails = savedDetails;
      ctrl.imageList.assignAll(savedImages);
      ctrl.currentDisplayImages.assignAll(savedDisplay);
      ctrl.selectedSize.value = savedSize;
      ctrl.selectedColor.value = savedColor;
      ctrl.isDetails.value = false;
      ctrl.update();

      // Restore scroll position after rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final scrollable = Scrollable.maybeOf(context);
          scrollable?.position.jumpTo(savedScroll);
        } catch (_) {}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSimilar = !_loadingSimilar && _similar.isNotEmpty;
    final hasTrending = !_loadingTrending && _trending.isNotEmpty;

    if (!hasSimilar && !hasTrending && !_loadingSimilar && !_loadingTrending) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Similar Products ──────────────────────────────────────
        if (_loadingSimilar)
          _buildShimmerRow('YOU MAY ALSO LIKE')
        else if (_similar.isNotEmpty) ...[
          _buildSectionHeader('YOU MAY ALSO LIKE'),
          _buildRow(_similar, isTrending: false),
          SizedBox(height: 8.sp),
        ],

        // ── Trending Products ─────────────────────────────────────
        if (_loadingTrending)
          _buildShimmerRow('TRENDING NOW')
        else if (_trending.isNotEmpty) ...[
          _buildSectionHeader('TRENDING NOW'),
          _buildRow(_trending, isTrending: true),
          SizedBox(height: 16.sp),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16.sp, right: 16.sp, top: 16.sp, bottom: 12.sp),
      child: Text(
        title,
        maxLines: 1,
        style: TextStyle(
          fontFamily: 'Clash Display Semibold',
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: blackColor,
        ),
      ),
    );
  }

  Widget _buildRow(List<RecommendationProduct> products,
      {required bool isTrending}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: products.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(right: 12.sp),
            child: _buildCard(entry.value, entry.key,
                showTrendingBadge: isTrending && entry.key < 3),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerRow(String title) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140.sp,
              height: 18.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.sp),
              ),
            ),
            SizedBox(height: 12.sp),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(right: 12.sp),
                    child: Container(
                      width: 160.sp,
                      height: 240.sp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(RecommendationProduct product, int index,
      {bool showTrendingBadge = false}) {
    // Snapshot controller state at build time — before any tap delay
    final ctrl = Get.find<ProductController>();
    final savedDetails = Map<String, dynamic>.from(ctrl.productDetails);
    final savedImages = List.from(ctrl.imageList);
    final savedDisplay = List<String>.from(ctrl.currentDisplayImages);
    final savedSize = ctrl.selectedSize.value;
    final savedColor = ctrl.selectedColor.value;

    return Listener(
        // On pointer DOWN (before PounceWrapper's 60ms delay), freeze the controller
        onPointerDown: (_) {
          ctrl.isDetails.value = false;
        },
        child: PounceWrapper(
          scaleFactor: 0.97,
          duration: const Duration(milliseconds: 80),
          onTap: () => _navigate(product, index, savedDetails, savedImages,
              savedDisplay, savedSize, savedColor),
          child: SizedBox(
            width: 160.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.sp),
                        topRight: Radius.circular(8.sp),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: 160.sp,
                        height: 180.sp,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            width: 160.sp,
                            height: 180.sp,
                            color: colorSecondary),
                        errorWidget: (_, __, ___) => Container(
                            width: 160.sp,
                            height: 180.sp,
                            color: colorSecondary,
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 32.sp)),
                      ),
                    ),
                    // if (showTrendingBadge)
                    //   Positioned(
                    //     top: 8.sp,
                    //     left: 8.sp,
                    //     child: Container(
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal: 6.sp, vertical: 3.sp),
                    //       decoration: BoxDecoration(
                    //         color: Colors.orange,
                    //         borderRadius: BorderRadius.circular(4.sp),
                    //       ),
                    //       child: Text(
                    //         '🔥 Trending',
                    //         style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 9.sp,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                SizedBox(height: 6.sp),
                if (product.brandName.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.sp),
                    child: Text(
                      product.brandName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Clash Display Semibold',
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                SizedBox(height: 2.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: Text(
                    product.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Clash Display',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: blackColor,
                    ),
                  ),
                ),
                SizedBox(height: 4.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.sp),
                  child: Text(
                    '₹${product.sellingPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Clash Display Semibold',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: colorPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
