// ProductViewScreen.dart - Updated with filters and sort

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
import 'package:shimmer/shimmer.dart';
import '../../../common/widget/appbar/productlist_appbar.dart';
import '../../../common/widget/lists/dummy_grid_list.dart';
import '../../../common/widget/other/common_widget.dart';
import '../../../common/widget/text/app_text.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../controllers/brand_controller.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../core/constant/constants.dart';
import 'dart:async';

class ProductViewScreen extends StatefulWidget {
  final String title;
  final String genderName;
  final List<Map<String, dynamic>>? searchResults;
  final String? searchQuery;

  const ProductViewScreen({
    super.key,
    required this.title,
    required this.genderName,
    this.searchResults,
    this.searchQuery,
  });

  @override
  State<ProductViewScreen> createState() => ProductViewScreenState();
}

class ProductViewScreenState extends State<ProductViewScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final controller = Get.put(CartController());
  final brandController = Get.put(BrandController());
  final catalogController = Get.put(CatalogController(), permanent: false);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // ✅ Filter and Sort State
  List<int> _appliedBrandIds = [];
  List<String> _appliedColors = [];
  List<String> _appliedSizes = [];
  String _appliedMinPrice = "300";
  String _appliedMaxPrice = "100000";
  String _appliedSortOption = "recommended";
  bool _hasActiveFilters = false;
  bool _isFilterMetadataLoaded = false;
  bool _isProductsLoaded = false;

  // ✅ Hash tracking for change detection
  String? _lastProductListHash;
  String? _lastFilterHash;
  String? _lastSortHash;

  // ✅ Store original home product IDs for client-side filtering
  Set<int> _originalHomeProductIds = {};

  // ✅ Debounce timer
  Timer? _debounceTimer;

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
    // Return the selling price (NOT mrp)
    // API now provides displayPrice (= basePrice) for filtered products
    return item['displayPrice'] ??
        item['basePrice'] ??
        item['price'] ??
        item['msp'] ??
        item['lfMsp'];
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

  // ✅ Generate hash for product list to detect changes
  String _generateProductHash(List<dynamic> products) {
    if (products.isEmpty) return 'empty';
    return products.map((p) => p['id'].toString()).join('|');
  }

  // ✅ Generate hash for current filter state
  String _generateFilterHash() {
    return '${_appliedBrandIds.join(',')}_${_appliedColors.join(',')}_${_appliedSizes.join(',')}_${_appliedMinPrice}_${_appliedMaxPrice}_$_hasActiveFilters';
  }

  // ✅ Generate hash for current sort state
  String _generateSortHash() {
    return _appliedSortOption;
  }
  // ---- end helpers ----

  @override
  void initState() {
    super.initState();

    final g = widget.genderName.trim().toLowerCase();
    if (g == 'men') {
      productController.categoryFilter.value = 1;
    } else if (g == 'women') {
      productController.categoryFilter.value = 2;
    } else {
      productController.categoryFilter.value = 3;
    }
    productController.selectedCategoryGender.value = widget.genderName;

    // ✅ CRITICAL FIX: Clear cached data when screen initializes
    productController.handPickedProductList.clear();
    productController.handpickedHasnextpage.value = true;
    productController.handpickedLoadMore.value = false;
    productController.isHandPicked.value = false;
    productController.handpickedPage.value = 1;

    // ✅ CRITICAL FIX: Reset all filter/sort state flags to force reload
    _isFilterMetadataLoaded = false;
    _isProductsLoaded = false;
    _lastProductListHash = null;
    _lastFilterHash = null;
    _lastSortHash = null;
    _originalHomeProductIds = {};

    // ✅ CRITICAL FIX: Clear API filter results cache
    catalogController.categoryProductList.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      wishlistController.getWishlistData();

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: statusBarColor,
      ));

      controller.getCartData();

      productController.handpickedController.addListener(() {
        productController.update();
      });

      // ✅ Only load products if NOT in search mode
      if (widget.searchResults == null) {
        // ✅ Check if we have a specific collectionId
        final collectionId = productController.tagId.value;

        if (collectionId > 0) {
          // ✅ NEW: Fetch products directly from /filter-products API for this collection
          print("🔹 Loading products for collection $collectionId from API");
          await catalogController.getFilterAndSortProducts(
            superCatId: productController.categoryFilter.value,
            collectionId: collectionId,
            page: 1,
            limit: 100, // Load all products for collection
          );

          _isProductsLoaded = true;
          print("✅ Loaded ${catalogController.categoryProductList.length} products from API for collection $collectionId");
        } else {
          // ✅ Fallback: Use home products if no specific collection
          final currentGender = productController.categoryFilter.value;
          await productController.getHomeProduct(currentGender, withLimit: false);

          // ✅ Load and track home products
          _loadHomeProductsIfNeeded();
        }
      }
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

    print("🔄 ProductViewScreen initialized for collection: ${productController.tagId.value}, gender: ${widget.genderName}");
  }

  // ✅ Load filter metadata for filter
  Future<void> _loadFilterMetadataIfNeeded() async {
    if (_isFilterMetadataLoaded) {
      print("✅ Filter metadata already loaded - skipping");
      return;
    }

    final currentGender = productController.categoryFilter.value;
    await productController.getFilterMetadata(currentGender);
    _isFilterMetadataLoaded = true;
    print("✅ Filter metadata loaded successfully");
  }

  // ✅ Load initial home products
  Future<void> _loadHomeProductsIfNeeded() async {
    if (_isProductsLoaded) {
      print("✅ Home products already loaded - skipping");
      return;
    }

    // Home products should already be loaded from home screen
    // Just store the original product IDs for filtering
    final allProducts = _getAllProducts();
    _originalHomeProductIds = allProducts
        .map((p) => int.tryParse(p['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    // Generate initial hashes
    _lastProductListHash = _generateProductHash(allProducts);
    _lastFilterHash = _generateFilterHash();
    _lastSortHash = _generateSortHash();

    _isProductsLoaded = true;
    print("✅ Home products tracked (${_originalHomeProductIds.length} items)");
  }

  // ✅ Get categories based on super category (genderType from productController)
  // Uses actual API-loaded categories from catalogController.catalogList
  // ✅ Get all products from collections
  List<Map<String, dynamic>> _getAllProducts() {
    // If search results are provided, return them directly
    if (widget.searchResults != null && widget.searchResults!.isNotEmpty) {
      return widget.searchResults!;
    }

    final int selectedCollectionId = productController.tagId.value;
    final int superCatId = productController.categoryFilter.value;

    final List<Map<String, dynamic>> collections = productController
        .homeProductList
        .whereType<Map<String, dynamic>>()
        .toList();

    final List<Map<String, dynamic>> allProducts = <Map<String, dynamic>>[];

    print("🔍 DEBUG: Getting products - selectedCollectionId: $selectedCollectionId, superCatId: $superCatId");
    print("🔍 DEBUG: Total collections: ${collections.length}");

    for (final c in collections) {
      // ✅ Get the collection ID from the collection object (not from products)
      final collectionId = c['id'] is int
          ? c['id']
          : int.tryParse(c['id']?.toString() ?? '') ?? 0;

      final List<Map<String, dynamic>> prods =
          (c['products'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList();

      print("📦 Collection ID: $collectionId, Name: ${c['name']}, Products: ${prods.length}");

      // ✅ If a specific collection is selected, skip other collections
      if (selectedCollectionId != 0 && collectionId != selectedCollectionId) {
        print("   ⏭️ Skipping collection $collectionId (looking for $selectedCollectionId)");
        continue;
      }

      for (final p in prods) {
        final sc = p['superCatId'];
        final scId = sc is int ? sc : int.tryParse(sc?.toString() ?? '') ?? 0;

        // ✅ Apply same workaround as homescreen: if superCatId is 0 (missing), assume it matches
        // because API already filters by gender parameter
        if (scId == 0) {
          allProducts.add(p);
          continue;
        }

        // ✅ Filter by gender if superCatId is set
        if (superCatId != 0 && scId != superCatId) {
          print("   ⏭️ Product ${p['id']} skipped (superCatId: $scId, need: $superCatId)");
          continue;
        }

        allProducts.add(p);
      }
    }

    print("✅ Total products returned: ${allProducts.length}");
    return allProducts;
  }

  // ✅ Apply filters and sort using API (like categoryproduct.dart)
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

      // ✅ Determine the action based on filters and sort state
      // Case 1: Has filters → Call API (with or without sort)
      // Case 2: Only sort (no filters) → Client-side sort
      // Case 3: Neither filters nor sort → Show original
      
      if (_hasActiveFilters && filterChanged) {
        // 📞 Case 1: Filters changed → Call /filter-products API
        // Note: API does backend filtering + client-side price/brand safety net
        print("🔹 Case 1: Filter changed (has active filters)");
        print("   • brand IDs    → ${_appliedBrandIds.isNotEmpty ? _appliedBrandIds : 'all brands'}");
        print("   • colors       → ${_appliedColors.isNotEmpty ? _appliedColors : 'all colors'}");
        print("   • sizes        → ${_appliedSizes.isNotEmpty ? _appliedSizes : 'all sizes'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print("   • sortOption   → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          colors: _appliedColors.isNotEmpty ? _appliedColors : null,
          sizes: _appliedSizes.isNotEmpty ? _appliedSizes : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          sortOption: _appliedSortOption != "recommended" ? _appliedSortOption : null,
          superCatId: productController.categoryFilter.value, // ✅ Pass gender type (Men/Women/Kids)
          collectionId: productController.tagId.value > 0 ? productController.tagId.value : null, // ✅ Pass collection ID if selected
        );

        // ✅ Additional client-side filtering for view-specific constraints
        // API already filtered by price & brand; we filter by home products
        final apiResults = List<dynamic>.from(catalogController.categoryProductList);

        // Restrict to home products only
        final filteredResults = apiResults.where((product) {
          final productId = int.tryParse(product['id']?.toString() ?? '');
          return productId != null && _originalHomeProductIds.contains(productId);
        }).toList();

        print("🔍 API returned ${apiResults.length} products, filtered to ${filteredResults.length} from home collections");
        catalogController.categoryProductList.assignAll(filteredResults);
        
        _lastFilterHash = currentFilterHash;
        if (sortChanged) _lastSortHash = currentSortHash;

        print("✅ Filter applied - ${catalogController.categoryProductList.length} products");
        
      } else if (!_hasActiveFilters && _appliedSortOption != "recommended" && sortChanged) {
        // 🔧 Case 2: ONLY sort changed (no filters) → Client-side sort
        print("🔧 Client-side sorting: $_appliedSortOption (no filters, so not calling API)");
        
        // Get original products
        final productsToSort = List<dynamic>.from(_getAllProducts());
        
        productsToSort.sort((a, b) {
          final priceA = (a['price'] ?? a['basePrice'] ?? a['displayPrice'] ?? 0) as num;
          final priceB = (b['price'] ?? b['basePrice'] ?? b['displayPrice'] ?? 0) as num;
          
          if (_appliedSortOption == 'price_asc') {
            return priceA.compareTo(priceB);
          } else if (_appliedSortOption == 'price_desc') {
            return priceB.compareTo(priceA);
          } else if (_appliedSortOption == 'whats_new') {
            final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idB.compareTo(idA);
          }
          return 0;
        });
        
        // Store sorted results in catalogController
        catalogController.categoryProductList.assignAll(productsToSort);
        _lastSortHash = currentSortHash;
        
        print("✅ Client-side sort complete - ${catalogController.categoryProductList.length} products");
        
      } else if (_hasActiveFilters && sortChanged) {
        // 🔧 Case 3: Filters already applied, but sort changed → Re-apply filters with new sort
        // Note: API does backend filtering + client-side price/brand safety net
        print("🔹 Case 3: Sort changed (filters already applied)");
        print("   • brand IDs    → ${_appliedBrandIds.isNotEmpty ? _appliedBrandIds : 'all brands'}");
        print("   • colors       → ${_appliedColors.isNotEmpty ? _appliedColors : 'all colors'}");
        print("   • sizes        → ${_appliedSizes.isNotEmpty ? _appliedSizes : 'all sizes'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print("   • sortOption   → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          colors: _appliedColors.isNotEmpty ? _appliedColors : null,
          sizes: _appliedSizes.isNotEmpty ? _appliedSizes : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          sortOption: _appliedSortOption != "recommended" ? _appliedSortOption : null,
          superCatId: productController.categoryFilter.value, // ✅ Pass gender type (Men/Women/Kids)
          collectionId: productController.tagId.value > 0 ? productController.tagId.value : null, // ✅ Pass collection ID if selected
        );

        // ✅ Additional client-side filtering for view-specific constraints
        // API already filtered by price & brand; we filter by home products
        final apiResults = List<dynamic>.from(catalogController.categoryProductList);

        // Restrict to home products only
        final filteredResults = apiResults.where((product) {
          final productId = int.tryParse(product['id']?.toString() ?? '');
          return productId != null && _originalHomeProductIds.contains(productId);
        }).toList();
        catalogController.categoryProductList.assignAll(filteredResults);

        _lastSortHash = currentSortHash;

        print("✅ Filters re-applied with new sort - ${catalogController.categoryProductList.length} products");
        
      } else if (!_hasActiveFilters && filterChanged) {
        // Filters cleared - clear filtered results
        catalogController.categoryProductList.clear();
        _lastFilterHash = currentFilterHash;
        print("✅ Filters cleared - showing original products");
      } else if (_appliedSortOption == "recommended" && sortChanged) {
        // Sort reset to recommended - clear sorted results if no filters
        if (!_hasActiveFilters) {
          catalogController.categoryProductList.clear();
        }
        _lastSortHash = currentSortHash;
        print("✅ Sort reset to recommended");
      }

      setState(() {
        // Reset pagination when filters change
        productController.handpickedPage.value = 1;
      });

      // Update final hash
      final List<dynamic> productsForHash = catalogController.categoryProductList.isNotEmpty
          ? List<dynamic>.from(catalogController.categoryProductList)
          : _getAllProducts();
      _lastProductListHash = _generateProductHash(productsForHash);
    } catch (e) {
      print("❌ Error applying filters/sort: $e");
      getSnackBar("Something went wrong, please try again");
    }
  }

  // ✅ Debounced update
  void _applyFiltersAndSortDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFiltersAndSort();
    });
  }

  // ✅ Get displayed products - either filtered or original
  List<Map<String, dynamic>> _getDisplayedProducts() {
    // If we have filtered results from API, use those
    if (catalogController.categoryProductList.isNotEmpty) {
      return catalogController.categoryProductList
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    // Otherwise, use original products from home
    return _getAllProducts();
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
              Get.to(CartScreen())?.then((_) => setState(() {
                    controller.getCartData();
                  }));
              analytics.logEvent(
                  name: "cart_page", parameters: {"page_name": "cart_page"});
            },
          ),
          SizedBox(height: 10.sp),

          // ===== GRID =====
          Expanded(
            child: Obx(() {
              // ✅ Show loading when fetching from API or home products
              final loading = widget.searchResults == null &&
                  (productController.isHomeProduct.value ||
                      productController.isHandPicked.value ||
                      catalogController.isSorting.value ||
                      catalogController.isCategory.value);

              if (loading) {
                return _buildSkeletonGrid();
              }

              // ✅ Calculate displayed products WITHOUT setState
              final items = _getDisplayedProducts();

              if (items.isEmpty) {
                return Column(
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
                );
              }

              // client-side paging (infinite scroll)
              const int pageSize = 12;
              final int page = (productController.handpickedPage.value <= 0)
                  ? 1
                  : productController.handpickedPage.value;

              final int maxToShow = page * pageSize;
              final int visibleCount =
                  maxToShow < items.length ? maxToShow : items.length;
              final List<Map<String, dynamic>> displayItems =
                  items.take(visibleCount).toList();

              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 160) {
                    final bool canLoadMore =
                        displayItems.length < items.length &&
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
                            final item = displayItems[index];

                            final imageUrl = _firstImageUrl(item);
                            final brand = _brandOf(item);
                            final title = _titleOf(item);
                            final price = _priceOf(item);
                            // API provides displayMrp (null if mrp = basePrice, otherwise mrp value)
                            final mrp = item['displayMrp'] ?? item['mrp'];
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
                                      aspectRatio: 0.75,
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
                                  // Product Name
                                  AppText(
                                    text: title.toUpperCase(),
                                    color: blackColor,
                                    maxLines: 1,
                                    fontSize: 12,
                                    fontFamily: "Clash Display Semibold",
                                    fontWeight: FontWeight.w700,
                                  ),
                                  // Brand Name
                                  AppText(
                                    text: brand.toUpperCase(),
                                    color: const Color(0xFF6B7280),
                                    maxLines: 1,
                                    fontSize: 11,
                                    fontFamily: "Clash Display Regular",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  // Price Row
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.sp),
                                    child: () {
                                      final numPrice = price is num ? price : 0;
                                      final numMrp = mrp is num ? mrp : 0;

                                      // Calculate discount percentage
                                      int? discountPercent;
                                      if (numPrice > 0 && numMrp > 0 && numMrp > numPrice) {
                                        discountPercent = (((numMrp - numPrice) / numMrp) * 100).round();
                                      }

                                      // ✅ Case 1: Price is 0 or null - show only MRP (not crossed)
                                      if (numPrice == 0 && numMrp > 0) {
                                        return AppText(
                                          text: "₹ ${numMrp.toString()}",
                                          color: blackColor,
                                          maxLines: 1,
                                          fontSize: 12,
                                          fontFamily: "Clash Display Semibold",
                                          fontWeight: FontWeight.w700,
                                        );
                                      }

                                      // ✅ Case 2: Both exist and price < mrp - show base price, crossed MRP, and discount %
                                      if (numPrice > 0 && numMrp > 0 && numPrice < numMrp) {
                                        return Row(
                                          children: [
                                            // Base Price
                                            AppText(
                                              text: "₹ ${numPrice.toString()}",
                                              color: blackColor,
                                              maxLines: 1,
                                              fontSize: 12,
                                              fontFamily: "Clash Display Semibold",
                                              fontWeight: FontWeight.w700,
                                            ),
                                            // MRP (crossed out)
                                            Padding(
                                              padding: EdgeInsets.only(left: 5.sp),
                                              child: Text(
                                                "₹ $numMrp",
                                                style: TextStyle(
                                                  color: const Color(0xFF9CA3AF),
                                                  fontSize: 11.sp,
                                                  decoration: TextDecoration.lineThrough,
                                                  fontFamily: "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            // Discount %
                                            if (discountPercent != null)
                                              Padding(
                                                padding: EdgeInsets.only(left: 5.sp),
                                                child: Text(
                                                  "($discountPercent% OFF)",
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontFamily: "Clash Display",
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      }

                                      // ✅ Case 3: Only price exists - show price
                                      if (numPrice > 0) {
                                        return AppText(
                                          text: "₹ ${numPrice.toString()}",
                                          color: blackColor,
                                          maxLines: 1,
                                          fontSize: 12,
                                          fontFamily: "Clash Display Semibold",
                                          fontWeight: FontWeight.w700,
                                        );
                                      }

                                      // ✅ Case 4: Nothing to show
                                      return const SizedBox.shrink();
                                    }(),
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
                                            fontFamily: "Clash Display Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          childCount: displayItems.length,
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
              );
            }),
          ),

          // ===== bottom sort / category / filters row =====
          Container(
            color: statusBarColor,
            child: Column(
              children: [
                Container(height: 1.sp, color: dividerColor),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Sort by
                      GestureDetector(
                        onTap: () => _showSortBottomSheet(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.sp, horizontal: 5.sp),
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
                                    fontFamily: "Clash Display",
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

                      // Only show category if NOT in search mode
                      if (widget.searchResults == null) ...[
                        // Category
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.sp, horizontal: 5.sp),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                                  child: Text(
                                    "CATEGORY",
                                    style: TextStyle(
                                      color: const Color(0xFF374151),
                                      fontSize: 13.sp,
                                      fontFamily: "Clash Display",
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 5.sp, right: 5.sp, top: 1.sp),
                                  child: Text(
                                    widget.genderName.toUpperCase(),
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontFamily: "Clash Display Regular",
                                      fontWeight: FontWeight.w400,
                                      color: appBarColor,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(width: 1.sp, color: borderColor, height: 40.sp),
                      ],

                      // Filters
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.sp, horizontal: 5.sp),
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
                                    fontFamily: "Clash Display",
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// ✅ Skeleton Grid
  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.sp,
        crossAxisSpacing: 5.sp,
        childAspectRatio: 0.56,
      ),
      itemBuilder: (context, index) => _SkeletonProductTile(),
    );
  }

  /// ✅ Filter Bottom Sheet
  Future<void> _showFilterBottomSheet(BuildContext context) async {
    String selectedFilter = "Brand";

    List<String> selectedBrands = [];
    List<String> selectedColors = List.from(_appliedColors);
    List<String> selectedSizes = List.from(_appliedSizes);
    RangeValues priceRange = RangeValues(
      double.parse(_appliedMinPrice),
      double.parse(_appliedMaxPrice),
    );

    final List<String> filterCategories = [
      "Brand",
      "Price Range",
      "Color",
      "Size"
    ];

    // ✅ Ensure filter metadata is loaded
    await _loadFilterMetadataIfNeeded();

    if (productController.isFilterMetadata.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

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
      final brandData = productController.filterBrands.firstWhereOrNull((item) =>
          int.tryParse(item['id']?.toString() ?? '') == id);
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
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: blackColor)),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedBrands.clear();
                                selectedColors.clear();
                                selectedSizes.clear();
                                priceRange = const RangeValues(300, 100000);
                              });
                            },
                            child: const Text("CLEAR ALL",
                                style: TextStyle(
                                    color: appBarColor,
                                    fontSize: 13,
                                    fontFamily: "Clash Display",
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
                                                ? "Clash Display"
                                                : "Clash Display Regular",
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
                                                      "Clash Display Regular",
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
                                                    fontFamily: "Franklin Gothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15)),
                                            const SizedBox(height: 8),
                                            RangeSlider(
                                              values: priceRange,
                                              min: 300,
                                              max: 100000,
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
                                        )
                                      : selectedFilter == "Color"
                                          ? colors.isEmpty
                                              ? const Center(
                                                  child: Text("No colors available"))
                                              : ListView.builder(
                                                  itemCount: colors.length,
                                                  itemBuilder: (context, i) {
                                                    final color = colors[i];
                                                    final checked =
                                                        selectedColors.contains(color);
                                                    return CheckboxListTile(
                                                      value: checked,
                                                      onChanged: (val) {
                                                        setModalState(() {
                                                          if (val == true) {
                                                            selectedColors.add(color);
                                                          } else {
                                                            selectedColors.remove(color);
                                                          }
                                                        });
                                                      },
                                                      controlAffinity:
                                                          ListTileControlAffinity.leading,
                                                      title: Text(
                                                        color.toUpperCase(),
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                          : selectedFilter == "Size"
                                              ? sizes.isEmpty
                                                  ? const Center(
                                                      child: Text("No sizes available"))
                                                  : ListView.builder(
                                                      itemCount: sizes.length,
                                                      itemBuilder: (context, i) {
                                                        final size = sizes[i];
                                                        final checked =
                                                            selectedSizes.contains(size);
                                                        return CheckboxListTile(
                                                          value: checked,
                                                          onChanged: (val) {
                                                            setModalState(() {
                                                              if (val == true) {
                                                                selectedSizes.add(size);
                                                              } else {
                                                                selectedSizes.remove(size);
                                                              }
                                                            });
                                                          },
                                                          controlAffinity:
                                                              ListTileControlAffinity.leading,
                                                          title: Text(
                                                            size.toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )
                                              : const SizedBox(),
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
                                    fontFamily: "Clash Display",
                                    color: blackColor)),
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            onPressed: () {
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

                              print("✅ Filters configured:");
                              print("  Brands: ${selectedBrands.join(', ')}");
                              print("  Brand IDs: $selectedBrandIds");
                              print("  Price: ₹${priceRange.start.toInt()} - ₹${priceRange.end.toInt()}");
                              print("  Colors: ${selectedColors.join(', ')}");
                              print("  Sizes: ${selectedSizes.join(', ')}");

                              setState(() {
                                _appliedBrandIds = selectedBrandIds;
                                _appliedMinPrice =
                                    priceRange.start.toInt().toString();
                                _appliedMaxPrice =
                                    priceRange.end.toInt().toString();
                                _appliedColors = List.from(selectedColors);
                                _appliedSizes = List.from(selectedSizes);
                                _hasActiveFilters =
                                    selectedBrandIds.isNotEmpty ||
                                        priceRange.start > 300 ||
                                        priceRange.end < 100000 ||
                                        selectedColors.isNotEmpty ||
                                        selectedSizes.isNotEmpty;

                                // Reset pagination
                                productController.handpickedPage.value = 1;
                              });

                              _applyFiltersAndSortDebounced();

                              if (_hasActiveFilters) {
                                final filterParts = <String>[];
                                if (selectedBrands.isNotEmpty) {
                                  filterParts.add("${selectedBrands.length} brand(s)");
                                }
                                if (priceRange.start > 300 || priceRange.end < 100000) {
                                  filterParts.add("₹${priceRange.start.toInt()}–₹${priceRange.end.toInt()}");
                                }
                                if (selectedColors.isNotEmpty) {
                                  filterParts.add("${selectedColors.length} color(s)");
                                }
                                if (selectedSizes.isNotEmpty) {
                                  filterParts.add("${selectedSizes.length} size(s)");
                                }
                                getSnackBar("Filtered by ${filterParts.join(', ')}");
                              } else {
                                getSnackBar("Filters cleared");
                              }
                            },
                            child: const Text("APPLY",
                                style: TextStyle(
                                    fontFamily: "Clash Display",
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

  /// ✅ Sort Bottom Sheet
  Future<void> _showSortBottomSheet(BuildContext context) async {
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
                        fontFamily: "Clash Display",
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
                                fontFamily: "Clash Display Regular",
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
                                color: blackColor)))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          final selected = selectedOption.value;
                          Get.back();

                          print("✅ Sort option selected: $selected");

                          setState(() {
                            _appliedSortOption = selected;
                            // Reset pagination
                            productController.handpickedPage.value = 1;
                          });

                          _applyFiltersAndSortDebounced();

                          getSnackBar(
                              "Sorted by ${sortOptions[selected] ?? 'Recommended'}");
                        },
                        child: const Text("APPLY",
                            style: TextStyle(
                                fontFamily: "Clash Display",
                                color: whiteColor))))
              ]),
              SizedBox(height: 10.sp)
            ],
          ),
        );
      },
    );
  }
}

/// ✅ Skeleton Product Tile
class _SkeletonProductTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.75,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(height: 5.sp),
          Container(
            width: double.infinity,
            height: 14.sp,
            color: Colors.white,
          ),
          SizedBox(height: 4.sp),
          Container(
            width: double.infinity * 0.7,
            height: 12.sp,
            color: Colors.white,
          ),
          SizedBox(height: 6.sp),
          Container(
            width: 60.sp,
            height: 14.sp,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
