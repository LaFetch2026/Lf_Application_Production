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
  String _appliedMinPrice = "300";
  String _appliedMaxPrice = "100000";
  String _appliedSortOption = "recommended";
  int? _appliedSuperCatId;
  int? _appliedCatId;
  int? _appliedSubCatId;
  int? _appliedCollectionId;
  bool _hasActiveFilters = false;
  bool _isCategoriesLoaded = false;
  List<Map<String, dynamic>> _collections = [];

  // ✅ Store original category product IDs for client-side filtering
  Set<int> _originalCategoryProductIds = {};

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
  // This hash includes the ORDER of product IDs, so sorting will be detected
  String _generateProductHash(List<dynamic> products) {
    if (products.isEmpty) return 'empty';
    // Include just IDs in order - this way sorting changes will be detected
    return products.map((p) => p['id'].toString()).join('|');
  }

  // ✅ Generate hash for current filter state
  String _generateFilterHash() {
    return '${_appliedBrandIds.join(',')}_${_appliedMinPrice}_${_appliedMaxPrice}_${_appliedSuperCatId}_${_appliedCatId}_${_appliedSubCatId}_${_appliedCollectionId}_$_hasActiveFilters';
  }

  // ✅ Generate hash for current sort state
  String _generateSortHash() {
    return _appliedSortOption;
  }

  // ✅ Check if products list has actually changed
  bool _hasProductsChanged(
      List<dynamic> previousProducts, List<dynamic> newProducts) {
    final previousHash = _generateProductHash(previousProducts);
    final newHash = _generateProductHash(newProducts);

    // 🔍 Debug: Show detailed comparison
    print("🔍 Hash Comparison:");
    final prevHashPreview = previousHash.length > 50
        ? previousHash.substring(0, 50) + "..."
        : previousHash;
    final newHashPreview =
        newHash.length > 50 ? newHash.substring(0, 50) + "..." : newHash;
    print(
        "   Previous: ${previousProducts.length} products, hash: $prevHashPreview");
    print("   New: ${newProducts.length} products, hash: $newHashPreview");

    // Show first product from each list for comparison
    if (previousProducts.isNotEmpty && newProducts.isNotEmpty) {
      final prevFirst = previousProducts.first;
      final newFirst = newProducts.first;
      print(
          "   Previous first: ID=${prevFirst['id']}, Price=${prevFirst['basePrice'] ?? prevFirst['displayPrice']}");
      print(
          "   New first: ID=${newFirst['id']}, Price=${newFirst['basePrice'] ?? newFirst['displayPrice']}");
    }

    if (previousHash != newHash) {
      print("🔄 Products CHANGED - applying update");
      return true;
    }

    print(
        "⚠️ Products UNCHANGED - hash match (this might indicate backend not sorting/filtering)");
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

  // ✅ Smart collections loader - only loads once
  Future<void> _loadCollectionsIfNeeded() async {
    if (_isCategoriesLoaded) {
      print("✅ Collections already loaded - skipping");
      return;
    }

    // Extract collections from home product list
    // Use collectionID from products if available, otherwise use collection id
    _collections = productController.homeProductList
        .whereType<Map<String, dynamic>>()
        .map((c) {
      // Check if collection has products with collectionID
      final products = c['products'] as List?;
      final firstProduct =
          products?.isNotEmpty == true ? products!.first : null;
      final collectionId = firstProduct != null && firstProduct is Map
          ? (firstProduct['collectionID'] ?? c['id'])
          : c['id'];

      return {
        'id': collectionId,
        'name': c['name'] ?? 'Unknown',
      };
    }).toList();

    _isCategoriesLoaded = true;
    print("✅ Collections loaded: ${_collections.length}");
    for (final col in _collections) {
      print("   - ID: ${col['id']}, Name: ${col['name']}");
    }
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

    // ✅ Store original product IDs for client-side filtering
    _originalCategoryProductIds = catalogController.categoryProductList
        .map((p) => int.tryParse(p['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    // Generate initial hash
    _lastProductListHash = _generateProductHash(
      catalogController.categoryProductList,
    );
    _lastFilterHash = _generateFilterHash();
    _lastSortHash = _generateSortHash();

    _isCategoryProductsLoaded = true;
    print(
        "✅ Category products loaded successfully (${catalogController.categoryProductList.length} items)");
    print(
        "✅ Stored ${_originalCategoryProductIds.length} product IDs for filtering");
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

      // Load collections after initial load (requires homeProductList)
      await _loadCollectionsIfNeeded();

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

      // ✅ Determine the action based on filters and sort state
      // Case 1: Has filters → Call API (with or without sort)
      // Case 2: Only sort (no filters) → Client-side sort
      // Case 3: Neither filters nor sort → Show original

      if (_hasActiveFilters && filterChanged) {
        // 📞 Case 1: Filters changed → Call /filter-products API
        print("🔹 Case 1: Filter changed (has active filters)");
        print("   • Current _appliedSortOption → $_appliedSortOption");
        print(
            "   • brand IDs    → ${_appliedBrandIds.isNotEmpty ? _appliedBrandIds : 'all brands'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print("   • superCatId   → $_appliedSuperCatId");
        print("   • catId        → $_appliedCatId");
        print("   • subCatId     → $_appliedSubCatId");
        print("   • collectionId → $_appliedCollectionId");
        print("   • sortChanged  → $sortChanged");
        print(
            "   • Passing sortOption → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          // Only pass actual filter values (not defaults)
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          superCatId: _appliedSuperCatId,
          catId: _appliedCatId,
          subCatId: _appliedSubCatId,
          collectionId: _appliedCollectionId,
          sortOption:
              _appliedSortOption != "recommended" ? _appliedSortOption : null,
        );

        // ✅ Client-side filter: Only keep products from this category
        var apiResults =
            List<dynamic>.from(catalogController.categoryProductList);

        // Filter by collectionId if specified (backend may ignore this)
        if (_appliedCollectionId != null) {
          apiResults = apiResults.where((product) {
            final productCollectionId =
                int.tryParse(product['collectionID']?.toString() ?? '');
            return productCollectionId == _appliedCollectionId;
          }).toList();
          print(
              "🔍 Filtered ${catalogController.categoryProductList.length} products to ${apiResults.length} with collectionID=$_appliedCollectionId");
        }

        final filteredResults = apiResults.where((product) {
          final productId = int.tryParse(product['id']?.toString() ?? '');
          return productId != null &&
              _originalCategoryProductIds.contains(productId);
        }).toList();

        print(
            "🔍 API returned ${catalogController.categoryProductList.length} products, filtered to ${filteredResults.length} from this category");

        catalogController.categoryProductList.assignAll(filteredResults);

        _lastFilterHash = currentFilterHash;
        if (sortChanged) _lastSortHash = currentSortHash;

        print(
            "✅ Filter applied - ${catalogController.categoryProductList.length} products");
      } else if (!_hasActiveFilters &&
          _appliedSortOption != "recommended" &&
          sortChanged) {
        // 🔧 Case 2: ONLY sort changed (no filters) → Client-side sort
        print(
            "🔧 Client-side sorting: $_appliedSortOption (no filters, so not calling API)");

        // Load original products if needed
        if (!_isCategoryProductsLoaded) {
          await catalogController.getCategoryProductData(
            widget.categoryId,
            widget.genderType,
          );
          _isCategoryProductsLoaded = true;
        }

        // Sort the current products client-side
        final productsToSort =
            List<dynamic>.from(catalogController.categoryProductList);

        productsToSort.sort((a, b) {
          final priceA = (a['basePrice'] ?? a['displayPrice'] ?? 0) as num;
          final priceB = (b['basePrice'] ?? b['displayPrice'] ?? 0) as num;

          if (_appliedSortOption == 'price_asc') {
            return priceA.compareTo(priceB);
          } else if (_appliedSortOption == 'price_desc') {
            return priceB.compareTo(priceA);
          } else if (_appliedSortOption == 'newest') {
            final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idB.compareTo(idA);
          }
          return 0;
        });

        catalogController.categoryProductList.assignAll(productsToSort);
        _lastSortHash = currentSortHash;

        print(
            "✅ Client-side sort complete - ${catalogController.categoryProductList.length} products");
        print(
            "   First 3: ${productsToSort.take(3).map((p) => 'ID:${p['id']} Price:₹${p['basePrice'] ?? p['displayPrice']}').join(', ')}");
      } else if (_hasActiveFilters && sortChanged) {
        // 🔧 Case 3: Filters already applied, but sort changed → Re-apply filters with new sort
        print("🔹 Case 3: Sort changed (filters already applied)");
        print("   • New _appliedSortOption → $_appliedSortOption");
        print(
            "   • brand IDs    → ${_appliedBrandIds.isNotEmpty ? _appliedBrandIds : 'all brands'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print("   • superCatId   → $_appliedSuperCatId");
        print("   • catId        → $_appliedCatId");
        print("   • subCatId     → $_appliedSubCatId");
        print("   • collectionId → $_appliedCollectionId");
        print(
            "   • Passing sortOption → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          superCatId: _appliedSuperCatId,
          catId: _appliedCatId,
          subCatId: _appliedSubCatId,
          collectionId: _appliedCollectionId,
          sortOption:
              _appliedSortOption != "recommended" ? _appliedSortOption : null,
        );

        var apiResults =
            List<dynamic>.from(catalogController.categoryProductList);

        // Filter by collectionId if specified (backend may ignore this)
        if (_appliedCollectionId != null) {
          apiResults = apiResults.where((product) {
            final productCollectionId =
                int.tryParse(product['collectionID']?.toString() ?? '');
            return productCollectionId == _appliedCollectionId;
          }).toList();
        }

        final filteredResults = apiResults.where((product) {
          final productId = int.tryParse(product['id']?.toString() ?? '');
          return productId != null &&
              _originalCategoryProductIds.contains(productId);
        }).toList();

        catalogController.categoryProductList.assignAll(filteredResults);
        _lastSortHash = currentSortHash;

        print(
            "✅ Filters re-applied with new sort - ${catalogController.categoryProductList.length} products");
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
      } else if (_appliedSortOption == "recommended" && sortChanged) {
        // Sort reset to recommended - reload original products if no filters
        if (!_hasActiveFilters) {
          if (!_isCategoryProductsLoaded) {
            await catalogController.getCategoryProductData(
              widget.categoryId,
              widget.genderType,
            );
            _isCategoryProductsLoaded = true;
          }
        }
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

              Get.to(CartScreen())?.then((_) async {
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
                fontFamily: "Clash Display Regular",
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

  /// ✅ Helper: Build Category Dropdown
  Widget _buildCategoryDropdown(
    String title,
    int? selectedValue,
    List<Map<String, dynamic>> options,
    Function(int?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select $title",
          style: const TextStyle(
            fontFamily: "Clash Display",
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) {
          final id = option['id'] as int;
          final name = option['name'] as String;
          return RadioListTile<int>(
            value: id,
            groupValue: selectedValue,
            activeColor: appBarColor,
            title: Text(
              name,
              style: const TextStyle(
                fontFamily: "Clash Display Regular",
                color: blackColor,
              ),
            ),
            onChanged: onChanged,
          );
        }),
        if (selectedValue != null)
          TextButton(
            onPressed: () => onChanged(null),
            child: const Text(
              "Clear Selection",
              style: TextStyle(
                color: appBarColor,
                fontFamily: "Clash Display",
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

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
                    fontFamily: "Clash Display",
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
      double.parse(_appliedMinPrice).clamp(100.0, 50000.0),
      double.parse(_appliedMaxPrice).clamp(100.0, 50000.0),
    );

    // Category filter selections
    int? selectedSuperCatId = _appliedSuperCatId;
    int? selectedCatId = _appliedCatId;
    int? selectedSubCatId = _appliedSubCatId;
    int? selectedCollectionId = _appliedCollectionId;

    final List<String> filterCategories = [
      "Brand",
      "Price Range",
      "Super Category",
      "Category",
      "Sub Category",
      "Collection"
    ];

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
                                  fontFamily: "Clash Display Semibold",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: blackColor)),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedBrands.clear();
                                priceRange = const RangeValues(300, 100000);
                                selectedSuperCatId = null;
                                selectedCatId = null;
                                selectedSubCatId = null;
                                selectedCollectionId = null;
                              });
                            },
                            child: const Text("CLEAR ALL",
                                style: TextStyle(
                                    color: appBarColor,
                                    fontSize: 13,
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, color: dividerColor),
                    Expanded(
                      child: Row(children: [
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
                                              ? "Clash Display Semibold"
                                              : "Clash Display Regular",
                                          fontWeight: selected
                                              ? FontWeight.w600
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
                                                    "Clash Display Regular",
                                                fontWeight: FontWeight.w400,
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
                                : selectedFilter == "Price Range"
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Select price range",
                                              style: TextStyle(
                                                  fontFamily:
                                                      "Clash Display Semibold",
                                                  fontWeight: FontWeight.w600,
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
                                              Text(
                                                  "₹${priceRange.start.toInt()}",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          "Clash Display Regular",
                                                      color: Colors.grey)),
                                              Text("₹${priceRange.end.toInt()}",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          "Clash Display Regular",
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      )
                                    : selectedFilter == "Super Category"
                                        ? _buildCategoryDropdown(
                                            "Super Category",
                                            selectedSuperCatId,
                                            [
                                              {'id': 1, 'name': 'Men'},
                                              {'id': 2, 'name': 'Women'},
                                              {'id': 3, 'name': 'Accessories'},
                                            ],
                                            (val) => setModalState(() {
                                              selectedSuperCatId = val;
                                            }),
                                          )
                                        : selectedFilter == "Category"
                                            ? _buildCategoryDropdown(
                                                "Category",
                                                selectedCatId,
                                                [
                                                  {'id': 1, 'name': 'Topwear'},
                                                  {
                                                    'id': 2,
                                                    'name': 'Bottomwear'
                                                  },
                                                  {'id': 3, 'name': 'Footwear'},
                                                  {'id': 4, 'name': 'Bags'},
                                                  {
                                                    'id': 5,
                                                    'name': 'Accessories'
                                                  },
                                                  {
                                                    'id': 6,
                                                    'name': 'Innerwear'
                                                  },
                                                ],
                                                (val) => setModalState(() {
                                                  selectedCatId = val;
                                                }),
                                              )
                                            : selectedFilter == "Sub Category"
                                                ? _buildCategoryDropdown(
                                                    "Sub Category",
                                                    selectedSubCatId,
                                                    [
                                                      {
                                                        'id': 1,
                                                        'name': 'T-Shirts'
                                                      },
                                                      {
                                                        'id': 2,
                                                        'name': 'Shirts'
                                                      },
                                                      {
                                                        'id': 3,
                                                        'name': 'Jeans'
                                                      },
                                                      {
                                                        'id': 4,
                                                        'name': 'Trousers'
                                                      },
                                                      {
                                                        'id': 5,
                                                        'name': 'Casual Shoes'
                                                      },
                                                      {
                                                        'id': 6,
                                                        'name': 'Formal Shoes'
                                                      },
                                                    ],
                                                    (val) => setModalState(() {
                                                      selectedSubCatId = val;
                                                    }),
                                                  )
                                                : selectedFilter == "Collection"
                                                    ? _collections.isEmpty
                                                        ? const Center(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          20.0),
                                                              child: Text(
                                                                "No collections available",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Clash Display Regular",
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : _buildCategoryDropdown(
                                                            "Collection",
                                                            selectedCollectionId,
                                                            _collections,
                                                            (val) =>
                                                                setModalState(
                                                                    () {
                                                              selectedCollectionId =
                                                                  val;
                                                            }),
                                                          )
                                                    : const SizedBox(),
                          ),
                        ),
                      ]),
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
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
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
                                _appliedSuperCatId = selectedSuperCatId;
                                _appliedCatId = selectedCatId;
                                _appliedSubCatId = selectedSubCatId;
                                _appliedCollectionId = selectedCollectionId;
                                _hasActiveFilters =
                                    selectedBrandIds.isNotEmpty ||
                                        priceRange.start > 300 ||
                                        priceRange.end < 100000 ||
                                        _appliedSuperCatId != null ||
                                        _appliedCatId != null ||
                                        _appliedSubCatId != null ||
                                        _appliedCollectionId != null;
                              });

                              print("✅ Filters configured:");
                              print("  Brands: ${selectedBrands.join(', ')}");
                              print("  Brand IDs: $selectedBrandIds");
                              print(
                                  "  Price: ₹${priceRange.start.toInt()} - ₹${priceRange.end.toInt()}");

                              await _applyFiltersAndSortDebounced();

                              if (_hasActiveFilters) {
                                final filterParts = <String>[];
                                if (selectedBrandIds.isNotEmpty) {
                                  filterParts
                                      .add("${selectedBrands.length} brand(s)");
                                }
                                if (priceRange.start > 300 ||
                                    priceRange.end < 100000) {
                                  filterParts.add(
                                      "₹${priceRange.start.toInt()}–₹${priceRange.end.toInt()}");
                                }
                                if (selectedSuperCatId != null) {
                                  filterParts.add("Super Category");
                                }
                                if (selectedCatId != null) {
                                  filterParts.add("Category");
                                }
                                if (selectedSubCatId != null) {
                                  filterParts.add("Sub Category");
                                }
                                if (selectedCollectionId != null) {
                                  filterParts.add("Collection");
                                }
                                getSnackBar(
                                    "Filtered by ${filterParts.join(', ')}");
                              } else {
                                getSnackBar("Filters cleared");
                              }
                            },
                            child: const Text("APPLY",
                                style: TextStyle(
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
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
                        fontFamily: "Clash Display Semibold",
                        fontWeight: FontWeight.w600,
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
                                fontFamily: "Clash Display Regular",
                                fontWeight: FontWeight.w400,
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
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w500,
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
                                fontFamily: "Clash Display",
                                fontWeight: FontWeight.w500,
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
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500)),
                if ((subtitle ?? '').isNotEmpty)
                  Padding(
                      padding: EdgeInsets.only(top: 1.sp),
                      child: Text(subtitle!,
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
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

/// ✅ Product Tile with Clash Display Font
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

  int _discountPercent(num? mrp, num? price) {
    if (mrp == null || price == null || mrp <= 0 || price >= mrp) return 0;
    return (((mrp - price) / mrp) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final discount = _discountPercent(mrp, price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// IMAGE (takes fixed portion)
        AspectRatio(
          aspectRatio: 0.80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Image.asset(dummyWishlistImage, fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 6),

        /// BRAND
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.sp),
          child: Text(
            brand.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: "Clash Display Semibold",
            ),
          ),
        ),

        /// DESCRIPTION
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
          child: Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        /// PRICE ROW
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.sp),
          child: Row(
            children: [
              if (price != null)
                Text(
                  fmt(price, cents: true),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Clash Display Semibold",
                  ),
                ),
              if (mrp != null && price != null && mrp! > price!)
                Padding(
                  padding: EdgeInsets.only(left: 6.sp),
                  child: Text(
                    fmt(mrp, cents: true),
                    style: const TextStyle(
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: Color(0xFF9CA3AF),
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
