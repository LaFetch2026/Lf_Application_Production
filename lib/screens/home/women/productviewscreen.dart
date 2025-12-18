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
  final brandController = Get.put(BrandController());
  final catalogController = Get.put(CatalogController(), permanent: false);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // ✅ Filter and Sort State
  List<int> _appliedBrandIds = [];
  String _appliedMinPrice = "300";
  String _appliedMaxPrice = "100000";
  String _appliedSortOption = "recommended";
  int? _appliedSuperCatId;
  int? _appliedCatId;
  int? _appliedSubCatId;
  int? _appliedCollectionId;
  bool _hasActiveFilters = false;
  bool _isBrandsLoaded = false;
  bool _isProductsLoaded = false;
  bool _isCategoriesLoaded = false;
  List<Map<String, dynamic>> _collections = [];

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
    return '${_appliedBrandIds.join(',')}_${_appliedMinPrice}_${_appliedMaxPrice}_${_appliedSuperCatId}_${_appliedCatId}_${_appliedSubCatId}_${_appliedCollectionId}_$_hasActiveFilters';
  }

  // ✅ Generate hash for current sort state
  String _generateSortHash() {
    return _appliedSortOption;
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

      controller.getCartData();

      productController.handpickedController.addListener(() {
        productController.update();
      });

      // ✅ Load brands for filters
      _loadBrandsIfNeeded();

      // ✅ Load and track home products
      _loadHomeProductsIfNeeded();
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

  // ✅ Load brands for filter
  Future<void> _loadBrandsIfNeeded() async {
    if (_isBrandsLoaded) {
      print("✅ Brands already loaded - skipping");
      return;
    }

    await brandController.getBrandData("all");
    _isBrandsLoaded = true;
    print("✅ Brands loaded successfully");
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

    // Extract collections from home product list
    // Use collectionID from products if available, otherwise use collection id
    _collections = productController.homeProductList
        .whereType<Map<String, dynamic>>()
        .map((c) {
          // Check if collection has products with collectionID
          final products = c['products'] as List?;
          final firstProduct = products?.isNotEmpty == true ? products!.first : null;
          final collectionId = firstProduct != null && firstProduct is Map
              ? (firstProduct['collectionID'] ?? c['id'])
              : c['id'];

          return {
            'id': collectionId,
            'name': c['name'] ?? 'Unknown',
          };
        })
        .toList();

    // Generate initial hashes
    _lastProductListHash = _generateProductHash(allProducts);
    _lastFilterHash = _generateFilterHash();
    _lastSortHash = _generateSortHash();

    _isProductsLoaded = true;
    print("✅ Home products tracked (${_originalHomeProductIds.length} items)");
    print("✅ Collections loaded: ${_collections.length}");
    for (final col in _collections) {
      print("   - ID: ${col['id']}, Name: ${col['name']}");
    }
  }

  // ✅ Get all products from collections
  List<Map<String, dynamic>> _getAllProducts() {
    final int selectedCollectionId = productController.tagId.value;
    final int superCatId = productController.categoryFilter.value;

    final List<Map<String, dynamic>> collections = productController
        .homeProductList
        .whereType<Map<String, dynamic>>()
        .toList();

    final List<Map<String, dynamic>> allProducts = <Map<String, dynamic>>[];

    for (final c in collections) {
      final List<Map<String, dynamic>> prods =
          (c['products'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList();

      for (final p in prods) {
        if (selectedCollectionId != 0 &&
            (p['collectionID'] != selectedCollectionId)) continue;

        final sc = p['superCatId'];
        if (superCatId != 0 && sc is int && sc != superCatId) continue;

        allProducts.add(p);
      }
    }

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
        print("🔹 Case 1: Filter changed (has active filters)");
        print("   • brand IDs    → ${_appliedBrandIds.isNotEmpty ? _appliedBrandIds : 'all brands'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print("   • superCatId   → $_appliedSuperCatId");
        print("   • catId        → $_appliedCatId");
        print("   • subCatId     → $_appliedSubCatId");
        print("   • collectionId → $_appliedCollectionId");
        print("   • sortOption   → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          superCatId: _appliedSuperCatId,
          catId: _appliedCatId,
          subCatId: _appliedSubCatId,
          collectionId: _appliedCollectionId,
          sortOption: _appliedSortOption != "recommended" ? _appliedSortOption : null,
        );

        // ✅ Client-side filter: Only filter by home products if NO category filters are applied
        // When user explicitly filters by super category, category, or sub-category, trust the API results
        final apiResults = List<dynamic>.from(catalogController.categoryProductList);

        if (_appliedSuperCatId == null && _appliedCatId == null && _appliedSubCatId == null && _appliedCollectionId == null) {
          // No category/collection filters - restrict to home products
          final filteredResults = apiResults.where((product) {
            final productId = int.tryParse(product['id']?.toString() ?? '');
            return productId != null && _originalHomeProductIds.contains(productId);
          }).toList();

          print("🔍 API returned ${apiResults.length} products, filtered to ${filteredResults.length} from this view (no category/collection filters)");
          catalogController.categoryProductList.assignAll(filteredResults);
        } else {
          // Category/collection filters applied - but backend may ignore filters, so filter client-side
          var filteredResults = apiResults;

          // ✅ Client-side filter by collectionId (backend ignores this parameter)
          if (_appliedCollectionId != null) {
            filteredResults = filteredResults.where((product) {
              final productCollectionId = int.tryParse(product['collectionID']?.toString() ?? '');
              return productCollectionId == _appliedCollectionId;
            }).toList();
            print("🔍 API returned ${apiResults.length} products, filtered to ${filteredResults.length} with collectionID=$_appliedCollectionId");
          } else {
            print("🔍 API returned ${apiResults.length} products, using all (category filters applied)");
          }

          catalogController.categoryProductList.assignAll(filteredResults);
        }
        
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
        print("🔹 Case 3: Sort changed (filters already applied)");
        print("   • brand IDs    → ${_appliedBrandIds.isNotEmpty ? _appliedBrandIds : 'all brands'}");
        print("   • price range  → ₹$_appliedMinPrice - ₹$_appliedMaxPrice");
        print("   • superCatId   → $_appliedSuperCatId");
        print("   • catId        → $_appliedCatId");
        print("   • subCatId     → $_appliedSubCatId");
        print("   • collectionId → $_appliedCollectionId");
        print("   • sortOption   → ${_appliedSortOption != "recommended" ? _appliedSortOption : null}");

        await catalogController.getFilterAndSortProducts(
          brandIds: _appliedBrandIds.isNotEmpty ? _appliedBrandIds : null,
          minPrice: _appliedMinPrice,
          maxPrice: _appliedMaxPrice,
          superCatId: _appliedSuperCatId,
          catId: _appliedCatId,
          subCatId: _appliedSubCatId,
          collectionId: _appliedCollectionId,
          sortOption: _appliedSortOption != "recommended" ? _appliedSortOption : null,
        );

        final apiResults = List<dynamic>.from(catalogController.categoryProductList);

        if (_appliedSuperCatId == null && _appliedCatId == null && _appliedSubCatId == null && _appliedCollectionId == null) {
          // No category/collection filters - restrict to home products
          final filteredResults = apiResults.where((product) {
            final productId = int.tryParse(product['id']?.toString() ?? '');
            return productId != null && _originalHomeProductIds.contains(productId);
          }).toList();
          catalogController.categoryProductList.assignAll(filteredResults);
        } else {
          // Category/collection filters applied - filter client-side by collectionId
          var filteredResults = apiResults;

          if (_appliedCollectionId != null) {
            filteredResults = filteredResults.where((product) {
              final productCollectionId = int.tryParse(product['collectionID']?.toString() ?? '');
              return productCollectionId == _appliedCollectionId;
            }).toList();
          }

          catalogController.categoryProductList.assignAll(filteredResults);
        }

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
              final loading = productController.isHomeProduct.value ||
                  productController.isHandPicked.value;

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
                                    child: () {
                                      final numPrice = price is num ? price : 0;
                                      final numMrp = mrp is num ? mrp : 0;

                                      // ✅ Case 1: Price is 0 or null - show only MRP (not crossed)
                                      if (numPrice == 0 && numMrp > 0) {
                                        return AppText(
                                          text: "₹ ${numMrp.toString()}",
                                          color: homeAppBarColor,
                                          maxLines: 1,
                                          fontSize: 11,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w400,
                                        );
                                      }

                                      // ✅ Case 2: Both exist and price < mrp - show both
                                      if (numPrice > 0 &&
                                          numMrp > 0 &&
                                          numPrice < numMrp) {
                                        return Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5.sp),
                                              child: Text(
                                                "₹ $numMrp",
                                                style: TextStyle(
                                                  color: searchTextColor,
                                                  fontSize: 11.sp,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            AppText(
                                              text: "₹ ${numPrice.toString()}",
                                              color: homeAppBarColor,
                                              maxLines: 1,
                                              fontSize: 11,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        );
                                      }

                                      // ✅ Case 3: Only price exists - show price
                                      if (numPrice > 0) {
                                        return AppText(
                                          text: "₹ ${numPrice.toString()}",
                                          color: homeAppBarColor,
                                          maxLines: 1,
                                          fontSize: 11,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w400,
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
                                    fontFamily: "Franklin Gothic",
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
                                    fontFamily: "Franklin Gothic Regular",
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
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                        fontFamily: "Franklin Gothic Regular",
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
                        fontFamily: "Franklin Gothic",
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Filter Bottom Sheet
  Future<void> _showFilterBottomSheet(BuildContext context) async {
    String selectedFilter = "Brand";

    List<String> selectedBrands = [];
    RangeValues priceRange = RangeValues(
      double.parse(_appliedMinPrice),
      double.parse(_appliedMaxPrice),
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
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w700,
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
                                      : selectedFilter == "Super Category"
                                          ? _buildCategoryDropdown(
                                              "Super Category",
                                              selectedSuperCatId,
                                              [
                                                {"id": 1, "name": "Men"},
                                                {"id": 2, "name": "Women"},
                                                {"id": 3, "name": "Accessories"},
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
                                                    {"id": 1, "name": "Topwear"},
                                                    {"id": 2, "name": "Bottomwear"},
                                                    {"id": 3, "name": "Footwear"},
                                                    {"id": 4, "name": "Ethnic Wear"},
                                                    {"id": 5, "name": "Western Wear"},
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
                                                        {"id": 1, "name": "T-Shirts"},
                                                        {"id": 2, "name": "Shirts"},
                                                        {"id": 3, "name": "Jeans"},
                                                        {"id": 4, "name": "Trousers"},
                                                        {"id": 5, "name": "Shoes"},
                                                        {"id": 6, "name": "Sneakers"},
                                                      ],
                                                      (val) => setModalState(() {
                                                        selectedSubCatId = val;
                                                      }),
                                                    )
                                                  : _collections.isEmpty
                                                      ? const Center(
                                                          child: Padding(
                                                            padding: EdgeInsets.all(20.0),
                                                            child: Text(
                                                              "No collections available",
                                                              style: TextStyle(
                                                                fontFamily: "Franklin Gothic Regular",
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : _buildCategoryDropdown(
                                                          "Collection",
                                                          selectedCollectionId,
                                                          _collections,
                                                          (val) {
                                                            setModalState(() {
                                                              selectedCollectionId = val;
                                                              if (val != null) {
                                                                final collectionName = _collections
                                                                    .firstWhere((c) => c['id'] == val, orElse: () => {'name': 'Unknown'})['name'];
                                                                print("🎯 Collection selected in dropdown: ID=$val, Name=$collectionName");
                                                              } else {
                                                                print("🎯 Collection cleared in dropdown");
                                                              }
                                                            });
                                                          },
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
                              print("  Super Category ID: $selectedSuperCatId");
                              print("  Category ID: $selectedCatId");
                              print("  Sub Category ID: $selectedSubCatId");
                              print("  Collection ID: $selectedCollectionId");

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
                                if (selectedSuperCatId != null) {
                                  filterParts.add("Super Cat");
                                }
                                if (selectedCatId != null) {
                                  filterParts.add("Cat");
                                }
                                if (selectedSubCatId != null) {
                                  filterParts.add("Sub Cat");
                                }
                                if (selectedCollectionId != null) {
                                  filterParts.add("Collection");
                                }
                                getSnackBar("Filtered by ${filterParts.join(', ')}");
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
