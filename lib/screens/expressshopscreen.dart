// ignore_for_file: avoid_print
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//import 'package:lafetch/commonwidget/smallbtn.dart';
import 'package:lafetch/screens/expressshopping/viewall.dart';
import 'package:lafetch/screens/searchscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import '../commonwidget/common_widgets.dart';

import '../common/widget/appbar/home_appbar.dart';
import '../common/widget/lists/dummy_container.dart';
import '../common/widget/other/common_widget.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/brand_controller.dart';
import '../controllers/product_controller.dart';
import '../core/constant/constants.dart';
import 'bottomnavscreen.dart';
import 'cartscreen.dart';
import 'mapscreen.dart';

class ExpressShoppingScreen extends StatefulWidget {
  const ExpressShoppingScreen({super.key});

  @override
  State<ExpressShoppingScreen> createState() => ExpressShoppingScreenState();
}

class ExpressShoppingScreenState extends State<ExpressShoppingScreen>
    with WidgetsBindingObserver {
  final brandController = Get.put(BrandController());
  final productController = Get.put(ProductController());
  int current = 0;
  PageController pageController = PageController();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late GoogleMapController googleMapController;
  String locationText = "Please enable the location to view the products";

  @override
  void initState() {
    if (productController.lat.value == 0) {
      getCurrentLocation();
    } else {
      FetchProduct();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.brandListController.addListener(() {
        // brandController.fetchMoreData("express");
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
    productController.showAddressList.value = false;
    productController.addressText.value = "";
    productController.addressTypeValue.value = "";
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  callOnchanged(int index) {
    setState(() {
      current = index;
    });
  }

  void FetchProduct() async {
    locationText = "Fetching NearBy Products";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('latitude') != null) {
      productController.lat.value = prefs.getDouble('latitude')!;
      productController.lng.value = prefs.getDouble('longitude')!;
    }
    productController.isBrandProduct.value = true;
    setState(() {});

    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData("express"));
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
        permission = await Geolocator.requestPermission();
        return Future.error("Please enable the location to view the products");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        barrierColor: Colors.black26,
        context: context,
        builder: (context) {
          return showSingleBtnNonCancelableDailog(
              click1: () {
                /*  Geolocator.openLocationSettings().then((value) {
                  Get.back();
                }); */
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

    locationText = "Fetching Location";
    setState(() {});
    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  @override
  void dispose() {
    pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
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
  }

  /* deniedLocationCheck() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("check1");
      showDialog(
        barrierColor: Colors.black26,
        context: context,
        builder: (context) {
          return showSingleBtnNonCancelableDailog(
              click1: () {
                Geolocator.openLocationSettings().then((value) => Get.back());
              },
              btncolor: colorPrimary,
              text:
                  "Location services are disabled. Please enable the services",
              btn1Text: "Open Location Settings");
        },
      );
    } else {
      print("check2");
      getCurrentLocation();
    }
  } */

  /*  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  } */

  /*  AppLifecycleState _notification = AppLifecycleState.paused;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
      getSnackBar(_notification.toString());
    });
  } */

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // ✅ FIXED: Always allow back navigation immediately
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          // Back was pressed and navigation succeeded - clean up state
          try {
            final prefs = await SharedPreferences.getInstance();
            prefs.remove("brandList");
            prefs.remove("colorList");
            prefs.remove("sizeList");
            prefs.remove("upper");
            prefs.remove("lower");
            prefs.remove("sortby");
            productController.size_ids.clear();
            productController.color_ids.clear();
            productController.brand_ids.clear();
          } catch (e) {
            print('⚠️ Error cleaning up preferences: $e');
          }
          // Navigation already happened via didPop=true
        }
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppbar(
              onPressedSearch: () async {
                Get.to(const SearchScreen(), preventDuplicates: true);
                await analytics.logEvent(
                  name: 'search_page',
                  parameters: <String, Object>{
                    'page_name': 'search_page',
                  },
                );
              },
              onPressedHeart: () async {
                /*  Get.to(const CatalogScreen());
                await analytics.logEvent(
                  name: 'catalog_page',
                  parameters: <String, Object>{
                    'page_name': 'catalog_page',
                  },
                ); */
              },
              onPressedCart: () async {
                Get.to(CartScreen());
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
                    fontFamily: "Clash Display Regular",
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ), */
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20.sp, left: 16.sp, right: 16.sp, bottom: 5.sp),
                child: AppText(
                  text: "XPRESS DELIVERY",
                  fontFamily: "Clash Display Regular",
                  fontWeight: FontWeight.w400,
                  color: blackColor,
                  fontSize: 22,
                ),
              ),
            ),
            Obx(() => productController.isAddress.value
                ? Padding(
                    padding: EdgeInsets.only(
                        top: 10.sp, left: 16.sp, right: 16.sp, bottom: 5.sp),
                    child: DummyContainer(height: 20, width: double.infinity),
                  )
                : /*  productController.addressText.value == ""
                    ? */
                Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const MapScreen(
                                        addressId: 0,
                                        cartId: 0,
                                      )))
                              .then((value) {
                                if (mounted) {
                                  setState(
                                    () {
                                      productController.addressList.clear();
                                    },
                                  );
                                }
                              });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.sp,
                              left: 16.sp,
                              right: 16.sp,
                              bottom: 5.sp),
                          child: Row(
                            children: [
                              AppText(
                                text: "",
                                fontFamily: "Clash Display Regular",
                                fontWeight: FontWeight.w400,
                                color: textHintColor,
                                fontSize: 12,
                              ),
                              const Expanded(
                                child: SizedBox(
                                  width: 0,
                                ),
                              ),
                              Icon(
                                Icons.add,
                                color: blackColor,
                                size: 16.sp,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5.sp),
                                child: AppText(
                                  text: "Add Address",
                                  color: blackColor,
                                  fontSize: 12,
                                  fontFamily: "Clash Display Bold",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (productController.showAddressList.value) {
                            productController.showAddressList.value = false;
                          } else {
                            productController.showAddressList.value = true;
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.sp,
                              left: 16.sp,
                              right: 16.sp,
                              bottom: 5.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            //  mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16.sp),
                                child: AppText(
                                  text:
                                      "${productController.addressTypeValue.value} -",
                                  fontFamily: "Clash Display",
                                  maxLines: 1,
                                  fontWeight: FontWeight.w500,
                                  color: blackColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 2.sp),
                                  child: AppText(
                                    text: productController.addressText.value,
                                    fontFamily: "Clash Display Regular",
                                    maxLines: 1,
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: 2.sp, right: 16.sp, left: 5.sp),
                                child: ImageIcon(
                                  AssetImage(downArrowImage),
                                  color: blackColor,
                                  size: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            Stack(
              children: [
                Obx(
                  () => productController.lat.value != 0
                      ? brandController.isBrand.value
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  bottom: 10.sp,
                                  right: 16.sp,
                                  top: 10.sp),
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.sp),
                                  child: SizedBox(
                                      width: double.infinity,
                                      height: 50.sp,
                                      child: GetBuilder<BrandController>(
                                        builder: (value) => ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount:
                                                value.brandList.length + 1,
                                            scrollDirection: Axis.horizontal,
                                            controller:
                                                value.brandListController,
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
                                                            .brand_id
                                                            .value = value
                                                                .brandList[
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
                                                      productController
                                                          .update();
                                                      setState(() {});
                                                      pageController
                                                          .animateToPage(
                                                        current,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
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
                                                            ? BorderRadius
                                                                .circular(20)
                                                            : BorderRadius
                                                                .circular(20),
                                                        border: current == index
                                                            ? Border.all(
                                                                color:
                                                                    btnTextColor,
                                                                width: 1)
                                                            : Border.all(
                                                                color:
                                                                    textHintColor,
                                                                width: 1),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.sp),
                                                        child: Center(
                                                          child: AppText(
                                                            text: index == 0
                                                                ? "View All"
                                                                : value.brandList[
                                                                        index -
                                                                            1]
                                                                    ["name"],
                                                            color: current ==
                                                                    index
                                                                ? whiteBorderColor
                                                                : textHintColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Clash Display",
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
                  () => productController.showAddressList.value
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: 16.sp, right: 16.sp, bottom: 10.sp),
                          child: SizedBox(
                            height: 180.sp,
                            child: ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: productController.addressList.length,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          productController.addressText.value =
                                              "${productController.addressList[index]["zip"]}, ${productController.addressList[index]["address"]}";
                                          productController
                                                  .addressTypeValue.value =
                                              productController
                                                  .addressList[index]["type"];
                                          productController
                                              .showAddressList.value = false;
                                          productController.lat.value =
                                              double.parse(productController
                                                      .addressList[index]
                                                  ["latitude"]);
                                          productController.lng.value =
                                              double.parse(productController
                                                      .addressList[index]
                                                  ["longitude"]);
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.setDouble("latitude",
                                              productController.lat.value);
                                          prefs.setDouble("longitude",
                                              productController.lng.value);
                                          productController
                                              .isBrandProduct.value = true;
                                          productController.callSaveAddress(
                                              "express",
                                              productController.addressList[index]
                                                  ["id"],
                                              productController.addressList[index]
                                                  ["name"],
                                              productController.addressList[index]
                                                  ["phone"],
                                              productController.addressList[index]
                                                  ["city"]["name"],
                                              productController.addressList[index]
                                                  ["type"],
                                              productController.addressList[index]
                                                  ["address"],
                                              productController
                                                  .addressList[index]["zip"]
                                                  .toString(),
                                              productController.addressList[index]
                                                  ["locality"],
                                              productController.addressList[index]
                                                  ["city"]["state"]["name"],
                                              double.parse(productController
                                                      .addressList[index]
                                                  ["latitude"]),
                                              double.parse(productController.addressList[index]["longitude"]),
                                              context);
                                          setState(() {});
                                        },
                                        child: Container(
                                          color: whiteTextColor,
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.sp,
                                                      horizontal: 10.sp),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        productController
                                                                .addressList[
                                                            index]["name"],
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: nameText,
                                                          fontFamily:
                                                              "Clash Display",
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2.sp),
                                                        child: Text(
                                                          productController
                                                                  .addressList[
                                                              index]["address"],
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: nameText,
                                                            fontFamily:
                                                                "Clash Display Regular",
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2.sp),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "${productController.addressList[index]["zip"]},",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: nameText,
                                                                fontFamily:
                                                                    "Clash Display Regular",
                                                              ),
                                                            ),
                                                            Text(
                                                              productController
                                                                          .addressList[
                                                                      index]
                                                                  ["locality"],
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: nameText,
                                                                fontFamily:
                                                                    "Clash Display Regular",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2.sp),
                                                        child: Text(
                                                          productController
                                                                  .addressList[
                                                              index]["type"],
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: nameText,
                                                            fontFamily:
                                                                "Clash Display Regular",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              index ==
                                                      productController
                                                              .addressList
                                                              .length -
                                                          1
                                                  ? SizedBox(
                                                      width: double.infinity,
                                                      height: 5.sp,
                                                    )
                                                  : Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.sp,
                                                              vertical: 2.sp),
                                                      child: Container(
                                                        width: double.infinity,
                                                        color: colorSecondary,
                                                        height: 1.sp,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                ),
              ],
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
                          // return ViewAllScreen(
                          //   brandId: productController.brand_id.value,
                          // );
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
                                    fontFamily: "Clash Display Regular")),
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
