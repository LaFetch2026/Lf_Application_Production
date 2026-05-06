// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import 'package:lafetch/controllers/home_controller.dart';
import 'package:lafetch/controllers/catalog_controller.dart';
import 'package:lafetch/controllers/search_controller.dart';
import 'package:lafetch/common/widget/other/haptic_helper.dart';
import 'package:lafetch/common/widget/other/common_widget.dart';

import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/home_appbar.dart';
import '../../common/widget/lists/dummy_catalog_list.dart';
import '../../common/widget/text/app_text.dart';
import '../../core/constant/constants.dart';
import 'package:lafetch/common/widget/other/lf_loader_widget.dart';

class WomenCatalogScreen extends StatefulWidget {
  const WomenCatalogScreen({super.key});

  @override
  State<WomenCatalogScreen> createState() => _WomenCatalogScreenState();
}

class _WomenCatalogScreenState extends State<WomenCatalogScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final CatalogController catalogController = Get.put(CatalogController());
  final SearchScreenController searchController =
      Get.put(SearchScreenController());
  final HomeController homeController = Get.find<HomeController>();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  TabController? _genderTabController;
  static bool _isInitialized = false; // Static to persist across rebuilds
  bool _isRefreshing = false;
  double _pullOffset = 0;

  // Keep screen alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // ✅ On first init, seed catalog gender from the first available tab (default Men).
    // We deliberately do NOT read homeController.homeGenderValue here so that
    // the catalog tab and the home tab remain fully independent.
    if (!_isInitialized) {
      final int defaultGender = homeController.genderTabs.isNotEmpty
          ? (homeController.genderTabs.first['id'] is int
              ? homeController.genderTabs.first['id'] as int
              : int.tryParse(
                      homeController.genderTabs.first['id']?.toString() ?? '') ??
                  1)
          : 1;
      catalogController.selectCategoryGender.value = defaultGender;
      catalogController.categoryName.value = homeController.genderTabs.isNotEmpty
          ? homeController.genderTabs.first['name']?.toString() ?? 'Men'
          : 'Men';
    }

    // Initialize TabController (always runs to prevent null errors)
    _initGenderTabController();

    // Only fetch data if not already loaded
    if (!_isInitialized || catalogController.catalogList.isEmpty) {
      catalogController.getCatalogData(catalogController.selectCategoryGender.value);
      _isInitialized = true;
    } else {
      print("✅ WomenCatalogScreen already initialized, skipping API call");
    }
  }

  void _initGenderTabController() {
    if (homeController.genderTabs.isNotEmpty) {
      // ✅ Find initial index based on catalog's OWN gender value, not home's
      int initialIndex = 0;
      for (int i = 0; i < homeController.genderTabs.length; i++) {
        final tab = homeController.genderTabs[i];
        final int tabGenderId = tab['id'] is int
            ? tab['id']
            : int.tryParse(tab['id']?.toString() ?? '0') ?? 0;
        if (tabGenderId == catalogController.selectCategoryGender.value) {
          initialIndex = i;
          break;
        }
      }

      _genderTabController?.dispose();
      _genderTabController = TabController(
        length: homeController.genderTabs.length,
        vsync: this,
        initialIndex:
            initialIndex.clamp(0, homeController.genderTabs.length - 1),
      );
      _genderTabController!.addListener(_onGenderTabChanged);
      setState(() {});
    } else {
      // If genderTabs not loaded yet, listen for changes
      ever(homeController.genderTabs, (_) {
        if (homeController.genderTabs.isNotEmpty &&
            _genderTabController == null) {
          _initGenderTabController();
        }
      });
    }
  }

  void _onGenderTabChanged() {
    if (_genderTabController == null || _genderTabController!.indexIsChanging) {
      return;
    }

    final int index = _genderTabController!.index;
    if (index < 0 || index >= homeController.genderTabs.length) return;

    final tab = homeController.genderTabs[index];
    final int genderId = tab['id'] is int
        ? tab['id']
        : int.tryParse(tab['id']?.toString() ?? '0') ?? 0;
    final String genderName = tab['name']?.toString() ?? '';

    catalogController.selectCategoryGender.value = genderId;
    catalogController.categoryName.value = genderName;

    catalogController.getCatalogData(genderId);

    analytics.logEvent(
      name: 'category_${genderName.toLowerCase()}',
      parameters: {'page_name': 'category_${genderName.toLowerCase()}'},
    );
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    if (_genderTabController == null) return;

    const double sensitivity = 300;
    final velocity = details.primaryVelocity ?? 0;

    if (velocity > sensitivity) {
      // Swipe Right -> Previous tab
      if (_genderTabController!.index > 0) {
        _genderTabController!.animateTo(_genderTabController!.index - 1);
      }
    } else if (velocity < -sensitivity) {
      // Swipe Left -> Next tab
      if (_genderTabController!.index < _genderTabController!.length - 1) {
        _genderTabController!.animateTo(_genderTabController!.index + 1);
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      Haptic.light();
      await catalogController.getCatalogData(
        catalogController.selectCategoryGender.value,
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  void dispose() {
    _genderTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAll(() => const BottomNavScreen(index: 0));
        }
      },
      child: Scaffold(
        backgroundColor: whiteColor,

        /// AppBar
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.sp),
          child: HomeAppbar(
            showSearch: true,
            title: 'Categories',
            onPressedSearch: () {
              Get.to(() => const SearchScreen(), preventDuplicates: true)?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ),
                );
              });
            },
            onPressedHeart: () {
              Get.to(() => const WishlistScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ),
                );
              });
            },
            onPressedCart: () {
              Get.to(() => CartScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ),
                );
              });
            },
          ),
        ),

        /// Body
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Gender Tabs with animated indicator
              Obx(
                () => homeController.genderTabs.isEmpty ||
                        _genderTabController == null
                    ? SizedBox(
                        height: 42.sp,
                        child: const Center(
                          child: LfLogoLoader(size: 20, showGlow: false),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 42.sp,
                        child: TabBar(
                          controller: _genderTabController,
                          isScrollable: false,
                          indicatorColor: homeAppBarColor,
                          indicatorWeight: 2.sp,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: homeAppBarColor,
                          unselectedLabelColor: searchTextColor,
                          dividerColor: Colors.transparent,
                          labelStyle: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: "Clash Display Semibold",
                            fontWeight: FontWeight.w500,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: "Clash Display",
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: homeController.genderTabs.map((tab) {
                            final String genderName =
                                tab['name']?.toString() ?? '';
                            return Tab(
                              text: genderName.toUpperCase(),
                            );
                          }).toList(),
                        ),
                      ),
              ),

              Divider(height: 1, color: lightgreyColor),

              /// Title
              Padding(
                padding: EdgeInsets.only(top: 20.sp, left: 16.sp),
                child: const AppText(
                  text: 'Explore our entire collection',
                  fontFamily: 'Clash Display Regular',
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  fontSize: 22,
                ),
              ),

              /// Subtitle
              Obx(
                () => Padding(
                  padding: EdgeInsets.only(top: 8.sp, left: 16.sp),
                  child: AppText(
                    text: 'For ${catalogController.categoryName.value}',
                    fontSize: 14,
                    fontFamily: 'Clash Display Regular',
                    fontWeight: FontWeight.w400,
                    color: textHintColor,
                  ),
                ),
              ),

              /// Category List with swipe gesture
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: _onHorizontalSwipe,
                  behavior: HitTestBehavior.translucent,
                  child: Obx(() {
                    if (catalogController.isCatalog.value) {
                      return const DummyCatalogList();
                    }

                    if (catalogController.catalogList.isEmpty) {
                      return const Center(
                        child: AppText(
                          text: 'No Categories Found',
                          fontFamily: 'Clash Display Regular',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is OverscrollNotification &&
                            notification.overscroll < 0 &&
                            !_isRefreshing) {
                          final pull = (-notification.overscroll * 0.4).clamp(0.0, 80.0);
                          if (_pullOffset != pull) setState(() => _pullOffset = pull);
                        } else if ((notification is ScrollEndNotification ||
                            notification is UserScrollNotification) && !_isRefreshing) {
                          if (_pullOffset > 50) {
                            setState(() => _pullOffset = 0);
                            _onRefresh();
                          } else if (_pullOffset > 0) {
                            setState(() => _pullOffset = 0);
                          }
                        }
                        return false;
                      },
                      child: Stack(
                        children: [
                          AnimationLimiter(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.sp,
                            vertical: 16.sp,
                          ),
                          itemCount: catalogController.catalogList.length,
                          itemBuilder: (context, index) {
                            final item = catalogController.catalogList[index]
                                as Map<String, dynamic>;

                            final int categoryId = item['id'] is int
                                ? item['id']
                                : int.tryParse(
                                      '${item['id'] ?? item['catId'] ?? item['categoryId']}',
                                    ) ??
                                    0;

                            final String categoryName =
                                (item['name'] ?? item['title'] ?? '')
                                    .toString();

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 12.sp),
                                    decoration: BoxDecoration(
                                      color: whiteBack,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () async {
                                          Haptic.light();

                                          // ✅ Use sub-category-products API
                                          await catalogController
                                              .getSubCategoryProducts(
                                            categoryId,
                                          );

                                          if (!context.mounted) return;

                                          Navigator.push(
                                            context,
                                            scaleIn(
                                              CategoryProductScreen(
                                                categoryName: categoryName,
                                                screen: 'category',
                                                genderName: catalogController.categoryName.value,
                                                categoryId: categoryId,
                                                brandId: 0,
                                                genderType: catalogController.selectCategoryGender.value,
                                                categoryList: const [],
                                                collectionIds: const [],
                                                title: '',
                                              ),
                                            ),
                                          );

                                          analytics.logEvent(
                                            name: 'categories_home_page',
                                            parameters: {
                                              'page_name':
                                                  'categories_home_page'
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(12.sp),
                                          child: Row(
                                            children: [
                                              /// Category Name & Explore hint
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text: categoryName
                                                          .toUpperCase(),
                                                      fontFamily:
                                                          'Clash Display Semibold',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(height: 6.sp),
                                                    Row(
                                                      children: [
                                                        AppText(
                                                          text: 'Explore',
                                                          fontFamily:
                                                              'Clash Display Regular',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12,
                                                          color: textHintColor,
                                                        ),
                                                        SizedBox(width: 4.sp),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 10.sp,
                                                          color: textHintColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// Category Image (Enhanced)
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.08),
                                                      blurRadius: 6,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        (item['image'] ?? '')
                                                            .toString(),
                                                    width: 100.sp,
                                                    height: 110.sp,
                                                    fit: BoxFit.fill,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 200),
                                                    placeholder: (_, __) =>
                                                        Container(
                                                      width: 100.sp,
                                                      height: 110.sp,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    errorWidget: (_, __, ___) =>
                                                        Container(
                                                      width: 100.sp,
                                                      height: 110.sp,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.category_outlined,
                                                        size: 24,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _isRefreshing
                            ? 1.0
                            : (_pullOffset / 80.0).clamp(0.0, 1.0),
                        duration: const Duration(milliseconds: 150),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: _isRefreshing ? 8 : (_pullOffset - 40).clamp(0.0, 8.0)),
                            child: const LfLogoLoader(size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
