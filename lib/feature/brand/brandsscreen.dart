// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../common/widget/appbar/home_appbar.dart';
import '../../common/widget/lists/dummy_brand_list.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/brand_controller.dart';
import '../../core/constant/constants.dart';
import '../cart/cartscreen.dart';
import '../profile/bottomnavscreen.dart';
import '../wishlist/wishlistscreen.dart';
import 'allbrandscreen.dart';


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
      brandController.selectIndex.value = 0;
    });
    /*   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.brandListController.addListener(() {
        brandController.fetchMoreData("brand");
        brandController.update();
      });
    }); */
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
    return Obx(
            () => /*  brandController.showAllBrand.value
        ? AllBrandScreen(
            title: brandController.brandName.value,
            brandbackground: brandController.brandbackground.value,
            screen: widget.screen!,
          )
        :  */
        WillPopScope(
          onWillPop: () async {
            Get.offAll(const BottomNavScreen(
              index: 0,
            ));
            return false;
          },
          child: Scaffold(
            backgroundColor: whiteColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeAppbar(
                  showSearch: false,
                  title: "Brands",
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
                ),
                /* Container(
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
                  ), */
                SizedBox(
                  height: 10.sp,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.sp, vertical: 10.sp),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (value) {
                      print(value);
                      if (value is RawKeyDownEvent) {
                        brandController.queryText.value = "";
                        brandController.getBrandData("brand");
                      }
                    },
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                          color: titleColor,
                          fontFamily: "Franklin Gothic Regular",
                          fontSize: 14.sp),
                      controller: brandController.searchController,
                      onChanged: onSearchChanged,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        fillColor: whiteColor,
                        prefixIcon: IconButton(
                          icon: SvgPicture.asset(searchSvgImage,
                              color: titleColor,
                              height: 17.sp,
                              width: 17.sp,
                              fit: BoxFit.cover),
                          onPressed: () {},
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.sp),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.sp),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        counterText: "",
                        hintText: "Search for 'Brands'",
                        hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: searchTextColor,
                            fontFamily: "Franklin Gothic Regular"),
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
                          /*  Padding(
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
                            ), */
                          brandController.isBrand.value
                              ? const DummybrandList()
                              : brandController.brandList.isNotEmpty
                              ? Padding(
                            padding: EdgeInsets.only(
                                bottom: 10.sp, top: 10.sp),
                            child: GetBuilder<BrandController>(
                              builder: (val) => ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  controller:
                                  val.brandListController,
                                  physics: const ScrollPhysics(),
                                  itemCount: val.brandList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, a) {
                                    return Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: a != 0
                                              ? true
                                              : false,
                                          child: Padding(
                                            padding: EdgeInsets
                                                .symmetric(
                                                vertical:
                                                8.sp),
                                            child: Container(
                                              height: 1.sp,
                                              color:
                                              lightgreyColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets
                                              .symmetric(
                                              vertical: 8.sp,
                                              horizontal:
                                              16.sp),
                                          child: AppText(
                                            text: val.brandList[a]
                                            [
                                            "alphabet"] ??
                                                "",
                                            color: subtitleColor,
                                            fontSize: 14,
                                            fontFamily:
                                            "Franklin Gothic Regular",
                                            fontWeight:
                                            FontWeight.w400,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets
                                              .symmetric(
                                              horizontal:
                                              16.sp),
                                          child: GetBuilder<
                                              BrandController>(
                                            builder: (value) =>
                                                ListView.builder(
                                                    primary:
                                                    false,
                                                    shrinkWrap:
                                                    true,
                                                    physics:
                                                    const ScrollPhysics(),
                                                    itemCount: val
                                                        .brandList[
                                                    a][
                                                    "brands"]
                                                        .length,
                                                    padding:
                                                    EdgeInsets
                                                        .zero,
                                                    scrollDirection:
                                                    Axis
                                                        .vertical,
                                                    itemBuilder:
                                                        (ctx,
                                                        index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.only(bottom: 10.sp),
                                                            child:
                                                            Column(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    brandController.brandlogo.value = val.brandList[a]["brands"][index]["logo"];
                                                                    brandController.brandbackground.value = val.brandList[a]["brands"][index]["background_image"] ?? "";
                                                                    brandController.brandName.value = val.brandList[a]["brands"][index]["name"];
                                                                    brandController.showAllBrand.value = true;
                                                                    brandController.brandId.value = val.brandList[a]["brands"][index]["id"];
                                                                    brandController.update();
                                                                    brandController.brandProductDetailsList.clear();
                                                                    Get.to(AllBrandScreen(
                                                                      id: val.brandList[a]["brands"][index]["id"],
                                                                      slug: "",
                                                                      screen: widget.screen!,
                                                                    ))?.then((value) {
                                                                      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                        statusBarColor: whiteColor,
                                                                        systemNavigationBarColor: whiteColor,
                                                                        statusBarIconBrightness: Brightness.dark,
                                                                        statusBarBrightness: Brightness.light,
                                                                      ));
                                                                    });
                                                                    await analytics.logEvent(
                                                                      name: 'brand_details',
                                                                      parameters: <String, Object>{
                                                                        'page_name': 'brand_details',
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    color: statusBarColor,
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(left: 8.sp, top: 10.sp, bottom: 10.sp),
                                                                      child: Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          val.brandList[a]["brands"][index]["logo"] != null
                                                                              ? Container(
                                                                            height: 48.sp,
                                                                            width: 48.sp,
                                                                            decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(width: 1.sp, color: lightgreyColor),
                                                                            ),
                                                                            child: ClipOval(
                                                                              child: CachedNetworkImage(
                                                                                height: 48.sp,
                                                                                width: 48.sp,
                                                                                cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                fit: BoxFit.contain,
                                                                                imageUrl: val.brandList[a]["brands"][index]["logo"],
                                                                                errorWidget: (context, url, error) => Image.asset(
                                                                                  downloadImage,
                                                                                  fit: BoxFit.contain,
                                                                                  height: 48.sp,
                                                                                  width: 48.sp,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Padding(
                                                                            padding: EdgeInsets.only(right: 12.sp),
                                                                            child: CircleAvatar(
                                                                              child: Image.asset(dummyWishlistImage, height: 48.sp, width: 48.sp, fit: BoxFit.cover),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                                                                            child: AppText(
                                                                              text: val.brandList[a]["brands"][index]["name"] ?? "",
                                                                              color: colorPrimary,
                                                                              fontSize: 16,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          const Expanded(
                                                                            child: SizedBox(
                                                                              width: 0,
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              if (val.selectIndex.value == val.brandList[a]["brands"][index]["id"]) {
                                                                                val.selectIndex.value = 0;
                                                                              } else {
                                                                                val.selectIndex.value = 0;
                                                                                val.selectIndex.value = val.brandList[a]["brands"][index]["id"];
                                                                              }
                                                                              value.update();
                                                                            },
                                                                            child: Container(
                                                                              child: Padding(
                                                                                padding: EdgeInsets.only(right: 20.sp, top: 20.sp, bottom: 20.sp, left: 60.sp),
                                                                                child: SvgPicture.asset(
                                                                                  val.selectIndex.value == val.brandList[a]["brands"][index]["id"] ? upDropDownSvgImage : dropdownSvgImage,
                                                                                  color: colorPrimary,
                                                                                  height: 7.sp,
                                                                                  width: 11.sp,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                val.selectIndex.value == val.brandList[a]["brands"][index]["id"]
                                                                    ? val.brandList[a]["brands"][index]["products"].isNotEmpty
                                                                    ? Container(
                                                                  color: statusBarColor,
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height: 10.sp,
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
                                                                        child:
                                                                        /*   GetBuilder<BrandController>(
                                                                                        builder: (val) => */
                                                                        GridView.count(
                                                                          shrinkWrap: true,
                                                                          crossAxisCount: 3,
                                                                          scrollDirection: Axis.vertical,
                                                                          padding: EdgeInsets.zero,
                                                                          childAspectRatio: 0.85, //0.7
                                                                          physics: const ScrollPhysics(),
                                                                          crossAxisSpacing: 10.sp,
                                                                          mainAxisSpacing: 0,
                                                                          children: List.generate(
                                                                            val.brandList[a]["brands"][index]["products"].length,
                                                                                (i) {
                                                                              return GestureDetector(
                                                                                onTap: () async {
                                                                                  /*   Get.to(CategoryProductScreen(
                                                                                                            categoryName: val.brandList[a]["brands"][index]["categories"][i]["name"],
                                                                                                            categoryId: val.brandList[a]["brands"][index]["categories"][i]["id"],
                                                                                                            brandId: val.brandList[a]["brands"][index]["id"],
                                                                                                            genderType: 0,
                                                                                                            screen: "category",
                                                                                                            genderName: "",
                                                                                                            tagIds: const [],
                                                                                                            categoryList: [],
                                                                                                          ));
                                                                                                          await analytics.logEvent(
                                                                                                            name: 'brand_category_click',
                                                                                                            parameters: <String, Object>{
                                                                                                              'page_name': 'brand_category_click',
                                                                                                            },
                                                                                                          ); */
                                                                                  brandController.brandlogo.value = val.brandList[a]["brands"][index]["logo"];
                                                                                  brandController.brandbackground.value = val.brandList[a]["brands"][index]["background_image"] ?? "";
                                                                                  brandController.brandName.value = val.brandList[a]["brands"][index]["name"];
                                                                                  brandController.showAllBrand.value = true;
                                                                                  brandController.brandId.value = val.brandList[a]["brands"][index]["id"];
                                                                                  brandController.update();
                                                                                  brandController.brandProductDetailsList.clear();
                                                                                  Get.to(AllBrandScreen(
                                                                                    id: val.brandList[a]["brands"][index]["id"],
                                                                                    slug: "",
                                                                                    screen: widget.screen!,
                                                                                  ))?.then((value) {
                                                                                    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                                      statusBarColor: whiteColor,
                                                                                      systemNavigationBarColor: whiteColor,
                                                                                      statusBarIconBrightness: Brightness.dark,
                                                                                      statusBarBrightness: Brightness.light,
                                                                                    ));
                                                                                  });
                                                                                  await analytics.logEvent(
                                                                                    name: 'brand_details',
                                                                                    parameters: <String, Object>{
                                                                                      'page_name': 'brand_details',
                                                                                    },
                                                                                  );
                                                                                },
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    val.brandList[a]["brands"][index]["products"][i]["images"] != null
                                                                                        ? SizedBox(
                                                                                      height: 97.sp,
                                                                                      width: 97.sp,
                                                                                      child: CachedNetworkImage(
                                                                                        cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                                        fit: BoxFit.cover,
                                                                                        alignment: Alignment.topCenter,
                                                                                        imageUrl: val.brandList[a]["brands"][index]["products"][i]["images"][0]["name"],
                                                                                        errorWidget: (context, url, error) => Image.asset(
                                                                                          downloadImage,
                                                                                          height: 97.sp,
                                                                                          width: 97.sp,
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                        : Image.asset(dummyWishlistImage, height: 97.sp, width: 97.sp, fit: BoxFit.cover),
                                                                                    /* Padding(
                                                                                                padding: EdgeInsets.symmetric(vertical: 5.sp),
                                                                                                child: AppText(
                                                                                                  text: "${value.brandList[index]["categories"][i]["catalog"]["type_detail"]} ${value.brandList[index]["categories"][i]["name"]}",
                                                                                                  color: greyTextColor,
                                                                                                  fontSize: 8,
                                                                                                  maxLines: 2,
                                                                                                  fontFamily: "Franklin Gothic Regular",
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                ),
                                                                                              ), */
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //  ),
                                                                      InkWell(
                                                                        onTap: () async {
                                                                          brandController.brandlogo.value = val.brandList[a]["brands"][index]["logo"];
                                                                          brandController.brandbackground.value = val.brandList[a]["brands"][index]["background_image"] ?? "";
                                                                          brandController.brandName.value = val.brandList[a]["brands"][index]["name"];
                                                                          brandController.showAllBrand.value = true;
                                                                          brandController.brandId.value = val.brandList[a]["brands"][index]["id"];
                                                                          brandController.update();
                                                                          brandController.brandProductDetailsList.clear();
                                                                          Get.to(AllBrandScreen(
                                                                            id: val.brandList[a]["brands"][index]["id"],
                                                                            slug: "",
                                                                            screen: widget.screen!,
                                                                          ))?.then((value) {
                                                                            SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                              statusBarColor: whiteColor,
                                                                              systemNavigationBarColor: whiteColor,
                                                                              statusBarIconBrightness: Brightness.dark,
                                                                              statusBarBrightness: Brightness.light,
                                                                            ));
                                                                          });
                                                                          await analytics.logEvent(
                                                                            name: 'brand_details',
                                                                            parameters: <String, Object>{
                                                                              'page_name': 'brand_details',
                                                                            },
                                                                          );
                                                                        },
                                                                        child: Padding(
                                                                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                                                                          child: Container(
                                                                            height: 42.sp,
                                                                            color: homeAppBarColor,
                                                                            width: double.infinity,
                                                                            child: Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: 8.sp),
                                                                                  child: AppText(
                                                                                    text: "Explore brand".toUpperCase(),
                                                                                    fontFamily: "Franklin Gothic",
                                                                                    fontWeight: FontWeight.w400,
                                                                                    color: whiteColor,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                                    : SizedBox(
                                                                  height: 50.sp,
                                                                  width: double.infinity,
                                                                  child: Center(
                                                                    child: Text("No Product Found", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontFamily: "Franklin Gothic Regular")),
                                                                  ),
                                                                )
                                                                    : const SizedBox(
                                                                  height: 0,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          )
                              : /* Container(
                                          height: 400.sp,
                                          margin: EdgeInsets.only(
                                              top: 48.sp, left: 16.sp),
                                          width: double.infinity,
                                          child: Text(
                                              "${'"'}${"NO BRAND FOUND"}${'"'}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xff6B7280),
                                                  fontFamily:
                                                      "Franklin Gothic")),
                                        ) */
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                EdgeInsets.only(top: 80.sp),
                                child: Center(
                                  child: Image.asset(errorImage,
                                      height: 200.sp,
                                      width: 220.sp,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 6.sp,
                                      left: 20.sp,
                                      bottom: 20.sp,
                                      right: 20.sp),
                                  child: brandController
                                      .searchController.text
                                      .toString()
                                      .trim()
                                      .isNotEmpty
                                      ? Text(
                                      "No ${brandController.searchController.text.toString().trim()} found"
                                          .toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                          homeAppBarColor,
                                          fontFamily:
                                          "Franklin Gothic"))
                                      : Text(
                                      "Coming Soon to Your Area",
                                      textAlign:
                                      TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                          homeAppBarColor,
                                          fontFamily:
                                          "Franklin Gothic"))),
                            ],
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
