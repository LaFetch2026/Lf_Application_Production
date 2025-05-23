// ignore_for_file: avoid_print, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

//import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
//import 'package:lafetch/commonwidget/common_widgets.dart';

//import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/change_address.dart';
import 'package:lafetch/screens/quick/brandproductscreen.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/home_controller.dart';
import '../controllers/product_controller.dart';
import '../core/constant/constants.dart';

class QuickScreen extends StatefulWidget {
  const QuickScreen({super.key});

  @override
  State<QuickScreen> createState() => QuickScreenState();
}

class QuickScreenState extends State<QuickScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final homeController = Get.put(HomeController());
  final productController = Get.put(ProductController());
  Timer? debounce;
  bool isBottomSheet = false;
  List<Placemark>? placeMarks;
  String addressString = "Fetching your Location,Please wait...";
  Placemark? address;

  @override
  void initState() {
    // getPrefrenceValue();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: homeAppBarColor,
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: homeAppBarColor));
      productController.brandController.clear();
      productController.expressBrandList.clear();
      productController.brandProductList.clear();
      productController.enableLocationText.value = "";
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.isBrand.value = false;
      productController.quickProductLoadMore.value = false;
      productController.quickProductHasnextpage.value = true;
      productController.quickProductPage.value = 1;
    });
    getCurrentLocation();
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBannar2Data();
    }); */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.quickProductListController.addListener(() {
        productController.fetchMoreBrandProductData();
        productController.update();
      });
    });
    super.initState();
  }

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      productController.getBrandProductData();
      setState(() {});
    });
  }

  /*  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("expresshour") != null) {
      homeController.expressHour.value = prefs.getString("expresshour")!;
    }
  } */

  void getCurrentLocation() async {
    Position position = await _determinePosition();
    if (productController.defaultAddress == "") {
      productController.lat.value = position.latitude;
      productController.lng.value = position.longitude;
      placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      address = placeMarks![0];
      addressString =
          "${address!.street},${address!.locality},${address!.administrativeArea}, ${address!.postalCode}";
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble("latitude", productController.lat.value);
      prefs.setDouble("longitude", productController.lng.value);
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.getExpressBrandData();
      });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.getBrandProductData();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        productController.getDefaultAddressData(0, context);
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      productController.locationText.value = "Turn on Location";
      productController.enableLocationText.value =
          "Please enable you device location";
      return Future.error(
          'Grant location permission to quickly checkout products and get it delivered to your location. Ensure your location setting is turned. ');
    }

    permission = await Geolocator.checkPermission();

    /*  if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      productController.locationText.value = "Permission Denied";
 */
    if (permission == LocationPermission.denied) {
      productController.locationText.value = "Permission Denied";
      permission = await Geolocator.requestPermission();
      return Future.error("Please enable the location to view the products");
      //  }
    }

    if (permission == LocationPermission.deniedForever) {
      productController.locationText.value = "Permission Denied Forever";
      showDialog(
        barrierColor: Colors.black26,
        context: context,
        builder: (context) {
          return showSingleBtnNonCancelableDailog(
              click1: () {
                openAppSettings().then((value) {
                  Get.back();
                });
              },
              btncolor: colorPrimary,
              text:
                  "Location services are disabled. Please enable the services",
              btn1Text: "Open Location Settings");
        },
      );

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied');
      }
    }

    productController.locationText.value = "";
    productController.isBrand.value = true;
    productController.isExpressBrand.value = true;
    setState(() {});
    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  /*  void FetchProduct() async {
    productController.locationText.value = "";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('latitude') != null) {
      productController.lat.value = prefs.getDouble('latitude')!;
      productController.lng.value = prefs.getDouble('longitude')!;
    }
    // productController.isBrandProduct.value = true;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.getExpressBrandData();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.getBrandProductData();
    });
  } */

  /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location not enable");
      } else {
        getCurrentLocation();
      }
    }
  } */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(const BottomNavScreen(
          index: 0,
        ));
        return false;
      },
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
            sigmaX: isBottomSheet ? 1 : 0, sigmaY: isBottomSheet ? 1 : 0),
        child: Scaffold(
          backgroundColor: homeAppBarColor,
          body: SingleChildScrollView(
            controller: productController.quickProductListController,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.1, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      quickBack,
                      height: 250.sp,
                      width: 300.sp,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 56.sp, left: 16.sp, right: 16.sp),
                      child: Row(
                        children: [
                          Container(
                            height: 50.sp,
                            width: 50.sp,
                            decoration: BoxDecoration(
                              color: purpleColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.sp)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(1.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(() => AppText(
                                        text:
                                            "${homeController.expressHour.value}",
                                        color: whiteColor,
                                        fontSize: 18,
                                        fontFamily: "Franklin Gothic Semibold",
                                        fontWeight: FontWeight.w500,
                                      )),
                                  AppText(
                                    text: "HRS",
                                    color: whiteColor,
                                    fontSize: 14,
                                    fontFamily: "Franklin Gothic",
                                  )
                                ],
                              ),
                            ),
                          ),
                          Obx(() => productController.isAddress.value
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 20.sp,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.sp,
                                        color: cardBg,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 2.sp),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2 +
                                              40.sp,
                                          height: 20.sp,
                                          color: cardBg,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : productController.defaultAddress != ""
                                  ? InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isBottomSheet = true;
                                        });
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          constraints: BoxConstraints(
                                              maxWidth: double.infinity,
                                              maxHeight: 600.sp,
                                              minHeight: 500.sp),
                                          builder: (ctx) {
                                            return ChangeAddressScreen(
                                              cartId: 0,
                                            );
                                          },
                                        ).whenComplete(() {
                                          productController
                                              .getBrandProductData();
                                          productController
                                              .getExpressBrandData();
                                          setState(() {
                                            isBottomSheet = false;
                                          });
                                        });
                                        await analytics.logEvent(
                                          name: 'quick_select_address',
                                          parameters: <String, Object>{
                                            'page_name': 'quick_select_address',
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                AppText(
                                                  text: productController
                                                      .defaultAddress["name"],
                                                  color: whiteColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Franklin Gothic Semibold",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4.sp),
                                                  child: SvgPicture.asset(
                                                    dropdownSvgImage,
                                                    height: 6.sp,
                                                    width: 8.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 +
                                                  40.sp,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 4.sp),
                                                child: AppText(
                                                  text:
                                                      "${productController.defaultAddress["address"]},${productController.defaultAddress["city"]["name"]},${productController.defaultAddress["city"]["state"]["name"]}",
                                                  color: whiteColor,
                                                  fontSize: 12,
                                                  maxLines: 1,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width -
                                          90.sp,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.sp),
                                        child: AppText(
                                          text: addressString,
                                          color: whiteColor,
                                          fontSize: 12,
                                          maxLines: 3,
                                          fontFamily: "Franklin Gothic Regular",
                                        ),
                                      ),
                                    ))
                        ],
                      ),
                    ),
                    /*  ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(25)), // Adjust the radius as needed
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: 10.0,
                            sigmaY: 10.0), // Adjust the blur intensity
                        child: Container(
                          width: 300, // Adjust the width as needed
                          height: 50, // Adjust the height as needed
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(
                                0.2), // Adjust the color and opacity
                            borderRadius: BorderRadius.all(Radius.circular(
                                25)), // Adjust the radius as needed
                          ),
                          child: Center(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ), */
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16.sp, top: 24.sp, right: 16.sp, bottom: 24.sp),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.sp)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.sp)),
                              ),
                              child: RawKeyboardListener(
                                focusNode: FocusNode(),
                                onKey: (value) {
                                  print(value);
                                  if (value is RawKeyDownEvent) {
                                    productController.getBrandProductData();
                                    //  productController.brandController.clear();
                                    // setState(() {});
                                  }
                                },
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                      color: colorSecondary,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontSize: 14.sp),
                                  controller: productController.brandController,
                                  onChanged: onSearchChanged,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    fillColor:
                                        Color(0xff443e73).withOpacity(0.1),
                                    prefixIcon: IconButton(
                                      icon: SvgPicture.asset(searchSvgImage,
                                          color: searchTextColor,
                                          height: 17.sp,
                                          width: 17.sp,
                                          fit: BoxFit.cover),
                                      onPressed: () {},
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.sp),
                                        borderSide: BorderSide(
                                            color:
                                                appBarColor.withOpacity(0.5))),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.sp),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.sp),
                                      borderSide: BorderSide(
                                          color: appBarColor.withOpacity(0.5)),
                                    ),
                                    counterText: "",
                                    hintText: "Search for 'Brands'",
                                    hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        color: searchTextColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => productController.enableLocationText.isNotEmpty
                        ? Container(
                            color: Colors.transparent,
                            margin: EdgeInsets.only(bottom: 10.sp),
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp, vertical: 4.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Please Turn on your device location",
                                    fontFamily: "Franklin Gothic Regular",
                                    color: redColor,
                                    fontSize: 12,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          )),
                    Obx(() => productController.locationText.isNotEmpty
                        ? Container(
                            color: redColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp, vertical: 4.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.zero,
                                        child: AppText(
                                          text:
                                              "Location Permission isn't given",
                                          fontFamily: "Franklin Gothic Regular",
                                          color: whiteColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          openAppSettings().then((value) async {
                                            getCurrentLocation();
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: deepRed,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(2))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: AppText(
                                              text: "Give Permission",
                                              fontFamily:
                                                  "Franklin Gothic Bold",
                                              color: whiteColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          )),
                    /*  Obx(() => Visibility(
                          visible: productController.brandController.text
                                  .toString()
                                  .trim()
                                  .isEmpty
                              ? true
                              : false,
                          child: homeController.isBanner2.value
                              ? Padding(
                                  padding: EdgeInsets.only(top: 24.sp),
                                  child: SizedBox(
                                    height: 128.sp,
                                    width: double.infinity,
                                    child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: 5,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (ctx, index) {
                                          return Container(
                                            height: 128.sp,
                                            width:
                                                MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: cardBg,
                                            ),
                                          );
                                        }),
                                  ))
                              : homeController.banner2List.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 24.sp),
                                          child: CarouselSlider.builder(
                                            itemCount:
                                                homeController.banner2List.length,
                                            options: CarouselOptions(
                                              height: 128.sp,
                                              viewportFraction: 1.0,
                                              aspectRatio: 2.0,
                                              autoPlay: true,
                                              onPageChanged: (index, reason) {
                                                homeController.currentPage.value =
                                                    index;
                                                homeController.update();
                                              },
                                              autoPlayInterval:
                                                  const Duration(seconds: 3),
                                              enlargeCenterPage: true,
                                            ),
                                            itemBuilder: (BuildContext context,
                                                    int itemIndex,
                                                    int pageViewIndex) =>
                                                GestureDetector(
                                              onTap: () async {
                                                homeController.bannerTag1Id
                                                    .clear();
                                                homeController.bannerCategory1Id
                                                    .clear();
                                                productController.productCategory
                                                    .clear();
                                                productController.productTags
                                                    .clear();

                                                for (var i = 0;
                                                    i <
                                                        homeController
                                                            .banner2List[
                                                                itemIndex]["tags"]
                                                            .length;
                                                    i++) {
                                                  homeController.bannerTag1Id.add(
                                                      homeController.banner2List[
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
                                                  homeController.bannerCategory1Id
                                                      .add(homeController
                                                                  .banner2List[
                                                              itemIndex][
                                                          "categories"][i]["id"]);
                                                }
                                                productController
                                                        .productCategory =
                                                    homeController
                                                        .bannerCategory1Id;
                                                productController.productTags =
                                                    homeController.bannerTag1Id;
                                                Navigator.push(
                                                    context,
                                                    scaleIn(
                                                      CategoryProductScreen(
                                                        genderName: "",
                                                        categoryName:
                                                            homeController
                                                                    .banner2List[
                                                                itemIndex]["name"],
                                                        categoryId: 0,
                                                        brandId: 0,
                                                        genderType: homeController
                                                            .homeGenderValue
                                                            .value,
                                                        tagIds: homeController
                                                            .bannerTag1Id,
                                                        categoryList:
                                                            homeController
                                                                .bannerCategory1Id,
                                                      ),
                                                    ));
                                                await analytics.logEvent(
                                                  name: 'banner_home_page',
                                                  parameters: <String, Object>{
                                                    'page_name':
                                                        'banner_home_page',
                                                  },
                                                );
                                              },
                                              child: CachedNetworkImage(
                                                cacheManager: CacheManager(Config(
                                                    "customCacheKey",
                                                    stalePeriod:
                                                        const Duration(days: 15),
                                                    maxNrOfCacheObjects: 100)),
                                                fit: BoxFit.fill,
                                                imageUrl: homeController
                                                        .banner2List[itemIndex]
                                                    ["image"],
                                                height: 128.sp,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child: Container(
                                                    height: 128.sp,
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    decoration: BoxDecoration(
                                                      color: cardBg,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  downloadImage,
                                                  height: 128.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                        )), */
                    Visibility(
                      visible: productController.brandController.text
                              .toString()
                              .trim()
                              .isEmpty
                          ? true
                          : false,
                      child: Container(
                        width: double.infinity,
                        child: Lottie.asset(
                          width: double.infinity,
                          fit: BoxFit.cover,
                          quickLottie,
                        ),
                      ),
                    ),
                    /*  Obx(() => */ Visibility(
                      visible: productController.brandController.text
                              .toString()
                              .trim()
                              .isEmpty
                          ? true
                          : false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 24.sp,
                        ),
                        child: Container(
                          height: 30.sp,
                          color: expressDeliveryBanner,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: Platform.isIOS ? 7.sp : 6.sp,
                                bottom: Platform.isIOS ? 5.sp : 6.sp),
                            child: Center(
                              child: Marquee(
                                text:
                                    '  ✦  More than 50+ Homegrown Brands  ✦  Delivered in 30 mins',
                                //text:
                                //      '  ✦  DELIVERED WITHIN ${homeController.expressHour.value} HRS  ✦  MORE THAN 50 HOMEGROWN BRANDS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // blankSpace: 20.0,
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
                      ),
                      // )
                    ),
                    Obx(() => Visibility(
                          visible: productController.brandController.text
                                  .toString()
                                  .trim()
                                  .isEmpty
                              ? true
                              : false,
                          child: productController.isExpressBrand.value
                              ? Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 24.sp,
                                              left: 16.sp,
                                              right: 16.sp),
                                          child: Container(
                                            height: 20.sp,
                                            width: 120.sp,
                                            decoration: BoxDecoration(
                                              color: cardBg,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 16.sp,
                                          bottom: 16.sp,
                                        ),
                                        child: SizedBox(
                                          height: 80.sp,
                                          child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: 5,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (ctx, index) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 12.sp),
                                                  child: Container(
                                                    height: 80.sp,
                                                    width: 80.sp,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: cardBg,
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : productController.expressBrandList.isNotEmpty
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 24.sp,
                                              left: 16.sp,
                                              right: 16.sp),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: SvgPicture.asset(
                                                  leftLineSvgImage,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.sp),
                                                child: AppText(
                                                  text: "Featured brands"
                                                      .toUpperCase(),
                                                  fontFamily: "Franklin Gothic",
                                                  color:
                                                      expressDeliveryFeaturedBrandsColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Expanded(
                                                child: SvgPicture.asset(
                                                  rightLineSvgImage,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 16.sp,
                                            bottom: 16.sp,
                                          ),
                                          child: SizedBox(
                                            height: 80.sp,
                                            child: ListView.builder(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemCount: productController
                                                    .expressBrandList.length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (ctx, index) {
                                                  return productController
                                                                  .expressBrandList[
                                                              index]["logo"] !=
                                                          null
                                                      ? GestureDetector(
                                                          onTap: () async {
                                                            /*  Get.to(AllBrandScreen(
                                                                    id: homeController
                                                                            .brandList[index]
                                                                        ["id"],
                                                                    screen:
                                                                        "home",
                                                                    slug: ""))
                                                                ?.then(
                                                                    (value) =>
                                                                        setState(
                                                                          () {
                                                                            homeController.getBrandData("express");
                                                                          },

                                                                        )); */
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            final prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            prefs.remove(
                                                                "brandList");
                                                            prefs.remove(
                                                                "colorList");
                                                            prefs.remove(
                                                                "sizeList");
                                                            prefs.remove(
                                                                "upper");
                                                            prefs.remove(
                                                                "lower");
                                                            prefs.remove(
                                                                "sortby");
                                                            prefs.remove(
                                                                "category");
                                                            productController
                                                                .productSortBy
                                                                .value = "";
                                                            productController
                                                                .filterProductEnable
                                                                .value = false;
                                                            productController
                                                                .categoryFilter
                                                                .value = 0;
                                                            Get.to(BrandViewProductScreen(
                                                                    screen:
                                                                        "quick",
                                                                    expresshour:
                                                                        homeController
                                                                            .expressHour
                                                                            .value,
                                                                    brand_id:
                                                                        productController.expressBrandList[index][
                                                                            "id"],
                                                                    title: productController
                                                                            .expressBrandList[index]
                                                                        [
                                                                        "name"],
                                                                    genderName:
                                                                        ""))
                                                                ?.then(
                                                                    (value) =>
                                                                        setState(
                                                                          () {
                                                                            productController.productSortBy.value =
                                                                                "";
                                                                            productController.filterProductEnable.value =
                                                                                false;
                                                                            productController.categoryFilter.value =
                                                                                0;
                                                                            productController.getBrandDetailsProduct(
                                                                                "",
                                                                                false,
                                                                                false,
                                                                                0,
                                                                                "quick");
                                                                          },
                                                                        ));
                                                            await analytics
                                                                .logEvent(
                                                              name:
                                                                  'quick_featurebrand_click',
                                                              parameters: <String,
                                                                  Object>{
                                                                'page_name':
                                                                    'quick_featurebrand_click',
                                                              },
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left:
                                                                        16.sp),
                                                            child: Container(
                                                              height: 80.sp,
                                                              width: 80.sp,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    width: 1.sp,
                                                                    color: Color(
                                                                        0x59897CE6)),
                                                              ),
                                                              margin: EdgeInsets.only(
                                                                  right: index ==
                                                                          productController.expressBrandList.length -
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
                                                                      stalePeriod: const Duration(
                                                                          days:
                                                                              15),
                                                                      maxNrOfCacheObjects:
                                                                          100)),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  imageUrl: productController
                                                                              .expressBrandList[
                                                                          index]
                                                                      ["logo"],
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    downloadImage,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    height:
                                                                        80.sp,
                                                                    width:
                                                                        80.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 12.sp),
                                                          child: CircleAvatar(
                                                            child: Image.asset(
                                                                dummyWishlistImage,
                                                                height: 80.sp,
                                                                width: 80.sp,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        );
                                                }),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.sp,
                                              right: 16.sp,
                                              bottom: 12.sp),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                leftLineSvgImage,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    16.sp,
                                              ),
                                              SvgPicture.asset(
                                                rightLineSvgImage,
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    16.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                        )),
                    Obx(() => productController.isBrand.value
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: 16.sp,
                                right: 16.sp,
                                bottom: 10.sp,
                                top: 12.sp),
                            child: ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: 2,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 24.sp),
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                      vertical: 12.sp),
                                                  child: Container(
                                                    height: 20.sp,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width
                                                            .sp,
                                                    decoration: BoxDecoration(
                                                      color: cardBg,
                                                    ),
                                                  )),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 16.sp, bottom: 16.sp),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  height: 220.sp,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      primary: false,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemCount: 3,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 16
                                                                          .sp),
                                                              color: cardBg,
                                                              height: 170.sp,
                                                              width: 136.sp,
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 8.sp,
                                                                      left: 16
                                                                          .sp),
                                                              child: Container(
                                                                color: cardBg,
                                                                height: 16.sp,
                                                                width: 100.sp,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 8.sp,
                                                                      left: 16
                                                                          .sp),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right: 6
                                                                            .sp),
                                                                    child:
                                                                        Container(
                                                                      color:
                                                                          cardBg,
                                                                      height:
                                                                          16.sp,
                                                                      width:
                                                                          40.sp,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    color:
                                                                        cardBg,
                                                                    height:
                                                                        16.sp,
                                                                    width:
                                                                        40.sp,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          )
                        : productController.brandProductList.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    left: 16.sp,
                                    right: 16.sp,
                                    bottom: 10.sp,
                                    top: 22.sp),
                                child: GetBuilder<ProductController>(
                                  builder: (value) => ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      controller:
                                          value.quickProductListController,
                                      physics: const ScrollPhysics(),
                                      itemCount: value.brandProductList.length,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (ctx, index) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 24.sp),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.sp),
                                                    color: cardBg),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {},
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12.sp,
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            value.brandProductList[
                                                                            index]
                                                                        [
                                                                        "logo"] !=
                                                                    null
                                                                ? Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 10
                                                                            .sp,
                                                                        bottom:
                                                                            10.sp),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          32.sp,
                                                                      width:
                                                                          32.sp,
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            whiteColor,
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border:
                                                                                Border.all(width: 1.sp, color: lightgreyColor),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.all(8.0.sp),
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              height: 32.sp,
                                                                              width: 32.sp,
                                                                              cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                              fit: BoxFit.cover,
                                                                              imageUrl: value.brandProductList[index]["logo"],
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                downloadImage,
                                                                                height: 32.sp,
                                                                                width: 32.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 10
                                                                            .sp,
                                                                        bottom:
                                                                            10.sp),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          32.sp,
                                                                      width:
                                                                          32.sp,
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            whiteColor,
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.all(8.0.sp),
                                                                            child: Image.asset(dummyWishlistImage,
                                                                                height: 32.sp,
                                                                                width: 32.sp,
                                                                                fit: BoxFit.cover),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                            InkWell(
                                                              onTap: () async {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                final prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                prefs.remove(
                                                                    "brandList");
                                                                prefs.remove(
                                                                    "colorList");
                                                                prefs.remove(
                                                                    "sizeList");
                                                                prefs.remove(
                                                                    "upper");
                                                                prefs.remove(
                                                                    "lower");
                                                                prefs.remove(
                                                                    "sortby");
                                                                prefs.remove(
                                                                    "category");
                                                                productController
                                                                    .productSortBy
                                                                    .value = "";
                                                                productController
                                                                    .filterProductEnable
                                                                    .value = false;
                                                                productController
                                                                    .categoryFilter
                                                                    .value = 0;
                                                                Get.to(BrandViewProductScreen(
                                                                        screen:
                                                                            "quick",
                                                                        expresshour: homeController
                                                                            .expressHour
                                                                            .value,
                                                                        brand_id: value.brandProductList[index]
                                                                            [
                                                                            "id"],
                                                                        title: value.brandProductList[index]
                                                                            [
                                                                            "name"],
                                                                        genderName:
                                                                            ""))
                                                                    ?.then((value) =>
                                                                        setState(
                                                                          () {
                                                                            productController.productSortBy.value =
                                                                                "";
                                                                            productController.filterProductEnable.value =
                                                                                false;
                                                                            productController.categoryFilter.value =
                                                                                0;
                                                                            productController.getBrandDetailsProduct(
                                                                                "",
                                                                                false,
                                                                                false,
                                                                                0,
                                                                                "quick");
                                                                          },
                                                                        ));
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'quick_brandname_click',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'quick_brandname_click',
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal: 8
                                                                            .sp,
                                                                        vertical:
                                                                            12.sp),
                                                                child: AppText(
                                                                  text: value
                                                                          .brandProductList[
                                                                              index]
                                                                              [
                                                                              "name"]
                                                                          .toUpperCase() ??
                                                                      "",
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      "Franklin Gothic Semibold",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            const Expanded(
                                                              child: SizedBox(
                                                                width: 0,
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () async {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                final prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                prefs.remove(
                                                                    "brandList");
                                                                prefs.remove(
                                                                    "colorList");
                                                                prefs.remove(
                                                                    "sizeList");
                                                                prefs.remove(
                                                                    "upper");
                                                                prefs.remove(
                                                                    "lower");
                                                                prefs.remove(
                                                                    "sortby");
                                                                prefs.remove(
                                                                    "category");
                                                                productController
                                                                    .productSortBy
                                                                    .value = "";
                                                                productController
                                                                    .filterProductEnable
                                                                    .value = false;
                                                                productController
                                                                    .categoryFilter
                                                                    .value = 0;
                                                                Get.to(BrandViewProductScreen(
                                                                        screen:
                                                                            "quick",
                                                                        expresshour: homeController
                                                                            .expressHour
                                                                            .value,
                                                                        brand_id: value.brandProductList[index]
                                                                            [
                                                                            "id"],
                                                                        title: value.brandProductList[index]
                                                                            [
                                                                            "name"],
                                                                        genderName:
                                                                            ""))
                                                                    ?.then((value) =>
                                                                        setState(
                                                                          () {
                                                                            productController.productSortBy.value =
                                                                                "";
                                                                            productController.filterProductEnable.value =
                                                                                false;
                                                                            productController.categoryFilter.value =
                                                                                0;
                                                                            productController.getBrandDetailsProduct(
                                                                                "",
                                                                                false,
                                                                                false,
                                                                                0,
                                                                                "quick");
                                                                          },
                                                                        ));
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'quick_brandviewall_click',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'quick_brandviewall_click',
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 8
                                                                            .sp,
                                                                        top: 10
                                                                            .sp,
                                                                        bottom:
                                                                            10.sp),
                                                                child: AppText(
                                                                  text: "VIEW ALL"
                                                                      .toUpperCase(),
                                                                  fontFamily:
                                                                      "Franklin Gothic",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () async {
                                                                final prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                prefs.remove(
                                                                    "brandList");
                                                                prefs.remove(
                                                                    "colorList");
                                                                prefs.remove(
                                                                    "sizeList");
                                                                prefs.remove(
                                                                    "upper");
                                                                prefs.remove(
                                                                    "lower");
                                                                prefs.remove(
                                                                    "sortby");
                                                                prefs.remove(
                                                                    "category");
                                                                productController
                                                                    .productSortBy
                                                                    .value = "";
                                                                productController
                                                                    .filterProductEnable
                                                                    .value = false;
                                                                productController
                                                                    .categoryFilter
                                                                    .value = 0;
                                                                Get.to(BrandViewProductScreen(
                                                                        screen:
                                                                            "quick",
                                                                        expresshour: homeController
                                                                            .expressHour
                                                                            .value,
                                                                        brand_id: value.brandProductList[index]
                                                                            [
                                                                            "id"],
                                                                        title: value.brandProductList[index]
                                                                            [
                                                                            "name"],
                                                                        genderName:
                                                                            ""))
                                                                    ?.then((value) =>
                                                                        setState(
                                                                          () {
                                                                            productController.productSortBy.value =
                                                                                "";
                                                                            productController.filterProductEnable.value =
                                                                                false;
                                                                            productController.categoryFilter.value =
                                                                                0;
                                                                            productController.getBrandDetailsProduct(
                                                                                "",
                                                                                false,
                                                                                false,
                                                                                0,
                                                                                "quick");
                                                                          },
                                                                        ));
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left: 8
                                                                            .sp,
                                                                        top: 10
                                                                            .sp,
                                                                        bottom:
                                                                            10.sp),
                                                                child: SvgPicture.asset(
                                                                    arrowSearchImage,
                                                                    color:
                                                                        whiteColor,
                                                                    height:
                                                                        7.sp,
                                                                    width: 7.sp,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    BrandProductList(
                                                        onPressed:
                                                            (p0, p1) async {
                                                          Get.to(ProductDetailsScreen(
                                                                  expresshour:
                                                                      homeController
                                                                          .expressHour
                                                                          .value,
                                                                  backgroundcolor:
                                                                      homeAppBarColor,
                                                                  brandName: p1,
                                                                  productId: p0,
                                                                  expressValue:
                                                                      1,
                                                                  type: "add"))
                                                              ?.then((value) =>
                                                                  setState(
                                                                    () {
                                                                      productController
                                                                          .getBrandProductData();
                                                                    },
                                                                  ));
                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'quick_product_details',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'quick_product_details',
                                                            },
                                                          );
                                                        },
                                                        list: value
                                                                .brandProductList[
                                                            index]["products"])
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Obx(() => productController
                                          .locationText.isEmpty
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Center(
                                            child: Image.asset(errorImage,
                                                height: 200.sp,
                                                width: 220.sp,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        )),
                                  Padding(
                                      padding: EdgeInsets.only(
                                        top: 6.sp,
                                        bottom: 20.sp,
                                        right: 20.sp,
                                        left: 20.sp,
                                      ),
                                      child: Obx(
                                        () => productController
                                                .locationText.isNotEmpty
                                            ? Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      openAppSettings()
                                                          .then((value) async {
                                                        getCurrentLocation();
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.sp),
                                                      child: Text(
                                                          "Grant location permission",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: whiteColor,
                                                              fontFamily:
                                                                  "Franklin Gothic")),
                                                    ),
                                                  ),
                                                  Text(" or ",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: whiteColor,
                                                          fontFamily:
                                                              "Franklin Gothic")),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: double
                                                                    .infinity,
                                                                maxHeight:
                                                                    600.sp,
                                                                minHeight:
                                                                    500.sp),
                                                        builder: (ctx) {
                                                          return ChangeAddressScreen(
                                                            cartId: 0,
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                        "select an address",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: whiteColor,
                                                            fontFamily:
                                                                "Franklin Gothic")),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: double
                                                                    .infinity,
                                                                maxHeight:
                                                                    600.sp,
                                                                minHeight:
                                                                    500.sp),
                                                        builder: (ctx) {
                                                          return ChangeAddressScreen(
                                                            cartId: 0,
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        "to quickly checkout and get products delivered to your location. Ensure your location setting is turned on.",
                                                        maxLines: 4,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: whiteColor,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Text(
                                                // "${'"'}${"NO BRAND FOUND"}${'"'}",
                                                productController
                                                        .brandController.text
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty
                                                    ? "No ${productController.brandController.text} found"
                                                        .toUpperCase()
                                                    : productController
                                                            .brandProductdetails
                                                            .containsKey(
                                                                'message')
                                                        ? productController
                                                                .brandProductdetails[
                                                            "message"]
                                                        : "Coming Soon to Your Area",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: whiteColor,
                                                    fontFamily:
                                                        "Franklin Gothic")),
                                      )),
                                ],
                              )),
                    Obx(() => productController.quickProductLoadMore.value
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: 16.sp,
                                right: 16.sp,
                                bottom: 10.sp,
                                top: 12.sp),
                            child: ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: 2,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 24.sp),
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.sp,
                                                      vertical: 12.sp),
                                                  child: Container(
                                                    height: 20.sp,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width
                                                            .sp,
                                                    decoration: BoxDecoration(
                                                      color: cardBg,
                                                    ),
                                                  )),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 16.sp, bottom: 16.sp),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  height: 220.sp,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      primary: false,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemCount: 3,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 16
                                                                          .sp),
                                                              color: cardBg,
                                                              height: 170.sp,
                                                              width: 136.sp,
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 8.sp,
                                                                      left: 16
                                                                          .sp),
                                                              child: Container(
                                                                color: cardBg,
                                                                height: 16.sp,
                                                                width: 100.sp,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 8.sp,
                                                                      left: 16
                                                                          .sp),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right: 6
                                                                            .sp),
                                                                    child:
                                                                        Container(
                                                                      color:
                                                                          cardBg,
                                                                      height:
                                                                          16.sp,
                                                                      width:
                                                                          40.sp,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    color:
                                                                        cardBg,
                                                                    height:
                                                                        16.sp,
                                                                    width:
                                                                        40.sp,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          )
                        : const SizedBox(
                            height: 0,
                          )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
