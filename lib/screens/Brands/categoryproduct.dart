// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/widget/appbar/productlist_appbar.dart';
import '../../common/widget/lists/dummy_container.dart';
import '../../common/widget/lists/dummy_grid_list.dart';
import '../../common/widget/other/common_widget.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId; // can be 0 for "banner only" lists
  final int brandId; // optional 0
  final int genderType; // 1/2/3 (Men/Women/Accessories)
  final List tagIds; // keep dynamic to match existing code
  final List categoryList; // keep dynamic to match existing code
  final String genderName;
  final String screen; // e.g. "category"
  final String type; // default: "category products"

  const CategoryProductScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.brandId,
    required this.genderType,
    required this.tagIds,
    required this.genderName,
    this.type = "category products",
    this.screen = "",
    required this.categoryList,
    required String title, // kept for backward signature compatibility
  });

  @override
  State<CategoryProductScreen> createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController(), permanent: false);
  final controller = Get.put(CartController(), permanent: false);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final catalogController = Get.put(CatalogController(), permanent: false);

  /// INR formatter – tolerant of nulls
  String _fmtINR(num? v, {bool cents = true}) {
    if (v == null) return '';
    final f = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: cents ? 2 : 0,
    );
    return f.format(v);
  }

  /// Robustly pick an image string from new/old shapes
  String? _imageFrom(Map<String, dynamic> m) {
    // new API: imageUrls: [String, ...]
    final urlList = (m['imageUrls'] as List?)
            ?.whereType()
            .map((e) => e.toString())
            .where((s) => s.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    if (urlList.isNotEmpty) return urlList.first;

    // legacy fallbacks
    for (final key in const [
      'image',
      'thumbnail',
      'thumb',
      'cover',
      'defaultImage',
      'primaryImage',
      'img',
      'photo'
    ]) {
      final v = m[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  Future<void> _clearPref() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in [
      "brandList",
      "colorList",
      "sizeList",
      "upper",
      "lower",
      "sortby",
      "category"
    ]) {
      await prefs.remove(k);
    }
  }

  void _showGenderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Category",
                style: TextStyle(
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: blackColor,
                ),
              ),
              SizedBox(height: 16.sp),
              _genderOption(context, "Men", 1),
              _genderOption(context, "Women", 2),
              _genderOption(context, "Accessories", 3),
              SizedBox(height: 12.sp),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // One post-frame is enough
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Set system bars for this screen
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: statusBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      // Load data
      await wishlistController.getWishlistData();
      if (widget.type == "category products") {
        await controller.getCartData();
      }
      await _clearPref();

      // Drive list by category (and gender) as before
      await catalogController.getCategoryProductData(
        widget.categoryId,
        widget.genderType,
      );
    });
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
            onPressedSearch: () async {
              Get.to(const SearchScreen());
              await analytics.logEvent(
                name: "search_page",
                parameters: {"page_name": "search_page"},
              );
            },
            onPressedHeart: () async {
              Get.to(const WishlistScreen())
                  ?.then((_) => controller.getCartData());
              await analytics.logEvent(
                name: "wishlist_page",
                parameters: {"page_name": "wishlist_page"},
              );
            },
            isCart: widget.type != "coupon" && widget.type != "express",
            isHandPicked: widget.screen.isNotEmpty,
            text: widget.categoryName.toUpperCase(),
            onPressedCart: () async {
              Get.to(const CartScreen())?.then((_) => controller.getCartData());
              await analytics.logEvent(
                name: "cart_page",
                parameters: {"page_name": "cart_page"},
              );
            },
          ),

          SizedBox(height: 8.sp),

          Expanded(
            child: Obx(() {
              if (catalogController.isCategory.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: DummyGridList(size: 2),
                );
              }

              final items = catalogController.categoryProductList;
              if (items.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      errorImage,
                      height: 200.sp,
                      width: 220.sp,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 2.sp,
                      ),
                      child: const Text(
                        "No products found",
                        style: TextStyle(
                          color: colorPrimary,
                          fontSize: 14,
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.sp),
                      child: getSingleButton(
                        width: double.infinity,
                        label: "BACK TO HOME",
                        textColor: whiteColor,
                        fontSize: 13,
                        backgroundColor: homeAppBarColor,
                        onPressed: () => Get.off(const BottomNavScreen()),
                        borderColor: colorPrimary,
                      ),
                    ),
                  ],
                );
              }

              return GridView.builder(
                padding: EdgeInsets.fromLTRB(16.sp, 8.sp, 16.sp, 20.sp),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // Taller cells reduce overflow risk on long titles
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 16.sp,
                  mainAxisSpacing: 18.sp,
                ),
                itemBuilder: (context, index) {
                  final m = items[index] as Map<String, dynamic>? ?? {};

                  // Prefer new API fields, fallback to legacy
                  final brand = (m['brand_name'] ?? m['brandName'] ?? '')
                      .toString()
                      .trim();

                  final title =
                      (m['title'] ?? m['name'] ?? m['productTitle'] ?? '')
                          .toString()
                          .trim();

                  final shortDesc = (m['shortDescription'] ??
                          m['short_description'] ??
                          m['shortDesc'] ??
                          '')
                      .toString()
                      .trim();

                  num? price;
                  final rawPrice = m['basePrice'] ??
                      m['base_price'] ??
                      m['baseprice'] ??
                      m['price'];
                  if (rawPrice is num) {
                    price = rawPrice;
                  } else if (rawPrice is String) {
                    price = num.tryParse(rawPrice);
                  }

                  num? mrp;
                  final rawMrp = m['mrp'];
                  if (rawMrp is num) {
                    mrp = rawMrp;
                  } else if (rawMrp is String) {
                    mrp = num.tryParse(rawMrp);
                  }

                  final img = _imageFrom(m);

                  // Robust product id parsing
                  final int pid = () {
                    final v = m['id'];
                    if (v is int) return v;
                    return int.tryParse(v?.toString() ?? '') ?? 0;
                  }();

                  return GestureDetector(
                    onTap: () async {
                      if (pid == 0) {
                        getSnackBar("Product not available");
                        return;
                      }
                      Get.to(
                        ProductDetailsScreen(
                          brandName: brand.isEmpty ? title : brand,
                          expressValue: widget.type == "express" ? 1 : 0,
                          backgroundcolor: widget.type == "express"
                              ? homeAppBarColor
                              : whiteColor,
                          productId: pid,
                          type: "add",
                        ),
                      )?.then((_) => controller.getCartData());
                      await analytics.logEvent(
                        name: 'category_product_details',
                        parameters: {'page_name': 'category_product_details'},
                      );
                    },
                    child: _ProductTileNoOverflow(
                      imageUrl: img,
                      brand: brand.isEmpty ? title : brand,
                      description: shortDesc.isEmpty ? title : shortDesc,
                      mrp: mrp,
                      price: price,
                      fmt: _fmtINR,
                    ),
                  );
                },
              );
            }),
          ),

          // --- ENABLED BOTTOM BAR ---
          Container(
            color: statusBarColor,
            child: Column(
              children: [
                Container(height: 1.sp, color: dividerColor),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _activeBottomButton(
                        icon: sortBySvgImage,
                        label: "SORT BY",
                        onTap: () async {
                          // 👉 Open your sort modal or page
                          getSnackBar("Sort options coming soon!");
                          // Example: await showSortBottomSheet(context);
                        },
                      ),
                      _divider(),
                      _activeTextOnlyButton(
                        "CATEGORY",
                        subtitle: widget.genderName.toUpperCase(),
                        onTap: () async {
                          // _showGenderSelector(context);
                        },
                      ),
                      _divider(),
                      _activeBottomButton(
                        icon: filterSvgImage,
                        label: "FILTERS",
                        vector: true,
                        onTap: () async {
                          // 👉 Open filters bottom sheet
                          getSnackBar("Filter options coming soon!");
                          // Example: await showFilterBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderOption(BuildContext context, String label, int genderType) {
    return ListTile(
      leading: Icon(
        genderType == 1
            ? Icons.male
            : genderType == 2
                ? Icons.female
                : Icons.shopping_bag_outlined,
        color: appBarColor,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: "Franklin Gothic Regular",
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: blackColor,
        ),
      ),
      onTap: () async {
        Navigator.pop(context); // close sheet

        // Save new gender selection
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('selectedGender', genderType);

        // Clear cached filters
        await _clearPref();

        // Fetch category products for selected gender
        catalogController.isCategory.value = true;
        await catalogController.getCategoryProductData(
          widget.categoryId,
          genderType,
        );
        catalogController.isCategory.value = false;

        // Show feedback
        getSnackBar("Switched to $label");

        setState(() {
          // Update local gender name in UI
          widget.genderName == label;
        });
      },
    );
  }

  Widget _divider() =>
      Container(width: 1.sp, color: dividerColor, height: 46.sp);

  Widget _activeBottomButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool vector = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: vector ? 11.sp : 19.sp,
              width: vector ? 17.sp : 15.sp,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.sp),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeTextOnlyButton(
    String label, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontFamily: "Franklin Gothic",
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            if ((subtitle ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 1.sp),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: appBarColor,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card that never overflows.
class _ProductTileNoOverflow extends StatelessWidget {
  final String? imageUrl;
  final String brand;
  final String description;
  final num? mrp;
  final num? price;
  final String Function(num?, {bool cents}) fmt;

  const _ProductTileNoOverflow({
    required this.imageUrl,
    required this.brand,
    required this.description,
    required this.mrp,
    required this.price,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl!.trim().isNotEmpty
                ? CachedNetworkImage(
                    cacheManager: CacheManager(
                      Config(
                        "productGridCache",
                        stalePeriod: Duration(days: 15),
                        maxNrOfCacheObjects: 100,
                      ),
                    ),
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Image.asset(downloadImage, fit: BoxFit.cover),
                  )
                : Image.asset(dummyWishlistImage, fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 8.sp, 6.sp, 0),
          child: Text(
            brand.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: blackColor,
              fontSize: 15,
              fontFamily: "Franklin Gothic",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 4.sp, 6.sp, 0),
          child: Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 6.sp, 6.sp, 0),
          child: Row(
            children: [
              if (mrp != null && mrp! > 0)
                Padding(
                  padding: EdgeInsets.only(right: 6.sp),
                  child: Text(
                    fmt(mrp, cents: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              Text(
                (price == null || price == 0) ? "" : fmt(price, cents: true),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
