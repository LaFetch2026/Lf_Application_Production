// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

  // --- Header media (video / image) ---
  Future<void>? _initializeVideoPlayerFuture;
  late VideoPlayerController videoController;
  bool hasVideoError = false;
  String videoErrorMessage = '';

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: homeAppBarColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: homeAppBarColor,
      ));

      // reset some shared UI state
      brandController.brandProductDetailsList.clear();
      productController.productSortBy.value = "";
      productController.filterProductEnable.value = false;
      productController.categoryFilter.value = 0;

      // ✅ Fetch brand details from your new API
      await brandController.getBrandDetails(widget.id, widget.slug);

      // Decide header media
      final mediaUrl =
          brandController.brandDetails["brandInfo"]?["video"]?.toString() ?? "";
      if (mediaUrl.isNotEmpty && _looksLikeVideo(mediaUrl)) {
        _initializeMainVideo(mediaUrl);
        hasVideoError = false;
        videoErrorMessage = '';
      } else {
        // It's not a video; we'll show it as an image in the build method
        hasVideoError = true; // this disables the video widget branch
        videoErrorMessage = 'Using image banner';
      }

      if (mounted) setState(() {});
    });
  }

  // ---------- Helpers ----------
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

  List<Map<String, dynamic>> _normalizedProducts() {
    final raw = (brandController.brandDetails["products"] as List?) ?? const [];
    final brandName =
        (brandController.brandDetails["brandInfo"]?["name"] ?? '').toString();

    return raw.map<Map<String, dynamic>>((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = m['id'];
      final title = (m['title'] ?? m['name'] ?? '').toString();

      // ✅ Always prefer basePrice, fallback to mrp if missing
      final double price = (m['basePrice'] ?? m['mrp'] ?? 0).toDouble();
      final double mrp = (m['mrp'] ?? price).toDouble();

      // ✅ Map imageUrls from API
      final List<dynamic> imageUrls = m['imageUrls'] ?? [];
      final images = imageUrls
          .map((url) => {'name': url.toString()})
          .where((img) => img['name']!.isNotEmpty)
          .toList();

      return {
        'id': id,
        'name': title,
        'brand_name': brandName,
        'price': price, // 👈 maps basePrice here
        'mrp': mrp,
        'images': images,
      };
    }).toList();
  }

  void _initializeMainVideo(String videoUrl) {
    try {
      videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _initializeVideoPlayerFuture = videoController.initialize().then((_) {
        videoController.setLooping(true);
        videoController.setVolume(1.0);
        videoController.play();
      }).catchError((error) {
        setState(() {
          hasVideoError = true;
          videoErrorMessage = 'Failed to load video: $error';
        });
      });

      videoController.addListener(() {
        if (videoController.value.hasError) {
          setState(() {
            hasVideoError = true;
            videoErrorMessage =
                videoController.value.errorDescription ?? 'Unknown video error';
          });
        }
      });
    } catch (e) {
      hasVideoError = true;
      videoErrorMessage = 'Video controller creation error: $e';
    }
  }

  Widget _buildMainVideoWidget() {
    if (hasVideoError || _initializeVideoPlayerFuture == null) {
      return _buildVideoErrorWidget(
        videoErrorMessage.isNotEmpty
            ? videoErrorMessage
            : 'Video not initialized yet',
      );
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildVideoErrorWidget(
              'Video loading failed: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.done &&
            !hasVideoError) {
          return AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          );
        }
        return Container(
          height: 211.sp,
          width: double.infinity,
          color: cardBg,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildVideoErrorWidget(String errorMessage) {
    return Container(
      height: 211.sp,
      width: double.infinity,
      color: cardBg,
      child: Center(
        child: Text(
          ' ', // keep it empty; we’ll show an image instead in the build
          style: TextStyle(color: Colors.white70, fontSize: 16.sp),
        ),
      ),
    );
  }

  // void _onScroll() {
  //   if (!_scrollController.hasClients) return;
  //   final maxScroll = _scrollController.position.maxScrollExtent;
  //   final currentScroll = _scrollController.position.pixels;
  //   final scrollPercentage =
  //       maxScroll == 0 ? 100.0 : (currentScroll / maxScroll) * 100;

  //   if (scrollPercentage >= 25 && !_triggeredScrolls.contains('25%')) {
  //     AnalyticsHelper.logScrollEvent('25%');
  //     _triggeredScrolls.add('25%');
  //   }
  //   if (scrollPercentage >= 50 && !_triggeredScrolls.contains('50%')) {
  //     AnalyticsHelper.logScrollEvent('50%');
  //     _triggeredScrolls.add('50%');
  //   }
  //   if (scrollPercentage >= 75 && !_triggeredScrolls.contains('75%')) {
  //     AnalyticsHelper.logScrollEvent('75%');
  //     _triggeredScrolls.add('75%');
  //   }
  //   if (scrollPercentage >= 100 && !_triggeredScrolls.contains('100%')) {
  //     AnalyticsHelper.logScrollEvent('100%');
  //     _triggeredScrolls.add('100%');
  //   }
  // }

  @override
  void dispose() {
    try {
      if (!hasVideoError) {
        videoController.pause();
        videoController.dispose();
      }
    } catch (e) {
      print('Error disposing main video controller: $e');
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String brandName =
        (brandController.brandDetails["brandInfo"]?["name"] ?? '').toString();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: homeAppBarColor,
      body: Column(
        children: [
          AllBrandAppbar(
            onPressedBack: () {
              try {
                if (!hasVideoError) videoController.pause();
              } catch (_) {}
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
                parameters: <String, Object>{'page_name': 'share_brand_click'},
              );
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
                parameters: <String, Object>{'page_name': 'wishlist_page'},
              );
            },
            onPressedCart: () async {
              Get.to(const CartScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: homeAppBarColor,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                  systemNavigationBarColor: homeAppBarColor,
                ));
              });
              await analytics.logEvent(
                name: 'cart_page',
                parameters: <String, Object>{'page_name': 'cart_page'},
              );
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

                      // Header media (Video if real video, otherwise Image)
                      Obx(() {
                        if (brandController.isDetails.value) {
                          return Container(
                            height: 211.sp,
                            width: double.infinity,
                            color: cardBg,
                          );
                        }

                        final mediaUrl = (brandController
                                    .brandDetails["brandInfo"]?["video"] ??
                                "")
                            .toString();
                        final fallbackImage = (brandController
                                    .brandDetails["brandInfo"]?["logo"] ??
                                "")
                            .toString();

                        // Show real video
                        if (mediaUrl.isNotEmpty &&
                            _looksLikeVideo(mediaUrl) &&
                            !hasVideoError) {
                          return SizedBox(
                            height: 211.sp,
                            width: double.infinity,
                            child: _buildMainVideoWidget(),
                          );
                        }

                        // Show image banner (PNG/JPG/etc.)
                        if (mediaUrl.isNotEmpty && _looksLikeImage(mediaUrl)) {
                          return fallbackImage.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: fallbackImage,
                                  height: 211.sp,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    brandback,
                                    height: 211.sp,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  brandback,
                                  height: 211.sp,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                        }

                        // Fallback asset
                        return Image.asset(
                          brandback,
                          height: 211.sp,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }),

                      // Brand Logo (use proper URL validation) - FIXED VERSION
                      Obx(() {
                        if (brandController.isDetails.value) {
                          return const SizedBox(height: 0);
                        }
                        final logoUrl = (brandController
                                    .brandDetails["brandInfo"]?["logo"] ??
                                "")
                            .toString();
                        final uri = Uri.tryParse(logoUrl);
                        final isValidUrl =
                            uri != null && uri.hasScheme && uri.host.isNotEmpty;

                        return Container(
                          alignment: Alignment.bottomCenter,
                          margin: EdgeInsets.only(top: 160.sp),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: homeAppBarColor,
                              width: 4.0.sp,
                            ),
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
                                      // ✅ ADD THIS ERROR HANDLER
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.white,
                                        child: Icon(
                                          Icons.storefront,
                                          size: 40.sp,
                                          color: colorPrimary,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Icon(
                                        Icons.storefront,
                                        size: 40.sp,
                                        color: colorPrimary,
                                      ),
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
                                      color: cardBg,
                                    )
                                  : AppText(
                                      text: (brandController
                                                      .brandDetails["brandInfo"]
                                                  ?["name"] ??
                                              "")
                                          .toString()
                                          .toUpperCase(),
                                      color: whiteColor,
                                      fontSize: 16,
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w400,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Description + "All Products"
                      Container(
                        margin: EdgeInsets.only(top: 290.sp),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Obx(
                                  () => brandController.isDetails.value
                                      ? Container(
                                          height: 20.sp,
                                          width: double.infinity,
                                          color: cardBg,
                                        )
                                      : Text(
                                          (brandController.brandDetails[
                                                          "brandInfo"]
                                                      ?["description"] ??
                                                  "No description available")
                                              .toString(),
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: productSubtitleColor,
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14.sp,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: showDescription ? 12 : 2,
                                        ),
                                ),
                              ),
                              Obx(
                                () => brandController.isDetails.value
                                    ? const SizedBox(height: 0)
                                    : Visibility(
                                        visible: ((brandController.brandDetails[
                                                            "brandInfo"]
                                                        ?["description"] ??
                                                    "") as String)
                                                .length >
                                            100,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 4.sp),
                                          child: InkWell(
                                            onTap: () => setState(() =>
                                                showDescription =
                                                    !showDescription),
                                            child: Row(
                                              children: [
                                                AppText(
                                                  text: showDescription
                                                      ? "Show less"
                                                      : "Show more",
                                                  color: productSubtitleColor,
                                                  fontSize: 12,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 20.sp, left: 5.sp),
                                                  child: SvgPicture.asset(
                                                    showDescription
                                                        ? upDropDownSvgImage
                                                        : dropdownSvgImage,
                                                    color: productSubtitleColor,
                                                    height: 5.sp,
                                                    width: 7.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
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

                  // Product list (normalized)
                  Obx(
                    () {
                      if (brandController.isProductBrand.value) {
                        // shimmer
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
                                      width: 100.sp,
                                    ),
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
                          // Pause header media if any
                          try {
                            if (!hasVideoError) videoController.pause();
                          } catch (_) {}

                          // Loader while fetching product
                          Get.dialog(
                            const Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          await productController.getProductById(productId);

                          if (Get.isDialogOpen ?? false) Get.back();

                          final err = productController.errorMsg.value;
                          if (err.isNotEmpty) {
                            getSnackBar(err);
                            try {
                              if (!hasVideoError) videoController.play();
                            } catch (_) {}
                            return;
                          }

                          Get.to(() => ProductDetailsScreen(
                                expresshour: homeController.expressHour.value,
                                backgroundcolor: whiteColor,
                                brandName: bName.isNotEmpty ? bName : brandName,
                                productId: productId,
                                type: "add",
                              ))?.then((_) {
                            try {
                              if (!hasVideoError) videoController.play();
                            } catch (_) {}

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
                    },
                  ),

                  // Explore All
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

                      try {
                        if (!hasVideoError) videoController.pause();
                      } catch (_) {}

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
                        try {
                          if (!hasVideoError) videoController.play();
                        } catch (_) {}
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
                            fontFamily: "Franklin Gothic",
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
