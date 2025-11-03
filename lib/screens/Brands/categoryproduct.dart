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
import '../../common/widget/lists/dummy_grid_list.dart';
import '../../common/widget/other/common_widget.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
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
                  padding: EdgeInsets.only(top: 8),
                  child: DummyGridList(size: 2),
                );
              }

              final items = catalogController.categoryProductList;
              if (items.isEmpty) {
                return _emptyView();
              }

              return GridView.builder(
                padding: EdgeInsets.fromLTRB(16.sp, 8.sp, 16.sp, 20.sp),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 16.sp,
                  mainAxisSpacing: 18.sp,
                ),
                itemBuilder: (context, index) {
                  final m = items[index] as Map<String, dynamic>;
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
                  final img = _imageFrom(m);

                  num? price = _parseNum(m['basePrice'] ??
                      m['base_price'] ??
                      m['baseprice'] ??
                      m['price']);
                  num? mrp = _parseNum(m['mrp']);

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
                            collectionId:
                                widget.genderType, // or correct collection ID
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

  Widget _emptyView() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(errorImage, height: 200.sp, width: 220.sp),
          const Text(
            "No products found",
            style: TextStyle(
              color: colorPrimary,
              fontSize: 14,
              fontFamily: "Franklin Gothic Regular",
              fontWeight: FontWeight.w400,
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

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    final selectedFilter = "Brand".obs;
    final selectedBrands = <String>[].obs;
    final priceRange = const RangeValues(100, 50000).obs;

    final List<String> filterCategories = [
      "Brand",
      "Price Range",
    ];

    final List<String> brands = [
      "Select All",
      "Balenciaga",
      "Bottega Veneta",
      "Burberry",
      "Celine",
      "Chloe",
      "Christian Dior",
      "Fendi",
      "Givenchy",
      "Gucci",
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          height: Get.height * 0.8,
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "FILTERS",
                    style: TextStyle(
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: blackColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      selectedBrands.clear();
                      priceRange.value = const RangeValues(100, 50000);
                    },
                    child: const Text(
                      "CLEAR ALL",
                      style: TextStyle(
                        fontFamily: "Franklin Gothic",
                        fontSize: 13,
                        color: appBarColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1, color: dividerColor),

              // ---------- MAIN CONTENT ----------
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- LEFT FILTER MENU ----------
                    Obx(() => Container(
                          width: 120,
                          color: const Color(0xFFF5F5F5),
                          child: ListView.builder(
                            itemCount: filterCategories.length,
                            itemBuilder: (context, index) {
                              final name = filterCategories[index];
                              final isSelected = selectedFilter.value == name;
                              return GestureDetector(
                                onTap: () => selectedFilter.value = name,
                                child: Container(
                                  color: isSelected
                                      ? whiteColor
                                      : const Color(0xFFF5F5F5),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.sp, vertical: 14.sp),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: isSelected
                                          ? "Franklin Gothic"
                                          : "Franklin Gothic Regular",
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      fontSize: 14,
                                      color: isSelected
                                          ? blackColor
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )),

                    // ---------- RIGHT FILTER CONTENT ----------
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        child: Obx(() {
                          // Switch between filter type
                          if (selectedFilter.value == "Brand") {
                            return ListView.builder(
                              itemCount: brands.length,
                              itemBuilder: (context, index) {
                                final brand = brands[index];
                                final isSelectAll = brand == "Select All";
                                final allChecked =
                                    selectedBrands.length == brands.length - 1;
                                final isChecked = isSelectAll
                                    ? allChecked
                                    : selectedBrands.contains(brand);

                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: appBarColor,
                                  title: Text(
                                    brand,
                                    style: const TextStyle(
                                      fontFamily: "Franklin Gothic Regular",
                                      fontSize: 14,
                                      color: blackColor,
                                    ),
                                  ),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    if (isSelectAll) {
                                      if (value == true) {
                                        selectedBrands.assignAll(
                                          brands
                                              .where((b) => b != "Select All")
                                              .toList(),
                                        );
                                      } else {
                                        selectedBrands.clear();
                                      }
                                    } else {
                                      if (value == true) {
                                        selectedBrands.add(brand);
                                      } else {
                                        selectedBrands.remove(brand);
                                      }
                                    }
                                  },
                                );
                              },
                            );
                          } else {
                            // PRICE RANGE SLIDER
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Select price range",
                                  style: TextStyle(
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: blackColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Obx(() => RangeSlider(
                                      values: priceRange.value,
                                      min: 100,
                                      max: 50000,
                                      divisions: 100,
                                      activeColor: appBarColor,
                                      inactiveColor: Colors.grey.shade300,
                                      labels: RangeLabels(
                                        "₹${priceRange.value.start.toInt()}",
                                        "₹${priceRange.value.end.toInt()}",
                                      ),
                                      onChanged: (RangeValues values) {
                                        priceRange.value = values;
                                      },
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Obx(() => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "₹${priceRange.value.start.toInt()}",
                                            style: const TextStyle(
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "₹${priceRange.value.end.toInt()}",
                                            style: const TextStyle(
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            );
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- FOOTER ----------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: dividerColor, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                      child: const Text(
                        "CLOSE",
                        style: TextStyle(
                          fontFamily: "Franklin Gothic",
                          color: blackColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blackColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                      onPressed: () {
                        Get.back();
                        print("✅ Applied Filters:");
                        print("Brands: ${selectedBrands.join(', ')}");
                        print(
                            "Price: ₹${priceRange.value.start.toInt()} - ₹${priceRange.value.end.toInt()}");

                        getSnackBar(
                          "Applied ${selectedBrands.length} brands, ₹${priceRange.value.start.toInt()}–₹${priceRange.value.end.toInt()}",
                        );
                      },
                      child: const Text(
                        "APPLY",
                        style: TextStyle(
                          fontFamily: "Franklin Gothic",
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SORT BY",
                    style: TextStyle(
                      fontFamily: "Franklin Gothic",
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: blackColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ---------- SORT OPTIONS ----------
              Obx(() => Column(
                    children: sortOptions.entries.map((entry) {
                      return RadioListTile<String>(
                        value: entry.key,
                        groupValue: selectedOption.value,
                        activeColor: appBarColor,
                        title: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 15,
                            color: blackColor,
                          ),
                        ),
                        onChanged: (value) =>
                            selectedOption.value = value ?? "recommended",
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 8),

              // ---------- ACTION BUTTONS ----------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: dividerColor, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                      child: const Text(
                        "CLOSE",
                        style: TextStyle(
                          fontFamily: "Franklin Gothic",
                          color: blackColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blackColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
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
                            "Sorted by ${sortOptions[selected] ?? 'Option'}",
                          );
                        } catch (e) {
                          getSnackBar("Failed to sort products");
                          print("Error in sorting: $e");
                        } finally {
                          catalogController.isSorting.value = false;
                        }
                      },
                      child: const Text(
                        "APPLY",
                        style: TextStyle(
                          fontFamily: "Franklin Gothic",
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.sp),
            ],
          ),
        );
      },
    );
  }

  Widget _activeTextOnlyButton(
    String label, {
    String? subtitle,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
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
                      fontSize: 10,
                      color: appBarColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

/// Product Tile
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
                      Config("productGridCache",
                          stalePeriod: const Duration(days: 15),
                          maxNrOfCacheObjects: 100),
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
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: "Franklin Gothic Regular",
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              Text(
                (price == null || price == 0) ? "" : fmt(price, cents: true),
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
