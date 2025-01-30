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
import 'package:lafetch/commonwidget/homewidget/dummy_home_brand.dart';
import 'package:lafetch/controller/home_controller.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import '../utils/constants.dart';

class QuickScreen extends StatefulWidget {
  const QuickScreen({super.key});

  @override
  State<QuickScreen> createState() => QuickScreenState();
}

class QuickScreenState extends State<QuickScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getBrandData();
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 56.sp, left: 16.sp, right: 16.sp),
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
                          Row(
                            children: [
                              AppText(
                                text: "Deliver to Akash",
                                color: whiteColor,
                                fontSize: 12,
                                fontFamily: "Franklin Gothic Semibold",
                                fontWeight: FontWeight.w500,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.sp),
                                child: SvgPicture.asset(
                                  dropdownSvgImage,
                                  height: 6.sp,
                                  width: 8.sp,
                                ),
                              ),
                            ],
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
                padding: EdgeInsets.only(left: 16.sp, top: 24.sp, right: 16.sp),
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
                          borderSide: const BorderSide(color: searchTextColor),
                        ),
                        counterText: "",
                        hintText: "Search for 'Kurta'",
                        hintStyle:
                            TextStyle(fontSize: 14.sp, color: searchTextColor),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.sp),
                child: SvgPicture.asset(
                  pumaSvgImage,
                  height: 128.sp,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Obx(() => homeController.isBrand.value
                  ? DummyHomeBrand()
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.sp),
                                    child: AppText(
                                      text: "Featured brands".toUpperCase(),
                                      fontFamily: "Franklin Gothic",
                                      color: expressDeliveryFeaturedBrandsColor,
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
                                    itemCount: homeController.brandList.length,
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
                                                      .brandList[index]["logo"],
                                                  backImage: homeController
                                                              .brandList[index][
                                                          "background_image"] ??
                                                      "",
                                                  name: homeController
                                                      .brandList[index]["name"],
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
                                                    backgroundColor: whiteColor,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            width: 1.sp,
                                                            color: Color(
                                                                0xff9CA3AF)),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            16.0.sp),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: 80.sp,
                                                          width: 80.sp,
                                                          cacheManager: CacheManager(Config(
                                                              "customCacheKey",
                                                              stalePeriod:
                                                                  const Duration(
                                                                      days: 15),
                                                              maxNrOfCacheObjects:
                                                                  100)),
                                                          fit: BoxFit.contain,
                                                          imageUrl: homeController
                                                                  .brandList[
                                                              index]["logo"],
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            downloadImage,
                                                            fit: BoxFit.contain,
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
                                              padding:
                                                  EdgeInsets.only(right: 12.sp),
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
                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
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
            ],
          ),
        ],
      ),
    );
  }
}
