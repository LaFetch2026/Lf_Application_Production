// ignore_for_file: avoid_print
import 'dart:io';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_home_brand.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_product_list.dart';
import 'package:lafetch/commonwidget/homewidget/home_product_list.dart';
//import 'package:lafetch/commonwidget/homewidget/question_card.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/catalogscreen.dart';
import 'package:lafetch/screens/home/women/productlistscreen.dart';
//import 'package:lafetch/screens/home/faqscreen.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/common_widgets.dart';
import '../../../controller/search_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

//import '../../account/customercare.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final searchController = Get.put(SearchScreenController());
  final cartController = Get.put(CartController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // homeController.homeGenderValue.value = 3;
      homeController.showGenderList.value = false;
      homeController.currentPage.value = 0;
      productController.current.value = 50;
      productController.tagId.value = 0;
      productController.tagname.value = "We think you might also like";
      productController.productCategory = [];
      productController.productTags = [];
      checkUserConnection();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsHasnextpage.value = true;
      productController.tagsLoadMore.value = false;
      productController.istagsProduct.value = false;
      productController.tagsPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.hasnextpage.value = true;
      productController.loadMore.value = false;
      productController.isProduct.value = false;
      productController.page.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getTagsData(homeController.homeGenderValue.value));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBannar1Data();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBrandData();
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBannar2Data();
    }); */
    /*  WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getCategoryData(3)); */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getConfigurationData();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getDeviceName();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initPlatformState();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsProductController.addListener(() {
        productController.fetchMoreTagsProductData(
            productController.tagId.value,
            homeController.homeGenderValue.value,
            0);
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    });
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.expressListController.addListener(() {
        productController.fetchExpressMoreData(productController.tagId.value,
            homeController.homeGenderValue.value);
        productController.update();
      });
    }); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.expressHasnextpage.value = true;
      productController.expressLoadMore.value = false;
      //  productController.isExpress.value = false;
      productController.expressPage.value = 1;
    }); */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.homeTagshasnextpage.value = true;
      productController.homeTagsloadMore.value = false;
      // productController.istags.value = false;
      productController.homeTagsPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsController.addListener(() {
        productController
            .fetchMoreTagsData(homeController.homeGenderValue.value);
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      determinePosition();
    });
  }

  static Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      getSnackBar("Please turn on internet");
      return false;
    }
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('latitude') != null) {
      productController.lat.value = prefs.getDouble('latitude')!;
      productController.lng.value = prefs.getDouble('longitude')!;
      wishlistController.lat.value = prefs.getDouble('latitude')!;
      wishlistController.lng.value = prefs.getDouble('longitude')!;
      searchController.lat.value = prefs.getDouble('latitude')!;
      searchController.lng.value = prefs.getDouble('longitude')!;
      cartController.lat.value = prefs.getDouble('latitude')!;
      cartController.lng.value = prefs.getDouble('longitude')!;
    }
  }

  determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Location not enable");
      getPrefrenceValue();
    } else {
      setState(() {});
      Position position = await Geolocator.getCurrentPosition();
      productController.lat.value = position.latitude;
      productController.lng.value = position.longitude;
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble("latitude", productController.lat.value);
      prefs.setDouble("longitude", productController.lng.value);
      print("Location enable ${position.latitude}");
    }
  }

  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("ee370d7a-1d35-45bb-8f86-09e43c87c15a");
    OneSignal.Notifications.clearAll();
    OneSignal.User.pushSubscription.addObserver((state) {
      print(OneSignal.User.pushSubscription.optedIn);
      print("player id${OneSignal.User.pushSubscription.id}");
      print("token${OneSignal.User.pushSubscription.token}");
      homeController.playerId.value =
          OneSignal.User.pushSubscription.id.toString();
      homeController.fcmToken.value =
          OneSignal.User.pushSubscription.token.toString();
      if (homeController.playerId.value.isNotEmpty) {
        homeController.callSendDeviceToken();
      }
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
      setState(() {
        print("data ${event.notification.additionalData}");
        if (event.notification.additionalData != null) {
          if (event.notification.additionalData?["page"] == "order") {
            Get.to(OrderDetailsScreen(
              orderId: event.notification.additionalData?["id"],
            ));
          }
        }
      });
    });
    OneSignal.Notifications.requestPermission(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          HomeAppbar(
            onPressedSearch: () async {
              Navigator.push(context, scaleIn(const SearchScreen()));
              await analytics.logEvent(
                name: 'search_page',
                parameters: <String, Object>{
                  'page_name': 'search_page',
                },
              );
            },
            onPressedCatalog: () async {
              Navigator.push(context, scaleIn(const CatalogScreen()));
              await analytics.logEvent(
                name: 'catalog_page',
                parameters: <String, Object>{
                  'page_name': 'catalog_page',
                },
              );
            },
            onPressedCart: () async {
              Navigator.push(context, scaleIn(const CartScreen()));
              await analytics.logEvent(
                name: 'cart_page',
                parameters: <String, Object>{
                  'page_name': 'cart_page',
                },
              );
            },
            showGender: true,
            onPressedDropDown: () {
              if (homeController.showGenderList.value) {
                homeController.showGenderList.value = false;
              } else {
                homeController.showGenderList.value = true;
              }
              setState(() {});
            },
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: homeController.discountScreenController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SaleCardWidget(),
                      /*   Obx(
                        () => SizedBox(
                          height: 40.sp,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  homeController.homeGenderValue.value = 3;
                                  homeController.currentPage.value = 0;
                                  productController.current.value = 50;
                                  productController.tagId.value = 0;
                                  productController.tagname.value =
                                      "We think you might also like";
                                  productController.productCategory = [];
                                  productController.productTags = [];
                                  productController.getTagsData(3);
                                  homeController.getBannar1Data();
                                  homeController.getBannar2Data();
                                  homeController.getCategoryData(3);
                                },
                                child: SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AppText(
                                        text: "Women",
                                        color: homeController
                                                    .homeGenderValue.value ==
                                                3
                                            ? btnTextColor
                                            : textHintColor,
                                        fontSize: 14,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.sp),
                                        child: Container(
                                          color: homeController
                                                      .homeGenderValue.value ==
                                                  3
                                              ? btnTextColor
                                              : whiteColor,
                                          width: 110.sp,
                                          height: 2.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  homeController.homeGenderValue.value = 2;
                                  homeController.currentPage.value = 0;
                                  productController.current.value = 50;
                                  productController.tagId.value = 0;
                                  productController.tagname.value =
                                      "We think you might also like";
                                  productController.productCategory = [];
                                  productController.productTags = [];
                                  productController.getTagsData(2);
                                  homeController.getCategoryData(2);
                                },
                                child: SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AppText(
                                        text: "Men",
                                        color: homeController
                                                    .homeGenderValue.value ==
                                                2
                                            ? btnTextColor
                                            : textHintColor,
                                        fontSize: 14,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.sp),
                                        child: Container(
                                          color: homeController
                                                      .homeGenderValue.value ==
                                                  2
                                              ? btnTextColor
                                              : whiteColor,
                                          width: 110.sp,
                                          height: 2.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  homeController.homeGenderValue.value = 1;
                                  homeController.currentPage.value = 0;
                                  productController.current.value = 50;
                                  productController.tagId.value = 0;
                                  productController.tagname.value =
                                      "We think you might also like";
                                  productController.productCategory = [];
                                  productController.productTags = [];
                                  productController.getTagsData(1);
                                  homeController.getCategoryData(1);
                                },
                                child: SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AppText(
                                        text: "Accessories",
                                        color: homeController
                                                    .homeGenderValue.value ==
                                                1
                                            ? btnTextColor
                                            : textHintColor,
                                        fontSize: 14,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.sp),
                                        child: Container(
                                          color: homeController
                                                      .homeGenderValue.value ==
                                                  1
                                              ? btnTextColor
                                              : whiteColor,
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
                      Container(
                        width: double.infinity,
                        color: lightText,
                        height: 1.sp,
                      ), */
                      Obx(() => productController.istags.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  bottom: 10.sp,
                                  right: 16.sp,
                                  top: 20.sp),
                              child: SizedBox(
                                height: 30.sp,
                                width: double.infinity,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: 5,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.sp),
                                            child: DummyContainer(
                                                height: 16, width: 85),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: 10.sp),
                                            child: DummyContainer(
                                              width: 85,
                                              height: 2,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              ))
                          : Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  bottom: 10.sp,
                                  right: 16.sp,
                                  top: 20.sp),
                              child: Center(
                                child: SizedBox(
                                    width: double.infinity,
                                    height: 30.sp,
                                    child: GetBuilder<ProductController>(
                                      builder: (value) => ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount:
                                              productController.tagsList.length,
                                          scrollDirection: Axis.horizontal,
                                          controller:
                                              productController.tagsController,
                                          itemBuilder: (ctx, index) {
                                            return GestureDetector(
                                              onTap: () async {
                                                if (productController
                                                        .current.value ==
                                                    index) {
                                                  productController
                                                      .current.value = 50;
                                                  productController
                                                      .tagId.value = 0;
                                                  productController
                                                          .tagname.value =
                                                      "We think you might also like";
                                                  productController
                                                      .tagProductList
                                                      .clear();
                                                  productController
                                                      .expressProductList
                                                      .clear();
                                                  productController
                                                      .getExpressProductData(
                                                          productController
                                                              .tagId.value,
                                                          homeController
                                                              .homeGenderValue
                                                              .value);
                                                  productController
                                                      .getTagsProductData(
                                                          productController
                                                              .tagId.value,
                                                          homeController
                                                              .homeGenderValue
                                                              .value,
                                                          0);
                                                  productController.update();
                                                } else {
                                                  productController
                                                      .current.value = index;
                                                  productController
                                                          .tagId.value =
                                                      productController
                                                              .tagsList[index]
                                                          ["id"];
                                                  productController
                                                          .tagname.value =
                                                      productController
                                                              .tagsList[index]
                                                          ["name"];
                                                  productController
                                                      .tagProductList
                                                      .clear();
                                                  productController
                                                      .expressProductList
                                                      .clear();
                                                  productController
                                                      .getExpressProductData(
                                                          productController
                                                              .tagId.value,
                                                          homeController
                                                              .homeGenderValue
                                                              .value);
                                                  productController
                                                      .getTagsProductData(
                                                          productController
                                                              .tagId.value,
                                                          homeController
                                                              .homeGenderValue
                                                              .value,
                                                          0);
                                                  productController.update();
                                                }

                                                await analytics.logEvent(
                                                  name: 'tabclick_home_page',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'tabclick_home_page',
                                                  },
                                                );
                                              },
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Center(
                                                      child: AppText(
                                                        text:
                                                            "${productController.tagsList[index]["name"]}"
                                                                .toUpperCase(),
                                                        color: productController
                                                                    .current
                                                                    .value ==
                                                                index
                                                            ? blackColor
                                                            : textHintColor,
                                                        fontSize: 13,
                                                        fontFamily:
                                                            "Franklin Gothic",
                                                        textAlign:
                                                            TextAlign.center,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.sp),
                                                      child: Container(
                                                        color: productController
                                                                    .current
                                                                    .value ==
                                                                index
                                                            ? blackColor
                                                            : whiteColor,
                                                        width: 85.sp,
                                                        height: 2.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    )),
                              ),
                            )),
                      Obx(() => homeController.isBanner1.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  bottom: 10.sp,
                                  right: 16.sp,
                                  top: 10.sp),
                              child: SizedBox(
                                height: 210.sp,
                                width: double.infinity,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: 5,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return Container(
                                        height: 210.sp,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                        ),
                                      );
                                    }),
                              ))
                          : homeController.banner1List.isNotEmpty &&
                                  productController.current.value == 50
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp,
                                          bottom: 10.sp,
                                          right: 16.sp,
                                          top: 10.sp),
                                      child: CarouselSlider.builder(
                                        itemCount:
                                            homeController.banner1List.length,
                                        options: CarouselOptions(
                                          height: 210.sp,
                                          viewportFraction: 1.0,
                                          aspectRatio: 2.0,
                                          autoPlay: true,
                                          onPageChanged: (index, reason) {
                                            homeController.currentPage.value =
                                                index;
                                            homeController.update();
                                          },
                                          autoPlayInterval:
                                              const Duration(seconds: 10),
                                          enlargeCenterPage: true,
                                        ),
                                        itemBuilder: (BuildContext context,
                                                int itemIndex,
                                                int pageViewIndex) =>
                                            GestureDetector(
                                          onTap: () async {
                                            homeController.bannerTag1Id.clear();
                                            homeController.bannerCategory1Id
                                                .clear();
                                            productController.productCategory
                                                .clear();
                                            productController.productTags
                                                .clear();
                                            /*  if (homeController
                                                .banner1List[itemIndex]["tags"]
                                                .isNotEmpty) { */
                                            for (var i = 0;
                                                i <
                                                    homeController
                                                        .banner1List[itemIndex]
                                                            ["tags"]
                                                        .length;
                                                i++) {
                                              homeController.bannerTag1Id.add(
                                                  homeController.banner1List[
                                                          itemIndex]["tags"][i]
                                                      ["id"]);
                                            }
                                            for (var i = 0;
                                                i <
                                                    homeController
                                                        .banner1List[itemIndex]
                                                            ["categories"]
                                                        .length;
                                                i++) {
                                              homeController.bannerCategory1Id
                                                  .add(homeController
                                                              .banner1List[
                                                          itemIndex]
                                                      ["categories"][i]["id"]);
                                            }
                                            productController.productCategory =
                                                homeController
                                                    .bannerCategory1Id;
                                            productController.productTags =
                                                homeController.bannerTag1Id;
                                            Navigator.push(
                                                context,
                                                scaleIn(
                                                  CategoryProductScreen(
                                                    categoryName: homeController
                                                            .banner1List[
                                                        itemIndex]["name"],
                                                    categoryId: 0,
                                                    brandId: 0,
                                                    genderType: homeController
                                                        .homeGenderValue.value,
                                                    tagIds: homeController
                                                        .bannerTag1Id,
                                                    categoryList: homeController
                                                        .bannerCategory1Id,
                                                  ),
                                                ));
                                            await analytics.logEvent(
                                              name: 'banner_home_page',
                                              parameters: <String, Object>{
                                                'page_name': 'banner_home_page',
                                              },
                                            );
                                            //   }
                                          },
                                          child: CachedNetworkImage(
                                            cacheManager: CacheManager(Config(
                                                "customCacheKey",
                                                stalePeriod:
                                                    const Duration(days: 15),
                                                maxNrOfCacheObjects: 100)),
                                            fit: BoxFit.fill,
                                            imageUrl: homeController
                                                    .banner1List[itemIndex]
                                                ["image"],
                                            height: 210.sp,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: Container(
                                                height: 210.sp,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              downloadImage,
                                              height: 210.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    /*  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1,
                                      ),
                                    ), */
                                    homeController.banner1List.length == 1
                                        ? SizedBox(
                                            height: 0,
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: SizedBox(
                                              width: 50 *
                                                  homeController
                                                      .banner1List.length
                                                      .toDouble(),
                                              height: 6,
                                              child: GetBuilder<HomeController>(
                                                  builder: (value) =>
                                                      ListView.builder(
                                                          physics:
                                                              const BouncingScrollPhysics(),
                                                          itemCount: value
                                                              .banner1List
                                                              .length,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder:
                                                              (ctx, index) {
                                                            return index ==
                                                                    value
                                                                        .currentPage
                                                                        .value
                                                                ? Image.asset(
                                                                    longIndicator,
                                                                    width:
                                                                        48.sp,
                                                                    height:
                                                                        6.sp,
                                                                  )
                                                                : Image.asset(
                                                                    greyIndicator,
                                                                    width: 8.sp,
                                                                    height:
                                                                        8.sp,
                                                                  );
                                                          })),
                                            ),
                                          ),
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                )),

                      /*  Obx(() => productController.isExpress.value
                          ? const DummyProductList(text: "Express Delivery")
                          : productController.expressProductList.isNotEmpty
                              ? HorizontalHomeList(
                                  text: "Express Delivery",
                                  height: 250.sp,
                                  controller: productController.expressListController,
                                  list: productController.expressProductList,
                                  visibleExpress: true,
                                  onPressed: (p0, p1) async {
                                    Get.to(
                                      ProductDetailsScreen(
                                        productId: p0,
                                        type: "add",
                                        brandName: p1,
                                      ),
                                    )?.then((value) => setState(
                                          () {
                                            productController.expressHasnextpage.value =
                                                true;
                                            productController.expressLoadMore.value =
                                                false;
                                            productController.isExpress.value = false;
                                            productController.expressPage.value = 1;
                                          },
                                        ));
                                    await analytics.logEvent(
                                      name: 'expressproductDetails_home_page',
                                      parameters: <String, Object>{
                                        'page_name': 'expressproductDetails_home_page',
                                      },
                                    );
                                  },
                                )
                              : SizedBox(
                                  height: 0,
                                )),
                     */
                      Obx(() => homeController.isBrand.value
                          ? DummyHomeBrand()
                          : homeController.brandList.isNotEmpty
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 10.sp, left: 16.sp),
                                          child: AppText(
                                            text:
                                                "Featured brands".toUpperCase(),
                                            fontFamily: "Franklin Gothic",
                                            color: blackColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 0,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12.sp,
                                                  right: 12.sp,
                                                  left: 16.sp,
                                                  bottom: 2.sp),
                                              child: Image.asset(
                                                rightBlackArrow,
                                                height: 30.sp,
                                                width: 30.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.sp,
                                          left: 16.sp,
                                          right: 16.sp),
                                      child: SizedBox(
                                        height: 100.sp,
                                        child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount:
                                                homeController.brandList.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (ctx, index) {
                                              return homeController
                                                              .brandList[index]
                                                          ["logo"] !=
                                                      null
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 12.sp),
                                                      child: SizedBox(
                                                        height: 80.sp,
                                                        width: 80.sp,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              blackColor,
                                                          child:
                                                              CachedNetworkImage(
                                                            height: 80.sp,
                                                            width: 80.sp,
                                                            cacheManager: CacheManager(Config(
                                                                "customCacheKey",
                                                                stalePeriod:
                                                                    const Duration(
                                                                        days:
                                                                            15),
                                                                maxNrOfCacheObjects:
                                                                    100)),
                                                            fit: BoxFit.contain,
                                                            imageUrl: homeController
                                                                    .brandList[
                                                                index]["logo"],
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              downloadImage,
                                                              fit: BoxFit
                                                                  .contain,
                                                              height: 80.sp,
                                                              width: 80.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 12.sp),
                                                      child: CircleAvatar(
                                                        child: Image.asset(
                                                            dummyWishlistImage,
                                                            height: 80.sp,
                                                            width: 80.sp,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    );
                                            }),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: 0,
                                )),
                      Obx(() => productController.istagsProduct.value
                          ? Padding(
                              padding: EdgeInsets.only(top: 10.sp),
                              child: DummyProductList(
                                  visibleSubtitle: true,
                                  text: "${productController.tagname.value}"
                                      .toUpperCase()),
                            )
                          : productController.tagProductList.isNotEmpty
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.sp),
                                      child: HomeProductList(
                                        text:
                                            "${productController.tagname.value}"
                                                .toUpperCase(),
                                        visibleViewAll: true,
                                        visibleSubtitle: true,
                                        text1:
                                            "Selected styles for a limited time only",
                                        controller: productController
                                            .tagsProductController,
                                        height: 235.sp,
                                        onPressedViewAll: () {
                                          productController.productCategory
                                              .clear();
                                          productController.productTags.clear();
                                          productController.productTags =
                                              productController.tagId.value == 0
                                                  ? []
                                                  : [
                                                      productController
                                                          .tagId.value
                                                    ];
                                          Navigator.push(
                                              context,
                                              scaleIn(
                                                CategoryProductScreen(
                                                  categoryName: productController
                                                              .tagId.value ==
                                                          0
                                                      ? "We think you might also like"
                                                      : productController
                                                          .tagname.value,
                                                  categoryId: 0,
                                                  brandId: 0,
                                                  genderType: homeController
                                                      .homeGenderValue.value,
                                                  tagIds: productController
                                                              .tagId.value ==
                                                          0
                                                      ? []
                                                      : [
                                                          productController
                                                              .tagId.value
                                                        ],
                                                  categoryList: [],
                                                ),
                                              )).then((value) => setState(
                                                () {
                                                  //  productController.tagId.value = 0;
                                                },
                                              ));
                                        },
                                        onPressed: (p0, p1) async {
                                          Navigator.push(
                                              context,
                                              scaleIn(
                                                ProductDetailsScreen(
                                                  productId: p0,
                                                  type: "add",
                                                  brandName: p1,
                                                ),
                                              )).then((value) => setState(
                                                () {
                                                  productController
                                                      .tagsHasnextpage
                                                      .value = true;
                                                  productController.tagsLoadMore
                                                      .value = false;
                                                  productController
                                                      .istagsProduct
                                                      .value = false;
                                                  productController
                                                      .tagsPage.value = 1;
                                                },
                                              ));
                                          await analytics.logEvent(
                                            name:
                                                'product_tabid_details_home_page',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'product_tabid_details_home_page',
                                            },
                                          );
                                        },
                                        list: productController.tagProductList,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.sp),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                )),
                      Obx(() => productController.isProduct.value
                          ? Padding(
                              padding: EdgeInsets.only(top: 10.sp),
                              child: DummyProductList(
                                  visibleSubtitle: true,
                                  text: "HANDPICKED FOR YOU"),
                            )
                          : productController.productList.isNotEmpty
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.sp),
                                      child: HomeProductList(
                                        text: "HANDPICKED FOR YOU",
                                        visibleViewAll: true,
                                        visibleSubtitle: true,
                                        text1:
                                            "Curated collection, just for you and only you.",
                                        controller: productController
                                            .tagsProductController,
                                        height: 235.sp,
                                        onPressedViewAll: () {
                                          Navigator.push(
                                              context,
                                              scaleIn(
                                                ProductListScreen(
                                                  title: "HANDPICKED FOR YOU",
                                                ),
                                              )).then((value) => setState(
                                                () {
                                                  productController
                                                      .hasnextpage.value = true;
                                                  productController
                                                      .loadMore.value = false;
                                                  productController
                                                      .isProduct.value = false;
                                                  productController.page.value =
                                                      1;
                                                },
                                              ));
                                        },
                                        onPressed: (p0, p1) async {
                                          Navigator.push(
                                              context,
                                              scaleIn(
                                                ProductDetailsScreen(
                                                  productId: p0,
                                                  type: "add",
                                                  brandName: p1,
                                                ),
                                              )).then((value) => setState(
                                                () {
                                                  productController
                                                      .hasnextpage.value = true;
                                                  productController
                                                      .loadMore.value = false;
                                                  productController
                                                      .isProduct.value = false;
                                                  productController.page.value =
                                                      1;
                                                },
                                              ));
                                          await analytics.logEvent(
                                            name:
                                                'product_tabid_details_home_page',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'product_tabid_details_home_page',
                                            },
                                          );
                                        },
                                        list: productController.productList,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.sp),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                )),
                      /*  Obx(
                        () => homeController.isCategory.value
                            ? const DummyProductList(text: "Popular Categories")
                            : homeController.categoryList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.sp, left: 16.sp),
                                        child: AppText(
                                          text: "Popular Categories",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: blackColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            right: 16.sp,
                                            top: 15.sp,
                                            bottom: 10.sp),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            homeController
                                                        .categoryList.length >=
                                                    1
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      Navigator.push(
                                                          context,
                                                          scaleIn(CategoryProductScreen(
                                                              categoryName:
                                                                  homeController
                                                                          .categoryList[0]
                                                                      ["name"],
                                                              categoryId:
                                                                  homeController
                                                                          .categoryList[
                                                                      0]["id"],
                                                              brandId: 0,
                                                              genderType:
                                                                  homeController
                                                                      .homeGenderValue
                                                                      .value,
                                                              categoryList: [],
                                                              tagIds: const [])));
                                                      await analytics.logEvent(
                                                        name:
                                                            'categories_home_page',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'categories_home_page',
                                                        },
                                                      );
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      margin: EdgeInsets.only(
                                                          right: 8.sp),
                                                      height: 180.sp,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          homeController.categoryList[
                                                                          0][
                                                                      "thumbnail"] !=
                                                                  null
                                                              ? SizedBox(
                                                                  height:
                                                                      144.sp,
                                                                  width: (MediaQuery.sizeOf(context)
                                                                              .width /
                                                                          2) -
                                                                      20.sp,
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    cacheManager: CacheManager(Config(
                                                                        "customCacheKey",
                                                                        stalePeriod: const Duration(
                                                                            days:
                                                                                15),
                                                                        maxNrOfCacheObjects:
                                                                            100)),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    imageUrl: homeController
                                                                            .categoryList[0]
                                                                        [
                                                                        "thumbnail"],
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      height:
                                                                          144.sp,
                                                                      width: (MediaQuery.sizeOf(context).width /
                                                                              2) -
                                                                          20.sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  dummyWishlistImage,
                                                                  height:
                                                                      144.sp,
                                                                  width: (MediaQuery.sizeOf(context)
                                                                              .width /
                                                                          2) -
                                                                      20.sp,
                                                                  fit: BoxFit
                                                                      .cover),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp,
                                                                    vertical:
                                                                        5.sp),
                                                            child: AppText(
                                                              text: homeController
                                                                          .categoryList[0]
                                                                      [
                                                                      "name"] ??
                                                                  "",
                                                              color:
                                                                  greyTextColor,
                                                              fontSize: 10,
                                                              maxLines: 2,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 0,
                                                  ),
                                            homeController
                                                        .categoryList.length >=
                                                    2
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      Navigator.push(
                                                          context,
                                                          scaleIn(
                                                            CategoryProductScreen(
                                                                categoryName:
                                                                    homeController
                                                                            .categoryList[1][
                                                                        "name"],
                                                                categoryId:
                                                                    homeController
                                                                            .categoryList[1]
                                                                        ["id"],
                                                                brandId: 0,
                                                                categoryList: [],
                                                                genderType:
                                                                    homeController
                                                                        .homeGenderValue
                                                                        .value,
                                                                tagIds: const []),
                                                          ));
                                                      await analytics.logEvent(
                                                        name:
                                                            'categories_home_page',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'categories_home_page',
                                                        },
                                                      );
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      height: 180.sp,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          homeController.categoryList[
                                                                          1][
                                                                      "thumbnail"] !=
                                                                  null
                                                              ? SizedBox(
                                                                  height:
                                                                      144.sp,
                                                                  width: (MediaQuery.sizeOf(context)
                                                                              .width /
                                                                          2) -
                                                                      20.sp,
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    cacheManager: CacheManager(Config(
                                                                        "customCacheKey",
                                                                        stalePeriod: const Duration(
                                                                            days:
                                                                                15),
                                                                        maxNrOfCacheObjects:
                                                                            100)),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    imageUrl: homeController
                                                                            .categoryList[1]
                                                                        [
                                                                        "thumbnail"],
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      height:
                                                                          144.sp,
                                                                      width: (MediaQuery.sizeOf(context).width /
                                                                              2) -
                                                                          20.sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  dummyWishlistImage,
                                                                  height:
                                                                      144.sp,
                                                                  width: (MediaQuery.sizeOf(context)
                                                                              .width /
                                                                          2) -
                                                                      20.sp,
                                                                  fit: BoxFit
                                                                      .cover),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp,
                                                                    vertical:
                                                                        5.sp),
                                                            child: AppText(
                                                              text: homeController
                                                                          .categoryList[1]
                                                                      [
                                                                      "name"] ??
                                                                  "",
                                                              color:
                                                                  greyTextColor,
                                                              fontSize: 10,
                                                              maxLines: 2,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 0,
                                                  ),
                                          ],
                                        ),
                                      ),
                                      homeController.categoryList.length >= 3
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp),
                                              child: Center(
                                                child: GridView.count(
                                                  shrinkWrap: true,
                                                  crossAxisCount: 4,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  padding: EdgeInsets.zero,
                                                  childAspectRatio: 0.7,
                                                  physics:
                                                      const ScrollPhysics(),
                                                  crossAxisSpacing: 5.sp,
                                                  mainAxisSpacing: 1.sp,
                                                  children: List.generate(
                                                    homeController.categoryList
                                                            .length -
                                                        2,
                                                    (index) {
                                                      return Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              Navigator.push(
                                                                  context,
                                                                  scaleIn(
                                                                    CategoryProductScreen(
                                                                        categoryName: homeController.categoryList[index +
                                                                                2]
                                                                            [
                                                                            "name"],
                                                                        categoryId:
                                                                            homeController.categoryList[index + 2][
                                                                                "id"],
                                                                        brandId:
                                                                            0,
                                                                        categoryList: [],
                                                                        genderType: homeController
                                                                            .homeGenderValue
                                                                            .value,
                                                                        tagIds: const []),
                                                                  ));
                                                              await analytics
                                                                  .logEvent(
                                                                name:
                                                                    'categories_home_page',
                                                                parameters: <String,
                                                                    Object>{
                                                                  'page_name':
                                                                      'categories_home_page',
                                                                },
                                                              );
                                                            },
                                                            child: SizedBox(
                                                              height: 110.sp,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Center(
                                                                    child: homeController.categoryList[index + 2]["thumbnail"] !=
                                                                            null
                                                                        ? SizedBox(
                                                                            width:
                                                                                80.sp,
                                                                            height:
                                                                                72.sp,
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                              fit: BoxFit.cover,
                                                                              imageUrl: homeController.categoryList[index + 2]["thumbnail"],
                                                                              /*   progressIndicatorBuilder:
                                                                              (context,
                                                                                      url,
                                                                                      downloadProgress) =>
                                                                                  Center(
                                                                            child: CircularProgressIndicator(
                                                                                value: downloadProgress
                                                                                    .progress),
                                                                          ), */
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                downloadImage,
                                                                                fit: BoxFit.cover,
                                                                                width: 80.sp,
                                                                                height: 72.sp,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Image.asset(
                                                                            dummyWishlistImage,
                                                                            width:
                                                                                80.sp,
                                                                            height: 72.sp,
                                                                            fit: BoxFit.cover),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 10
                                                                            .sp,
                                                                        vertical:
                                                                            5.sp),
                                                                    child:
                                                                        AppText(
                                                                      text: homeController.categoryList[index + 2]
                                                                              [
                                                                              "name"] ??
                                                                          "",
                                                                      color:
                                                                          greyTextColor,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontSize:
                                                                          10,
                                                                      maxLines:
                                                                          2,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(
                                              width: 0,
                                            ),
                                    ],
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                      ),
                      Obx(
                        () => homeController.isBanner2.value
                            ? Padding(
                                padding: EdgeInsets.only(
                                    left: 16.sp, bottom: 10.sp, right: 16.sp),
                                child: SizedBox(
                                  height: 210.sp,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: 5,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx, index) {
                                        return Container(
                                          height: 210.sp,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                          ),
                                        );
                                      }),
                                ))
                            : Column(
                                children: [
                                  homeController.banner2List.isNotEmpty
                                      ? CarouselSlider.builder(
                                          itemCount:
                                              homeController.banner2List.length,
                                          options: CarouselOptions(
                                            height: 210.sp,
                                            autoPlayInterval:
                                                const Duration(seconds: 10),
                                            onPageChanged: (index, reason) {
                                              homeController.currentPage.value =
                                                  index;
                                              homeController.update();
                                            },
                                            viewportFraction: 1.0,
                                            aspectRatio: 2.0,
                                            autoPlay: true,
                                            enlargeCenterPage: true,
                                          ),
                                          itemBuilder: (BuildContext context,
                                                  int itemIndex,
                                                  int pageViewIndex) =>
                                              GestureDetector(
                                            onTap: () async {
                                              homeController.bannerTag2Id
                                                  .clear();
                                              homeController.bannerCategory2Id
                                                  .clear();
                                              productController.productCategory
                                                  .clear();
                                              productController.productTags
                                                  .clear();
                                              if (homeController
                                                  .banner2List[itemIndex]
                                                      ["tags"]
                                                  .isNotEmpty) {
                                                for (var i = 0;
                                                    i <
                                                        homeController
                                                            .banner2List[
                                                                itemIndex]
                                                                ["tags"]
                                                            .length;
                                                    i++) {
                                                  homeController.bannerTag2Id
                                                      .add(homeController
                                                                  .banner2List[
                                                              itemIndex]["tags"]
                                                          [i]["id"]);
                                                }
                                                for (var i = 0;
                                                    i <
                                                        homeController
                                                            .banner2List[
                                                                itemIndex]
                                                                ["categories"]
                                                            .length;
                                                    i++) {
                                                  homeController
                                                      .bannerCategory2Id
                                                      .add(homeController
                                                                  .banner2List[
                                                              itemIndex][
                                                          "categories"][i]["id"]);
                                                }
                                                print(homeController
                                                    .bannerTag2Id);

                                                productController
                                                        .productCategory =
                                                    homeController
                                                        .bannerCategory2Id;
                                                productController.productTags =
                                                    homeController.bannerTag2Id;
                                                Navigator.push(
                                                    context,
                                                    scaleIn(
                                                      CategoryProductScreen(
                                                        categoryName: homeController
                                                                .banner2List[
                                                            itemIndex]["name"],
                                                        categoryId: 0,
                                                        brandId: 0,
                                                        genderType:
                                                            homeController
                                                                .homeGenderValue
                                                                .value,
                                                        tagIds: homeController
                                                            .bannerTag2Id,
                                                        categoryList:
                                                            homeController
                                                                .bannerCategory2Id,
                                                      ),
                                                    ));
                                                await analytics.logEvent(
                                                  name: 'promotion_home_page',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'promotion_home_page',
                                                  },
                                                );
                                              }
                                            },
                                            child: CachedNetworkImage(
                                              cacheManager: CacheManager(Config(
                                                  "customCacheKey",
                                                  stalePeriod:
                                                      const Duration(days: 15),
                                                  maxNrOfCacheObjects: 100)),
                                              fit: BoxFit.fill,
                                              height: 210.sp,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              imageUrl: homeController
                                                      .banner2List[itemIndex]
                                                  ["image"],
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child: Container(
                                                  height: 210.sp,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.04),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                downloadImage,
                                                height: 210.sp,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  SizedBox(
                                    height: 20.sp,
                                  ),
                                  homeController.banner2List.length == 1
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: SizedBox(
                                            width: 50 *
                                                homeController
                                                    .banner2List.length
                                                    .toDouble(),
                                            height: 6,
                                            child: GetBuilder<HomeController>(
                                                builder: (value) =>
                                                    ListView.builder(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        itemCount: value
                                                            .banner2List.length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (ctx, index) {
                                                          return AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          400),
                                                              height: 6.sp,
                                                              width: 40.sp,
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          5.sp),
                                                              decoration: BoxDecoration(
                                                                  color: index ==
                                                                          value
                                                                              .currentPage
                                                                              .value
                                                                      ? colorPrimary
                                                                      : colorSecondary));
                                                        })),
                                          ),
                                        ),
                                  /*  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List<Widget>.generate(
                                                  homeController.banner2List.length,
                                                  (int index) {
                                                return AnimatedContainer(
                                                    duration:
                                                        const Duration(milliseconds: 400),
                                                    height: 6,
                                                    width: 40,
                                                    margin: const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        color: index ==
                                                                homeController
                                                                    .currentPage.value
                                                            ? colorPrimary
                                                            : colorSecondary));
                                              })),
                                        ),
                                      ),
                                    ),
                                  ) */
                                ],
                              ),
                      ),
                      SizedBox(
                        height: 20.sp,
                      ),
                      //  const LafetchCardWidget(),
                      QuestionCardWidget(
                          text1: "FAQs",
                          text2: "Your questions answered",
                          size: 26.sp,
                          onPressed: () async {
                            Navigator.push(context, scaleIn(FAQScreen()));
                            await analytics.logEvent(
                              name: 'FAQ_home_page',
                              parameters: <String, Object>{
                                'page_name': 'FAQ_home_page',
                              },
                            );
                          },
                          icon: question2Image),
                      QuestionCardWidget(
                          text1: "Need Help?",
                          text2: "Contact customer service",
                          size: 32.sp,
                          onPressed: () async {
                            // Get.to(CustomerCareScreen());
                            Navigator.push(
                                context, scaleIn(CustomerCareScreen()));
                            await analytics.logEvent(
                              name: 'needhelp_home_page',
                              parameters: <String, Object>{
                                'page_name': 'needhelp_home_page',
                              },
                            );
                          },
                          icon: questionIcon),
                      */
                      SizedBox(
                        height: 40.sp,
                      )
                    ],
                  ),
                ),
                homeController.showGenderList.value
                    ? Container(
                        color: blackColor,
                        height: 125.sp,
                        width: 115.sp,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                homeController.genderText.value = "Women";
                                homeController.showGenderList.value = false;
                                setState(() {});
                                homeController.homeGenderValue.value = 3;
                                homeController.currentPage.value = 0;
                                productController.current.value = 50;
                                productController.tagId.value = 0;
                                productController.tagname.value =
                                    "We think you might also like";
                                productController.productCategory = [];
                                productController.productTags = [];
                                productController.getTagsData(3);
                                homeController.getBannar1Data();
                                homeController.getBannar2Data();
                                // homeController.getCategoryData(3);
                              },
                              child: Container(
                                width: 110.sp,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.sp, horizontal: 16.sp),
                                  child: AppText(
                                    text: "Women",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                    color: whiteColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 110.sp,
                              color: lightText,
                              height: 1.sp,
                            ),
                            GestureDetector(
                              onTap: () {
                                homeController.genderText.value = "Men";
                                homeController.showGenderList.value = false;
                                setState(() {});
                                homeController.homeGenderValue.value = 2;
                                homeController.currentPage.value = 0;
                                productController.current.value = 50;
                                productController.tagId.value = 0;
                                productController.tagname.value =
                                    "We think you might also like";
                                productController.productCategory = [];
                                productController.productTags = [];
                                productController.getTagsData(2);
                                // homeController.getCategoryData(2);
                              },
                              child: Container(
                                width: 110.sp,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.sp, horizontal: 16.sp),
                                  child: AppText(
                                    text: "Men",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                    color: whiteColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 110.sp,
                              color: lightText,
                              height: 1.sp,
                            ),
                            GestureDetector(
                              onTap: () {
                                homeController.genderText.value = "Accessories";
                                homeController.showGenderList.value = false;
                                setState(() {});
                                homeController.homeGenderValue.value = 1;
                                homeController.currentPage.value = 0;
                                productController.current.value = 50;
                                productController.tagId.value = 0;
                                productController.tagname.value =
                                    "We think you might also like";
                                productController.productCategory = [];
                                productController.productTags = [];
                                productController.getTagsData(1);
                                // homeController.getCategoryData(1);
                              },
                              child: Container(
                                width: 110.sp,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.sp, horizontal: 16.sp),
                                  child: AppText(
                                    text: "Accessories",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                    color: whiteColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
