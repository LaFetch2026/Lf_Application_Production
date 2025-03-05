// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:async';
import 'dart:io';

//import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_grid_mostsearch.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_home_brand.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_product_list.dart';
import 'package:lafetch/commonwidget/homewidget/homelist.dart';
import 'package:lafetch/controller/brand_controller.dart';
//import 'package:lafetch/commonwidget/homewidget/question_card.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/controller/catalog_controller.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/home/women/productviewscreen.dart';
//import 'package:lafetch/screens/home/women/productviewscreen.dart';
//import 'package:lafetch/screens/home/faqscreen.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:marquee/marquee.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/common_widgets.dart';
import '../../../controller/search_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

//import '../../account/customercare.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onPressed;
  const HomeScreen({
    this.onPressed,
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
  final brandController = Get.put(BrandController());
  final catalogController = Get.put(CatalogController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (homeController.currentPage.value <
          homeController.banner1List.length - 1) {
        homeController.currentPage.value++;
      } else {
        homeController.currentPage.value = 0;
      }
      _pageController.animateToPage(
        homeController.currentPage.value,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: whiteColor, systemNavigationBarColor: whiteColor));
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.showGenderList.value = false;
      homeController.currentPage.value = 0;
      productController.current.value = 50;
      productController.tagId.value = 0;
      productController.tagname.value = "";
      productController.productCategory = [];
      productController.productTags = [];
      /*  homeController.homeGenderValue.value = 2;
      productController.selectedTabCategory.value = 1; */
      productController.categoryFilter.value =
          homeController.homeGenderValue.value;
      checkUserConnection();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => cartController.getCartData());
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsHasnextpage.value = true;
      productController.tagsLoadMore.value = false;
      productController.istagsProduct.value = false;
      productController.tagsPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.handpickedHasnextpage.value = true;
      productController.handpickedLoadMore.value = false;
      productController.isHandPicked.value = false;
      productController.handpickedPage.value = 1;
    }); */
    /*  WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getTagsData(homeController.homeGenderValue.value)); */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBannar1Data(homeController.homeGenderValue.value);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBrandData("home", homeController.homeGenderValue.value);
    });
    /*  WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getHandPickedProduct("", false, false, 0)); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBannar2Data();
    }); */
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        catalogController.getCatalogData(homeController.homeGenderValue.value));
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getHomeProduct(homeController.homeGenderValue.value));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getConfigurationData();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getDeviceName();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initPlatformState();
    });
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.tagsProductController.addListener(() {
        productController.fetchMoreTagsProductData(
            productController.tagId.value,
            homeController.homeGenderValue.value,
            0);
        productController.update();
      });
    }); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.handpickedController.addListener(() {
        productController.fetchMoreHandPickedProduct();
        productController.update();
      });
    }); */
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
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
    }); */
    WidgetsBinding.instance.addPostFrameCallback((_) => catalogController
        .getCatagoryData(catalogController.selectCategoryGender.value));
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

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  List<Widget> widgitBannerList() {
    List<Widget> list = [];
    if (homeController.banner1List.isNotEmpty) {
      for (var itemIndex = 0;
          itemIndex < homeController.banner1List.length;
          itemIndex++) {
        list.add(GestureDetector(
          onTap: () async {
            homeController.bannerTag1Id.clear();
            homeController.bannerCategory1Id.clear();
            productController.productCategory.clear();
            productController.productTags.clear();
            /*  if (homeController
                                                .banner1List[itemIndex]["tags"]
                                                .isNotEmpty) { */
            for (var i = 0;
                i < homeController.banner1List[itemIndex]["tags"].length;
                i++) {
              homeController.bannerTag1Id
                  .add(homeController.banner1List[itemIndex]["tags"][i]["id"]);
            }
            for (var i = 0;
                i < homeController.banner1List[itemIndex]["categories"].length;
                i++) {
              homeController.bannerCategory1Id.add(
                  homeController.banner1List[itemIndex]["categories"][i]["id"]);
            }
            productController.productCategory =
                homeController.bannerCategory1Id;
            productController.productTags = homeController.bannerTag1Id;
            if (homeController.banner1List[itemIndex]["tags"].isNotEmpty &&
                homeController
                    .banner1List[itemIndex]["categories"].isNotEmpty) {
              Get.to(
                CategoryProductScreen(
                  categoryName: homeController.banner1List[itemIndex]["name"],
                  categoryId: 0,
                  genderName: homeController.genderText.value,
                  brandId: 0,
                  genderType: homeController.homeGenderValue.value,
                  tagIds: homeController.bannerTag1Id,
                  categoryList: homeController.bannerCategory1Id,
                ),
              );
              await analytics.logEvent(
                name: 'banner_home_page',
                parameters: <String, Object>{
                  'page_name': 'banner_home_page',
                },
              );
            }
          },
          child: CachedNetworkImage(
            cacheManager: CacheManager(Config("customCacheKey",
                stalePeriod: const Duration(days: 15),
                maxNrOfCacheObjects: 100)),
            fit: BoxFit.fill,
            imageUrl: homeController.banner1List[itemIndex]["image"],
            height: 229.sp,
            width: MediaQuery.of(context).size.width,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child: Container(
                height: 229.sp,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              downloadImage,
              height: 229.sp,
            ),
          ),
        ));
      }
    }
    return list;
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
              searchController.searchController.clear();
              Get.to(const SearchScreen())?.then((value) => setState(
                    () {
                      productController.categoryFilter.value =
                          homeController.homeGenderValue.value;
                      SystemChrome.setSystemUIOverlayStyle(
                          const SystemUiOverlayStyle(
                              statusBarColor: whiteColor,
                              systemNavigationBarColor: whiteColor));
                      /*   productController.getHandPickedProduct(
                              "", false, false, productController.tagId.value); */
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
                          systemNavigationBarColor: whiteColor));
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
                          systemNavigationBarColor: whiteColor));
                },
              );
              await analytics.logEvent(
                name: 'cart_page',
                parameters: <String, Object>{
                  'page_name': 'cart_page',
                },
              );
            },
            onPressedDropDown: () {
              if (homeController.showGenderList.value) {
                homeController.showGenderList.value = false;
              } else {
                homeController.showGenderList.value = true;
              }
              setState(() {});
            },
          ),
          Obx(
            () => SizedBox(
              height: 40.sp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      homeController.genderText.value = "Men";
                      homeController.homeGenderValue.value = 2;
                      productController.selectedTabCategory.value = 0;
                      homeController.currentPage.value = 0;
                      productController.current.value = 50;
                      productController.tagId.value = 0;
                      /*  productController.tagname.value =
                                      "We think you might also like"; */
                      productController.productCategory = [];
                      productController.productTags = [];
                      // productController.getTagsData(2);
                      homeController.getBannar1Data(2);
                      catalogController.getCatalogData(2);
                      homeController.getBrandData("home", 2);
                      productController.getHomeProduct(2);
                      catalogController.selectCategoryGender.value = 2;
                      catalogController.categoryName.value = "Men";
                      catalogController.getCatagoryData(2);
                    },
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppText(
                            text: "Men".toUpperCase(),
                            color: homeController.homeGenderValue.value == 2
                                ? homeAppBarColor
                                : searchTextColor,
                            fontSize: 13,
                            fontFamily:
                                homeController.homeGenderValue.value == 2
                                    ? "Franklin Gothic Semibold"
                                    : "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.sp),
                            child: Container(
                              color: homeController.homeGenderValue.value == 2
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
                    onTap: () {
                      homeController.genderText.value = "Women";
                      homeController.homeGenderValue.value = 3;
                      productController.selectedTabCategory.value = 1;
                      homeController.currentPage.value = 0;
                      productController.current.value = 50;
                      productController.tagId.value = 0;
                      homeController.getBrandData("home", 3);
                      /* productController.tagname.value =
                                      "We think you might also like"; */
                      productController.productCategory = [];
                      productController.productTags = [];
                      //  productController.getTagsData(3);
                      homeController.getBannar1Data(3);
                      catalogController.getCatalogData(3);
                      productController.getHomeProduct(3);
                      catalogController.selectCategoryGender.value = 3;
                      catalogController.categoryName.value = "Women";
                      catalogController.getCatagoryData(3);
                    },
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppText(
                            text: "WOMEN".toUpperCase(),
                            color: homeController.homeGenderValue.value == 3
                                ? homeAppBarColor
                                : searchTextColor,
                            fontSize: 13,
                            fontFamily:
                                homeController.homeGenderValue.value == 3
                                    ? "Franklin Gothic Semibold"
                                    : "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.sp),
                            child: Container(
                              color: homeController.homeGenderValue.value == 3
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
                    onTap: () {
                      homeController.genderText.value = "Accessories";
                      homeController.homeGenderValue.value = 1;
                      productController.selectedTabCategory.value = 2;
                      homeController.currentPage.value = 0;
                      productController.current.value = 50;
                      productController.tagId.value = 0;
                      homeController.getBrandData("home", 1);
                      /*  productController.tagname.value =
                                      "We think you might also like"; */
                      productController.productCategory = [];
                      productController.productTags = [];
                      // productController.getTagsData(1);
                      homeController.getBannar1Data(1);
                      catalogController.getCatalogData(1);
                      productController.getHomeProduct(1);
                      catalogController.selectCategoryGender.value = 1;
                      catalogController.categoryName.value = "Accessories";
                      catalogController.getCatagoryData(1);
                    },
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppText(
                            text: "Accessories".toUpperCase(),
                            color: homeController.homeGenderValue.value == 1
                                ? homeAppBarColor
                                : searchTextColor,
                            fontSize: 13,
                            fontFamily:
                                homeController.homeGenderValue.value == 1
                                    ? "Franklin Gothic Semibold"
                                    : "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.sp),
                            child: Container(
                              color: homeController.homeGenderValue.value == 1
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
          Container(
            width: double.infinity,
            color: lightgreyColor,
            height: 2.sp,
          ),
          SizedBox(
            height: 16.sp,
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
                      /*   Obx(() => productController.istags.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  bottom: 5.sp,
                                  right: 16.sp,
                                  top: 8.sp),
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
                                                height: 16, width: 70),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 6.sp),
                                            child: DummyContainer(
                                              width: 70,
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
                                  bottom: 5.sp,
                                  right: 16.sp,
                                  top: 8.sp),
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
                                                  /*  productController
                                                      .getExpressProductData(
                                                          productController
                                                              .tagId.value,
                                                          homeController
                                                              .homeGenderValue
                                                              .value); */
                                                  productController
                                                      .getHandPickedProduct(
                                                          "",
                                                          false,
                                                          false,
                                                          productController
                                                              .tagId.value);
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
                                                  /* productController
                                                      .getExpressProductData(
                                                          productController
                                                              .tagId.value,
                                                          homeController
                                                              .homeGenderValue
                                                              .value); */
                                                  productController
                                                      .getHandPickedProduct(
                                                          "",
                                                          false,
                                                          false,
                                                          productController
                                                              .tagId.value);
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
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 16.sp),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            border: Border(
                                                                bottom: BorderSide(
                                                                    width: 2,
                                                                    color: productController.current.value ==
                                                                            index
                                                                        ? blackColor
                                                                        : whiteColor))),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        6.sp),
                                                            child: AppText(
                                                              text: "${productController.tagsList[index]["name"]}"
                                                                  .toUpperCase(),
                                                              color: productController
                                                                          .current
                                                                          .value ==
                                                                      index
                                                                  ? blackColor
                                                                  : Color(
                                                                      0xFF9CA3AF),
                                                              fontSize: 13,
                                                              fontFamily: productController
                                                                          .current
                                                                          .value ==
                                                                      index
                                                                  ? "Franklin Gothic Semibold"
                                                                  : "Franklin Gothic",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
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
                      */
                      /*  Obx(() => homeController.isBanner1.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  bottom: 10.sp,
                                  right: 16.sp,
                                  top: 6.sp),
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
                                          top: 6.sp),
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
                                    homeController.banner1List.length == 1
                                        ? SizedBox(
                                            height: 0,
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.sp, right: 10.sp),
                                            child: Center(
                                              child: Container(
                                                width: 25 *
                                                    homeController
                                                        .banner1List.length
                                                        .toDouble(),
                                                height: 6,
                                                child: GetBuilder<
                                                        HomeController>(
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
                                                                      width:
                                                                          8.sp,
                                                                      height:
                                                                          8.sp,
                                                                    );
                                                            })),
                                              ),
                                            ),
                                          ),
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                )), */
                      Obx(() => homeController.isBanner1.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                left: 16.sp,
                                bottom: 12.sp,
                                right: 16.sp,
                              ),
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
                                          bottom: 12.sp,
                                          right: 16.sp,
                                        ),
                                        child: /*  CarouselSlider.builder(
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
                                      ), */
                                            SizedBox(
                                          height: 210.sp,
                                          child: PageView(
                                            controller: _pageController,
                                            onPageChanged: (index) {
                                              homeController.currentPage.value =
                                                  index;
                                              homeController.update();
                                            },
                                            children: widgitBannerList(),
                                          ),
                                        )),
                                    homeController.banner1List.length == 1
                                        ? SizedBox(
                                            height: 0,
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.sp, right: 10.sp),
                                            child: Center(
                                              child: PageIndicator(
                                                controller: _pageController,
                                                count: homeController
                                                    .banner1List.length,
                                                size: 6.0.sp,
                                                activeColor: Colors.black,
                                                color: Color(0xffE5E7EB),
                                                layout:
                                                    PageIndicatorLayout.WARM,
                                                scale: 0.65,
                                                space: 8.sp,
                                              ),
                                            ),
                                          ),
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                )),
                      /*  Obx(() => */ Padding(
                        padding: EdgeInsets.only(top: 16.sp),
                        child: Container(
                          height: 30.sp,
                          color: Color(0xff7A6ECC),
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: Platform.isIOS ? 7.sp : 6.sp,
                                bottom: Platform.isIOS ? 5.sp : 6.sp),
                            child: Center(
                              child: Marquee(
                                text:
                                    '  ✦  More than 50+ Homegrown Brands  ✦  Fast and Reliable  ✦  Fashion for all occassions',
                                //  text:
                                //    '  ✦  DELIVERED WITHIN ${homeController.expressHour.value} HRS  ✦  MORE THAN 50 HOMEGROWN BRANDS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                //   blankSpace: 20.0,
                                velocity: 100.0,
                                pauseAfterRound: Duration(seconds: 1),
                                // startPadding: 10.0,
                                accelerationDuration: Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                          ),
                        ),
                        // )
                      ),
                      Obx(() => catalogController.isCatalog.value
                          ? const DummyGridMostSearch(
                              text: "",
                            )
                          : catalogController.catalogList.isNotEmpty
                              ? Container(
                                  color: statusBarColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 24.sp,
                                        ),
                                        child: Center(
                                          child: AppText(
                                            text: "SHOP BY CATEGORY"
                                                .toUpperCase(),
                                            fontFamily:
                                                "Franklin Gothic Semibold",
                                            fontWeight: FontWeight.w400,
                                            color: blackColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 16.sp,
                                          top: 16.sp,
                                          right: 16.sp,
                                        ),
                                        child: Center(
                                          child: GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 3,
                                            scrollDirection: Axis.vertical,
                                            padding: EdgeInsets.zero,
                                            childAspectRatio: 0.55,
                                            physics: const ScrollPhysics(),
                                            crossAxisSpacing: 12.sp,
                                            mainAxisSpacing: 0.sp,
                                            children: List.generate(
                                              catalogController
                                                  .catalogList.length,
                                              (index) {
                                                return Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        List categoryList = [];
                                                        for (var i = 0;
                                                            i <
                                                                catalogController
                                                                    .catalogList[
                                                                        index][
                                                                        "categories"]
                                                                    .length;
                                                            i++) {
                                                          categoryList.add(
                                                              catalogController
                                                                              .catalogList[
                                                                          index]
                                                                      [
                                                                      "categories"]
                                                                  [i]["id"]);
                                                        }
                                                        Get.to(CategoryProductScreen(
                                                            categoryName:
                                                                catalogController
                                                                            .catalogList[
                                                                        index]
                                                                    ["name"],
                                                            screen: "category",
                                                            genderName:
                                                                homeController
                                                                    .genderText
                                                                    .value,
                                                            categoryId: 0,
                                                            brandId: 0,
                                                            genderType:
                                                                homeController
                                                                    .homeGenderValue
                                                                    .value,
                                                            categoryList:
                                                                categoryList,
                                                            tagIds: const []))?.then(
                                                          (value) {
                                                            SystemChrome.setSystemUIOverlayStyle(
                                                                const SystemUiOverlayStyle(
                                                                    statusBarColor:
                                                                        whiteColor,
                                                                    systemNavigationBarColor:
                                                                        whiteColor));
                                                          },
                                                        );
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
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          catalogController.catalogList[
                                                                          index]
                                                                      [
                                                                      "image"] !=
                                                                  null
                                                              ? SizedBox(
                                                                  width: 104.sp,
                                                                  height:
                                                                      130.sp,
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
                                                                    imageUrl: isImage(catalogController
                                                                                .catalogList[index]
                                                                            [
                                                                            "image"])
                                                                        ? catalogController.catalogList[index]
                                                                            [
                                                                            "image"]
                                                                        : catalogController.catalogList[index]
                                                                            [
                                                                            "image"],
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 104
                                                                          .sp,
                                                                      height:
                                                                          130.sp,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Center(
                                                                  child: Image.asset(
                                                                      dummyWishlistImage,
                                                                      width: 104
                                                                          .sp,
                                                                      height: 130
                                                                          .sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.sp),
                                                            child: AppText(
                                                              text: catalogController
                                                                  .catalogList[
                                                                      index]
                                                                      ["name"]
                                                                  .toUpperCase(),
                                                              color: blackColor,
                                                              fontSize: 13,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 2,
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          widget.onPressed?.call(2);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.sp,
                                              horizontal: 16.sp),
                                          child: Container(
                                            height: 42.sp,
                                            color: homeAppBarColor,
                                            width: double.infinity,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.sp),
                                                  child: AppText(
                                                    text: "VIEW ALL"
                                                        .toUpperCase(),
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w400,
                                                    color: whiteColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.sp),
                                                  child: SvgPicture.asset(
                                                      arrowSearchImage,
                                                      color: whiteColor,
                                                      height: 7.sp,
                                                      width: 7.sp,
                                                      fit: BoxFit.cover),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24.sp,
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 0.sp,
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
                                              top: 24.sp, left: 16.sp),
                                          child: AppText(
                                            text:
                                                "Featured brands".toUpperCase(),
                                            fontFamily:
                                                "Franklin Gothic Semibold",
                                            color: blackColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 0,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            widget.onPressed?.call(1);
                                          },
                                          child: Container(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 24.sp,
                                                  right: 12.sp,
                                                  left: 20.sp,
                                                  bottom: 2.sp),
                                              child: SvgPicture.asset(
                                                  arrowViewAllImage,
                                                  height: 11.sp,
                                                  width: 7.sp,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 16.sp,
                                      ),
                                      child: SizedBox(
                                        height: 80.sp,
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
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        brandController
                                                            .brandbackground
                                                            .value = homeController
                                                                    .brandList[
                                                                index][
                                                            "background_image"];
                                                        Get.to(AllBrandScreen(
                                                                id: homeController
                                                                        .brandList[
                                                                    index]["id"],
                                                                screen: "home",
                                                                slug: ""))
                                                            ?.then(
                                                          (value) {
                                                            SystemChrome.setSystemUIOverlayStyle(
                                                                const SystemUiOverlayStyle(
                                                                    statusBarColor:
                                                                        whiteColor,
                                                                    systemNavigationBarColor:
                                                                        whiteColor));
                                                          },
                                                        );
                                                        /*   Navigator.push(
                                                                context,
                                                                scaleIn(
                                                                  BrandViewProductScreen(
                                                                      expresshour: homeController
                                                                          .expressHour
                                                                          .value,
                                                                      brand_id:
                                                                          homeController.brandList[index]
                                                                              [
                                                                              "id"],
                                                                      title: homeController.brandList[
                                                                              index]
                                                                          [
                                                                          "name"],
                                                                      screen:
                                                                          "brand",
                                                                      genderName: homeController
                                                                          .genderText
                                                                          .value),
                                                                ))
                                                            .then(
                                                                (value) =>
                                                                    setState(
                                                                      () {
                                                                        homeController
                                                                            .getBrandData("home");
                                                                        productController.getTagsProductData(
                                                                            productController.tagId.value,
                                                                            homeController.homeGenderValue.value,
                                                                            0);
                                                                      },
                                                                    ));
                                                     */
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 16.sp),
                                                        child: Container(
                                                          height: 80.sp,
                                                          width: 80.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                width: 1.sp,
                                                                color:
                                                                    dividerColor),
                                                          ),
                                                          margin: EdgeInsets.only(
                                                              right: index ==
                                                                      homeController
                                                                              .brandList
                                                                              .length -
                                                                          1
                                                                  ? 16.sp
                                                                  : 0.sp),
                                                          child: ClipOval(
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
                                                              fit: BoxFit
                                                                  .contain,
                                                              imageUrl: homeController
                                                                      .brandList[
                                                                  index]["logo"],
                                                              errorWidget: (context,
                                                                      url,
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
                                    /* Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      child: Container(
                                        width: double.infinity,
                                        color: colorSecondary,
                                        height: 1,
                                      ),
                                    ), */
                                  ],
                                )
                              : SizedBox(
                                  height: 0,
                                )),
                      Obx(() => productController.isHomeProduct.value
                          ? Padding(
                              padding: EdgeInsets.only(top: 24.sp),
                              child: DummyProductList(
                                  visibleSubtitle: true,
                                  text: "${productController.tagname.value}"
                                      .toUpperCase()),
                            )
                          : productController.homeProductList.isNotEmpty
                              ? HomeList(
                                  onPressedExplore: (p0, p1) {
                                    productController.tagId.value = p0;
                                    productController.productSortBy.value = "";
                                    productController
                                        .filterProductEnable.value = false;
                                    productController.categoryFilter.value =
                                        homeController.homeGenderValue.value;
                                    Get.to(
                                      ProductViewScreen(
                                        title: p1,
                                        genderName:
                                            homeController.genderText.value,
                                      ),
                                    )?.then(
                                      (value) {
                                        SystemChrome.setSystemUIOverlayStyle(
                                            const SystemUiOverlayStyle(
                                                statusBarColor: whiteColor,
                                                systemNavigationBarColor:
                                                    whiteColor));
                                      },
                                    );
                                  },
                                  onPressed: (p0) async {
                                    Get.to(
                                      ProductDetailsScreen(
                                        productId: p0,
                                        type: "add",
                                        brandName: "",
                                      ),
                                    )?.then((value) => setState(
                                          () {
                                            cartController.getCartData();
                                            SystemChrome.setSystemUIOverlayStyle(
                                                const SystemUiOverlayStyle(
                                                    statusBarColor: whiteColor,
                                                    systemNavigationBarColor:
                                                        whiteColor));
                                          },
                                        ));
                                    await analytics.logEvent(
                                      name: 'product_tabid_details_home_page',
                                      parameters: <String, Object>{
                                        'page_name':
                                            'product_tabid_details_home_page',
                                      },
                                    );
                                  },
                                  list: productController.homeProductList)
                              : SizedBox(
                                  height: 20.sp,
                                )),
                      /*  SizedBox(
                        height: 20.sp,
                      ) */
                      /*  Obx(() => productController.isHandPicked.value
                          ? Padding(
                              padding: EdgeInsets.only(top: 6.sp),
                              child: DummyProductList(
                                  visibleSubtitle: true,
                                  text: "HANDPICKED FOR YOU"),
                            )
                          : productController.handPickedProductList.isNotEmpty
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 6.sp),
                                      child: HomeProductList(
                                        text: "HANDPICKED FOR YOU",
                                        visibleViewAll: true,
                                        visibleSubtitle: true,
                                        text1:
                                            "Curated collection, just for you and only you.",
                                        controller: productController
                                            .handpickedController,
                                        height: 230.sp,
                                        onPressedViewAll: () async {
                                          productController
                                              .productSortBy.value = "";
                                          productController.filterProductEnable
                                              .value = false;
                                          productController.size_ids.clear();
                                          productController.color_ids.clear();
                                          productController.brand_ids.clear();
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.remove("brandList");
                                          prefs.remove("colorList");
                                          prefs.remove("sizeList");
                                          prefs.remove("upper");
                                          prefs.remove("lower");
                                          prefs.remove("sortby");
                                          prefs.remove("category");
                                          productController
                                                  .categoryFilter.value =
                                              homeController
                                                  .homeGenderValue.value;
                                          Navigator.push(
                                              context,
                                              scaleIn(
                                                ProductViewScreen(
                                                  title: "HANDPICKED FOR YOU",
                                                  genderName: homeController
                                                      .genderText.value,
                                                ),
                                              )).then((value) => setState(
                                                () {
                                                  productController
                                                      .handpickedHasnextpage
                                                      .value = true;
                                                  productController
                                                      .handpickedLoadMore
                                                      .value = false;
                                                  productController.isHandPicked
                                                      .value = false;
                                                  productController
                                                      .handpickedPage.value = 1;
                                                  productController
                                                          .categoryFilter
                                                          .value =
                                                      homeController
                                                          .homeGenderValue
                                                          .value;
                                                  productController
                                                      .getHandPickedProduct(
                                                          "",
                                                          false,
                                                          false,
                                                          productController
                                                              .tagId.value);
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
                                                      .handpickedHasnextpage
                                                      .value = true;
                                                  productController
                                                      .handpickedLoadMore
                                                      .value = false;
                                                  productController.isHandPicked
                                                      .value = false;
                                                  productController
                                                      .handpickedPage.value = 1;
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
                                        list: productController
                                            .handPickedProductList,
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
                                )), */
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
                    ],
                  ),
                ),
                /*   homeController.showGenderList.value
                    ? Container(
                        color: whiteColor,
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
                                productController.categoryFilter.value =
                                    homeController.homeGenderValue.value;
                                homeController.getBannar1Data();
                                // homeController.getBannar2Data();
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
                                    color: blackColor,
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
                                productController.categoryFilter.value =
                                    homeController.homeGenderValue.value;
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
                                    color: blackColor,
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
                                productController.categoryFilter.value =
                                    homeController.homeGenderValue.value;
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
                                    color: blackColor,
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
                      ), */
              ],
            ),
          ),
        ],
      ),
    );
  }
}
