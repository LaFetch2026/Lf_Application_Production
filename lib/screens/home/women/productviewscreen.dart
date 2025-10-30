// ProductViewScreen.dart  (complete)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/widget/appbar/productlist_appbar.dart';
import '../../../common/widget/bottom_sheets/bottomcategory.dart';
import '../../../common/widget/bottom_sheets/bottomfiltters.dart';
import '../../../common/widget/bottom_sheets/bottomsortby.dart';
import '../../../common/widget/lists/dummy_grid_list.dart';
import '../../../common/widget/other/common_widget.dart';
import '../../../common/widget/text/app_text.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constant/constants.dart';

class ProductViewScreen extends StatefulWidget {
  final String title;
  final String genderName;

  const ProductViewScreen({
    super.key,
    required this.title,
    required this.genderName,
  });

  @override
  State<ProductViewScreen> createState() => ProductViewScreenState();
}

class ProductViewScreenState extends State<ProductViewScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final controller = Get.put(CartController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // ---- helpers ----
  String _firstImageUrl(Map<String, dynamic> item) {
    final imgs = item['images'];
    if (imgs is List && imgs.isNotEmpty) {
      final first = imgs.first;
      final name = (first is Map ? first['name'] : null)?.toString() ?? '';
      if (name.isNotEmpty) return name;
    }
    final urls = item['imageUrls'];
    if (urls is List && urls.isNotEmpty) {
      final first = urls.first;
      final s = (first == null) ? '' : first.toString();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  num? _priceOf(Map<String, dynamic> item) {
    return item['price'] ??
        item['msp'] ??
        item['lfMsp'] ??
        item['mrp'] ??
        item['basePrice'];
  }

  String _brandOf(Map<String, dynamic> item) {
    return (item['brand_name'] ??
            (item['brand'] is Map ? item['brand']['name'] : null) ??
            item['type'] ??
            '')
        .toString();
  }

  String _titleOf(Map<String, dynamic> item) {
    return (item['title'] ?? item['name'] ?? '').toString();
  }
  // ---- end helpers ----

  @override
  void initState() {
    super.initState();

    // Map genderName → superCatId
    final g = widget.genderName.trim().toLowerCase();
    if (g == 'men') {
      productController.categoryFilter.value = 1;
    } else if (g == 'women') {
      productController.categoryFilter.value = 2;
    } else {
      productController.categoryFilter.value = 3; // accessories
    }
    productController.selectedCategoryGender.value = widget.genderName;

    // keep your initialization flow
    productController.handPickedProductList.clear();
    productController.handpickedHasnextpage.value = true;
    productController.handpickedLoadMore.value = false;
    productController.isHandPicked.value = false;
    productController.handpickedPage.value = 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wishlistController.getWishlistData();

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: statusBarColor,
      ));

      // fetch all products in the tapped collection (tagId = collectionId)

      controller.getCartData();

      productController.handpickedController.addListener(() {
        productController.update();
      });
    });

    _clearPreferenceValue();
  }

  Future<void> _clearPreferenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("brandList");
    prefs.remove("colorList");
    prefs.remove("sizeList");
    prefs.remove("upper");
    prefs.remove("lower");
    prefs.remove("sortby");
    prefs.remove("category");
  }

  bool isImage(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: whiteColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductAppbar(
            text: widget.title,
            onPressedSearch: () async {
              Get.to(SearchScreen())?.then((_) {
                setState(() {});
              });
              analytics.logEvent(
                  name: "search_page",
                  parameters: {"page_name": "search_page"});
            },
            isHandPicked: true,
            onPressedHeart: () async {
              Get.to(const BottomNavScreen(index: 2))?.then((_) => setState(() {
                    controller.getCartData();
                  }));
              analytics.logEvent(
                  name: "wishlist_page",
                  parameters: {"page_name": "wishlist_page"});
            },
            onPressedCart: () async {
              Get.to(const CartScreen())?.then((_) => setState(() {
                    controller.getCartData();
                  }));
              analytics.logEvent(
                  name: "cart_page", parameters: {"page_name": "cart_page"});
            },
          ),
          SizedBox(height: 10.sp), // Add some space below the app bar
          // ===== GRID =====
          // ===== GRID (replace your entire Obx(...) with this) =====
          Obx(() {
            final loading = productController.isHomeProduct.value ||
                productController.isHandPicked.value;
            if (loading) {
              return const Expanded(child: DummyGridList(size: 2));
            }

            final int selectedCollectionId = productController
                .tagId.value; // collection tapped in "Explore All"
            final int superCatId = productController
                .categoryFilter.value; // 1=Men, 2=Women, 3=Accessories

            // flatten collections -> products
            final List<Map<String, dynamic>> collections = productController
                .homeProductList
                .whereType<Map<String, dynamic>>()
                .toList();

            final List<Map<String, dynamic>> allProducts =
                <Map<String, dynamic>>[];

            for (final c in collections) {
              final List<Map<String, dynamic>> prods =
                  (c['products'] as List? ?? const [])
                      .whereType<Map<String, dynamic>>()
                      .toList();

              for (final p in prods) {
                // keep only the tapped collection (when tagId is set)
                if (selectedCollectionId != 0 &&
                    (p['collectionID'] != selectedCollectionId)) continue;

                // keep only current gender tab
                final sc = p['superCatId'];
                if (superCatId != 0 && sc is int && sc != superCatId) continue;

                // IMPORTANT: do NOT drop status:false anymore
                allProducts.add(p);
              }
            }

            if (allProducts.isEmpty) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(errorImage,
                        height: 200.sp, width: 220.sp, fit: BoxFit.cover),
                    SizedBox(height: 20.sp),
                    getSingleButton(
                      width: double.infinity,
                      label: "BACK TO HOME",
                      textColor: whiteColor,
                      fontSize: 13,
                      backgroundColor: homeAppBarColor,
                      onPressed: () => Get.off(const BottomNavScreen()),
                      borderColor: colorPrimary,
                    ),
                  ],
                ),
              );
            }

            // client-side paging (infinite scroll)
            const int pageSize = 12;
            final int page = (productController.handpickedPage.value <= 0)
                ? 1
                : productController.handpickedPage.value;

            final int maxToShow = page * pageSize;
            final int visibleCount =
                maxToShow < allProducts.length ? maxToShow : allProducts.length;
            final List<Map<String, dynamic>> items =
                allProducts.take(visibleCount).toList();

            return Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 160) {
                    final bool canLoadMore =
                        items.length < allProducts.length &&
                            !productController.handpickedLoadMore.value;
                    if (canLoadMore) {
                      productController.handpickedLoadMore.value = true;
                      Future.delayed(const Duration(milliseconds: 200), () {
                        productController.handpickedPage.value += 1;
                        productController.handpickedLoadMore.value = false;
                      });
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: productController.handpickedController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];

                            final imageUrl = _firstImageUrl(item);
                            final brand = _brandOf(item);
                            final title = _titleOf(item);
                            final price = _priceOf(item);
                            final mrp = item['mrp'];
                            final express = item['express_delivery'] == true;

                            return GestureDetector(
                              onTap: () async {
                                Get.to(
                                  ProductDetailsScreen(
                                    brandName: brand,
                                    productId: item["id"],
                                    type: "add",
                                  ),
                                )?.then((_) {
                                  productController
                                      .handpickedHasnextpage.value = true;
                                  productController.handpickedLoadMore.value =
                                      false;
                                  productController.isHandPicked.value = false;
                                  productController.handpickedPage.value = 1;
                                  controller.getCartData();
                                });

                                await analytics.logEvent(
                                  name: 'category_product_details',
                                  parameters: {
                                    'page_name': 'category_product_details'
                                  },
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6.sp),
                                    child: AspectRatio(
                                      aspectRatio: 0.75, // 3:4
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        cacheManager: CacheManager(
                                          Config("customCacheKey",
                                              stalePeriod:
                                                  const Duration(days: 15),
                                              maxNrOfCacheObjects: 100),
                                        ),
                                        placeholder: (_, __) => Container(
                                            color:
                                                Colors.black.withOpacity(0.06)),
                                        errorWidget: (_, __, ___) => Container(
                                            color:
                                                Colors.black.withOpacity(0.06)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5.sp),
                                  AppText(
                                    text: brand.toUpperCase(),
                                    color: blackColor,
                                    maxLines: 1,
                                    fontSize: 13,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                  ),
                                  AppText(
                                    text: title,
                                    color: const Color(0xFF6B7280),
                                    maxLines: 1,
                                    fontSize: 11,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 6.sp),
                                    child: Row(
                                      children: [
                                        if (mrp != null &&
                                            mrp is num &&
                                            price != null &&
                                            price < mrp)
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 5.sp),
                                            child: Text(
                                              "₹ $mrp",
                                              style: TextStyle(
                                                color: searchTextColor,
                                                fontSize: 11.sp,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        AppText(
                                          text: "₹ ${price?.toString() ?? ''}",
                                          color: homeAppBarColor,
                                          maxLines: 2,
                                          fontSize: 11,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (express)
                                    Padding(
                                      padding: EdgeInsets.only(top: 3.sp),
                                      child: Row(
                                        children: [
                                          ImageIcon(AssetImage(truckImage),
                                              color: expressText, size: 14.sp),
                                          SizedBox(width: 5.sp),
                                          AppText(
                                            text: "Express",
                                            color: expressText,
                                            maxLines: 2,
                                            fontSize: 11,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.56,
                          crossAxisSpacing: 5.sp,
                          mainAxisSpacing: 8.sp,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: productController.handpickedLoadMore.value
                          ? const DummyGridList(size: 2)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),

          // ===== bottom sort / category / filters row =====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Sort by
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 340.sp),
                      builder: (ctx) => BottomSortBy(
                        onPressedButton: (p0) {
                          productController.productSortBy.value = p0;
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
                    child: Row(
                      children: [
                        SvgPicture.asset(sortBySvgImage,
                            height: 19.sp, width: 15.sp),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.sp),
                          child: Text(
                            "SORT BY",
                            style: TextStyle(
                              color: const Color(0xFF374151),
                              fontSize: 13.sp,
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1.sp, color: borderColor, height: 40.sp),

                // Category (Men/Women/Accessories) → sets superCatId
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 270.sp),
                      builder: (ctx) => BottomCategory(
                        gender: productController.selectedCategoryGender.value,
                        onPressedButton: (p0) {
                          // Mapping: Men=1, Women=2, Accessories=3
                          if (p0 == "Women") {
                            productController.categoryFilter.value = 2;
                          } else if (p0 == "Men") {
                            productController.categoryFilter.value = 1;
                          } else {
                            productController.categoryFilter.value = 3;
                          }

                          productController.selectedCategoryGender.value = p0;
                        },
                        onPressedFilter: () {
                          Get.back();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            constraints: BoxConstraints(
                                maxWidth: double.infinity, maxHeight: 500.sp),
                            builder: (ctx) => BottomFilters(
                              btnclearAll: () async {
                                productController.brand_ids.clear();
                                productController.color_ids.clear();
                                productController.size_ids.clear();
                                productController.productSortBy.value = "";
                                productController.filterProductEnable.value =
                                    false;
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove("brandList");
                                prefs.remove("colorList");
                                prefs.remove("sizeList");
                                prefs.remove("upper");
                                prefs.remove("lower");
                                prefs.remove("sortby");
                                prefs.remove("category");
                              },
                              onClick: (p0, p1) {
                                productController.filterProductEnable.value =
                                    true;
                                productController.lowPrice.value = p0;
                                productController.highPrice.value = p1;
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.sp),
                          child: Text(
                            "CATEGORY",
                            style: TextStyle(
                              color: const Color(0xFF374151),
                              fontSize: 13.sp,
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        Obx(
                          () => Visibility(
                            visible: productController
                                .selectedCategoryGender.value.isNotEmpty,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 5.sp, right: 5.sp, top: 1.sp),
                              child: Text(
                                productController.selectedCategoryGender.value
                                    .toUpperCase(),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: appBarColor,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1.sp, color: borderColor, height: 40.sp),

                // Filters
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, maxHeight: 500.sp),
                      builder: (ctx) => BottomFilters(
                        btnclearAll: () async {
                          productController.brand_ids.clear();
                          productController.color_ids.clear();
                          productController.size_ids.clear();
                          productController.productSortBy.value = "";
                          productController.filterProductEnable.value = false;
                          final prefs = await SharedPreferences.getInstance();
                          prefs.remove("brandList");
                          prefs.remove("colorList");
                          prefs.remove("sizeList");
                          prefs.remove("upper");
                          prefs.remove("lower");
                          prefs.remove("sortby");
                          prefs.remove("category");
                        },
                        onClick: (p0, p1) {
                          productController.filterProductEnable.value = true;
                          productController.lowPrice.value = p0;
                          productController.highPrice.value = p1;
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
                    child: Row(
                      children: [
                        SvgPicture.asset(filterSvgImage,
                            height: 11.sp, width: 17.sp),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.sp),
                          child: Text(
                            "FILTERS",
                            style: TextStyle(
                              color: const Color(0xFF374151),
                              fontSize: 13.sp,
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
