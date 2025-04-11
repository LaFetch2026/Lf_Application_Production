// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/commonwidget/catalogwidgets/dummy_catalog_list.dart';
import 'package:lafetch/controller/catalog_controller.dart';
import 'package:lafetch/controller/search_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/catalogdetails.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenCatalogScreen extends StatefulWidget {
  const WomenCatalogScreen({super.key});

  @override
  State<WomenCatalogScreen> createState() => WomenCatalogScreenState();
}

class WomenCatalogScreenState extends State<WomenCatalogScreen> {
  final controller = Get.put(CatalogController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final searchController = Get.put(SearchScreenController());

  @override
  void initState() {
    /*  WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCatalogData(2)); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(BottomNavScreen(
          index: 0,
        ));
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            HomeAppbar(
              showSearch: true,
              title: "Categories",
              onPressedSearch: () async {
                searchController.searchController.clear();
                Get.to(const SearchScreen())?.then((value) => setState(
                      () {
                        SystemChrome.setSystemUIOverlayStyle(
                            const SystemUiOverlayStyle(
                          statusBarColor: whiteColor,
                          systemNavigationBarColor: whiteColor,
                        ));
                      },
                    ));
                await analytics.logEvent(
                  name: 'search_page',
                  parameters: <String, Object>{
                    'page_name': 'search_page',
                  },
                );
              },
              onPressedHeart: () async {
                Get.to(const WishlistScreen())?.then(
                  (value) {
                    SystemChrome.setSystemUIOverlayStyle(
                        const SystemUiOverlayStyle(
                      statusBarColor: whiteColor,
                      systemNavigationBarColor: whiteColor,
                    ));
                  },
                );
                await analytics.logEvent(
                  name: 'wishlist_page',
                  parameters: <String, Object>{
                    'page_name': 'wishlist_page',
                  },
                );
              },
              onPressedCart: () async {
                Get.to(const CartScreen())?.then(
                  (value) {
                    SystemChrome.setSystemUIOverlayStyle(
                        const SystemUiOverlayStyle(
                      statusBarColor: whiteColor,
                      systemNavigationBarColor: whiteColor,
                    ));
                  },
                );
                await analytics.logEvent(
                  name: 'cart_page',
                  parameters: <String, Object>{
                    'page_name': 'cart_page',
                  },
                );
              },
            ),
            Obx(
              () => SizedBox(
                height: 40.sp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () async {
                        controller.selectCategoryGender.value = 2;
                        controller.categoryName.value = "Men";
                        controller.getCatagoryData(2);
                        await analytics.logEvent(
                          name: 'category_men',
                          parameters: <String, Object>{
                            'page_name': 'category_men',
                          },
                        );
                      },
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              text: "Men".toUpperCase(),
                              color: controller.selectCategoryGender.value == 2
                                  ? homeAppBarColor
                                  : searchTextColor,
                              fontSize: 13,
                              fontFamily:
                                  controller.selectCategoryGender.value == 2
                                      ? "Franklin Gothic Semibold"
                                      : "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.sp),
                              child: Container(
                                color:
                                    controller.selectCategoryGender.value == 2
                                        ? homeAppBarColor
                                        : Colors.transparent,
                                width: 110.sp,
                                height: 2.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        controller.selectCategoryGender.value = 3;
                        controller.categoryName.value = "Women";
                        controller.getCatagoryData(3);
                        await analytics.logEvent(
                          name: 'category_women',
                          parameters: <String, Object>{
                            'page_name': 'category_women',
                          },
                        );
                      },
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              text: "WOMEN".toUpperCase(),
                              color: controller.selectCategoryGender.value == 3
                                  ? homeAppBarColor
                                  : searchTextColor,
                              fontSize: 13,
                              fontFamily:
                                  controller.selectCategoryGender.value == 3
                                      ? "Franklin Gothic Semibold"
                                      : "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.sp),
                              child: Container(
                                color:
                                    controller.selectCategoryGender.value == 3
                                        ? homeAppBarColor
                                        : Colors.transparent,
                                width: 110.sp,
                                height: 2.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        controller.selectCategoryGender.value = 1;
                        controller.categoryName.value = "Accessories";
                        controller.getCatagoryData(1);
                        await analytics.logEvent(
                          name: 'category_accessories',
                          parameters: <String, Object>{
                            'page_name': 'category_accessories',
                          },
                        );
                      },
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              text: "Accessories".toUpperCase(),
                              color: controller.selectCategoryGender.value == 1
                                  ? homeAppBarColor
                                  : searchTextColor,
                              fontSize: 13,
                              fontFamily:
                                  controller.selectCategoryGender.value == 1
                                      ? "Franklin Gothic Semibold"
                                      : "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.sp),
                              child: Container(
                                color:
                                    controller.selectCategoryGender.value == 1
                                        ? homeAppBarColor
                                        : Colors.transparent,
                                width: 110.sp,
                                height: 2.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Container(
            //   width: double.infinity,
            //   color: lightgreyColor,
            //   height: 2.sp,
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
                      child: AppText(
                        text: "Explore our entire collection",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: appbarText,
                        fontSize: 22,
                      ),
                    ),
                    Obx(() => Padding(
                          padding:   EdgeInsets.symmetric(horizontal: 16.sp, vertical: 0.sp),
                          child: AppText(
                            text: "For ${controller.categoryName.value}",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: textHintColor,
                            fontSize: 14,
                          ),
                        )),
                    Obx(() => controller.isCatalogCategory.value
                        ? const DummyCatalogList()
                        : controller.catagoryList.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                  left: 16.sp,
                                  right: 16.sp,
                                  top: 10.sp,
                                ),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 300.sp,
                                  child: ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      itemCount: controller.catagoryList.length,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (ctx, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                                onTap: () async {
                                                  Get.to(CatalogDetailsScreen(
                                                    title:
                                                        controller.catagoryList[
                                                                index]["name"] ??
                                                            "",
                                                    catalogId: controller
                                                            .catagoryList[index]
                                                        ["id"],
                                                    catalogImage: controller
                                                                .catagoryList[
                                                            index]["thumbnail"] ??
                                                        "",
                                                    genderType: controller
                                                        .selectCategoryGender
                                                        .value,
                                                    catalogText: controller
                                                        .categoryName.value,
                                                  ))?.then(
                                                    (value) {
                                                      SystemChrome
                                                          .setSystemUIOverlayStyle(
                                                              const SystemUiOverlayStyle(
                                                        statusBarColor:
                                                            whiteColor,
                                                      ));
                                                    },
                                                  );
                                                  await analytics.logEvent(
                                                    name:
                                                        "category_page_${controller.categoryName.value}",
                                                    parameters: <String, Object>{
                                                      'page_name':
                                                          "category_page_${controller.categoryName.value}",
                                                    },
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10.sp),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 100.sp,
                                                    child: controller.catagoryList[
                                                                    index]
                                                                ["thumbnail"] !=
                                                            null
                                                        ? Stack(
                                                            children: [
                                                              SizedBox(
                                                                height: 100.sp,
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    CachedNetworkImage(
                                                                  cacheManager: CacheManager(Config(
                                                                      "customCacheKey",
                                                                      stalePeriod:
                                                                          const Duration(
                                                                              days:
                                                                                  15),
                                                                      maxNrOfCacheObjects:
                                                                          100)),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: controller
                                                                              .catagoryList[
                                                                          index][
                                                                      "thumbnail"],
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image.asset(
                                                                    downloadImage,
                                                                    height:
                                                                        100.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                              /*      Align(
                                                                alignment: Alignment
                                                                    .bottomCenter,
                                                                child: Container(
                                                                  height: 36.sp,
                                                                  decoration:
                                                                      new BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                            0, 0, 0, 0),
                                                                        Color.fromRGBO(
                                                                            0, 0, 0, 0.6),
                                                                      ],
                                                                      stops: [
                                                                        0.2527,
                                                                        0.8542
                                                                      ],
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment
                                                                          .bottomCenter,
                                                                    ),
                                                                  ),
                                                                  child: Padding(
                                                                    padding:
                                                                        EdgeInsets.only(
                                                                            left: 10.sp,
                                                                            right: 10.sp,
                                                                            bottom: 4.sp),
                                                                    child: Align(
                                                                      alignment: Alignment
                                                                          .bottomCenter,
                                                                      child: Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          AppText(
                                                                            text: controller
                                                                                        .catalogList[index]
                                                                                    [
                                                                                    "name"] ??
                                                                                "",
                                                                            color:
                                                                                whiteColor,
                                                                            fontSize: 14,
                                                                            fontFamily:
                                                                                "Franklin Gothic Regular",
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .w400,
                                                                          ),
                                                                          const Expanded(
                                                                            child:
                                                                                SizedBox(
                                                                              width: 0,
                                                                            ),
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap: () {
                                                                              Get.to(
                                                                                  CatalogDetailsScreen(
                                                                                title: controller.catalogList[index]
                                                                                        [
                                                                                        "name"] ??
                                                                                    "",
                                                                                catalogId:
                                                                                    controller.catalogList[index]
                                                                                        [
                                                                                        "id"],
                                                                                catalogImage:
                                                                                    controller.catalogList[index]["thumbnail"] ??
                                                                                        "",
                                                                                genderType:
                                                                                    widget
                                                                                        .type,
                                                                                catalogText:
                                                                                    widget
                                                                                        .categorytext,
                                                                              ));
                                                                            },
                                                                            child: Image.asset(
                                                                                rightArrowImage,
                                                                                height:
                                                                                    20.sp,
                                                                                width:
                                                                                    20.sp,
                                                                                color:
                                                                                    whiteColor,
                                                                                fit: BoxFit
                                                                                    .cover),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                           */
                                                            ],
                                                          )
                                                        : SizedBox(
                                                            height: 100.sp,
                                                            width:
                                                                double.infinity,
                                                            child: Image.asset(
                                                                backImage,
                                                                height: 100.sp,
                                                                fit:
                                                                    BoxFit.cover),
                                                          ),
                                                  ),
                                                )),
                                          ],
                                        );
                                      }),
                                ),
                              
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 100.sp),
                                child: Center(
                                  child: Text("No Category Found",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontFamily: "Franklin Gothic Regular")),
                                ),
                              ))
                  ],
                ),
              ),
            ),
          ],
        ),
     
      ),
    );
  }
}
