// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/brandwidgits/dummy_brand_list.dart';
import 'package:lafetch/controller/brand_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../utils/constants.dart';
import 'Brands/categoryproduct.dart';
import 'bottomnavscreen.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class BrandsScreen extends StatefulWidget {
  final String? screen;
  final String? logo;
  final String? backImage;
  final int? brandId;
  final String? name;
  const BrandsScreen(
      {super.key,
      this.screen,
      this.logo,
      this.backImage,
      this.name,
      this.brandId});

  @override
  State<BrandsScreen> createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {
  final brandController = Get.put(BrandController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? debounce;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      brandController.queryText.value = query;
      brandController.getBrandData("brand");
      await analytics.logEvent(
        name: 'brand_page_search',
        parameters: <String, Object>{
          'page_name': 'brand_page_search',
        },
      );
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.screen == "search") {
        brandController.showAllBrand.value = true;
        brandController.brandlogo.value = widget.logo!;
        brandController.brandbackground.value = widget.backImage!;
        brandController.brandName.value = widget.name!;
        brandController.brandId.value = widget.brandId!;
        brandController.update();
      } else {
        brandController.showAllBrand.value = false;
      }
      brandController.text.value = "Expand All";
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.brandListController.addListener(() {
        brandController.fetchMoreData("brand");
        brandController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.hasnextpage.value = true;
      brandController.loadMore.value = false;
      brandController.isBrand.value = false;
      brandController.page.value = 1;
      brandController.searchController.clear();
      brandController.queryText.value = "";
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData("brand"));
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => brandController.showAllBrand.value
        ? AllBrandScreen(
            title: brandController.brandName.value,
            brandbackground: brandController.brandbackground.value,
            screen: widget.screen!,
          )
        : WillPopScope(
            onWillPop: () async {
              Get.offAll(const BottomNavScreen(
                index: 0,
              ));
              return false;
            },
            child: Scaffold(
              backgroundColor: colorSecondary,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: colorPrimary,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: Container(
                        color: loginText,
                        // height: 50.sp,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (value) {
                            print(value);
                            if (value is RawKeyDownEvent) {
                              brandController.text.value = "Expand All";
                              brandController.queryText.value = "";
                              brandController.getBrandData("brand");
                            }
                          },
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                                color: colorSecondary,
                                fontFamily: "Franklin Gothic Regular",
                                fontSize: 14.sp),
                            controller: brandController.searchController,
                            onChanged: onSearchChanged,
                            /*  onChanged: (value) {
                              brandController.queryText.value = value;
                              brandController.getBrandData();
                            }, */
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              fillColor: loginText,
                              prefixIcon: Icon(Icons.search,
                                  size: 20.sp, color: colorSecondary),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.sp),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1.sp),
                                borderSide:
                                    const BorderSide(color: colorSecondary),
                              ),
                              counterText: "",
                              hintText: "Search for brands",
                              hintStyle: TextStyle(
                                  fontSize: 14.sp, color: colorSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: brandController.brandListController,
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {});
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp, top: 20.sp, right: 16.sp),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Explore all our Brands",
                                    color: colorPrimary,
                                    fontSize: 20,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  const Expanded(
                                    child: SizedBox(
                                      width: 0,
                                    ),
                                  ),
                                  Obx(
                                    () => GestureDetector(
                                      onTap: () async {
                                        if (brandController.text.value ==
                                            "Expand All") {
                                          brandController.text.value =
                                              "Collapse All";
                                          brandController.selected.clear();
                                          brandController.selected =
                                              List.generate(
                                                  brandController
                                                      .brandList.length,
                                                  (i) => true);
                                          brandController.update();
                                        } else {
                                          brandController.text.value =
                                              "Expand All";
                                          brandController.selected.clear();
                                          brandController.selected =
                                              List.generate(
                                                  brandController
                                                      .brandList.length,
                                                  (i) => false);
                                          brandController.update();
                                        }
                                        await analytics.logEvent(
                                          name: 'brand_page_expandAll',
                                          parameters: <String, Object>{
                                            'page_name': 'brand_page_expandAll',
                                          },
                                        );
                                      },
                                      child: AppText(
                                        text: brandController.text.value,
                                        color: blackColor,
                                        fontSize: 12,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            brandController.isBrand.value
                                ? const DummybrandList()
                                : brandController.brandList.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            right: 16.sp,
                                            bottom: 10.sp,
                                            top: 10.sp),
                                        child: GetBuilder<BrandController>(
                                          builder: (value) => ListView.builder(
                                              primary: false,
                                              shrinkWrap: true,
                                              controller:
                                                  value.brandListController,
                                              physics: const ScrollPhysics(),
                                              itemCount: value.brandList.length,
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (ctx, index) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 10.sp),
                                                      child: Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                            border: Border.all(
                                                                width: 1,
                                                                color: value.selected[
                                                                        index]
                                                                    ? greyTextColor
                                                                    : whiteBorderColor),
                                                            color:
                                                                whiteBorderColor),
                                                        child: Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () async {
                                                                brandController
                                                                    .brandlogo
                                                                    .value = value
                                                                        .brandList[
                                                                    index]["logo"];
                                                                brandController
                                                                    .brandbackground
                                                                    .value = value
                                                                            .brandList[index]
                                                                        [
                                                                        "background_image"] ??
                                                                    "";
                                                                brandController
                                                                    .brandName
                                                                    .value = value
                                                                        .brandList[
                                                                    index]["name"];
                                                                brandController
                                                                    .showAllBrand
                                                                    .value = true;
                                                                brandController
                                                                    .brandId
                                                                    .value = value
                                                                        .brandList[
                                                                    index]["id"];
                                                                brandController
                                                                    .update();
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'brand_details',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'brand_details',
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal: 16
                                                                            .sp,
                                                                        vertical:
                                                                            10.sp),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    value.brandList[index]["logo"] !=
                                                                            null
                                                                        ? /*  FadeInImage(
                                                                            fit: BoxFit
                                                                                .cover,
                                                                            height:
                                                                                32,
                                                                            width:
                                                                                32,
                                                                            image: NetworkImage(value.brandList[index][
                                                                                "logo"]),
                                                                            placeholder: const AssetImage(
                                                                                dummyWishlistImage)) */
                                                                        SizedBox(
                                                                            height:
                                                                                32.sp,
                                                                            width:
                                                                                32.sp,
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                              fit: BoxFit.cover,
                                                                              imageUrl: value.brandList[index]["logo"],
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                downloadImage,
                                                                                height: 32.sp,
                                                                                width: 32.sp,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Image.asset(
                                                                            dummyWishlistImage,
                                                                            height:
                                                                                32.sp,
                                                                            width: 32.sp,
                                                                            fit: BoxFit.cover),
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10.sp),
                                                                      child:
                                                                          AppText(
                                                                        text: value.brandList[index]["name"] ??
                                                                            "",
                                                                        color:
                                                                            colorPrimary,
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            "Franklin Gothic Regular",
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                    const Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            0,
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        value.selected[
                                                                            index] = !value
                                                                                .selected[
                                                                            index];
                                                                        value
                                                                            .update();
                                                                      },
                                                                      child: Image.asset(
                                                                          value.selected[index]
                                                                              ? downArrowImage
                                                                              : upArrowIcon,
                                                                          height: 20
                                                                              .sp,
                                                                          width: 20
                                                                              .sp,
                                                                          fit: BoxFit
                                                                              .cover),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            value.selected[
                                                                    index]
                                                                ? value
                                                                        .brandList[
                                                                            index]
                                                                            [
                                                                            "categories"]
                                                                        .isNotEmpty
                                                                    ? Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                10.sp,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 16.sp, right: 16.sp),
                                                                            child:
                                                                                /*   GetBuilder<BrandController>(
                                                                                  builder: (val) => */
                                                                                GridView.count(
                                                                              shrinkWrap: true,
                                                                              crossAxisCount: 3,
                                                                              scrollDirection: Axis.vertical,
                                                                              padding: EdgeInsets.zero,
                                                                              childAspectRatio: 0.8,
                                                                              physics: const ScrollPhysics(),
                                                                              crossAxisSpacing: 1.sp,
                                                                              mainAxisSpacing: 0,
                                                                              children: List.generate(
                                                                                value.brandList[index]["categories"].length,
                                                                                (i) {
                                                                                  return GestureDetector(
                                                                                    onTap: () async {
                                                                                      Get.to(CategoryProductScreen(
                                                                                        categoryName: value.brandList[index]["categories"][i]["name"],
                                                                                        categoryId: value.brandList[index]["categories"][i]["id"],
                                                                                        brandId: value.brandList[index]["id"],
                                                                                        genderType: 0,
                                                                                        genderName: "",
                                                                                        tagIds: const [],
                                                                                        categoryList: [],
                                                                                      ));
                                                                                      await analytics.logEvent(
                                                                                        name: 'brand_category_click',
                                                                                        parameters: <String, Object>{
                                                                                          'page_name': 'brand_category_click',
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        value.brandList[index]["categories"][i]["thumbnail"] != null
                                                                                            ? SizedBox(
                                                                                                height: 70.sp,
                                                                                                width: 90.sp,
                                                                                                child: CachedNetworkImage(
                                                                                                  cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                                  fit: BoxFit.cover,
                                                                                                  imageUrl: value.brandList[index]["categories"][i]["thumbnail"],
                                                                                                  errorWidget: (context, url, error) => Image.asset(
                                                                                                    downloadImage,
                                                                                                    height: 70.sp,
                                                                                                    width: 90.sp,
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            : Image.asset(dummyWishlistImage, height: 70.sp, width: 90.sp, fit: BoxFit.cover),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                                                          child: AppText(
                                                                                            text: "${value.brandList[index]["categories"][i]["catalog"]["type_detail"]} ${value.brandList[index]["categories"][i]["name"]}",
                                                                                            color: greyTextColor,
                                                                                            fontSize: 8,
                                                                                            maxLines: 2,
                                                                                            fontFamily: "Franklin Gothic Regular",
                                                                                            fontWeight: FontWeight.w400,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          //  ),
                                                                        ],
                                                                      )
                                                                    : SizedBox(
                                                                        height:
                                                                            50.sp,
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            Center(
                                                                          child: Text(
                                                                              "No Category Found",
                                                                              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontFamily: "Franklin Gothic Regular")),
                                                                        ),
                                                                      )
                                                                : const SizedBox(
                                                                    height: 0,
                                                                  )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 400.sp,
                                        width: double.infinity,
                                        child: Center(
                                          child: Text("No Brand Found",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      "Franklin Gothic Regular")),
                                        ),
                                      ),
                            brandController.loadMore.value
                                ? const DummybrandList()
                                : const SizedBox(
                                    height: 0,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
  }
}
