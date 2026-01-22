// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:lafetch/controllers/home_controller.dart';
import 'package:lafetch/controllers/catalog_controller.dart';
import 'package:lafetch/controllers/search_controller.dart';

import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/home_appbar.dart';
import '../../common/widget/lists/dummy_catalog_list.dart';
import '../../common/widget/text/app_text.dart';
import '../../core/constant/constants.dart';

class WomenCatalogScreen extends StatefulWidget {
  const WomenCatalogScreen({super.key});

  @override
  State<WomenCatalogScreen> createState() => _WomenCatalogScreenState();
}

class _WomenCatalogScreenState extends State<WomenCatalogScreen>
    with TickerProviderStateMixin {
  final CatalogController catalogController = Get.put(CatalogController());
  final SearchScreenController searchController =
      Get.put(SearchScreenController());
  final HomeController homeController = Get.find<HomeController>();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  TabController? _genderTabController;

  @override
  void initState() {
    super.initState();

    final int gender = homeController.homeGenderValue.value;

    catalogController.selectCategoryGender.value = gender;
    catalogController.categoryName.value = gender == 1
        ? 'Men'
        : gender == 2
            ? 'Women'
            : 'Accessories';

    catalogController.getCatalogData(gender);

    // Initialize TabController after genderTabs are loaded
    _initGenderTabController();
  }

  void _initGenderTabController() {
    if (homeController.genderTabs.isNotEmpty) {
      // Find initial index based on current gender value
      int initialIndex = 0;
      for (int i = 0; i < homeController.genderTabs.length; i++) {
        final tab = homeController.genderTabs[i];
        final int tabGenderId = tab['id'] is int
            ? tab['id']
            : int.tryParse(tab['id']?.toString() ?? '0') ?? 0;
        if (tabGenderId == homeController.homeGenderValue.value) {
          initialIndex = i;
          break;
        }
      }

      _genderTabController?.dispose();
      _genderTabController = TabController(
        length: homeController.genderTabs.length,
        vsync: this,
        initialIndex: initialIndex.clamp(0, homeController.genderTabs.length - 1),
      );
      _genderTabController!.addListener(_onGenderTabChanged);
      setState(() {});
    } else {
      // If genderTabs not loaded yet, listen for changes
      ever(homeController.genderTabs, (_) {
        if (homeController.genderTabs.isNotEmpty && _genderTabController == null) {
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
    homeController.homeGenderValue.value = genderId;
    homeController.genderText.value = genderName;

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

  @override
  void dispose() {
    _genderTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          preferredSize: const Size.fromHeight(56),
          child: HomeAppbar(
            showSearch: true,
            title: 'Categories',
            onPressedSearch: () {
              Get.to(() => const SearchScreen())?.then((_) {
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
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

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 16.sp),
                      itemCount: catalogController.catalogList.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 24.sp,
                        color: const Color.fromARGB(255, 255, 252, 252),
                      ),
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
                            (item['name'] ?? item['title'] ?? '').toString();

                        return InkWell(
                          onTap: () async {
                            await catalogController.getCategoryProductData(
                              categoryId,
                              homeController.homeGenderValue.value,
                            );

                            Get.to(
                              () => CategoryProductScreen(
                                categoryName: categoryName,
                                screen: 'category',
                                genderName: homeController.genderText.value,
                                categoryId: categoryId,
                                brandId: 0,
                                genderType: homeController.homeGenderValue.value,
                                categoryList: const [],
                                tagIds: const [],
                                title: '',
                              ),
                            );

                            await analytics.logEvent(
                              name: 'categories_home_page',
                              parameters: {'page_name': 'categories_home_page'},
                            );
                          },
                          child: Row(
                            children: [
                              /// Category Name
                              Expanded(
                                child: AppText(
                                  text: categoryName.toUpperCase(),
                                  fontFamily: 'Clash Display Regular',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),

                              /// Category Image (Soft + Clean)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: (item['image'] ?? '').toString(),
                                  width: 90.sp,
                                  height: 100.sp,
                                  fit: BoxFit.fill,
                                  color: const Color.fromARGB(255, 160, 159, 159)
                                      .withOpacity(0.15),
                                  colorBlendMode: BlendMode.darken,
                                  placeholder: (_, __) => Container(
                                    width: 90.sp,
                                    height: 90.sp,
                                    color: Colors.grey.shade200,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 90.sp,
                                    height: 90.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.category_outlined,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
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
