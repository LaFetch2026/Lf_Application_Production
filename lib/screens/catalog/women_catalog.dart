// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/catalogwidgets/dummy_catalog_list.dart';
import 'package:lafetch/controller/catalog_controller.dart';
import 'package:lafetch/screens/catalog/catalogdetails.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenCatalogScreen extends StatefulWidget {
  final String categorytext;
  final int type;
  const WomenCatalogScreen(
      {super.key, required this.categorytext, required this.type});

  @override
  State<WomenCatalogScreen> createState() => WomenCatalogScreenState();
}

class WomenCatalogScreenState extends State<WomenCatalogScreen> {
  final controller = Get.put(CatalogController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCatalogData(widget.type));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.sp, left: 16.sp, right: 16.sp),
              child: AppText(
                text: "Explore our entire collection",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: appbarText,
                fontSize: 22,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
              child: AppText(
                text: "For ${widget.categorytext}",
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: textHintColor,
                fontSize: 14,
              ),
            ),
            Obx(() => controller.isCatalog.value
                ? const DummyCatalogList()
                : controller.catalogList.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 16.sp, right: 16.sp, top: 10.sp),
                        child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: controller.catalogList.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (ctx, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                      onTap: () async {
                                        Get.to(CatalogDetailsScreen(
                                          title: controller.catalogList[index]
                                                  ["name"] ??
                                              "",
                                          catalogId: controller
                                              .catalogList[index]["id"],
                                          catalogImage:
                                              controller.catalogList[index]
                                                      ["thumbnail"] ??
                                                  "",
                                          genderType: widget.type,
                                          catalogText: widget.categorytext,
                                        ));
                                        await analytics.logEvent(
                                          name: "catalog_page_${widget.type}",
                                          parameters: <String, Object>{
                                            'page_name':
                                                "catalog_page_${widget.type}",
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10.sp),
                                        child: Container(
                                          width: double.infinity,
                                          height: 100.sp,
                                          child: controller.catalogList[index]
                                                      ["thumbnail"] !=
                                                  null
                                              ? Stack(
                                                  children: [
                                                    SizedBox(
                                                      height: 100.sp,
                                                      width: double.infinity,
                                                      child: CachedNetworkImage(
                                                        cacheManager:
                                                            CacheManager(Config(
                                                                "customCacheKey",
                                                                stalePeriod:
                                                                    const Duration(
                                                                        days:
                                                                            15),
                                                                maxNrOfCacheObjects:
                                                                    100)),
                                                        fit: BoxFit.cover,
                                                        imageUrl: controller
                                                                .catalogList[
                                                            index]["thumbnail"],
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          downloadImage,
                                                          height: 100.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
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
                                                                  fontSize: 16,
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
                                                  ],
                                                )
                                              : SizedBox(
                                                  height: 100.sp,
                                                  width: double.infinity,
                                                  child: Image.asset(backImage,
                                                      height: 100.sp,
                                                      fit: BoxFit.cover),
                                                ),
                                        ),
                                      )),
                                ],
                              );
                            }),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text("No Catolog Found",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontFamily: "Franklin Gothic Regular")),
                        ),
                      ))
          ],
        ),
      ),
    );
  }
}
