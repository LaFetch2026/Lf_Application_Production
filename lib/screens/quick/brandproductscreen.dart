// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';
import '../../common/widget/lists/dummy_grid_black.dart';
import '../../common/widget/other/chip_shimmer_row.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/other/filter_chips_row.dart';
import '../../common/widget/other/pounce_wrapper.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/brand_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/constant/constants.dart';
import '../cartscreen.dart';
import '../catalog/productlist/pdp_v2/product_details_screen_v2.dart';
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
  final catalogController = Get.put(CatalogController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Local UI state
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool isBottomSheet = false;

  // Filter/Sort state (API-based)
  List<String> _appliedColors = [];
  List<String> _appliedSizes = [];
  String _appliedMinPrice = "300";
  String _appliedMaxPrice = "100000";
  String _appliedSortOption = "recommended";
  bool _hasActiveFilters = false;
  bool _isFilterMetadataLoaded = false;
  bool _isProductsLoaded = false;
  int _currentPage = 1;
  bool _hasMoreProducts = true;

  // Local filters/sorts (client-side) - kept for search functionality
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

    // Fetch products via API with brandId filter
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load filter metadata for filter options
      await _loadFilterMetadata();

      // Fetch products from API with brandId as primary filter
      await _fetchBrandProducts();

      cartController.getCartData();
      _isProductsLoaded = true;
      setState(() {});
    });
  }

  // Load filter metadata (colors, sizes) for this brand
  Future<void> _loadFilterMetadata() async {
    if (_isFilterMetadataLoaded) return;

    // 🔹 Resolve superCatId from gender
    final g = widget.genderName.trim().toLowerCase();
    int superCatId = 0;

    if (g == 'men') {
      superCatId = 1;
    } else if (g == 'women') {
      superCatId = 2;
    }

    await productController.getFilterMetadata(
      superCatId: superCatId,
      catId: null,
      subCatId: null,
      collectionId: null,
      brandId: widget.brand_id > 0 ? widget.brand_id : null,
    );

    _isFilterMetadataLoaded = true;
  }

  // Fetch brand products via API
  Future<void> _fetchBrandProducts({bool append = false}) async {
    if (!append) {
      _currentPage = 1;
      catalogController.categoryProductList.clear();
    }

    await catalogController.getFilterAndSortProducts(
      brandId: widget.brand_id,
      colors: _appliedColors.isNotEmpty ? _appliedColors : null,
      sizes: _appliedSizes.isNotEmpty ? _appliedSizes : null,
      minPrice: _appliedMinPrice,
      maxPrice: _appliedMaxPrice,
      sortOption:
          _appliedSortOption != "recommended" ? _appliedSortOption : null,
      page: _currentPage,
      limit: 20,
      appendResults: append,
    );

    // Check if there are more products
    _hasMoreProducts =
        catalogController.categoryProductList.length >= _currentPage * 20;
  }

  // Apply filters and sort
  Future<void> _applyFiltersAndSort() async {
    setState(() {
      _currentPage = 1;
    });
    await _fetchBrandProducts();
    setState(() {});
  }

  // Sort Bottom Sheet (Dark Theme)
  Future<void> _showSortBottomSheet(BuildContext context) async {
    String selectedOption = _appliedSortOption;

    final Map<String, String> sortOptions = {
      "recommended": "Recommended",
      "price_asc": "Price - low to high",
      "price_desc": "Price - high to low",
      "whats_new": "What's new",
    };

    setState(() => isBottomSheet = true);

    await showModalBottomSheet(
      context: context,
      backgroundColor: homeAppBarColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 340.sp,
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SORT BY",
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16.sp,
                          fontFamily: "Clash Display Semibold",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: EdgeInsets.all(8.sp),
                          child:
                              Icon(Icons.close, color: whiteColor, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  Expanded(
                    child: ListView(
                      children: sortOptions.entries.map((entry) {
                        return RadioListTile<String>(
                          value: entry.key,
                          groupValue: selectedOption,
                          activeColor: whiteColor,
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return whiteColor;
                            }
                            return searchTextColor;
                          }),
                          title: Text(
                            entry.value,
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontFamily: "Clash Display Regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              selectedOption = value ?? "recommended";
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: whiteColor, width: 1),
                            padding: EdgeInsets.symmetric(vertical: 12.sp),
                          ),
                          child: Text(
                            "CLOSE",
                            style: TextStyle(
                              color: whiteColor,
                              fontFamily: "Clash Display Semibold",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            setState(() {
                              _appliedSortOption = selectedOption;
                            });
                            _applyFiltersAndSort();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: whiteColor,
                            padding: EdgeInsets.symmetric(vertical: 12.sp),
                          ),
                          child: Text(
                            "APPLY",
                            style: TextStyle(
                              color: homeAppBarColor,
                              fontFamily: "Clash Display Semibold",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
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
      },
    ).whenComplete(() => setState(() => isBottomSheet = false));
  }

  // Filter Bottom Sheet (Dark Theme)
  Future<void> _showFilterBottomSheet(BuildContext context) async {
    String selectedFilter = "Price Range";

    List<String> selectedColors = List.from(_appliedColors);
    List<String> selectedSizes = List.from(_appliedSizes);
    RangeValues priceRange = RangeValues(
      double.parse(_appliedMinPrice),
      double.parse(_appliedMaxPrice),
    );

    final List<String> filterCategories = ["Price Range", "Color", "Size"];

    // Ensure filter metadata is loaded
    if (!_isFilterMetadataLoaded) {
      await _loadFilterMetadata();
    }

    final colors = productController.filterColors.toList();
    final sizes = productController.filterSizes.toList();

    setState(() => isBottomSheet = true);

    await showModalBottomSheet(
      context: context,
      backgroundColor: homeAppBarColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SizedBox(
                height: Get.height * 0.7,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 16.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FILTERS",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16.sp,
                              fontFamily: "Clash Display Semibold",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedColors.clear();
                                selectedSizes.clear();
                                priceRange = const RangeValues(300, 100000);
                              });
                            },
                            child: Text(
                              "CLEAR ALL",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 13,
                                fontFamily: "Clash Display Semibold",
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: titleColor),
                    Expanded(
                      child: Row(
                        children: [
                          // Left sidebar - filter categories
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
                                        ? homeAppBarColor
                                        : const Color(0xff1b1b20),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.sp, vertical: 14.sp),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        color: selected
                                            ? whiteColor
                                            : searchTextColor,
                                        fontFamily: selected
                                            ? "Clash Display Semibold"
                                            : "Clash Display Regular",
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Right content area
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp, vertical: 10.sp),
                              child: _buildFilterContent(
                                selectedFilter,
                                colors,
                                sizes,
                                selectedColors,
                                selectedSizes,
                                priceRange,
                                setModalState,
                                (newRange) => priceRange = newRange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: whiteColor, width: 1),
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                              ),
                              child: Text(
                                "CLOSE",
                                style: TextStyle(
                                  color: whiteColor,
                                  fontFamily: "Clash Display Semibold",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();

                                setState(() {
                                  _appliedColors = List.from(selectedColors);
                                  _appliedSizes = List.from(selectedSizes);
                                  _appliedMinPrice =
                                      priceRange.start.toInt().toString();
                                  _appliedMaxPrice =
                                      priceRange.end.toInt().toString();
                                  _hasActiveFilters =
                                      selectedColors.isNotEmpty ||
                                          selectedSizes.isNotEmpty ||
                                          priceRange.start > 300 ||
                                          priceRange.end < 100000;
                                });

                                _applyFiltersAndSort();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: whiteColor,
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                              ),
                              child: Text(
                                "APPLY",
                                style: TextStyle(
                                  color: homeAppBarColor,
                                  fontFamily: "Clash Display Semibold",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => setState(() => isBottomSheet = false));
  }

  // Build filter content based on selected filter category
  Widget _buildFilterContent(
    String selectedFilter,
    List<String> colors,
    List<String> sizes,
    List<String> selectedColors,
    List<String> selectedSizes,
    RangeValues priceRange,
    StateSetter setModalState,
    Function(RangeValues) onPriceChanged,
  ) {
    if (selectedFilter == "Price Range") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select price range",
            style: TextStyle(
              color: whiteColor,
              fontFamily: "Clash Display Semibold",
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 20.sp),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: whiteColor,
              inactiveTrackColor: searchTextColor,
              thumbColor: whiteColor,
              overlayColor: whiteColor.withOpacity(0.2),
            ),
            child: RangeSlider(
              values: priceRange,
              min: 300,
              max: 100000,
              divisions: 100,
              onChanged: (v) {
                setModalState(() {
                  onPriceChanged(v);
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${priceRange.start.toInt()}",
                style: TextStyle(
                  color: searchTextColor,
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "₹${priceRange.end.toInt()}",
                style: TextStyle(
                  color: searchTextColor,
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (selectedFilter == "Color") {
      if (colors.isEmpty) {
        return Center(
          child: Text(
            "No colors available",
            style: TextStyle(
              color: searchTextColor,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
      return ListView.builder(
        itemCount: colors.length,
        itemBuilder: (context, i) {
          final color = colors[i];
          final checked = selectedColors.contains(color);
          return CheckboxListTile(
            value: checked,
            activeColor: whiteColor,
            checkColor: homeAppBarColor,
            side: BorderSide(color: searchTextColor),
            onChanged: (val) {
              setModalState(() {
                if (val == true) {
                  selectedColors.add(color);
                } else {
                  selectedColors.remove(color);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              color.toUpperCase(),
              style: TextStyle(
                color: whiteColor,
                fontSize: 14.sp,
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      );
    } else if (selectedFilter == "Size") {
      if (sizes.isEmpty) {
        return Center(
          child: Text(
            "No sizes available",
            style: TextStyle(
              color: searchTextColor,
              fontFamily: "Clash Display Regular",
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
      return ListView.builder(
        itemCount: sizes.length,
        itemBuilder: (context, i) {
          final size = sizes[i];
          final checked = selectedSizes.contains(size);
          return CheckboxListTile(
            value: checked,
            activeColor: whiteColor,
            checkColor: homeAppBarColor,
            side: BorderSide(color: searchTextColor),
            onChanged: (val) {
              setModalState(() {
                if (val == true) {
                  selectedSizes.add(size);
                } else {
                  selectedSizes.remove(size);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              size.toUpperCase(),
              style: TextStyle(
                color: whiteColor,
                fontSize: 14.sp,
                fontFamily: "Clash Display Regular",
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    catalogController.clearChipSelection();
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

  void _onSearchChanged(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {}); // local filter only
    });
  }

  // ---------- derive visible list from API or local data ----------
  List<Map<String, dynamic>> _visibleProducts() {
    // Use API filtered results if available
    if (catalogController.categoryProductList.isNotEmpty) {
      List<Map<String, dynamic>> out = catalogController.categoryProductList
          .whereType<Map<String, dynamic>>()
          .toList();

      // Apply local search filter on top of API results
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        out = out.where((m) => _prodName(m).toLowerCase().contains(q)).toList();
      }

      return out;
    }

    // Fallback to local data from brandDetails (initial load)
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
      DateTime dt(Map<String, dynamic> m) {
        final s = (m['updatedAt'] ?? m['createdAt'] ?? '').toString();
        return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }

      out.sort((a, b) => dt(b).compareTo(dt(a)));
    }

    return out;
  }

  // Get sort option label for display
  String _getSortLabel(String option) {
    switch (option) {
      case "price_asc":
        return "LOW TO HIGH";
      case "price_desc":
        return "HIGH TO LOW";
      case "whats_new":
        return "NEWEST";
      default:
        return "";
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final isLoading = brandController.isDetails.value ||
        catalogController.isCategory.value ||
        catalogController.isSorting.value;

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
                  left: 16.sp, top: 12.sp, right: 16.sp, bottom: 16.sp),
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

            // Chip row
            Obx(() {
              if (catalogController.isCategory.value) {
                return const ChipShimmerRow();
              }
              return FilterChipsRow(
                chips: catalogController.chips.toList(),
                selectedChips: catalogController.selectedChips.toList(),
                selectedChipIds: catalogController.selectedChipIds,
                onChipTap: catalogController.onChipTap,
              );
            }),
            const SizedBox(height: 8),

            // Body
            Expanded(
              child: Obx(() {
                // ✅ Watch categoryProductList for reactivity (triggers rebuild when filters applied)
                final _ = catalogController.categoryProductList.length;

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
                            fit: BoxFit.cover,
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
                    child: MasonryGridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8.sp,
                      mainAxisSpacing: 8.sp,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final m = items[index];
                        final pid = _prodId(m);
                        final name = _prodName(m);
                        final price = _prodPrice(m);
                        final mrp = _prodMrp(m);
                        final img = _firstImageUrl(m);
                        final basePrice = m["basePrice"];

                        return PounceWrapper(
                          onTap: () async {
                            // Fetch PDP data first
                            Get.dialog(
                              const Center(child: LfLogoLoader(size: 54)),
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
                              ProductDetailsScreenV2(
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
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.sp),
                                color: const Color.fromARGB(255, 47, 47, 47)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
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
                                                  6.sp,
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) -
                                                  24.sp,
                                              child: CachedNetworkImage(
                                                cacheManager: CacheManager(
                                                  Config(
                                                    "brandGridCache",
                                                    stalePeriod: const Duration(
                                                        days: 15),
                                                    maxNrOfCacheObjects: 100,
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                                imageUrl: img,
                                                errorWidget: (_, __, ___) =>
                                                    Image.asset(
                                                  downloadImage,
                                                  fit: BoxFit.cover,
                                                  height:
                                                      (MediaQuery.of(context)
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
                                            fit: BoxFit.cover,
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        /// ✅ MRP (only if valid & greater)
                                        if (mrp != null &&
                                            mrp > 0 &&
                                            mrp > basePrice)
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 6.sp),
                                            child: Text(
                                              "₹${mrp.toStringAsFixed(0)}",
                                              style: TextStyle(
                                                color: searchTextColor,
                                                fontSize: 11.sp,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    "Clash Display Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),

                                        /// ✅ SELLING PRICE (always)
                                        AppText(
                                          text:
                                              "₹${basePrice.toStringAsFixed(0)}",
                                          color: whiteColor,
                                          maxLines: 1,
                                          fontSize: 11,
                                          fontFamily: "Clash Display",
                                          fontWeight: FontWeight.w500,
                                        ),

                                        /// ✅ OFF %
                                        if (mrp != null &&
                                            mrp > 0 &&
                                            mrp > basePrice)
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 6.sp),
                                            child: Text(
                                              "${(((mrp - basePrice) / mrp) * 100).round()}% OFF",
                                              style: TextStyle(
                                                fontSize: 9.sp,
                                                fontFamily: "Clash Display",
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    lightPurpleColor, // 🔥 purple OFF
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),

            // Bottom bar (sort/filter)
            Container(height: 1.sp, width: double.infinity, color: titleColor),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // SORT BY
                  InkWell(
                    onTap: () => _showSortBottomSheet(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.sp, horizontal: 5.sp),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            sortBySvgImage,
                            color: whiteColor,
                            height: 19.sp,
                            width: 15.sp,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.sp),
                            child: Column(
                              children: [
                                Text(
                                  "SORT BY",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 13.sp,
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_appliedSortOption != "recommended")
                                  Text(
                                    _getSortLabel(_appliedSortOption),
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: lightgreyColor,
                                      fontFamily: "Clash Display Regular",
                                      fontWeight: FontWeight.w400,
                                      color: lightgreyColor,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(width: 1.sp, color: titleColor, height: 46.sp),

                  // FILTERS
                  InkWell(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.sp, horizontal: 5.sp),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            filterSvgImage,
                            color: whiteColor,
                            height: 11.sp,
                            width: 17.sp,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.sp),
                            child: Column(
                              children: [
                                Text(
                                  "FILTERS",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 13.sp,
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_hasActiveFilters)
                                  Text(
                                    "ACTIVE",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: lightPurpleColor,
                                      fontFamily: "Clash Display Regular",
                                      fontWeight: FontWeight.w400,
                                      color: lightPurpleColor,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1.sp, width: double.infinity, color: titleColor),
            // Safe area padding for devices with navigation bar
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
