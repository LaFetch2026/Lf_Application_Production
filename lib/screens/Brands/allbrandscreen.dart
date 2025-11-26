// ignore_for_file: avoid_print, deprecated_member_use

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

  // --- Header media (video / image) ---
  Future<void>? _initializeVideoPlayerFuture;
  late VideoPlayerController videoController;
  bool hasVideoError = false;
  String videoErrorMessage = '';
  bool _isMuted = false; // Define the mute state
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    // Initialize video player
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

      await brandController.getBrandDetails(widget.id, widget.slug);

      final mediaUrl =
          brandController.brandDetails["brandInfo"]?["video"]?.toString() ?? "";
      if (mediaUrl.isNotEmpty && _looksLikeVideo(mediaUrl)) {
        _initializeMainVideo(mediaUrl);
        hasVideoError = false;
        videoErrorMessage = '';
      } else {
        hasVideoError = true;
        videoErrorMessage = 'Using image banner';
      }

      if (mounted) setState(() {});
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

  void _initializeMainVideo(String videoUrl) {
    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _initializeVideoPlayerFuture =
          _videoPlayerController.initialize().then((_) {
        _videoPlayerController.setLooping(true);
        _videoPlayerController.setVolume(1.0);
        _videoPlayerController.play();
      }).catchError((error) {
        setState(() {
          hasVideoError = true;
          videoErrorMessage = 'Failed to load video: $error';
        });
      });

      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {
          setState(() {
            hasVideoError = true;
            videoErrorMessage = _videoPlayerController.value.errorDescription ??
                'Unknown video error';
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
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
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
          ' ', // Empty space to show an image instead
          style: TextStyle(color: Colors.white70, fontSize: 16.sp),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _normalizedProducts() {
    final raw = (brandController.brandDetails["products"] as List?) ?? [];
    final brandName =
        (brandController.brandDetails["brandInfo"]?["name"] ?? '').toString();

    return raw.map<Map<String, dynamic>>((e) {
      final m = Map<String, dynamic>.from(e as Map);

      final id = m["id"];
      final title = (m["title"] ?? m["name"] ?? "").toString();

      // -------- BASE & MRP --------
      final num base = (m["basePrice"] ?? m["mrp"] ?? 0);
      final num mrpVal = (m["mrp"] ?? 0);

      // -------- APPLY SAME RULE --------
      bool hideMrp = (mrpVal == 0 || mrpVal == base);

      final num displayPrice = base;
      final num? displayMrp = hideMrp ? null : mrpVal;

      // -------- IMAGES --------
      final List<dynamic> imageUrls = m["imageUrls"] ?? [];
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
  }

  @override
  void dispose() {
    try {
      if (!hasVideoError) {
        _videoPlayerController.pause();
        _videoPlayerController.dispose();
      }
    } catch (e) {
      print('Error disposing main video controller: $e');
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandName =
        (brandController.brandDetails["brandInfo"]?["name"] ?? '').toString();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: homeAppBarColor,
      body: Column(
        children: [
          AllBrandAppbar(
            onPressedBack: () {
              try {
                if (!hasVideoError) _videoPlayerController.pause();
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
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildMainVideoWidget(), // Your video player widget here
                                Positioned(
                                  top: 16.sp,
                                  right: 16.sp,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Toggle mute/unmute state
                                        _isMuted = !_isMuted;
                                        // Mute or unmute the video player here
                                        _videoPlayerController
                                            .setVolume(_isMuted ? 0.0 : 1.0);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8.sp),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(50.sp),
                                      ),
                                      child: Icon(
                                        _isMuted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
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

                      // Brand Logo (use proper URL validation)
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
                              Obx(
                                () => brandController.isDetails.value
                                    ? const SizedBox(height: 0)
                                    : Visibility(
                                        visible: ((brandController.brandDetails[
                                                            "brandInfo"]
                                                        ?["description"] ??
                                                    "") as String)
                                                .length >
                                            80,
                                        child: Obx(() {
                                          if (brandController.isDetails.value) {
                                            return Container(
                                              height: 20.sp,
                                              width: double.infinity,
                                              color: cardBg,
                                            );
                                          }

                                          final desc =
                                              (brandController.brandDetails[
                                                              "brandInfo"]
                                                          ?["description"] ??
                                                      "")
                                                  .toString()
                                                  .trim();

                                          return Column(
                                            children: [
                                              Text(
                                                desc,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 15.sp,
                                                  height: 1.45,
                                                  letterSpacing: 0.2,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: showDescription
                                                    ? null
                                                    : 2, // Only 2 lines
                                                overflow: showDescription
                                                    ? TextOverflow.visible
                                                    : TextOverflow.ellipsis,
                                              ),
                                              if (desc.length > 80)
                                                InkWell(
                                                  onTap: () => setState(() =>
                                                      showDescription =
                                                          !showDescription),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 6.sp),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          showDescription
                                                              ? "Show less"
                                                              : "Show more",
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.75),
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4.sp),
                                                        SvgPicture.asset(
                                                          showDescription
                                                              ? upDropDownSvgImage
                                                              : dropdownSvgImage,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.75),
                                                          height: 6.sp,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
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

                  // Product list (normalized with displayPrice & displayMrp)
                  Obx(
                    () {
                      if (brandController.isProductBrand.value) {
                        // shimmer while loading
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
                                          width: 40.sp,
                                        ),
                                        SizedBox(width: 6.sp),
                                        Container(
                                          color: cardBg,
                                          height: 16.sp,
                                          width: 40.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      /// Normalized product list with price rule applied
                      final List<Map<String, dynamic>> normalized =
                          _normalizedProducts();

                      return BrandProductList(
                        radius: 0,
                        list: normalized,
                        scrollDirection: Axis.vertical,
                        onPressed: (productId, bName) async {
                          try {
                            if (!hasVideoError) _videoPlayerController.pause();
                          } catch (_) {}

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
                              if (!hasVideoError) _videoPlayerController.play();
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
                              if (!hasVideoError) _videoPlayerController.play();
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
                        if (!hasVideoError) _videoPlayerController.pause();
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
                          if (!hasVideoError) _videoPlayerController.play();
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
