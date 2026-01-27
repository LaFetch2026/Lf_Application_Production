// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/widget/bottom_sheets/bottomcategory.dart';
import '../../common/widget/bottom_sheets/bottomfiltters.dart';
import '../../common/widget/bottom_sheets/bottomsortby.dart';
import '../../common/widget/lists/dummy_grid_black.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/brand_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';
import '../../core/utils/analytics_helper.dart';
import '../cartscreen.dart';
import '../catalog/productlist/productdetailsscreen.dart';
import '../searchscreen.dart';
import '../wishlistscreen.dart';

class BrandViewProductScreen extends StatefulWidget {
  final String title;
  final String genderName;
  final int brand_id;
  final String expresshour;
  final String screen;

  const BrandViewProductScreen({
    super.key,
    required this.title,
    required this.genderName,
    required this.expresshour,
    required this.screen,
    required this.brand_id,
  });

  @override
  State<BrandViewProductScreen> createState() => BrandViewProductScreenState();
}

class BrandViewProductScreenState extends State<BrandViewProductScreen> {
  // Controllers
  final productController = Get.find<ProductController>();
  final brandController = Get.put(BrandController());
  final wishlistController = Get.put(WishlistController());
  final cartController = Get.put(CartController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Local UI state
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _triggeredScrolls = [];
  Timer? _debounce;
  bool isBottomSheet = false;

  // Local filters/sorts (client-side)
  String _sortBy = ""; // "", "price_asc", "price_desc", "newest"
  int _categoryFilter = 0; // 0=All, 1=Women, 2=Men (maps to superCatId)
  num? _lowPrice;
  num? _highPrice;

  @override
  void initState() {
    super.initState();

    // _scrollController.addListener(_onScroll);

    // Status bar styling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: homeAppBarColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: homeAppBarColor,
      ));
    });

    // Fetch this brand ONLY (same API as first screen)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await brandController.getBrandDetails(widget.brand_id, "");
      cartController.getCartData();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ---------- helpers: field normalization ----------
  bool _isImg(String u) {
    final p = u.toLowerCase();
    return p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif') ||
        p.endsWith('.bmp');
  }

  String _firstImageUrl(Map<String, dynamic> raw) {
    try {
      // images: List<Map>{name} or List<String>
      final imgs = raw['images'];
      if (imgs is List && imgs.isNotEmpty) {
        for (final it in imgs) {
          if (it is String && it.trim().isNotEmpty && _isImg(it)) return it;
          if (it is Map) {
            final keys = ['name', 'url', 'image', 'src', 'thumbnail'];
            for (final k in keys) {
              final v = (it[k] ?? '').toString();
              if (v.isNotEmpty && _isImg(v)) return v;
            }
          }
        }
        final any = imgs.first;
        if (any is String) return any;
        if (any is Map) return (any['name'] ?? any['url'] ?? '').toString();
      }

      // imageUrls: List<String>
      final urls = raw['imageUrls'];
      if (urls is List && urls.isNotEmpty) {
        for (final u in urls) {
          if (u is String && u.trim().isNotEmpty && _isImg(u)) return u;
        }
        final u = urls.first;
        if (u is String) return u;
      }
    } catch (_) {}
    return '';
  }

  String _prodName(Map<String, dynamic> m) =>
      (m['name'] ?? m['title'] ?? '').toString();

  int _prodId(Map<String, dynamic> m) {
    final v = m['id'];
    if (v is int) return v;
    return int.tryParse('${v ?? 0}') ?? 0;
  }

  num _prodPrice(Map<String, dynamic> m) {
    final dynamic p =
        m['price'] ?? m['msp'] ?? m['lfMsp'] ?? m['mrp'] ?? m['basePrice'];
    if (p is num) return p;
    return num.tryParse(p.toString()) ?? 0;
  }

  num _prodMrp(Map<String, dynamic> m) {
    final dynamic v = m['mrp'] ?? 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  int _superCat(Map<String, dynamic> m) {
    final v = m['superCatId'];
    if (v is int) return v;
    return int.tryParse('${v ?? 0}') ?? 0;
  }

  // ---------- search / scroll analytics ----------
  // void _onScroll() {
  //   if (!_scrollController.hasClients) return;
  //   final maxScroll = _scrollController.position.maxScrollExtent;
  //   final current = _scrollController.position.pixels;
  //   final pct = maxScroll == 0 ? 100.0 : (current / maxScroll) * 100;

  //   if (pct >= 25 && !_triggeredScrolls.contains('25%')) {
  //     AnalyticsHelper.logScrollEvent('25%');
  //     _triggeredScrolls.add('25%');
  //   }
  //   if (pct >= 50 && !_triggeredScrolls.contains('50%')) {
  //     AnalyticsHelper.logScrollEvent('50%');
  //     _triggeredScrolls.add('50%');
  //   }
  //   if (pct >= 75 && !_triggeredScrolls.contains('75%')) {
  //     AnalyticsHelper.logScrollEvent('75%');
  //     _triggeredScrolls.add('75%');
  //   }
  //   if (pct >= 100 && !_triggeredScrolls.contains('100%')) {
  //     AnalyticsHelper.logScrollEvent('100%');
  //     _triggeredScrolls.add('100%');
  //   }
  // }

  void _onSearchChanged(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {}); // local filter only
    });
  }

  // ---------- derive visible list from brandDetails.products ----------
  List<Map<String, dynamic>> _visibleProducts() {
    final List raw = brandController.brandDetails["products"] is List
        ? brandController.brandDetails["products"]
        : const [];

    List<Map<String, dynamic>> out =
        raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

    // Category filter (by superCatId from API: 1=Women?, 2=Men?)
    if (_categoryFilter == 1) {
      out = out.where((m) => _superCat(m) == 1).toList();
    } else if (_categoryFilter == 2) {
      out = out.where((m) => _superCat(m) == 2).toList();
    }

    // Price filter
    if (_lowPrice != null) {
      out = out.where((m) => _prodPrice(m) >= _lowPrice!).toList();
    }
    if (_highPrice != null) {
      out = out.where((m) => _prodPrice(m) <= _highPrice!).toList();
    }

    // Search (name/title)
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((m) => _prodName(m).toLowerCase().contains(q)).toList();
    }

    // Sort
    if (_sortBy == "price_asc") {
      out.sort((a, b) => _prodPrice(a).compareTo(_prodPrice(b)));
    } else if (_sortBy == "price_desc") {
      out.sort((a, b) => _prodPrice(b).compareTo(_prodPrice(a)));
    } else if (_sortBy == "newest") {
      // try updatedAt/createdAt desc
      DateTime _dt(Map<String, dynamic> m) {
        final s = (m['updatedAt'] ?? m['createdAt'] ?? '').toString();
        return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }

      out.sort((a, b) => _dt(b).compareTo(_dt(a)));
    }

    return out;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final isLoading = brandController.isDetails.value;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(
          sigmaX: isBottomSheet ? 1 : 0, sigmaY: isBottomSheet ? 1 : 0),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: homeAppBarColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Container(
              width: MediaQuery.of(context).size.width,
              color: homeAppBarColor,
              child: Padding(
                padding:
                    EdgeInsets.only(right: 10.sp, top: 56.sp, bottom: 16.sp),
                child: Row(
                  children: [
                    InkWell(
                      onTap: Get.back,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16.sp, right: 12.sp, top: 4.sp),
                        child: SvgPicture.asset(
                          arrowBack,
                          color: whiteColor,
                          height: 15.sp,
                          width: 15.sp,
                        ),
                      ),
                    ),
                    AppText(
                      text: widget.title.toUpperCase(),
                      color: whiteColor,
                      fontSize: 16,
                      fontFamily: "Clash Display Semibold",
                      fontWeight: FontWeight.w500,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        Navigator.push(context, scaleIn(SearchScreen()))
                            .then((_) {
                          SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                              statusBarColor: homeAppBarColor,
                              statusBarIconBrightness: Brightness.light,
                              statusBarBrightness: Brightness.dark,
                            ),
                          );
                        });
                        await analytics.logEvent(
                          name: 'search_page',
                          parameters: {'page_name': 'search_page'},
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.sp),
                        child: SvgPicture.asset(
                          searchSvgImage,
                          color: whiteColor,
                          height: 18.sp,
                          width: 18.sp,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Get.to(const WishlistScreen())?.then((_) {
                          SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                              statusBarColor: homeAppBarColor,
                              statusBarIconBrightness: Brightness.light,
                              statusBarBrightness: Brightness.dark,
                            ),
                          );
                        });
                        await analytics.logEvent(
                          name: 'wishlist_page',
                          parameters: {'page_name': 'wishlist_page'},
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.sp),
                        child: SvgPicture.asset(
                          heartSvgImage,
                          color: whiteColor,
                          height: 18.sp,
                          width: 18.sp,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.push(context, scaleIn(CartScreen()))
                            .then((_) {
                          SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                              statusBarColor: homeAppBarColor.withOpacity(0.5),
                              statusBarIconBrightness: Brightness.light,
                              statusBarBrightness: Brightness.dark,
                            ),
                          );
                        });
                        await analytics.logEvent(
                          name: 'cart_page',
                          parameters: {'page_name': 'cart_page'},
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.sp, right: 8.sp),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 3.sp),
                              child: SvgPicture.asset(
                                cartSvgImage,
                                color: whiteColor,
                                height: 18.sp,
                                width: 18.sp,
                              ),
                            ),
                            Obx(
                              () => cartController.cartTotalValue.value != 0
                                  ? Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 10.sp,
                                        height: 10.sp,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: whiteColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            cartController.cartTotalValue.value
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: homeAppBarColor,
                                              fontFamily:
                                                  "Libre Franklin Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search
            Padding(
              padding: EdgeInsets.only(
                  left: 16.sp, top: 35.sp, right: 16.sp, bottom: 30.sp),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                    color: colorSecondary,
                    fontFamily: "Clash Display Regular",
                    fontSize: 14.sp),
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: const Color(0xff1b1b20),
                  prefixIcon: IconButton(
                    icon: SvgPicture.asset(
                      searchSvgImage,
                      color: searchTextColor,
                      height: 17.sp,
                      width: 17.sp,
                    ),
                    onPressed: () {},
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.sp),
                    borderSide: const BorderSide(color: Color(0xff333842)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.sp),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.sp),
                    borderSide: const BorderSide(color: Color(0xff333842)),
                  ),
                  counterText: "",
                  hintText:
                      "Search for products for ${widget.title.toUpperCase()}",
                  hintStyle: TextStyle(fontSize: 14.sp, color: searchTextColor),
                ),
              ),
            ),

            // Body
            Expanded(
              child: Obx(() {
                if (isLoading) {
                  return const DummyGridBlack(size: 2);
                }

                final items = _visibleProducts();

                if (items.isEmpty) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20.sp),
                          child: Image.asset(
                            errorImage,
                            height: 200.sp,
                            width: 220.sp,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.sp),
                          child: getSingleButton(
                            width: double.infinity,
                            label: "Back to Brands".toUpperCase(),
                            textColor: whiteColor,
                            fontSize: 13,
                            backgroundColor: homeAppBarColor,
                            onPressed: () => Get.close(2),
                            borderColor: whiteColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      childAspectRatio: 0.6,
                      physics: const ScrollPhysics(),
                      crossAxisSpacing: 12.sp,
                      mainAxisSpacing: 0.sp,
                      children: List.generate(items.length, (index) {
                        final m = items[index];
                        final pid = _prodId(m);
                        final name = _prodName(m);
                        final price = _prodPrice(m);
                        final mrp = _prodMrp(m);
                        final img = _firstImageUrl(m);
                        final basePrice = m["basePrice"];

                        return GestureDetector(
                          onTap: () async {
                            // Fetch PDP data first
                            Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );
                            await productController.getProductById(pid);
                            if (Get.isDialogOpen ?? false) Get.back();

                            final err = productController.errorMsg.value;
                            if (err.isNotEmpty) {
                              getSnackBar(err);
                              return;
                            }

                            Get.to(
                              ProductDetailsScreen(
                                expresshour: widget.expresshour,
                                backgroundcolor: whiteColor,
                                expressValue: widget.screen == "quick" ? 1 : 0,
                                brandName: (m['brand_name'] ?? '').toString(),
                                productId: pid,
                                type: "add",
                              ),
                            )?.then((_) {
                              FocusScope.of(context).unfocus();
                              cartController.getCartData();
                              SystemChrome.setSystemUIOverlayStyle(
                                SystemUiOverlayStyle(
                                  statusBarColor:
                                      homeAppBarColor.withOpacity(0.5),
                                ),
                              );
                            });

                            await analytics.logEvent(
                              name: 'brandproduct_product_details',
                              parameters: {
                                'page_name': 'brandproduct_product_details'
                              },
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // image
                              Center(
                                child: img.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.sp),
                                        child: SizedBox(
                                          height: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2) +
                                              10.sp,
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2) -
                                              24.sp,
                                          child: CachedNetworkImage(
                                            cacheManager: CacheManager(
                                              Config(
                                                "brandGridCache",
                                                stalePeriod:
                                                    const Duration(days: 15),
                                                maxNrOfCacheObjects: 100,
                                              ),
                                            ),
                                            fit: BoxFit.fill,
                                            imageUrl: img,
                                            errorWidget: (_, __, ___) =>
                                                Image.asset(
                                              downloadImage,
                                              fit: BoxFit.fill,
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) +
                                                  10.sp,
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) -
                                                  24.sp,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        dummyWishlistImage,
                                        height:
                                            (MediaQuery.of(context).size.width /
                                                    2) +
                                                10.sp,
                                        width:
                                            (MediaQuery.of(context).size.width /
                                                    2) -
                                                24.sp,
                                        fit: BoxFit.fill,
                                      ),
                              ),

                              // name
                              Padding(
                                padding: EdgeInsets.only(top: 8.sp),
                                child: AppText(
                                  text: name,
                                  color: productSubtitleColor,
                                  maxLines: 1,
                                  fontSize: 11,
                                  fontFamily: "Clash Display Regular",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              // price

                              Padding(
                                padding: EdgeInsets.only(top: 8.sp),
                                child: Row(
                                  children: [
                                    if (mrp != basePrice)
                                      Padding(
                                        padding: EdgeInsets.only(right: 6.sp),
                                        child: Text(
                                          "\u{20B9} ${mrp.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            color: searchTextColor,
                                            fontSize: 11.sp,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    AppText(
                                      text:
                                          "\u{20B9} ${basePrice.toStringAsFixed(0)}",
                                      color: whiteColor,
                                      maxLines: 2,
                                      fontSize: 11,
                                      fontFamily: "Clash Display",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),

            // Bottom bar (local sort/filter)
            // Container(height: 1.sp, width: double.infinity, color: titleColor),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 5.sp),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       // SORT BY
            //       InkWell(
            //         onTap: () {
            //           setState(() => isBottomSheet = true);
            //           showModalBottomSheet(
            //             context: context,
            //             isScrollControlled: true,
            //             constraints: BoxConstraints(
            //               maxWidth: double.infinity,
            //               maxHeight: 340.sp,
            //             ),
            //             builder: (ctx) => BottomSortBy(
            //               backgroundColor: homeAppBarColor,
            //               onPressedButton: (val) {
            //                 // map expected labels to local flags
            //                 if (val.toLowerCase().contains("low")) {
            //                   _sortBy = "price_asc";
            //                 } else if (val.toLowerCase().contains("high")) {
            //                   _sortBy = "price_desc";
            //                 } else if (val.toLowerCase().contains("new")) {
            //                   _sortBy = "newest";
            //                 } else {
            //                   _sortBy = "";
            //                 }
            //                 setState(() {});
            //               },
            //             ),
            //           ).whenComplete(
            //               () => setState(() => isBottomSheet = false));
            //         },
            //         child: Padding(
            //           padding: EdgeInsets.symmetric(
            //               vertical: 10.sp, horizontal: 5.sp),
            //           child: Row(
            //             children: [
            //               SvgPicture.asset(
            //                 sortBySvgImage,
            //                 color: whiteColor,
            //                 height: 19.sp,
            //                 width: 15.sp,
            //               ),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 5.sp),
            //                 child: Text(
            //                   "SORT BY",
            //                   style: TextStyle(
            //                     color: whiteColor,
            //                     fontSize: 13.sp,
            //                     fontFamily: "Clash Display",
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),

            //       Container(width: 1.sp, color: titleColor, height: 46.sp),

            //       // CATEGORY
            //       InkWell(
            //         onTap: () {
            //           setState(() => isBottomSheet = true);
            //           showModalBottomSheet(
            //             context: context,
            //             isScrollControlled: true,
            //             constraints: BoxConstraints(
            //               maxWidth: double.infinity,
            //               maxHeight: 270.sp,
            //             ),
            //             builder: (ctx) => BottomCategory(
            //               backgroundColor: homeAppBarColor,
            //               gender: widget.genderName,
            //               onPressedButton: (picked) {
            //                 // Map your existing labels to superCatId
            //                 if (picked == "Women") {
            //                   _categoryFilter = 1;
            //                 } else if (picked == "Men") {
            //                   _categoryFilter = 2;
            //                 } else {
            //                   _categoryFilter = 0;
            //                 }
            //                 setState(() {});
            //               },
            //               onPressedFilter: () {
            //                 Get.back();
            //                 setState(() => isBottomSheet = true);
            //                 showModalBottomSheet(
            //                   context: context,
            //                   isScrollControlled: true,
            //                   constraints: BoxConstraints(
            //                     maxWidth: double.infinity,
            //                     maxHeight: 500.sp,
            //                   ),
            //                   builder: (ctx) => BottomFilters(
            //                     backgroundColor: homeAppBarColor,
            //                     btnclearAll: () async {
            //                       _lowPrice = null;
            //                       _highPrice = null;
            //                       _sortBy = "";
            //                       _categoryFilter = 0;
            //                       final prefs =
            //                           await SharedPreferences.getInstance();
            //                       prefs.remove("brandList");
            //                       prefs.remove("colorList");
            //                       prefs.remove("sizeList");
            //                       prefs.remove("upper");
            //                       prefs.remove("lower");
            //                       prefs.remove("sortby");
            //                       prefs.remove("category");
            //                       setState(() {});
            //                     },
            //                     onClick: (low, high) {
            //                       _lowPrice = low;
            //                       _highPrice = high;
            //                       setState(() {});
            //                     },
            //                   ),
            //                 ).whenComplete(
            //                     () => setState(() => isBottomSheet = false));
            //               },
            //             ),
            //           ).whenComplete(
            //               () => setState(() => isBottomSheet = false));
            //         },
            //         child: Padding(
            //           padding: EdgeInsets.symmetric(
            //               vertical: 10.sp, horizontal: 5.sp),
            //           child: Column(
            //             children: [
            //               Text(
            //                 "CATEGORY",
            //                 style: TextStyle(
            //                   color: whiteColor,
            //                   fontSize: 13.sp,
            //                   fontFamily: "Clash Display",
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //               ),
            //               if (_categoryFilter != 0)
            //                 Padding(
            //                   padding: EdgeInsets.only(top: 1.sp),
            //                   child: Text(
            //                     (_categoryFilter == 1 ? "WOMEN" : "MEN"),
            //                     style: TextStyle(
            //                       decoration: TextDecoration.underline,
            //                       fontFamily: "Clash Display Regular",
            //                       fontWeight: FontWeight.w400,
            //                       color: lightgreyColor,
            //                       fontSize: 10.sp,
            //                     ),
            //                   ),
            //                 ),
            //             ],
            //           ),
            //         ),
            //       ),

            //       Container(width: 1.sp, color: titleColor, height: 46.sp),

            //       // FILTERS (price range only, local)
            //       InkWell(
            //         onTap: () {
            //           setState(() => isBottomSheet = true);
            //           showModalBottomSheet(
            //             context: context,
            //             isScrollControlled: true,
            //             constraints: BoxConstraints(
            //               maxWidth: double.infinity,
            //               maxHeight: 500.sp,
            //             ),
            //             builder: (ctx) => BottomFilters(
            //               backgroundColor: homeAppBarColor,
            //               btnclearAll: () async {
            //                 _lowPrice = null;
            //                 _highPrice = null;
            //                 _sortBy = "";
            //                 _categoryFilter = 0;
            //                 final prefs = await SharedPreferences.getInstance();
            //                 prefs.remove("brandList");
            //                 prefs.remove("colorList");
            //                 prefs.remove("sizeList");
            //                 prefs.remove("upper");
            //                 prefs.remove("lower");
            //                 prefs.remove("sortby");
            //                 prefs.remove("category");
            //                 setState(() {});
            //               },
            //               onClick: (low, high) {
            //                 _lowPrice = low;
            //                 _highPrice = high;
            //                 setState(() {});
            //               },
            //             ),
            //           ).whenComplete(
            //               () => setState(() => isBottomSheet = false));
            //         },
            //         child: Padding(
            //           padding: EdgeInsets.symmetric(
            //               vertical: 10.sp, horizontal: 5.sp),
            //           child: Row(
            //             children: [
            //               SvgPicture.asset(
            //                 filterSvgImage,
            //                 color: whiteColor,
            //                 height: 11.sp,
            //                 width: 17.sp,
            //               ),
            //               Padding(
            //                 padding: EdgeInsets.symmetric(horizontal: 5.sp),
            //                 child: Text(
            //                   "FILTERS",
            //                   style: TextStyle(
            //                     color: whiteColor,
            //                     fontSize: 13.sp,
            //                     fontFamily: "Clash Display",
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Container(height: 1.sp, width: double.infinity, color: titleColor),
          ],
        ),
      ),
    );
  }
}
