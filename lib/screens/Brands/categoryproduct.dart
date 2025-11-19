// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/widget/appbar/productlist_appbar.dart';
import '../../common/widget/lists/dummy_grid_list.dart';
import '../../common/widget/other/common_widget.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/brand_controller.dart';
import '../../core/constant/constants.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  final int brandId;
  final int genderType;
  final List tagIds;
  final List categoryList;
  final String genderName;
  final String screen;
  final String type;

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
    required String title,
  });

  @override
  State<CategoryProductScreen> createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController(), permanent: false);
  final cartController = Get.put(CartController(), permanent: false);
  final catalogController = Get.put(CatalogController(), permanent: false);
  final brandController = Get.put(BrandController(), permanent: false);
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String _fmtINR(num? v, {bool cents = true}) {
    if (v == null) return '';
    final f = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: cents ? 2 : 0,
    );
    return f.format(v);
  }

  String? _imageFrom(Map<String, dynamic> m) {
    final urlList = (m['imageUrls'] as List?)
            ?.whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toList() ??
        [];
    if (urlList.isNotEmpty) return urlList.first;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: statusBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      await wishlistController.getWishlistData();
      if (widget.type == "category products") {
        await cartController.getCartData();
      }
      await _clearPref();

      // Load brands for filter
      await brandController.getBrandData("all");

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
            text: widget.categoryName.toUpperCase(),
            isCart: widget.type != "coupon" && widget.type != "express",
            isHandPicked: widget.screen.isNotEmpty,
            onPressedSearch: () async {
              Get.to(const SearchScreen());
              await analytics.logEvent(
                name: "search_page",
                parameters: {"page_name": "search_page"},
              );
            },
            onPressedHeart: () async {
              Get.to(const WishlistScreen())
                  ?.then((_) => cartController.getCartData());
              await analytics.logEvent(
                name: "wishlist_page",
                parameters: {"page_name": "wishlist_page"},
              );
            },
            onPressedCart: () async {
              Get.to(const CartScreen())
                  ?.then((_) => cartController.getCartData());
              await analytics.logEvent(
                name: "cart_page",
                parameters: {"page_name": "cart_page"},
              );
            },
          ),
          SizedBox(height: 8.sp),

          /// ✅ Product Grid
          Expanded(
            child: Obx(() {
              if (catalogController.isCategory.value ||
                  catalogController.isSorting.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DummyGridList(size: 2),
                );
              }

              final items = catalogController.categoryProductList;
              if (items.isEmpty) return _emptyView();

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.sp,
                  crossAxisSpacing: 10.sp,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final m = items[index] as Map<String, dynamic>;

                  /// -------- Brand / Title / Description ----------
                  final brand = (m['brand_name'] ?? m['brandName'] ?? '')
                      .toString()
                      .trim();

                  final title =
                      (m['title'] ?? m['name'] ?? m['productTitle'] ?? '')
                          .toString()
                          .trim();

                  final shortDesc =
                      (m['shortDescription'] ?? m['short_description'] ?? '')
                          .toString()
                          .trim();

                  /// -------- Image ----------
                  final img = _imageFrom(m);

                  /// -------- Correct Price Logic ----------
                  num? price = _parseNum(m['displayPrice']);
                  num? mrp = _parseNum(
                      m['displayMrp']); // null when mrp==0 or ==basePrice

                  /// -------- Product ID ----------
                  final int pid = int.tryParse(m['id']?.toString() ?? '') ?? 0;

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
                      )?.then((_) => cartController.getCartData());

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

          /// ✅ Bottom bar
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
                          await _showSortBottomSheet(
                            context,
                            catId: widget.categoryId,
                            brandId: widget.brandId,
                            collectionId: widget.genderType,
                          );
                        },
                      ),
                      _divider(),
                      _activeTextOnlyButton(
                        "CATEGORY",
                        subtitle: widget.genderName.toUpperCase(),
                        onTap: () {},
                      ),
                      _divider(),
                      _activeBottomButton(
                        icon: filterSvgImage,
                        label: "FILTERS",
                        vector: true,
                        onTap: () async {
                          await _showFilterBottomSheet(context);
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

  num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  Widget _emptyView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(errorImage, height: 200.sp, width: 220.sp),
            const Text(
              "No products found",
              style: TextStyle(
                color: colorPrimary,
                fontSize: 14,
                fontFamily: "Franklin Gothic Regular",
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
        ),
      );

  Widget _divider() =>
      Container(width: 1.sp, color: dividerColor, height: 46.sp);

  Widget _activeBottomButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool vector = false,
  }) =>
      GestureDetector(
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
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // ✅ FIXED FILTER BOTTOM SHEET - Using StatefulBuilder + BrandController API
  Future<void> _showFilterBottomSheet(BuildContext context) async {
    String selectedFilter = "Brand";
    List<String> selectedBrands = [];
    RangeValues priceRange = const RangeValues(100, 50000);

    final List<String> filterCategories = ["Brand", "Price Range"];

    // Get brands from BrandController (excluding alphabet headers)
    final allBrands = brandController.brandList
        .where((item) => item['alphabet'] == null)
        .map((item) => (item['name'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();

    // Add "Select All" at the beginning
    final brands = ["Select All", ...allBrands];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: Get.height * 0.8,
                child: Column(
                  children: [
                    // ---------- HEADER ----------
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.sp, vertical: 16.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("FILTERS",
                              style: TextStyle(
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: blackColor)),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedBrands.clear();
                                priceRange = const RangeValues(100, 50000);
                              });
                            },
                            child: const Text("CLEAR ALL",
                                style: TextStyle(
                                    color: appBarColor,
                                    fontSize: 13,
                                    fontFamily: "Franklin Gothic",
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, color: dividerColor),

                    // ---------- CONTENT ----------
                    Expanded(
                      child: Row(
                        children: [
                          // Left Column
                          SizedBox(
                            width: 130,
                            child: ListView.builder(
                              itemCount: filterCategories.length,
                              itemBuilder: (context, index) {
                                final name = filterCategories[index];
                                final selected = selectedFilter == name;
                                return GestureDetector(
                                  onTap: () => setModalState(() {
                                    selectedFilter = name;
                                  }),
                                  child: Container(
                                    color: selected
                                        ? whiteColor
                                        : const Color(0xFFF5F5F5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.sp, vertical: 14.sp),
                                    child: Text(name,
                                        style: TextStyle(
                                            color: selected
                                                ? blackColor
                                                : const Color(0xFF6B7280),
                                            fontFamily: selected
                                                ? "Franklin Gothic"
                                                : "Franklin Gothic Regular",
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w400)),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Right Column
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp, vertical: 10.sp),
                              child: selectedFilter == "Brand"
                                  ? brandController.isBrand.value
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: appBarColor))
                                      : brands.isEmpty
                                          ? const Center(
                                              child: Text("No brands available",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      color:
                                                          Color(0xFF6B7280))))
                                          : ListView.builder(
                                              itemCount: brands.length,
                                              itemBuilder: (context, i) {
                                                final b = brands[i];
                                                final isSelectAll =
                                                    b == "Select All";
                                                final allSelected =
                                                    selectedBrands.length ==
                                                        brands.length - 1;
                                                final checked = isSelectAll
                                                    ? allSelected
                                                    : selectedBrands
                                                        .contains(b);

                                                return CheckboxListTile(
                                                  dense: true,
                                                  activeColor: appBarColor,
                                                  value: checked,
                                                  title: Text(b,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          color: blackColor)),
                                                  onChanged: (val) {
                                                    setModalState(() {
                                                      if (isSelectAll) {
                                                        if (val == true) {
                                                          selectedBrands = brands
                                                              .where((x) =>
                                                                  x !=
                                                                  "Select All")
                                                              .toList();
                                                        } else {
                                                          selectedBrands
                                                              .clear();
                                                        }
                                                      } else {
                                                        if (val == true) {
                                                          selectedBrands.add(b);
                                                        } else {
                                                          selectedBrands
                                                              .remove(b);
                                                        }
                                                      }
                                                    });
                                                  },
                                                );
                                              },
                                            )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Select price range",
                                            style: TextStyle(
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15)),
                                        const SizedBox(height: 8),
                                        RangeSlider(
                                          values: priceRange,
                                          min: 100,
                                          max: 50000,
                                          divisions: 100,
                                          activeColor: appBarColor,
                                          onChanged: (v) => setModalState(() {
                                            priceRange = v;
                                          }),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("₹${priceRange.start.toInt()}",
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                            Text("₹${priceRange.end.toInt()}",
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- FOOTER ----------
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.sp, vertical: 12.sp),
                      child: Row(
                        children: [
                          Expanded(
                              child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: dividerColor, width: 1.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: const Text("CLOSE",
                                style: TextStyle(
                                    fontFamily: "Franklin Gothic",
                                    color: blackColor)),
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            onPressed: () async {
                              Get.back();

                              // Convert selected brand names to brand IDs
                              final selectedBrandIds = <int>[];
                              for (final brandName in selectedBrands) {
                                final brandData = brandController.brandList
                                    .firstWhereOrNull((item) =>
                                        item['alphabet'] == null &&
                                        item['name']?.toString().trim() ==
                                            brandName);
                                if (brandData != null) {
                                  final id = int.tryParse(
                                      brandData['id']?.toString() ?? '');
                                  if (id != null) selectedBrandIds.add(id);
                                }
                              }

                              print("✅ Applied Filters:");
                              print("Brands: ${selectedBrands.join(', ')}");
                              print("Brand IDs: $selectedBrandIds");
                              print(
                                  "Price: ₹${priceRange.start.toInt()} - ₹${priceRange.end.toInt()}");

                              // Apply filters via API
                              try {
                                await catalogController.getFilteredProducts(
                                  brandIds: selectedBrandIds,
                                  minPrice: priceRange.start.toInt().toString(),
                                  maxPrice: priceRange.end.toInt().toString(),
                                  catId: widget.categoryId,
                                  brandId: widget.brandId,
                                  collectionId: widget.genderType,
                                );

                                getSnackBar(
                                    "Filtered by ${selectedBrands.length} brand(s), ₹${priceRange.start.toInt()}–₹${priceRange.end.toInt()}");
                              } catch (e) {
                                print("❌ Filter error: $e");
                                getSnackBar("Failed to apply filters");
                              }
                            },
                            child: const Text("APPLY",
                                style: TextStyle(
                                    fontFamily: "Franklin Gothic",
                                    color: whiteColor)),
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSortBottomSheet(BuildContext context,
      {int? catId, int? brandId, int? collectionId}) async {
    final RxString selectedOption = "recommended".obs;

    final Map<String, String> sortOptions = {
      "price_asc": "Price - low to high",
      "price_desc": "Price - high to low",
      "whats_new": "What's new",
      "rating": "Customer rating",
      "discount": "Discount",
    };

    await showModalBottomSheet(
      context: context,
      backgroundColor: whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("SORT BY",
                    style: TextStyle(
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: blackColor)),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: () => Get.back())
              ]),
              const SizedBox(height: 8),
              Obx(() => Column(
                    children: sortOptions.entries.map((e) {
                      return RadioListTile<String>(
                        value: e.key,
                        groupValue: selectedOption.value,
                        activeColor: appBarColor,
                        title: Text(e.value,
                            style: const TextStyle(
                                fontFamily: "Franklin Gothic Regular",
                                color: blackColor)),
                        onChanged: (v) =>
                            selectedOption.value = v ?? "recommended",
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: dividerColor, width: 1.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text("CLOSE",
                            style: TextStyle(
                                fontFamily: "Franklin Gothic",
                                color: blackColor)))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () async {
                          final selected = selectedOption.value;
                          Get.back();
                          if (selected == "recommended") {
                            getSnackBar("Showing recommended products");
                            return;
                          }
                          try {
                            catalogController.isSorting.value = true;
                            await catalogController.getSortedProducts(
                              sortOption: selected,
                              catId: catId,
                              brandId: brandId,
                              collectionId: collectionId,
                            );
                            catalogController.categoryProductList
                                .assignAll(catalogController.sortedProductList);
                            getSnackBar(
                                "Sorted by ${sortOptions[selected] ?? 'Option'}");
                          } catch (e) {
                            getSnackBar("Failed to sort products");
                            print("Error in sorting: $e");
                          } finally {
                            catalogController.isSorting.value = false;
                          }
                        },
                        child: const Text("APPLY",
                            style: TextStyle(
                                fontFamily: "Franklin Gothic",
                                color: whiteColor))))
              ]),
              SizedBox(height: 10.sp)
            ],
          ),
        );
      },
    );
  }

  Widget _activeTextOnlyButton(String label,
          {String? subtitle, required VoidCallback onTap}) =>
      GestureDetector(
          onTap: onTap,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
              child: Column(children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 13,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500)),
                if ((subtitle ?? '').isNotEmpty)
                  Padding(
                      padding: EdgeInsets.only(top: 1.sp),
                      child: Text(subtitle!,
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: "Franklin Gothic Regular",
                              fontSize: 10,
                              color: appBarColor)))
              ])));
}

/// ✅ Product Tile
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
        AspectRatio(
          aspectRatio: 0.88, // same look as your screenshot
          child: ClipRRect(
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    dummyWishlistImage,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 8.sp, 6.sp, 0),
          child: Text(brand.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontFamily: "Franklin Gothic",
                  fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 4.sp, 6.sp, 0),
          child: Text(description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontFamily: "Franklin Gothic Regular")),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 6.sp, 6.sp, 0),
          child: Row(children: [
            if (mrp != null && mrp! > 0)
              Padding(
                  padding: EdgeInsets.only(right: 6.sp),
                  child: Text(fmt(mrp, cents: true),
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: "Franklin Gothic Regular",
                          decoration: TextDecoration.lineThrough))),
            Text((price == null || price == 0) ? "" : fmt(price, cents: true),
                style: const TextStyle(
                    color: blackColor,
                    fontSize: 15,
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w700))
          ]),
        ),
      ],
    );
  }
}
