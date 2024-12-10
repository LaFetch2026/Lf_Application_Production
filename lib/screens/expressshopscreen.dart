// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lafetch/commonwidget/appbarwidgets/home_appbar.dart';
//import 'package:lafetch/commonwidget/smallbtn.dart';
import 'package:lafetch/screens/expressshopping/viewall.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commonwidget/app_text.dart';
//import '../commonwidget/common_widgets.dart';
import '../controller/brand_controller.dart';
import '../controller/product_controller.dart';
import '../utils/constants.dart';
import 'bottomnavscreen.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class ExpressShoppingScreen extends StatefulWidget {
  const ExpressShoppingScreen({super.key});

  @override
  State<ExpressShoppingScreen> createState() => ExpressShoppingScreenState();
}

class ExpressShoppingScreenState extends State<ExpressShoppingScreen> {
  final brandController = Get.put(BrandController());
  final productController = Get.put(ProductController());
  int current = 0;
  PageController pageController = PageController();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late GoogleMapController googleMapController;
  String locationText = "Please enable the location to view the products";

  @override
  void initState() {
    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.brandListController.addListener(() {
        brandController.fetchMoreData("express");
        brandController.update();
      });
    });
    productController.productExpressBrandList.clear();
    brandController.hasnextpage.value = true;
    brandController.loadMore.value = false;
    brandController.isBrand.value = false;
    brandController.page.value = 1;
    productController.isBrandProduct.value = false;
    productController.brand_id.value = 0;
    productController.brandExpressHasnextpage.value = true;
    productController.brandExpressLoadMore.value = false;
    productController.isBrandExpressProduct.value = false;
    productController.brandExpressPage.value = 1;
    productController.filterExpressEnable.value = false;
    super.initState();
  }

  callOnchanged(int index) {
    setState(() {
      current = index;
    });
  }

  void getCurrentLocation() async {
    Position position = await _determinePosition();
    productController.lat.value = position.latitude;
    productController.lng.value = position.longitude;
    //productController.lat.value = 12.9029224;
    // productController.lng.value = 77.6330036;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("latitude", productController.lat.value);
    prefs.setDouble("longitude", productController.lng.value);
    productController.isBrandProduct.value = true;
    setState(() {});
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData("express"));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Turn on Location")));
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Please enable the location to view the products");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    locationText = "Fetching Location";
    setState(() {});
    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("brandList");
        prefs.remove("colorList");
        prefs.remove("sizeList");
        prefs.remove("upper");
        prefs.remove("lower");
        Get.offAll(const BottomNavScreen(
          index: 0,
        ));
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedSearch: () async {
                Get.to(const SearchScreen());
                await analytics.logEvent(
                  name: 'search_page',
                  parameters: <String, Object>{
                    'page_name': 'search_page',
                  },
                );
              },
              onPressedCatalog: () async {
                Get.to(const CatalogScreen());
                await analytics.logEvent(
                  name: 'catalog_page',
                  parameters: <String, Object>{
                    'page_name': 'catalog_page',
                  },
                );
              },
              onPressedCart: () async {
                Get.to(const CartScreen());
                await analytics.logEvent(
                  name: 'cart_page',
                  parameters: <String, Object>{
                    'page_name': 'cart_page',
                  },
                );
              },
            ),
            /*  Container(
              height: 40,
              color: greyBack,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 5),
                    child: ImageIcon(
                      AssetImage(shopImage),
                      color: expressText,
                      size: 20,
                    ),
                  ),
                  AppText(
                    text: "Delivered at your doorstep in the next 4 hours",
                    color: expressText,
                    maxLines: 2,
                    fontSize: 12.sp,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ), */
            Padding(
              padding: EdgeInsets.only(
                  top: 20.sp, left: 16.sp, right: 16.sp, bottom: 5.sp),
              child: AppText(
                text: "Express Shop",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: blackColor,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(
              () => productController.lat.value != 0
                  ? brandController.isBrand.value
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: 16.sp, bottom: 10.sp, right: 16.sp),
                          child: SizedBox(
                            height: 30.sp,
                            width: double.infinity,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: 5,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 5.sp),
                                    width: 100.sp,
                                    height: 30.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.04),
                                      borderRadius:
                                          BorderRadius.circular(20.sp),
                                    ),
                                  );
                                }),
                          ))
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
                              child: SizedBox(
                                  width: double.infinity,
                                  height: 50.sp,
                                  child: GetBuilder<BrandController>(
                                    builder: (value) => ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: value.brandList.length + 1,
                                        scrollDirection: Axis.horizontal,
                                        controller: value.brandListController,
                                        itemBuilder: (ctx, index) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  current = index;
                                                  if (index == 0) {
                                                    productController
                                                        .brand_id.value = 0;
                                                  } else {
                                                    productController
                                                            .brand_id.value =
                                                        value.brandList[
                                                            index - 1]["id"];
                                                  }
                                                  productController
                                                      .brandExpressHasnextpage
                                                      .value = true;
                                                  productController
                                                      .brandExpressLoadMore
                                                      .value = false;
                                                  productController
                                                      .isBrandExpressProduct
                                                      .value = false;
                                                  productController
                                                      .brandExpressPage
                                                      .value = 1;
                                                  productController
                                                      .isBrandProduct
                                                      .value = true;
                                                  productController.update();
                                                  setState(() {});
                                                  pageController.animateToPage(
                                                    current,
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    curve: Curves.ease,
                                                  );
                                                  await analytics.logEvent(
                                                    name:
                                                        'express_page_brandtabclick',
                                                    parameters: <String,
                                                        Object>{
                                                      'page_name':
                                                          'express_page_brandtabclick',
                                                    },
                                                  );
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  margin: EdgeInsets.only(
                                                      right: 5.sp),
                                                  width: 100.sp,
                                                  height: 30.sp,
                                                  decoration: BoxDecoration(
                                                    color: current == index
                                                        ? btnTextColor
                                                        : whiteBorderColor,
                                                    borderRadius: current ==
                                                            index
                                                        ? BorderRadius.circular(
                                                            20)
                                                        : BorderRadius.circular(
                                                            20),
                                                    border: current == index
                                                        ? Border.all(
                                                            color: btnTextColor,
                                                            width: 1)
                                                        : Border.all(
                                                            color:
                                                                textHintColor,
                                                            width: 1),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.sp),
                                                    child: Center(
                                                      child: AppText(
                                                        text: index == 0
                                                            ? "View All"
                                                            : value.brandList[
                                                                    index - 1]
                                                                ["name"],
                                                        color: current == index
                                                            ? whiteBorderColor
                                                            : textHintColor,
                                                        fontSize: 12,
                                                        fontFamily:
                                                            "Franklin Gothic",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                  )),
                            ),
                          ],
                        )
                  : SizedBox(
                      height: 0,
                    ),
            ),
            Obx(
              () => productController.lat.value != 0 &&
                      productController.isBrandProduct.value
                  ? /* brandController.isBrand.value
                      //  ? const Expanded(child: DummyGridList())
                      : */
                  Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: callOnchanged,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ViewAllScreen(
                            brandId: productController.brand_id.value,
                          );
                        },
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 30.sp, left: 16.sp, right: 16.sp),
                            child: Text("$locationText",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: "Franklin Gothic Regular")),
                          ),
                        ),
                        /* Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 16.sp),
                          child: Center(
                            child: SmallButton(
                                label: "Turn on Location",
                                textColor: whiteColor,
                                onPressed: () {
                                  showDialog(
                                    barrierColor: Colors.black26,
                                    context: context,
                                    builder: (context) {
                                      return showSingleBtnNonCancelableDailog(
                                          click1: () {
                                            Geolocator.openLocationSettings()
                                                .then((value) => Get.back());
                                          },
                                          btncolor: colorPrimary,
                                          text:
                                              "Location services are disabled. Please enable the services",
                                          btn1Text: "Open Location Settings");
                                    },
                                  );
                                },
                                backgroundColor: colorPrimary,
                                borderColor: borderColor,
                                width: 150.sp),
                          ),
                        ) */
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
