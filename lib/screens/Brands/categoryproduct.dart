// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
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
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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

  // ✅ Cache flags to prevent redundant API calls
  bool _isWishlistLoaded = false;
  bool _isCartLoaded = false;
  bool _isBrandsLoaded = false;
  bool _isCategoryProductsLoaded = false;

  // ✅ Initial loading state
  bool _isInitialLoading = true;

  // ✅ Hash tracking for change detection
  String? _lastProductListHash;
  String? _lastFilterHash;
  String? _lastSortHash;

  // ✅ Debounce timer
  Timer? _debounceTimer;

  // ✅ Current filter/sort state
  List<int> _appliedBrandIds = [];
  String _appliedMinPrice = "100";
  String _appliedMaxPrice = "50000";
  String _appliedSortOption = "recommended";
  bool _hasActiveFilters = false;

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

  // ✅ Generate hash for product list to detect changes
  String _generateProductHash(List<dynamic> products) {
    if (products.isEmpty) return 'empty';
    return products
        .map((p) => '${p['id']}_${p['displayPrice']}_${p['displayMrp']}')
        .join('|');
  }

  // ✅ Generate hash for current filter state
  String _generateFilterHash() {
    return '${_appliedBrandIds.join(',')}_${_appliedMinPrice}_${_appliedMaxPrice}_$_hasActiveFilters';
  }

  // ✅ Generate hash for current sort state
  String _generateSortHash() {
    return _appliedSortOption;
  }

  // ✅ Check if products list has actually changed
  bool _hasProductsChanged(List<dynamic> newProducts) {
    final currentHash =
        _generateProductHash(catalogController.categoryProductList);
    final newHash = _generateProductHash(newProducts);

    if (currentHash != newHash) {
      print("🔄 Products changed: $currentHash → $newHash");
      return true;
    }

    print("✅ Products unchanged - skipping update");
    return false;
  }

  // ✅ Smart wishlist loader - only loads once
  Future<void> _loadWishlistIfNeeded() async {
    if (_isWishlistLoaded) {
      print("✅ Wishlist already loaded - skipping");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('skip') ?? false;

    if (!isGuest) {
      await wishlistController.getWishlistData();
      _isWishlistLoaded = true;
      print("✅ Wishlist loaded successfully");
    } else {
      print("👤 Guest user - skipping wishlist");
    }
  }

  // ✅ Smart cart loader - only loads once or when explicitly refreshed
  Future<void> _loadCartIfNeeded({bool forceRefresh = false}) async {
    if (_isCartLoaded && !forceRefresh) {
      print("✅ Cart already loaded - skipping");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('skip') ?? false;

    if (!isGuest && widget.type == "category products") {
      await cartController.getCartData();
      _isCartLoaded = true;
      print("✅ Cart loaded successfully");
    } else {
      print("👤 Guest user or non-category screen - skipping cart");
    }
  }

  // ✅ Smart brand loader - only loads once
  Future<void> _loadBrandsIfNeeded() async {
    if (_isBrandsLoaded) {
      print("✅ Brands already loaded - skipping");
      return;
    }

    await brandController.getBrandData("all");
    _isBrandsLoaded = true;
    print("✅ Brands loaded successfully");
  }

  // ✅ Smart category products loader - only loads once initially
  Future<void> _loadCategoryProductsIfNeeded() async {
    if (_isCategoryProductsLoaded) {
      print("✅ Category products already loaded - skipping");
      return;
    }

    await catalogController.getCategoryProductData(
      widget.categoryId,
      widget.genderType,
    );

    // Generate initial hash
    _lastProductListHash = _generateProductHash(
      catalogController.categoryProductList,
    );
    _lastFilterHash = _generateFilterHash();
    _lastSortHash = _generateSortHash();

    _isCategoryProductsLoaded = true;
    print(
        "✅ Category products loaded successfully (${catalogController.categoryProductList.length} items)");
  }

  // ✅ Initial load - happens before screen is visible
  Future<void> _performInitialLoad() async {
    try {
      print("🔄 Starting initial load...");

      // Load all data in parallel for faster loading
      await Future.wait([
        _loadWishlistIfNeeded(),
        _loadCartIfNeeded(),
        _clearPref(),
        _loadBrandsIfNeeded(),
        _loadCategoryProductsIfNeeded(),
      ]);

      print("✅ Initial load complete");
    } catch (e) {
      print("❌ Error during initial load: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  // ✅ Optimized filter and sort application
  Future<void> _applyFiltersAndSort() async {
    try {
      // Check if filter/sort state has actually changed
      final currentFilterHash = _generateFilterHash();
      final currentSortHash = _generateSortHash();

      final filterChanged = currentFilterHash != _lastFilterHash;
      final sortChanged = currentSortHash != _lastSortHash;

      if (!filterChanged && !sortChanged) {
        print("⚠️ No filter/sort changes detected - skipping API call");
        return;
      }

      print("🔄 Applying changes - Filter: $filterChanged, Sort: $sortChanged");

      catalogController.isCategory.value = true;

      // Store current products for comparison
      final previousProducts = List<dynamic>.from(
        catalogController.categoryProductList,
      );

      // Apply filters if active and changed
      if (_hasActiveFilters && filterChanged) {
        print(
            "🔍 Applying filters: brands=${_appliedBrandIds.length}, price=$_appliedMinPrice-$_appliedMaxPrice");

        await catalogController.getFilteredProducts(
          brandIds: _appliedBrandIds,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          catId: widget.categoryId,
          brandId: widget.brandId,
          collectionId: widget.genderType,
        );

        // Check if filtered products are different
        if (!_hasProductsChanged(catalogController.categoryProductList)) {
          print("⚠️ Filtered products unchanged - reverting");
          catalogController.categoryProductList.assignAll(previousProducts);
          return;
        }

        _lastFilterHash = currentFilterHash;
        print(
            "✅ Filters applied - ${catalogController.categoryProductList.length} products");
      } else if (!_hasActiveFilters && filterChanged) {
        // Filters cleared - reload original products
        if (!_isCategoryProductsLoaded) {
          await catalogController.getCategoryProductData(
            widget.categoryId,
            widget.genderType,
          );
          _isCategoryProductsLoaded = true;
        }
        _lastFilterHash = currentFilterHash;
      }

      // Apply sort if not recommended and changed
      if (_appliedSortOption != "recommended" && sortChanged) {
        print("🔀 Applying sort: $_appliedSortOption");

        await catalogController.getSortedProducts(
          sortOption: _appliedSortOption,
          catId: widget.categoryId,
          brandId: widget.brandId,
          collectionId: widget.genderType,
        );

        // Check if sort changed the product order
        final sortedHash = _generateProductHash(
          catalogController.sortedProductList,
        );
        final currentHash = _generateProductHash(
          catalogController.categoryProductList,
        );

        if (sortedHash != currentHash) {
          catalogController.categoryProductList.assignAll(
            catalogController.sortedProductList,
          );
          _lastProductListHash = sortedHash;
          _lastSortHash = currentSortHash;
          print("✅ Sort applied - order changed");
        } else {
          print("⚠️ Sort didn't change order - skipping update");
        }
      } else if (_appliedSortOption == "recommended" && sortChanged) {
        // Reset to original order
        _lastSortHash = currentSortHash;
      }

      // Update final hash
      _lastProductListHash = _generateProductHash(
        catalogController.categoryProductList,
      );
    } catch (e) {
      print("❌ Error applying filters/sort: $e");
      getSnackBar("Failed to apply filters");
    } finally {
      catalogController.isCategory.value = false;
    }
  }

  // ✅ Debounced filter/sort application
  Future<void> _applyFiltersAndSortDebounced() async {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFiltersAndSort();
    });
  }

  @override
  void initState() {
    super.initState();

    // ✅ Start loading immediately, before frame is rendered
    _performInitialLoad();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: statusBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
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
              final prefs = await SharedPreferences.getInstance();
              final isGuest = prefs.getBool('skip') ?? false;

              if (isGuest) {
                getSnackBar("Please login to view your wishlist");
                Get.toNamed('/login');
                return;
              }

              Get.to(const WishlistScreen())?.then((_) async {
                await _loadCartIfNeeded(forceRefresh: true);
              });
              await analytics.logEvent(
                name: "wishlist_page",
                parameters: {"page_name": "wishlist_page"},
              );
            },
            onPressedCart: () async {
              final prefs = await SharedPreferences.getInstance();
              final isGuest = prefs.getBool('skip') ?? false;

              if (isGuest) {
                getSnackBar("Please login to view your cart");
                Get.offAll(() => LoginScreen(initialTab: 0));
                return;
              }

              Get.to(const CartScreen())?.then((_) async {
                await _loadCartIfNeeded(forceRefresh: true);
              });
              await analytics.logEvent(
                name: "cart_page",
                parameters: {"page_name": "cart_page"},
              );
            },
          ),
          SizedBox(height: 8.sp),

          /// ✅ Product Grid with skeleton loading
          Expanded(
            child: _isInitialLoading
                ? _buildSkeletonGrid()
                : Obx(() {
                    if (catalogController.isCategory.value ||
                        catalogController.isSorting.value) {
                      return _buildSkeletonGrid();
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
                        final m = normalizeProduct(items[index]);

                        final brand = (m['brandName'] ?? '').toString().trim();
                        final title = (m['title'] ?? '').toString().trim();
                        final shortDesc =
                            (m['shortDescription'] ?? title).toString().trim();
                        final img = _imageFrom(m);

                        num? price = _parseNum(m['displayPrice']);
                        num? mrp = _parseNum(m['displayMrp']);

                        final int pid =
                            int.tryParse(m['id']?.toString() ?? '') ?? 0;

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
                            )?.then((_) async {
                              await _loadCartIfNeeded(forceRefresh: true);
                            });

                            await analytics.logEvent(
                              name: 'category_product_details',
                              parameters: {
                                'page_name': 'category_product_details'
                              },
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

  /// ✅ Skeleton Grid with shimmer effect
  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      itemCount: 6, // Show 6 skeleton items
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.sp,
        crossAxisSpacing: 10.sp,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        return _SkeletonProductTile();
      },
    );
  }

  num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  Map<String, dynamic> normalizeProduct(Map<String, dynamic> m) {
    return {
      "id": m["id"],
      "title": m["title"] ?? m["name"] ?? "",
      "brandName": m["brand_name"] ?? m["brandName"] ?? "",
      "shortDescription": m["shortDescription"] ??
          m["description"] ??
          m["short_description"] ??
          "",
      "imageUrls": m["imageUrls"] is List
          ? m["imageUrls"]
          : (m["images"] is List ? m["images"] : []),
      "displayPrice": m["displayPrice"] ??
          m["price"] ??
          m["selling_price"] ??
          m["mrp"] ??
          0,
      "displayMrp": m["displayMrp"] ?? m["mrp"] ?? m["original_price"] ?? 0,
    };
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

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    String selectedFilter = "Brand";

    List<String> selectedBrands = [];
    RangeValues priceRange = RangeValues(
      double.parse(_appliedMinPrice),
      double.parse(_appliedMaxPrice),
    );

    final List<String> filterCategories = ["Brand", "Price Range"];

    // ✅ Ensure brands are loaded
    await _loadBrandsIfNeeded();

    if (brandController.isBrand.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final allBrands = brandController.brandList
        .where((item) => item['alphabet'] == null)
        .map((item) => (item['name'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (allBrands.isEmpty) {
      getSnackBar("No brands available for filtering");
      return;
    }

    // ✅ Restore previously applied brands
    for (final id in _appliedBrandIds) {
      final brandData = brandController.brandList.firstWhereOrNull((item) =>
          item['alphabet'] == null &&
          int.tryParse(item['id']?.toString() ?? '') == id);
      if (brandData != null) {
        final name = brandData['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          selectedBrands.add(name);
        }
      }
    }

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
                    Expanded(
                      child: Row(
                        children: [
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
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp, vertical: 10.sp),
                              child: selectedFilter == "Brand"
                                  ? ListView.builder(
                                      itemCount: brands.length,
                                      itemBuilder: (context, i) {
                                        final b = brands[i];
                                        final isSelectAll = b == "Select All";
                                        final allSelected =
                                            selectedBrands.length ==
                                                brands.length - 1;
                                        final checked = isSelectAll
                                            ? allSelected
                                            : selectedBrands.contains(b);

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
                                                          x != "Select All")
                                                      .toList();
                                                } else {
                                                  selectedBrands.clear();
                                                }
                                              } else {
                                                if (val == true) {
                                                  selectedBrands.add(b);
                                                } else {
                                                  selectedBrands.remove(b);
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

                              setState(() {
                                _appliedBrandIds = selectedBrandIds;
                                _appliedMinPrice =
                                    priceRange.start.toInt().toString();
                                _appliedMaxPrice =
                                    priceRange.end.toInt().toString();
                                _hasActiveFilters =
                                    selectedBrandIds.isNotEmpty ||
                                        priceRange.start > 100 ||
                                        priceRange.end < 50000;
                              });

                              print("✅ Filters configured:");
                              print("  Brands: ${selectedBrands.join(', ')}");
                              print("  Brand IDs: $selectedBrandIds");
                              print(
                                  "  Price: ₹${priceRange.start.toInt()} - ₹${priceRange.end.toInt()}");

                              await _applyFiltersAndSortDebounced();

                              if (_hasActiveFilters) {
                                getSnackBar(
                                    "Filtered by ${selectedBrands.length} brand(s), ₹${priceRange.start.toInt()}–₹${priceRange.end.toInt()}");
                              } else {
                                getSnackBar("Filters cleared");
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
    final RxString selectedOption = _appliedSortOption.obs;

    final Map<String, String> sortOptions = {
      "recommended": "Recommended",
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

                          setState(() {
                            _appliedSortOption = selected;
                          });

                          print("✅ Sort option selected: $selected");

                          await _applyFiltersAndSortDebounced();

                          getSnackBar(
                              "Sorted by ${sortOptions[selected] ?? 'Recommended'}");
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

/// ✅ Skeleton Product Tile with Shimmer Effect
class _SkeletonProductTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          AspectRatio(
            aspectRatio: 0.88,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          SizedBox(height: 8.sp),

          // Brand name skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            child: Container(
              width: double.infinity,
              height: 16.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          SizedBox(height: 6.sp),

          // Description skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            child: Container(
              width: double.infinity * 0.8,
              height: 14.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          SizedBox(height: 6.sp),

          // Price skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            child: Row(
              children: [
                Container(
                  width: 60.sp,
                  height: 14.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 8.sp),
                Container(
                  width: 50.sp,
                  height: 16.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Product Tile with Skeleton Placeholder
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
          aspectRatio: 0.88,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      dummyWishlistImage,
                      fit: BoxFit.cover,
                    ),
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
