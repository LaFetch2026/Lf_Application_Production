// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/pdp_v2/product_details_screen_v2.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/widget/appbar/productlist_appbar.dart';
import '../../common/widget/cards/product_card.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/other/chip_shimmer_row.dart';
import '../../common/widget/other/filter_chips_row.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/brand_controller.dart';
import '../../core/constant/constants.dart';
import '../../models/nudge_model.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  final int brandId;
  final int genderType;
  final List collectionIds;
  final List categoryList;
  final String genderName;
  final String screen;
  final String type;
  final String? segment; // ✅ NEW: segment parameter for LUXE filter

  const CategoryProductScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.brandId,
    required this.genderType,
    required this.collectionIds,
    required this.genderName,
    this.type = "category products",
    this.screen = "",
    required this.categoryList,
    required String title,
    this.segment, // ✅ NEW: segment parameter
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
  bool _isFilterMetadataLoaded = false;
  bool _isCategoryProductsLoaded = false;

  // ✅ Initial loading state
  bool _isInitialLoading = true;

  // ✅ Hash tracking for change detection
  String? _lastFilterHash;
  String? _lastSortHash;

  // ✅ Debounce timer
  Timer? _debounceTimer;

  // ✅ Current filter/sort state
  List<int> _appliedBrandIds = [];
  List<String> _appliedColors = [];
  List<String> _appliedSizes = [];
  String _appliedMinPrice = "300";
  String _appliedMaxPrice = "100000";
  int _appliedMinDiscount = 0;
  int _appliedMaxDiscount = 100;
  String _appliedSortOption = "recommended";
  bool _hasActiveFilters = false;

  // ✅ Pagination state
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  // ✅ Store original category product IDs for client-side filtering
  Set<int> _originalCategoryProductIds = {};

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
      "category",
      "minDiscount",
      "maxDiscount",
    ]) {
      await prefs.remove(k);
    }
  }

  // ✅ Generate hash for current filter state
  String _generateFilterHash() {
    return '${_appliedBrandIds.join(',')}_${_appliedColors.join(',')}_${_appliedSizes.join(',')}_${_appliedMinPrice}_${_appliedMaxPrice}_${_appliedMinDiscount}_${_appliedMaxDiscount}_$_hasActiveFilters';
  }

  // ✅ Generate hash for current sort state
  String _generateSortHash() {
    return _appliedSortOption;
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

  // ✅ Smart filter metadata loader - only loads once
  Future<void> _loadFilterMetadataIfNeeded() async {
    if (_isFilterMetadataLoaded) {
      print("✅ Filter metadata already loaded - skipping");
      return;
    }

    // Extract collectionId if available
    final collectionId = widget.collectionIds.isNotEmpty
        ? (widget.collectionIds.first is int
            ? widget.collectionIds.first
            : int.tryParse(widget.collectionIds.first?.toString() ?? ''))
        : null;

    await productController.getFilterMetadata(
      superCatId: widget.genderType,
      catId: widget.categoryId > 0 ? widget.categoryId : null,
      subCatId: null,
      collectionId:
          collectionId != null && collectionId > 0 ? collectionId : null,
      brandId: widget.brandId > 0 ? widget.brandId : null,
    );
    _isFilterMetadataLoaded = true;
    print("✅ Filter metadata loaded successfully");
  }

  // ✅ Smart category products loader - only loads once initially
  Future<void> _loadCategoryProductsIfNeeded() async {
    if (_isCategoryProductsLoaded) {
      print("✅ Category products already loaded - skipping");
      return;
    }

    // ✅ NEW: Check if categoryProductList already has data (loaded via getSubCategoryProducts)
    if (catalogController.categoryProductList.isNotEmpty) {
      print(
          "✅ Products already loaded via sub-category API (${catalogController.categoryProductList.length} items) - skipping reload");

      // ✅ Store original product IDs for client-side filtering
      _originalCategoryProductIds = catalogController.categoryProductList
          .map((p) => int.tryParse(p['id']?.toString() ?? ''))
          .whereType<int>()
          .toSet();

      // Generate initial hash
      _lastFilterHash = _generateFilterHash();
      _lastSortHash = _generateSortHash();

      _isCategoryProductsLoaded = true;
      print(
          "✅ Stored ${_originalCategoryProductIds.length} product IDs for filtering");

      // Fetch chips separately since products were loaded via a different endpoint
      final collectionId = widget.collectionIds.isNotEmpty
          ? (widget.collectionIds.first is int
              ? widget.collectionIds.first as int
              : int.tryParse(widget.collectionIds.first?.toString() ?? ''))
          : null;
      catalogController.fetchChipsForCategory(
        catId: widget.categoryId > 0 ? widget.categoryId : null,
        superCatId: widget.genderType > 0 ? widget.genderType : null,
        collectionId:
            collectionId != null && collectionId > 0 ? collectionId : null,
        segment: widget.segment,
      );
      return;
    }

    // ✅ Check if we should load by collection/tag ID instead of category ID
    final hascollectionIds = widget.collectionIds.isNotEmpty;
    final hasCategoryId = widget.categoryId > 0;

    if (hascollectionIds) {
      // Load products by collection/tag ID
      print(
          "🔹 Loading products by collection/tag ID: ${widget.collectionIds}");
      final collectionId = widget.collectionIds.first is int
          ? widget.collectionIds.first
          : int.tryParse(widget.collectionIds.first?.toString() ?? '') ?? 0;

      await catalogController.getFilterAndSortProducts(
        collectionId: collectionId,
        superCatId: widget.genderType,
      );

      // getFilterAndSortProducts parses chips, but also call explicitly
      // in case the response format differs for collection queries
      if (catalogController.chips.isEmpty) {
        catalogController.fetchChipsForCategory(
          collectionId: collectionId > 0 ? collectionId : null,
          superCatId: widget.genderType > 0 ? widget.genderType : null,
          segment: widget.segment,
        );
      }
    } else if (hasCategoryId) {
      // Load products by category ID using filter-products so chips are returned
      print("🔹 Loading products by category ID: ${widget.categoryId}");
      await catalogController.getFilterAndSortProducts(
        catId: widget.categoryId,
        superCatId: widget.genderType,
        page: 1,
        limit: 20,
      );
    } else {
      // No valid ID provided
      print("⚠️ No valid categoryId or collectionIds provided");
      catalogController.categoryProductList.clear();
      _isCategoryProductsLoaded = true;
      return;
    }

    // ✅ Store original product IDs for client-side filtering
    _originalCategoryProductIds = catalogController.categoryProductList
        .map((p) => int.tryParse(p['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    // Generate initial hash
    _lastFilterHash = _generateFilterHash();
    _lastSortHash = _generateSortHash();

    _isCategoryProductsLoaded = true;
    print(
        "✅ Products loaded successfully (${catalogController.categoryProductList.length} items)");
    print(
        "✅ Stored ${_originalCategoryProductIds.length} product IDs for filtering");
  }

  // ✅ Initial load - happens before screen is visible
  Future<void> _performInitialLoad() async {
    try {
      print("🔄 Starting initial load...");

      // ✅ Check if this is a LUXE view (by type or segment parameter)
      final isLuxeView = widget.type == 'luxe' || widget.segment == 'luxury';

      if (isLuxeView) {
        // For LUXE view, fetch luxury products scoped to the collection if provided
        final collectionId = widget.collectionIds.isNotEmpty
            ? int.tryParse(widget.collectionIds.first?.toString() ?? '') ?? 0
            : 0;

        print("🎯 Loading LUXE products for collectionId=$collectionId, gender=${widget.genderType}...");

        if (collectionId > 0) {
          // ✅ Fetch LUXE products scoped to this specific collection AND gender
          final luxeProducts = await productController
              .fetchCollectionLuxeProducts(
                collectionId,
                limit: 100,
                gender: widget.genderType, // ✅ Pass gender to filter by gender
              );
          productController.allLuxeList.assignAll(luxeProducts);
        } else {
          // No collection — fetch all luxury products globally
          await productController.fetchAllLuxeProducts();
        }

        // If API returns nothing, try client-side filtering from collections
        if (productController.allLuxeList.isEmpty) {
          print(
              "⚠️ No LUXE products from API, trying client-side filtering...");

          List<dynamic> allCollectionProducts = [];
          for (final collection in productController.homeProductList) {
            allCollectionProducts
                .addAll(collection.products.map((p) => p.toJson()).toList());
          }

          if (allCollectionProducts.isNotEmpty) {
            final filteredLuxe = productController
                .filterLuxeProductsFromCollection(allCollectionProducts);
            productController.allLuxeList.assignAll(filteredLuxe);
            print(
                "✅ Loaded ${productController.allLuxeList.length} LUXE products from collections");
          }
        }

        // Populate category product list with LUXE products
        catalogController.categoryProductList.assignAll(
          productController.allLuxeList,
        );

        print(
            "✅ LUXE products loaded: ${productController.allLuxeList.length}");
      } else {
        // Load all data in parallel for faster loading
        await Future.wait([
          _loadWishlistIfNeeded(),
          _loadCartIfNeeded(),
          _clearPref(),
          _loadFilterMetadataIfNeeded(),
          _loadCategoryProductsIfNeeded(),
        ]);
      }

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

  // ✅ Load more products (pagination)
  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData || !_hasActiveFilters) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      await catalogController.getFilterAndSortProducts(
        brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
        colors: _appliedColors.isNotEmpty ? _appliedColors : null,
        sizes: _appliedSizes.isNotEmpty ? _appliedSizes : null,
        minPrice: _appliedMinPrice,
        maxPrice: _appliedMaxPrice,
        minDiscount: (_appliedMinDiscount == 0 && _appliedMaxDiscount == 100)
            ? null
            : _appliedMinDiscount.toString(),
        maxDiscount: (_appliedMinDiscount == 0 && _appliedMaxDiscount == 100)
            ? null
            : _appliedMaxDiscount.toString(),
        sortOption:
            _appliedSortOption != "recommended" ? _appliedSortOption : null,
        catId: widget.categoryId,
        superCatId: widget.genderType,
        page: _currentPage,
        limit: 20,
        appendResults: true, // ✅ Append instead of replace
      );

      // Client-side filter
      var apiResults =
          List<dynamic>.from(catalogController.categoryProductList);
      final filteredResults = apiResults.where((product) {
        final productId = int.tryParse(product['id']?.toString() ?? '');
        return productId != null &&
            _originalCategoryProductIds.contains(productId);
      }).toList();

      catalogController.categoryProductList.assignAll(filteredResults);

      // Check if we got less than 20 products (means no more data)
      if (apiResults.length < 20) {
        setState(() {
          _hasMoreData = false;
        });
      }

      print("✅ Loaded page $_currentPage (${filteredResults.length} products)");
    } catch (e) {
      print("❌ Error loading more products: $e");
      setState(() {
        _currentPage--; // Rollback page number on error
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
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

      // ✅ Reset pagination when filters change
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
      });

      catalogController.isCategory.value = true;

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
        print(
            "   • colors       → ${_appliedColors.isNotEmpty ? _appliedColors : 'all colors'}");
        print(
            "   • sizes        → ${_appliedSizes.isNotEmpty ? _appliedSizes : 'all sizes'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print(
            "   • discount range → $_appliedMinDiscount% - $_appliedMaxDiscount%");
        print("   • sortChanged  → $sortChanged");
        print(
            "   • Passing sortOption → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          // Only pass actual filter values (not defaults)
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          colors: _appliedColors.isNotEmpty ? _appliedColors : null,
          sizes: _appliedSizes.isNotEmpty ? _appliedSizes : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          minDiscount: (_appliedMinDiscount == 0 && _appliedMaxDiscount == 100)
              ? null
              : _appliedMinDiscount.toString(),
          maxDiscount: (_appliedMinDiscount == 0 && _appliedMaxDiscount == 100)
              ? null
              : _appliedMaxDiscount.toString(),
          sortOption:
              _appliedSortOption != "recommended" ? _appliedSortOption : null,
          catId: widget
              .categoryId, // ✅ Pass category ID to filter by this category
          superCatId: widget.genderType, // ✅ Pass gender type
          page: 1, // ✅ Reset to page 1
          limit: 20, // ✅ Load 20 items per page
        );

        // ✅ Client-side filter: Only keep products from this category
        var apiResults =
            List<dynamic>.from(catalogController.categoryProductList);

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
          final hascollectionIds = widget.collectionIds.isNotEmpty;
          final hasCategoryId = widget.categoryId > 0;

          if (hascollectionIds) {
            final collectionId = widget.collectionIds.first is int
                ? widget.collectionIds.first
                : int.tryParse(widget.collectionIds.first?.toString() ?? '') ??
                    0;

            await catalogController.getFilterAndSortProducts(
              collectionId: collectionId,
              superCatId: widget.genderType,
            );
          } else if (hasCategoryId) {
            await catalogController.getFilterAndSortProducts(
              catId: widget.categoryId,
              superCatId: widget.genderType,
              page: 1,
              limit: 20,
            );
          }
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
        print(
            "   • colors       → ${_appliedColors.isNotEmpty ? _appliedColors : 'all colors'}");
        print(
            "   • sizes        → ${_appliedSizes.isNotEmpty ? _appliedSizes : 'all sizes'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print(
            "   • discount range → $_appliedMinDiscount% - $_appliedMaxDiscount%");
        print(
            "   • Passing sortOption → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          colors: _appliedColors.isNotEmpty ? _appliedColors : null,
          sizes: _appliedSizes.isNotEmpty ? _appliedSizes : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          minDiscount: (_appliedMinDiscount == 0 && _appliedMaxDiscount == 100)
              ? null
              : _appliedMinDiscount.toString(),
          maxDiscount: (_appliedMinDiscount == 0 && _appliedMaxDiscount == 100)
              ? null
              : _appliedMaxDiscount.toString(),
          sortOption:
              _appliedSortOption != "recommended" ? _appliedSortOption : null,
          catId: widget
              .categoryId, // ✅ Pass category ID to filter by this category
          superCatId: widget.genderType, // ✅ Pass gender type
          page: 1, // ✅ Reset to first page
          limit: 20, // ✅ Fetch 20 items per page
        );

        var apiResults =
            List<dynamic>.from(catalogController.categoryProductList);

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
        print("🔹 Filters cleared - reloading original products");

        final hascollectionIds = widget.collectionIds.isNotEmpty;
        final hasCategoryId = widget.categoryId > 0;

        if (hascollectionIds) {
          final collectionId = widget.collectionIds.first is int
              ? widget.collectionIds.first
              : int.tryParse(widget.collectionIds.first?.toString() ?? '') ?? 0;

          await catalogController.getFilterAndSortProducts(
            collectionId: collectionId,
            superCatId: widget.genderType,
          );
        } else if (hasCategoryId) {
          await catalogController.getFilterAndSortProducts(
            catId: widget.categoryId,
            superCatId: widget.genderType,
            page: 1,
            limit: 20,
          );
        }
        _lastFilterHash = currentFilterHash;
      } else if (_appliedSortOption == "recommended" && sortChanged) {
        // Sort reset to recommended - reload original products if no filters
        if (!_hasActiveFilters) {
          print("🔹 Sort reset to recommended - reloading original products");

          final hascollectionIds = widget.collectionIds.isNotEmpty;
          final hasCategoryId = widget.categoryId > 0;

          if (hascollectionIds) {
            final collectionId = widget.collectionIds.first is int
                ? widget.collectionIds.first
                : int.tryParse(widget.collectionIds.first?.toString() ?? '') ??
                    0;

            await catalogController.getFilterAndSortProducts(
              collectionId: collectionId,
              superCatId: widget.genderType,
            );
          } else if (hasCategoryId) {
            await catalogController.getFilterAndSortProducts(
              catId: widget.categoryId,
              superCatId: widget.genderType,
              page: 1,
              limit: 20,
            );
          }
        }
        _lastSortHash = currentSortHash;
      }
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
      // ✅ Determine if this is a LUXE view
      final isLuxeView = widget.type == 'luxe' || widget.segment == 'luxury';

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: isLuxeView ? const Color(0xFF000000) : statusBarColor,
        statusBarIconBrightness:
            isLuxeView ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: statusBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    catalogController.clearChipSelection();

    // ✅ Restore default status bar colors when navigating away
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: statusBarColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Determine background color based on LUXE type or segment parameter
    final isLuxeView = widget.type == 'luxe' || widget.segment == 'luxury';
    final backgroundColor = isLuxeView ? const Color(0xFF000000) : whiteColor;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductAppbar(
            text: widget.categoryName.toUpperCase(),
            isCart: widget.type != "coupon" && widget.type != "express",
            isHandPicked: widget.screen.isNotEmpty,
            backColor: backgroundColor,
            onPressedSearch: () async {
              Get.off(() => const SearchScreen());
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

          // Category Title and Description for LUXE
          if (isLuxeView)
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'LUXE',
            //         style: TextStyle(
            //           fontSize: 20.sp,
            //           fontWeight: FontWeight.bold,
            //           fontFamily: 'Clash Display',
            //           color: Colors.white,
            //           decoration: TextDecoration.underline,
            //           decorationColor: const Color(0xFF9C27B0),
            //           decorationThickness: 2.0,
            //         ),
            //       ),
            //       SizedBox(height: 8.h),
            //       Text(
            //         'Discover our most exclusive luxury collection',
            //         style: TextStyle(
            //           fontSize: 13.sp,
            //           color: Colors.white70,
            //           fontWeight: FontWeight.w400,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Filter Chips Row
            // Uses a StatefulBuilder so both setState (filter pills) and
            // GetX reactive (chips/activeChipId) changes trigger a rebuild.
            _FilterChipsSection(
              catalogController: catalogController,
              buildPills: _buildActiveFilterPills,
            ),

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

                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        // ✅ Detect when user scrolls near bottom (160px before end)
                        if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 160) {
                          if (_hasActiveFilters &&
                              _hasMoreData &&
                              !_isLoadingMore) {
                            _loadMoreProducts();
                          }
                        }
                        return false;
                      },
                      child: MasonryGridView.count(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
                        itemCount: items.length +
                            (_isLoadingMore
                                ? 2
                                : 0), // ✅ Add 2 for loading indicators
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.sp,
                        crossAxisSpacing: 10.sp,
                        itemBuilder: (context, index) {
                          // ✅ Show loading indicator at the end
                          if (index >= items.length) {
                            return _SkeletonProductTile();
                          }
                          final m = normalizeProduct(items[index]);

                          final brand =
                              (m['brandName'] ?? '').toString().trim();
                          final title = (m['title'] ?? '').toString().trim();
                          final shortDesc = (m['shortDescription'] ?? title)
                              .toString()
                              .trim();
                          final img = _imageFrom(m);

                          num? price = _parseNum(m['displayPrice']);
                          num? mrp = _parseNum(m['displayMrp']);

                          final int pid =
                              int.tryParse(m['id']?.toString() ?? '') ?? 0;

                          return ProductGridCard(
                            imageUrl: img ?? '',
                            title: title.isNotEmpty ? title : shortDesc,
                            brandName: brand.isEmpty ? title : brand,
                            price: price,
                            mrp: mrp,
                            showExpress: widget.type == "express",
                            isLuxe: isLuxeView,
                            nudges: (m['nudges'] as List<dynamic>?)
                                    ?.map((e) => Nudge.fromJson(
                                        e as Map<String, dynamic>))
                                    .toList() ??
                                [],
                            onTap: () async {
                              if (pid == 0) {
                                getSnackBar("Product not available");
                                return;
                              }

                              Get.to(
                                ProductDetailsScreenV2(
                                  brandName: brand.isEmpty ? title : brand,
                                  expressValue:
                                      widget.type == "express" ? 1 : 0,
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
                          );
                        },
                      ), // Close GridView.builder
                    ); // Close NotificationListener
                  }),
          ),

          /// ✅ Bottom bar
          Container(
            color: isLuxeView ? Colors.black : statusBarColor,
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                Container(
                    height: 1.sp,
                    color: isLuxeView ? const Color(0xFF333333) : dividerColor),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _activeBottomButton(
                        icon: sortBySvgImage,
                        label: "SORT BY",
                        isLuxe: isLuxeView,
                        onTap: () async {
                          await _showSortBottomSheet(
                            context,
                            catId: widget.categoryId,
                            brandId: widget.brandId,
                            collectionId: widget.genderType,
                          );
                        },
                      ),
                      _divider(isLuxe: isLuxeView),
                      _activeTextOnlyButton(
                        "CATEGORY",
                        subtitle: widget.genderName.toUpperCase(),
                        isLuxe: isLuxeView,
                        onTap: () {},
                      ),
                      _divider(isLuxe: isLuxeView),
                      _activeBottomButton(
                        icon: filterSvgImage,
                        label: "FILTERS",
                        vector: true,
                        isLuxe: isLuxeView,
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

  /// Builds the list of active filter pills from current filter state.
  List<ActiveFilterPill> _buildActiveFilterPills() {
    final pills = <ActiveFilterPill>[];

    // Brand pills — show brand names (look up from filterBrands metadata)
    for (final id in _appliedBrandIds) {
      final brandData = productController.filterBrands.firstWhereOrNull(
          (item) => int.tryParse(item['id']?.toString() ?? '') == id);
      final name = brandData?['name']?.toString().trim() ?? 'Brand';
      pills.add(ActiveFilterPill(
        label: name,
        onRemove: () => _removeFilter(brandId: id),
      ));
    }

    // Color pills
    for (final color in _appliedColors) {
      pills.add(ActiveFilterPill(
        label: color,
        onRemove: () => _removeFilter(color: color),
      ));
    }

    // Size pills
    for (final size in _appliedSizes) {
      pills.add(ActiveFilterPill(
        label: size,
        onRemove: () => _removeFilter(size: size),
      ));
    }

    // Price pill — only show if non-default
    final minP = int.tryParse(_appliedMinPrice) ?? 300;
    final maxP = int.tryParse(_appliedMaxPrice) ?? 100000;
    if (minP > 300 || maxP < 100000) {
      pills.add(ActiveFilterPill(
        label: '₹$minP–₹$maxP',
        onRemove: () => _removeFilter(resetPrice: true),
      ));
    }

    // Discount pill — only show if non-default
    if (_appliedMinDiscount > 0 || _appliedMaxDiscount < 100) {
      pills.add(ActiveFilterPill(
        label: '$_appliedMinDiscount%–$_appliedMaxDiscount%',
        onRemove: () => _removeFilter(resetDiscount: true),
      ));
    }

    // Sort pill — only show if non-default
    if (_appliedSortOption != 'recommended') {
      final sortLabels = {
        'price_asc': 'Price ↑',
        'price_desc': 'Price ↓',
        'whats_new': "What's New",
        'rating': 'Top Rated',
        'discount': 'Discount',
      };
      pills.add(ActiveFilterPill(
        label: sortLabels[_appliedSortOption] ?? _appliedSortOption,
        onRemove: () => _removeFilter(resetSort: true),
      ));
    }

    return pills;
  }

  /// Removes a single filter and re-applies.
  void _removeFilter({
    int? brandId,
    String? color,
    String? size,
    bool resetPrice = false,
    bool resetDiscount = false,
    bool resetSort = false,
  }) {
    setState(() {
      if (brandId != null) _appliedBrandIds.remove(brandId);
      if (color != null) _appliedColors.remove(color);
      if (size != null) _appliedSizes.remove(size);
      if (resetPrice) {
        _appliedMinPrice = '300';
        _appliedMaxPrice = '100000';
      }
      if (resetDiscount) {
        _appliedMinDiscount = 0;
        _appliedMaxDiscount = 100;
      }
      if (resetSort) _appliedSortOption = 'recommended';

      _hasActiveFilters = _appliedBrandIds.isNotEmpty ||
          _appliedColors.isNotEmpty ||
          _appliedSizes.isNotEmpty ||
          (int.tryParse(_appliedMinPrice) ?? 300) > 300 ||
          (int.tryParse(_appliedMaxPrice) ?? 100000) < 100000 ||
          _appliedMinDiscount > 0 ||
          _appliedMaxDiscount < 100;
    });
    _applyFiltersAndSortDebounced();
  }

  /// ✅ Skeleton Grid with shimmer effect
  Widget _buildSkeletonGrid() {
    return MasonryGridView.count(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      itemCount: 6, // Show 6 skeleton items
      crossAxisCount: 2,
      mainAxisSpacing: 10.sp,
      crossAxisSpacing: 10.sp,
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
    // Extract brand name from multiple possible sources
    String brandName = "";
    if (m["brand_name"] != null) {
      brandName = m["brand_name"].toString();
    } else if (m["brandName"] != null) {
      brandName = m["brandName"].toString();
    } else if (m["brand"] is Map) {
      brandName = (m["brand"]["name"] ?? "").toString();
    }

    return {
      "id": m["id"],
      "title": m["title"] ?? m["name"] ?? "",
      "brandName": brandName,
      "shortDescription": m["shortDescription"] ??
          m["description"] ??
          m["short_description"] ??
          "",
      "imageUrls": m["imageUrls"] is List
          ? m["imageUrls"]
          : (m["images"] is List ? m["images"] : []),
      "displayPrice": m["basePrice"] ??
          m["displayPrice"] ??
          m["price"] ??
          m["selling_price"] ??
          m["mrp"] ??
          0,
      "displayMrp": m["mrp"] ?? m["displayMrp"] ?? m["original_price"] ?? 0,
      "nudges": m["nudges"],
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

  Widget _divider({bool isLuxe = false}) => Container(
      width: 1.sp,
      color: isLuxe ? const Color(0xFF444444) : dividerColor,
      height: 46.sp);

  Widget _activeBottomButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool vector = false,
    bool isLuxe = false,
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
                colorFilter: isLuxe
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.sp),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isLuxe ? Colors.white : const Color(0xFF374151),
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
    List<String> selectedColors = List.from(_appliedColors);
    List<String> selectedSizes = List.from(_appliedSizes);
    RangeValues priceRange = RangeValues(
      double.parse(_appliedMinPrice).clamp(100.0, 50000.0),
      double.parse(_appliedMaxPrice).clamp(100.0, 50000.0),
    );
    RangeValues discountRange = RangeValues(
      _appliedMinDiscount.toDouble(),
      _appliedMaxDiscount.toDouble(),
    );

    final List<String> filterCategories = [
      "Brand",
      "Price Range",
      "Color",
      "Size",
      "Discount",
    ];

    // ✅ Get brands from filter metadata
    final allBrands = productController.filterBrands
        .map((item) => (item['name'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (allBrands.isEmpty) {
      getSnackBar("No brands available for filtering");
      return;
    }

    // ✅ Restore previously applied brands
    for (final id in _appliedBrandIds) {
      final brandData = productController.filterBrands.firstWhereOrNull(
          (item) => int.tryParse(item['id']?.toString() ?? '') == id);
      if (brandData != null) {
        final name = brandData['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          selectedBrands.add(name);
        }
      }
    }

    final brands = ["Select All", ...allBrands];
    final colors = productController.filterColors.toList();
    final sizes = productController.filterSizes.toList();

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
                                selectedColors.clear();
                                selectedSizes.clear();
                                priceRange = const RangeValues(300, 100000);
                                discountRange = const RangeValues(0, 100);
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
                                    : selectedFilter == "Color"
                                        ? colors.isEmpty
                                            ? const Center(
                                                child: Text(
                                                  "No colors available",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Clash Display Regular",
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount: colors.length,
                                                itemBuilder: (context, i) {
                                                  final color = colors[i];
                                                  final checked = selectedColors
                                                      .contains(color);

                                                  return CheckboxListTile(
                                                    dense: true,
                                                    activeColor: appBarColor,
                                                    value: checked,
                                                    title: Text(
                                                      color.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            "Clash Display Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: blackColor,
                                                      ),
                                                    ),
                                                    onChanged: (val) {
                                                      setModalState(() {
                                                        if (val == true) {
                                                          selectedColors
                                                              .add(color);
                                                        } else {
                                                          selectedColors
                                                              .remove(color);
                                                        }
                                                      });
                                                    },
                                                  );
                                                },
                                              )
                                        : selectedFilter == "Size"
                                            ? sizes.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                      "No sizes available",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Clash Display Regular",
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    itemCount: sizes.length,
                                                    itemBuilder: (context, i) {
                                                      final size = sizes[i];
                                                      final checked =
                                                          selectedSizes
                                                              .contains(size);

                                                      return CheckboxListTile(
                                                        dense: true,
                                                        activeColor:
                                                            appBarColor,
                                                        value: checked,
                                                        title: Text(
                                                          size.toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                "Clash Display Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: blackColor,
                                                          ),
                                                        ),
                                                        onChanged: (val) {
                                                          setModalState(() {
                                                            if (val == true) {
                                                              selectedSizes
                                                                  .add(size);
                                                            } else {
                                                              selectedSizes
                                                                  .remove(size);
                                                            }
                                                          });
                                                        },
                                                      );
                                                    },
                                                  )
                                            : selectedFilter == "Discount"
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                          "Select discount range",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Clash Display Semibold",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 15)),
                                                      const SizedBox(height: 8),
                                                      RangeSlider(
                                                        values: discountRange,
                                                        min: 0,
                                                        max: 100,
                                                        divisions: 20,
                                                        activeColor:
                                                            appBarColor,
                                                        onChanged: (v) =>
                                                            setModalState(() {
                                                          discountRange = v;
                                                        }),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "${discountRange.start.toInt()}%",
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      "Clash Display Regular",
                                                                  color: Colors
                                                                      .grey)),
                                                          Text(
                                                              "${discountRange.end.toInt()}%",
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      "Clash Display Regular",
                                                                  color: Colors
                                                                      .grey)),
                                                        ],
                                                      ),
                                                    ],
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
                                final brandData = productController.filterBrands
                                    .firstWhereOrNull((item) =>
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
                                _appliedColors = selectedColors;
                                _appliedSizes = selectedSizes;
                                _appliedMinPrice =
                                    priceRange.start.toInt().toString();
                                _appliedMaxPrice =
                                    priceRange.end.toInt().toString();
                                _appliedMinDiscount =
                                    discountRange.start.toInt();
                                _appliedMaxDiscount = discountRange.end.toInt();
                                _hasActiveFilters =
                                    selectedBrandIds.isNotEmpty ||
                                        selectedColors.isNotEmpty ||
                                        selectedSizes.isNotEmpty ||
                                        priceRange.start > 300 ||
                                        priceRange.end < 100000 ||
                                        discountRange.start > 0 ||
                                        discountRange.end < 100;
                              });

                              print("✅ Filters configured:");
                              print("  Brands: ${selectedBrands.join(', ')}");
                              print("  Brand IDs: $selectedBrandIds");
                              print("  Colors: ${selectedColors.join(', ')}");
                              print("  Sizes: ${selectedSizes.join(', ')}");
                              print(
                                  "  Price: ₹${priceRange.start.toInt()} - ₹${priceRange.end.toInt()}");

                              await _applyFiltersAndSortDebounced();

                              if (_hasActiveFilters) {
                                final filterParts = <String>[];
                                if (selectedBrandIds.isNotEmpty) {
                                  filterParts
                                      .add("${selectedBrands.length} brand(s)");
                                }
                                if (selectedColors.isNotEmpty) {
                                  filterParts
                                      .add("${selectedColors.length} color(s)");
                                }
                                if (selectedSizes.isNotEmpty) {
                                  filterParts
                                      .add("${selectedSizes.length} size(s)");
                                }
                                if (priceRange.start > 300 ||
                                    priceRange.end < 100000) {
                                  filterParts.add(
                                      "₹${priceRange.start.toInt()}–₹${priceRange.end.toInt()}");
                                }
                                if (discountRange.start > 0 ||
                                    discountRange.end < 100) {
                                  filterParts.add(
                                      "${discountRange.start.toInt()}%–${discountRange.end.toInt()}%");
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
          {String? subtitle,
          required VoidCallback onTap,
          bool isLuxe = false}) =>
      GestureDetector(
          onTap: onTap,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
              child: Column(children: [
                Text(label,
                    style: TextStyle(
                        color: isLuxe ? Colors.white : const Color(0xFF374151),
                        fontSize: 13,
                        fontFamily: "Clash Display",
                        fontWeight: FontWeight.w500)),
                if ((subtitle ?? '').isNotEmpty)
                  Padding(
                      padding: EdgeInsets.only(top: 1.sp),
                      child: Text(subtitle!,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: isLuxe ? Colors.white70 : appBarColor)))
              ])));
}

/// ✅ Skeleton Product Tile with Shimmer Effect
class _SkeletonProductTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F1F1),
          borderRadius: BorderRadius.circular(6.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image skeleton - matches ProductGridCard image height
            Container(
              height: 160.sp,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.sp),
              ),
            ),

            SizedBox(height: 6.sp),

            // Title skeleton
            Container(
              width: double.infinity,
              height: 14.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            SizedBox(height: 4.sp),

            // Brand name skeleton
            Container(
              width: 100.sp,
              height: 12.sp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            SizedBox(height: 4.sp),

            // Price skeleton
            Row(
              children: [
                Container(
                  width: 50.sp,
                  height: 12.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 6.sp),
                Container(
                  width: 40.sp,
                  height: 10.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A dedicated StatefulWidget for the filter chips row in CategoryProductScreen.
///
/// This widget subscribes to GetX observables (chips, activeChipId) via [Obx]
/// AND re-reads the active filter pills via [buildPills] on every rebuild.
/// Because it is a separate StatefulWidget, calling setState on the parent
/// does NOT cause this widget to rebuild — only GetX changes do.
/// Conversely, when the parent calls setState (e.g. after removing a filter),
/// the parent rebuilds and passes a fresh [buildPills] closure, which this
/// widget picks up on its next GetX-triggered rebuild.
///
/// The key insight: we store the pills in local state and update them whenever
/// the parent rebuilds (via [didUpdateWidget]) OR when GetX triggers a rebuild.
class _FilterChipsSection extends StatefulWidget {
  final CatalogController catalogController;
  final List<ActiveFilterPill> Function() buildPills;

  const _FilterChipsSection({
    required this.catalogController,
    required this.buildPills,
  });

  @override
  State<_FilterChipsSection> createState() => _FilterChipsSectionState();
}

class _FilterChipsSectionState extends State<_FilterChipsSection> {
  late List<ActiveFilterPill> _pills;

  @override
  void initState() {
    super.initState();
    _pills = widget.buildPills();
  }

  @override
  void didUpdateWidget(_FilterChipsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent called setState — refresh pills immediately
    _pills = widget.buildPills();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.catalogController.isCategory.value) {
        return const ChipShimmerRow();
      }
      return FilterChipsRow(
        chips: widget.catalogController.chips.toList(),
        selectedChipIds: widget.catalogController.selectedChipIds,
        selectedChips: widget.catalogController.selectedChips.toList(),
        onChipTap: widget.catalogController.onChipTap,
        activeFilters: widget.buildPills(),
      );
    });
  }
}
