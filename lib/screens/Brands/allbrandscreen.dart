// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:math' show Random;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/Brands/brand_product_list.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/quick/brandproductscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../common/widget/appbar/allbrand_appbar.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/brand_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/product_controller.dart';
import '../../core/constant/constants.dart';
import '../../core/utils/analytics_helper.dart';
import '../cartscreen.dart';

class AllBrandScreen extends StatefulWidget {
  final String screen;
  final String slug;
  final int id;

  const AllBrandScreen({
    required this.id,
    required this.screen,
    super.key,
    required this.slug,
  });

  @override
  State<AllBrandScreen> createState() => AllBrandScreenState();
}

class AllBrandScreenState extends State<AllBrandScreen> {
  final productController = Get.put(ProductController());
  final ScrollController _scrollController = ScrollController();
  final List<String> _triggeredScrolls = [];
  final brandController = Get.put(BrandController());
  final homeController = Get.put(HomeController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  bool showDescription = false;

  // --- Optimized video handling ---
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  String _videoErrorMessage = '';
  bool _isMuted = false;
  String? _cachedVideoUrl;
  String? _cachedLogoUrl;
  String? _cachedBrandName;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: homeAppBarColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: homeAppBarColor,
      ));

      brandController.brandProductDetailsList.clear();
      productController.productSortBy.value = "";
      productController.filterProductEnable.value = false;
      productController.categoryFilter.value = 0;

      // ✅ Check if brand details are already loaded for this brand (prevents double API call)
      final currentBrandId = (brandController.brandDetails["brandInfo"]?["id"] is int)
          ? brandController.brandDetails["brandInfo"]["id"] as int
          : int.tryParse(brandController.brandDetails["brandInfo"]?["id"]?.toString() ?? '0') ?? 0;

      final needsToFetch = currentBrandId != widget.id ||
                           brandController.brandDetails["brandInfo"] == null ||
                           (brandController.brandDetails["products"] as List?)?.isEmpty == true;

      if (needsToFetch) {
        print("🔄 Fetching brand details for ID: ${widget.id}");
        await brandController.getBrandDetails(widget.id, widget.slug);
      } else {
        print("✅ Using cached brand details for ID: ${widget.id}");
      }
      // TEMPORARY FIX: Commenting out getBrandProducts because it returns incomplete data
      // TODO: Uncomment when backend fixes /brand-products API to return images and prices
      // await brandController.getBrandProducts(widget.id, showLoader: true);

      // Clear cached normalized products to force recalculation with new data
      _cachedNormalizedProducts = null;

      // Cache values to avoid repeated map lookups
      _cachedBrandName =
          (brandController.brandDetails["brandInfo"]?["name"] ?? '').toString();
      _cachedLogoUrl =
          (brandController.brandDetails["brandInfo"]?["logo"] ?? '').toString();
      final mediaUrl =
          (brandController.brandDetails["brandInfo"]?["video"]?.toString() ??
              "");

      if (mounted) setState(() {});

      // Initialize video asynchronously after UI is rendered
      if (mediaUrl.isNotEmpty && _looksLikeVideo(mediaUrl)) {
        _cachedVideoUrl = mediaUrl;
        // Delay video initialization to prioritize UI rendering
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _initializeVideo(mediaUrl);
        });
      } else {
        _hasVideoError = true;
        _videoErrorMessage = 'Using image banner';
        if (mounted) setState(() {});
      }
    });
  }

  bool _looksLikeVideo(String u) {
    final x = u.toLowerCase();
    return x.endsWith('.mp4') ||
        x.endsWith('.mov') ||
        x.endsWith('.m3u8') ||
        x.endsWith('.webm') ||
        x.endsWith('.mkv') ||
        x.endsWith('.avi');
  }

  bool _looksLikeImage(String u) {
    final x = u.toLowerCase();
    return x.endsWith('.png') ||
        x.endsWith('.jpg') ||
        x.endsWith('.jpeg') ||
        x.endsWith('.webp') ||
        x.endsWith('.gif') ||
        x.endsWith('.bmp');
  }

  Future<void> _initializeVideo(String videoUrl) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoPlayerController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _hasVideoError = false;
        });

        // Start playing after initialization
        _videoPlayerController!.setLooping(true);
        _videoPlayerController!.setVolume(1.0);
        _videoPlayerController!.play();
      }

      // Add error listener
      _videoPlayerController!.addListener(_videoListener);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage = 'Video load failed: $e';
        });
      }
    }
  }

  void _videoListener() {
    if (_videoPlayerController?.value.hasError ?? false) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage =
              _videoPlayerController?.value.errorDescription ?? 'Unknown error';
        });
      }
    }
  }

  Widget _buildVideoWidget() {
    // Show placeholder while loading
    if (!_isVideoInitialized ||
        _hasVideoError ||
        _videoPlayerController == null) {
      return _buildVideoPlaceholder();
    }

    return SizedBox(
      height: 211.sp,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController!),
          ),
          Positioned(
            top: 16.sp,
            right: 16.sp,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50.sp),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    if (_videoPlayerController != null) {
      setState(() {
        _isMuted = !_isMuted;
        _videoPlayerController!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  Widget _buildVideoPlaceholder() {
    // Show cached logo as placeholder
    if (_cachedLogoUrl != null && _cachedLogoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _cachedLogoUrl!,
        height: 211.sp,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 211.sp,
          width: double.infinity,
          color: cardBg,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 211.sp,
          width: double.infinity,
          color: cardBg,
        ),
      );
    }

    return Container(
      height: 211.sp,
      width: double.infinity,
      color: cardBg,
      child: _isVideoInitialized
          ? null
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  // Optimized product normalization - cache results
  List<Map<String, dynamic>>? _cachedNormalizedProducts;

  List<Map<String, dynamic>> _normalizedProducts() {
    if (_cachedNormalizedProducts != null) {
      return _cachedNormalizedProducts!;
    }

    // TEMPORARY FIX: Use brandDetails["products"] from /view-brand API instead of /brand-products
    // because /brand-products only returns id and title (missing images and prices)
    final raw = (brandController.brandDetails["products"] as List?) ?? [];
    final brandName = _cachedBrandName ?? '';

    // Randomize and limit to maximum 3 products
    final shuffled = List.from(raw)..shuffle(Random());
    final limitedRaw = shuffled.take(3).toList();

    _cachedNormalizedProducts = limitedRaw.map<Map<String, dynamic>>((e) {
      final m = Map<String, dynamic>.from(e as Map);

      final id = m["id"];
      final title = (m["title"] ?? m["name"] ?? "").toString();

      // Try multiple price fields from API response
      final num base = (m["basePrice"] ?? m["msp"] ?? m["lfMsp"] ?? m["mrp"] ?? 0);
      final num mrpVal = (m["mrp"] ?? 0);

      bool hideMrp = (mrpVal == 0 || mrpVal == base);
      final num displayPrice = base;
      final num? displayMrp = hideMrp ? null : mrpVal;

      // Support multiple image field formats
      final List<dynamic> imageUrls = m["imageUrls"] ?? m["images"] ?? [];
      final images = imageUrls
          .map((url) => {"name": url.toString()})
          .where((img) => img["name"]!.isNotEmpty)
          .toList();

      return {
        "id": id,
        "name": title,
        "brand_name": brandName,
        "displayPrice": displayPrice,
        "displayMrp": displayMrp,
        "images": images,
      };
    }).toList();

    return _cachedNormalizedProducts!;
  }

  void _pauseVideo() {
    try {
      _videoPlayerController?.pause();
    } catch (e) {
      print('Error pausing video: $e');
    }
  }

  void _resumeVideo() {
    try {
      if (_isVideoInitialized && !_hasVideoError) {
        _videoPlayerController?.play();
      }
    } catch (e) {
      print('Error resuming video: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandName = _cachedBrandName ?? '';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: homeAppBarColor,
      body: Column(
        children: [
          AllBrandAppbar(
            onPressedBack: () {
              _pauseVideo();
              Get.close(1);
            },
            onPressedShare: () async {
              final website = (brandController.brandDetails["brandInfo"]
                          ?["websiteLink"] ??
                      "")
                  .toString();
              if (website.isNotEmpty) {
                Share.share(website);
              } else {
                getSnackBar("No website link available for this brand.");
              }
              await analytics.logEvent(
                  name: 'share_brand_click',
                  parameters: <String, Object>{
                    'page_name': 'share_brand_click'
                  });
            },
            onPressedHeart: () async {
              Get.to(const WishlistScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: homeAppBarColor,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                  systemNavigationBarColor: homeAppBarColor,
                ));
              });
              await analytics.logEvent(
                  name: 'wishlist_page',
                  parameters: <String, Object>{'page_name': 'wishlist_page'});
            },
            onPressedCart: () async {
              Get.to(CartScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: homeAppBarColor,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                  systemNavigationBarColor: homeAppBarColor,
                ));
              });
              await analytics.logEvent(
                  name: 'cart_page',
                  parameters: <String, Object>{'page_name': 'cart_page'});
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Background Circle
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(top: 210.sp),
                        child: Image.asset(circleBack),
                      ),

                      // Video/Image Banner
                      Obx(() {
                        if (brandController.isDetails.value) {
                          return Container(
                            height: 211.sp,
                            width: double.infinity,
                            color: cardBg,
                          );
                        }

                        final mediaUrl = _cachedVideoUrl ?? '';

                        // Show video if available and initialized
                        if (mediaUrl.isNotEmpty && _looksLikeVideo(mediaUrl)) {
                          return _buildVideoWidget();
                        }

                        // Show image banner
                        if (_cachedLogoUrl != null &&
                            _cachedLogoUrl!.isNotEmpty) {
                          return CachedNetworkImage(
                            imageUrl: _cachedLogoUrl!,
                            height: 211.sp,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Image.asset(
                              brandback,
                              height: 211.sp,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          );
                        }

                        return Image.asset(
                          brandback,
                          height: 211.sp,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }),

                      // Brand Logo
                      Obx(() {
                        if (brandController.isDetails.value) {
                          return const SizedBox(height: 0);
                        }

                        final logoUrl = _cachedLogoUrl ?? '';
                        final uri = Uri.tryParse(logoUrl);
                        final isValidUrl =
                            uri != null && uri.hasScheme && uri.host.isNotEmpty;

                        return Container(
                          alignment: Alignment.bottomCenter,
                          margin: EdgeInsets.only(top: 160.sp),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: homeAppBarColor, width: 4.0.sp),
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: SizedBox(
                              height: 80.sp,
                              width: 80.sp,
                              child: isValidUrl
                                  ? CachedNetworkImage(
                                      cacheManager: CacheManager(
                                        Config(
                                          "brandLogoCache",
                                          stalePeriod: const Duration(days: 15),
                                          maxNrOfCacheObjects: 100,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                      imageUrl: logoUrl,
                                      placeholder: (context, url) => Container(
                                        color: cardBg,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.white,
                                        child: Icon(Icons.storefront,
                                            size: 40.sp, color: colorPrimary),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Icon(Icons.storefront,
                                          size: 40.sp, color: colorPrimary),
                                    ),
                            ),
                          ),
                        );
                      }),

                      // Brand Name
                      Container(
                        margin: EdgeInsets.only(top: 260.sp),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.sp),
                          child: Center(
                            child: Obx(
                              () => brandController.isDetails.value
                                  ? Container(
                                      height: 20.sp,
                                      width: 100.sp,
                                      color: cardBg)
                                  : AppText(
                                      text: brandName.toUpperCase(),
                                      color: whiteColor,
                                      fontSize: 16,
                                      fontFamily: "Clash Display",
                                      fontWeight: FontWeight.w400,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Description
                      Container(
                        margin: EdgeInsets.only(top: 290.sp),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                if (brandController.isDetails.value) {
                                  return const SizedBox(height: 0);
                                }

                                final desc =
                                    (brandController.brandDetails["brandInfo"]
                                                ?["description"] ??
                                            "")
                                        .toString()
                                        .trim();

                                if (desc.length <= 80) {
                                  return const SizedBox(height: 0);
                                }

                                return Column(
                                  children: [
                                    Text(
                                      desc,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 15.sp,
                                        height: 1.45,
                                        letterSpacing: 0.2,
                                        fontFamily: "Clash Display Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: showDescription ? null : 2,
                                      overflow: showDescription
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                    ),
                                    InkWell(
                                      onTap: () => setState(() =>
                                          showDescription = !showDescription),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 6.sp),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              showDescription
                                                  ? "Show less"
                                                  : "Show more",
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.75),
                                                fontSize: 12.sp,
                                                fontFamily: "Clash Display",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(width: 4.sp),
                                            SvgPicture.asset(
                                              showDescription
                                                  ? upDropDownSvgImage
                                                  : dropdownSvgImage,
                                              color: Colors.white
                                                  .withOpacity(0.75),
                                              height: 6.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              Padding(
                                padding: EdgeInsets.only(top: 24.sp),
                                child: AppText(
                                  text: "All Products",
                                  color: whiteColor,
                                  fontSize: 20,
                                  fontFamily: "Playfair Display Medium",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Product List
                  Obx(() {
                    if (brandController.isProductBrand.value) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.sp),
                        child: SizedBox(
                          width: double.infinity,
                          height: 220.sp,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (ctx, index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 16.sp),
                                  color: cardBg,
                                  height: 170.sp,
                                  width: 136.sp,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.sp, left: 16.sp),
                                  child: Container(
                                      color: cardBg,
                                      height: 16.sp,
                                      width: 100.sp),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.sp, left: 16.sp),
                                  child: Row(
                                    children: [
                                      Container(
                                          color: cardBg,
                                          height: 16.sp,
                                          width: 40.sp),
                                      SizedBox(width: 6.sp),
                                      Container(
                                          color: cardBg,
                                          height: 16.sp,
                                          width: 40.sp),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final normalized = _normalizedProducts();

                    return BrandProductList(
                      radius: 0,
                      list: normalized,
                      scrollDirection: Axis.vertical,
                      onPressed: (productId, bName) async {
                        _pauseVideo();

                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        await productController.getProductById(productId);

                        if (Get.isDialogOpen ?? false) Get.back();

                        final err = productController.errorMsg.value;
                        if (err.isNotEmpty) {
                          getSnackBar(err);
                          _resumeVideo();
                          return;
                        }

                        Get.to(() => ProductDetailsScreen(
                              expresshour: homeController.expressHour.value,
                              backgroundcolor: whiteColor,
                              brandName: bName.isNotEmpty ? bName : brandName,
                              productId: productId,
                              type: "add",
                            ))?.then((_) {
                          _resumeVideo();
                          SystemChrome.setSystemUIOverlayStyle(
                            const SystemUiOverlayStyle(
                              statusBarColor: homeAppBarColor,
                              systemNavigationBarColor: homeAppBarColor,
                              statusBarIconBrightness: Brightness.light,
                              statusBarBrightness: Brightness.dark,
                            ),
                          );
                        });

                        await analytics.logEvent(
                          name: 'branddetails_product_details',
                          parameters: {
                            'page_name': 'branddetails_product_details'
                          },
                        );
                      },
                    );
                  }),

                  // Explore All Button
                  InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove("brandList");
                      prefs.remove("colorList");
                      prefs.remove("sizeList");
                      prefs.remove("upper");
                      prefs.remove("lower");
                      prefs.remove("sortby");
                      prefs.remove("category");
                      productController.productSortBy.value = "";
                      productController.filterProductEnable.value = false;
                      productController.categoryFilter.value = 0;

                      _pauseVideo();

                      Navigator.push(
                        context,
                        scaleIn(
                          BrandViewProductScreen(
                            expresshour: homeController.expressHour.value,
                            brand_id: brandController.brandDetails["brandInfo"]
                                    ["id"] ??
                                0,
                            title: brandName,
                            screen: "brand",
                            genderName: "",
                          ),
                        ),
                      ).then((_) {
                        productController.productSortBy.value = "";
                        productController.filterProductEnable.value = false;
                        productController.categoryFilter.value = 0;
                        _resumeVideo();
                      });

                      await analytics.logEvent(
                        name: 'branddetails_btnexploreall',
                        parameters: {'page_name': 'branddetails_btnexploreall'},
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: Container(
                        height: 42.sp,
                        color: whiteColor,
                        child: Center(
                          child: AppText(
                            text: "EXPLORE ALL",
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w400,
                            color: colorPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
