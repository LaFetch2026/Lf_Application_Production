// ignore_for_file: avoid_print, deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/quickwidgets/brand_product_list.dart';
import 'package:lafetch/controller/brand_controller.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import 'package:lafetch/screens/quick/brandproductscreen.dart';
import '../utils/constants.dart';

class QuickScreen extends StatefulWidget {
  const QuickScreen({super.key});

  @override
  State<QuickScreen> createState() => QuickScreenState();
}

class QuickScreenState extends State<QuickScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final homeController = Get.put(HomeController());
  final brandController = Get.put(BrandController());
  final productController = Get.put(ProductController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBrandData();
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getHandPickedProduct("", false, false, 0));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.getBrandData("brand");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homeAppBarColor,
      body: Stack(
        children: [
          /*  SvgPicture.asset(
            quickBackCircleImage,
          ), */
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(top: 56.sp, left: 16.sp, right: 16.sp),
                  child: Row(
                    children: [
                      Container(
                        height: 50.sp,
                        width: 50.sp,
                        decoration: BoxDecoration(
                          color: purpleColor,
                          borderRadius: BorderRadius.all(Radius.circular(8.sp)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.sp),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                text: "2",
                                color: whiteColor,
                                fontSize: 18,
                                fontFamily: "Franklin Gothic Semibold",
                                fontWeight: FontWeight.w500,
                              ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  AppText(
                                    text: "Deliver to Akash",
                                    color: whiteColor,
                                    fontSize: 12,
                                    fontFamily: "Franklin Gothic Semibold",
                                    fontWeight: FontWeight.w500,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.sp),
                                    child: SvgPicture.asset(
                                      dropdownSvgImage,
                                      height: 6.sp,
                                      width: 8.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width / 2 + 40.sp,
                              child: Padding(
                                padding: EdgeInsets.only(top: 4.sp),
                                child: AppText(
                                  text: "6 FLoor ,Lafetch,Universal Trade Tow",
                                  color: whiteColor,
                                  fontSize: 12,
                                  maxLines: 1,
                                  fontFamily: "Franklin Gothic Regular",
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 16.sp, top: 24.sp, right: 16.sp),
                  child: Container(
                    color: loginText,
                    // height: 50.sp,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (value) {
                        print(value);
                        if (value is RawKeyDownEvent) {}
                      },
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                            color: colorSecondary,
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14.sp),
                        //   controller: brandController.searchController,
                        //   onChanged: onSearchChanged,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          isDense: true,
                          fillColor: homeAppBarColor,
                          prefixIcon: IconButton(
                            icon: SvgPicture.asset(searchSvgImage,
                                color: searchTextColor,
                                height: 17.sp,
                                width: 17.sp,
                                fit: BoxFit.cover),
                            onPressed: () {},
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: searchTextColor)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.sp),
                            borderSide:
                                const BorderSide(color: searchTextColor),
                          ),
                          counterText: "",
                          hintText: "Search for 'Kurta'",
                          hintStyle: TextStyle(
                              fontSize: 14.sp, color: searchTextColor),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.sp),
                  child: Image.asset(
                    pumaImage,
                    height: 128.sp,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 24.sp),
                  child: Container(
                    height: 30.sp,
                    color: expressDeliveryBanner,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        'MORE THAN 50 HOMEGROWN BRANDS ✦ DELIVERED WITHIN 30 MINS ✦ MORE THAN 50 HOMEGROWN BRANDS',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 12, // Text size
                          fontWeight: FontWeight.w400, // Text weight
                        ),
                        textAlign: TextAlign.center, // Center align text
                      ),
                    ),
                  ),
                ),
                Obx(() => homeController.isBrand.value
                    ? Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 24.sp, left: 16.sp, right: 16.sp),
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
                                top: 8.sp,
                                bottom: 16.sp,
                              ),
                              child: SizedBox(
                                height: 100.sp,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: 5,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 12.sp),
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
                    : homeController.brandList.isNotEmpty
                        ? Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 24.sp, left: 16.sp, right: 16.sp),
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
                                        text: "Featured brands".toUpperCase(),
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
                                  top: 8.sp,
                                  bottom: 16.sp,
                                ),
                                child: SizedBox(
                                  height: 100.sp,
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount:
                                          homeController.brandList.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (ctx, index) {
                                        return homeController.brandList[index]
                                                    ["logo"] !=
                                                null
                                            ? GestureDetector(
                                                onTap: () {
                                                  Get.to(BrandsScreen(
                                                    screen: "search",
                                                    logo: homeController
                                                            .brandList[index]
                                                        ["logo"],
                                                    backImage: homeController
                                                                    .brandList[
                                                                index][
                                                            "background_image"] ??
                                                        "",
                                                    name: homeController
                                                            .brandList[index]
                                                        ["name"],
                                                    brandId: homeController
                                                        .brandList[index]["id"],
                                                  ))?.then((value) => setState(
                                                        () {
                                                          homeController
                                                              .getBrandData();
                                                        },
                                                      ));
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 16.sp),
                                                  child: Container(
                                                    height: 80.sp,
                                                    width: 80.sp,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          whiteColor,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              width: 1.sp,
                                                              color: Color(
                                                                  0xff9CA3AF)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16.0.sp),
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
                                padding: EdgeInsets.only(
                                    left: 16.sp, right: 16.sp, bottom: 24.sp),
                                child: SvgPicture.asset(
                                  fullLineSvgImage,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 0,
                          )),
                Obx(() => brandController.isBrand.value
                    ? SizedBox(
                        height: 0,
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            left: 16.sp,
                            right: 16.sp,
                            bottom: 10.sp,
                            top: 10.sp),
                        child: GetBuilder<BrandController>(
                          builder: (value) => ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              controller: value.brandListController,
                              physics: const ScrollPhysics(),
                              itemCount: value.brandList.length,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 24.sp),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.sp),
                                            color: cardBg),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {},
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.sp,
                                                    vertical: 12.sp),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    value.brandList[index]
                                                                ["logo"] !=
                                                            null
                                                        ? SizedBox(
                                                            height: 32.sp,
                                                            width: 32.sp,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .all(8.0
                                                                          .sp),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    height:
                                                                        32.sp,
                                                                    width:
                                                                        32.sp,
                                                                    cacheManager: CacheManager(Config(
                                                                        "customCacheKey",
                                                                        stalePeriod: const Duration(
                                                                            days:
                                                                                15),
                                                                        maxNrOfCacheObjects:
                                                                            100)),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    imageUrl: value
                                                                            .brandList[index]
                                                                        [
                                                                        "logo"],
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Image
                                                                            .asset(
                                                                      downloadImage,
                                                                      height:
                                                                          32.sp,
                                                                      width:
                                                                          32.sp,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            height: 32.sp,
                                                            width: 32.sp,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .all(8.0
                                                                          .sp),
                                                                  child: Image.asset(
                                                                      dummyWishlistImage,
                                                                      height:
                                                                          32.sp,
                                                                      width:
                                                                          32.sp,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.sp),
                                                      child: AppText(
                                                        text: value.brandList[
                                                                    index]
                                                                ["name"] ??
                                                            "",
                                                        color: whiteColor,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            "Franklin Gothic Semibold",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      child: SizedBox(
                                                        width: 0,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(BrandViewProductScreen(
                                                                title:
                                                                    value.brandList[
                                                                            index]
                                                                        [
                                                                        "name"],
                                                                genderName:
                                                                    "Men"))
                                                            ?.then(
                                                                (value) =>
                                                                    setState(
                                                                      () {
                                                                        productController.getHandPickedProduct(
                                                                            "",
                                                                            false,
                                                                            false,
                                                                            0);
                                                                      },
                                                                    ));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 8.sp),
                                                        child: AppText(
                                                          text: "VIEW ALL"
                                                              .toUpperCase(),
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: whiteColor,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(BrandViewProductScreen(
                                                                title:
                                                                    value.brandList[
                                                                            index]
                                                                        [
                                                                        "name"],
                                                                genderName:
                                                                    "Men"))
                                                            ?.then(
                                                                (value) =>
                                                                    setState(
                                                                      () {
                                                                        productController.getHandPickedProduct(
                                                                            "",
                                                                            false,
                                                                            false,
                                                                            0);
                                                                      },
                                                                    ));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 8.sp),
                                                        child: SvgPicture.asset(
                                                            arrowSearchImage,
                                                            color: whiteColor,
                                                            height: 7.sp,
                                                            width: 7.sp,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            BrandProductList(
                                                list: productController
                                                    .handPickedProductList)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
