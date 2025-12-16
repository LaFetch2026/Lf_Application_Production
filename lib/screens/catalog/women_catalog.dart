// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/controllers/home_controller.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/home_appbar.dart';
import '../../common/widget/lists/dummy_catalog_list.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/search_controller.dart';
import '../../core/constant/constants.dart';

class WomenCatalogScreen extends StatefulWidget {
  const WomenCatalogScreen({super.key});

  @override
  State<WomenCatalogScreen> createState() => WomenCatalogScreenState();
}

class WomenCatalogScreenState extends State<WomenCatalogScreen> {
  final CatalogController catalogController = Get.put(CatalogController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final SearchScreenController searchController =
      Get.put(SearchScreenController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();

    final g = homeController.homeGenderValue.value;
    catalogController.selectCategoryGender.value = g;
    catalogController.categoryName.value = g == 1
        ? 'Men'
        : g == 2
            ? 'Women'
            : 'Accessories';

    catalogController.getCatalogData(g);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const BottomNavScreen(index: 0));
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,

        // ✅ Put the custom app bar in Scaffold.appBar to avoid Column overflow
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: HomeAppbar(
            showSearch: true,
            title: 'Categories',
            onPressedSearch: () async {
              Get.to(() => const SearchScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ),
                );
              });
            },
            onPressedHeart: () async {
              Get.to(() => const WishlistScreen())?.then((_) {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: whiteColor,
                    systemNavigationBarColor: whiteColor,
                  ),
                );
              });
            },
            onPressedCart: () async {
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

        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs
              Obx(
                () => SizedBox(
                  height: 40.sp,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildCategoryTab('MEN', 1),
                      buildCategoryTab('WOMEN', 2),
                      buildCategoryTab('ACCESSORIES', 3),
                    ],
                  ),
                ),
              ),
              Divider(height: 2.sp, color: lightgreyColor),

              // Subtitle
              Padding(
                padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
                child: const AppText(
                  text: 'Explore our entire collection',
                  fontFamily: 'Franklin Gothic Regular',
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  fontSize: 22,
                ),
              ),
              Obx(
                () => Padding(
                  padding: EdgeInsets.only(top: 10.sp, left: 16.sp),
                  child: AppText(
                    text: 'For ${catalogController.categoryName.value}',
                    fontSize: 14,
                    fontFamily: 'Franklin Gothic Regular',
                    color: textHintColor,
                  ),
                ),
              ),

              // Body
              Expanded(
                child: Obx(() {
                  if (catalogController.isCatalog.value) {
                    return const DummyCatalogList();
                  }
                  if (catalogController.catalogList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100.sp),
                        child: Text(
                          'No Categories Found',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontFamily: 'Franklin Gothic Regular',
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.sp, horizontal: 16.sp),
                    itemCount: catalogController.catalogList.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> item =
                          catalogController.catalogList[index];

                      final int categoryId = item['id'] is int
                          ? item['id'] as int
                          : int.tryParse(
                                  '${item['id'] ?? item['catId'] ?? item['categoryId']}') ??
                              0;
                      final String categoryName =
                          (item['name'] ?? item['title'] ?? '').toString();

                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.sp),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              // (Optional) prefetch to warm caches
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
                                  genderType:
                                      homeController.homeGenderValue.value,
                                  categoryList: const [],
                                  tagIds: const [],
                                  title: '',
                                ),
                              )?.then((_) {
                                SystemChrome.setSystemUIOverlayStyle(
                                  const SystemUiOverlayStyle(
                                    statusBarColor: whiteColor,
                                    systemNavigationBarColor: whiteColor,
                                  ),
                                );
                              });

                              await analytics.logEvent(
                                name: 'categories_home_page',
                                parameters: {
                                  'page_name': 'categories_home_page'
                                },
                              );
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F6F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 18.sp, horizontal: 14.sp),
                                      child: AppText(
                                        text: categoryName.toUpperCase(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        fontFamily: 'Franklin Gothic Demi',
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          (item['image'] ?? '').toString(),
                                      height: 100.sp,
                                      width: 100.sp,
                                      fit: BoxFit.cover,
                                      cacheManager: CacheManager(
                                        Config(
                                          'customCacheKey',
                                          stalePeriod: Duration(days: 15),
                                          maxNrOfCacheObjects: 100,
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryTab(String label, int genderId) {
    final isSelected = catalogController.selectCategoryGender.value == genderId;
    return InkWell(
      onTap: () async {
        catalogController.selectCategoryGender.value = genderId;
        catalogController.categoryName.value =
            label[0] + label.substring(1).toLowerCase();
        catalogController.getCatalogData(genderId);

        await analytics.logEvent(
          name: 'category_${label.toLowerCase()}',
          parameters: {'page_name': 'category_${label.toLowerCase()}'},
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppText(
            text: label,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily:
                isSelected ? 'Franklin Gothic Semibold' : 'Franklin Gothic',
            color: isSelected ? homeAppBarColor : searchTextColor,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.sp),
            child: Container(
              height: 2.sp,
              width: 100.sp,
              color: isSelected ? homeAppBarColor : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
