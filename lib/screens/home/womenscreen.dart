import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/home/women/homescreen.dart';
import '../../controller/home_controller.dart';
import '../../controller/product_controller.dart';

class WomenScreen extends StatefulWidget {
  final int genderType;
  const WomenScreen({super.key, required this.genderType});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen>
    with SingleTickerProviderStateMixin {
  final productController = Get.put(ProductController());
  PageController pageController = PageController();
  final homeController = Get.put(HomeController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getTagsData(widget.genderType));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.genderType == 3) {
        homeController.getBannar1Data(widget.genderType);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.genderType == 3) {
        homeController.getBannar2Data();
      }
    });
    /*  WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getBannar1Data());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => homeController.getBannar2Data()); */
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => homeController.getCategoryData(widget.genderType));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      homeController.getConfigurationData();
    });
    super.initState();
  }

  callOnchanged(int index) {
    productController.current.value = index;
    productController.update();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*  Obx(
            () => homeController.istags.value
                ? Padding(
                    padding: EdgeInsets.only(
                        left: 16.sp, bottom: 10.sp, right: 16.sp),
                    child: SizedBox(
                      height: 30.sp,
                      width: double.infinity,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 5.sp),
                              width: 100.sp,
                              height: 30.sp,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20.sp),
                              ),
                            );
                          }),
                    ))
                : homeController.IsAnimateTag.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        child: Center(
                          child: SizedBox(
                              width: double.infinity,
                              height: 50.sp,
                              child: GetBuilder<HomeController>(
                                builder: (value) => ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: homeController.tagsList.length,
                                    scrollDirection: Axis.horizontal,
                                    controller: homeController.tagsController,
                                    itemBuilder: (ctx, index) {
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              homeController.current.value =
                                                  index;
                                              homeController.tagId.value =
                                                  homeController.tagsList[index]
                                                      ["id"];
                                              pageController.animateToPage(
                                                homeController.current.value,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                curve: Curves.ease,
                                              );
                                              homeController.update();
                                              await analytics.logEvent(
                                                name: 'tabclick_home_page',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'tabclick_home_page',
                                                },
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              margin:
                                                  EdgeInsets.only(right: 5.sp),
                                              width: 100.sp,
                                              height: 30.sp,
                                              decoration: BoxDecoration(
                                                color: homeController
                                                            .current.value ==
                                                        index
                                                    ? btnTextColor
                                                    : whiteColor,
                                                borderRadius: homeController
                                                            .current.value ==
                                                        index
                                                    ? BorderRadius.circular(20)
                                                    : BorderRadius.circular(20),
                                                border: homeController
                                                            .current.value ==
                                                        index
                                                    ? Border.all(
                                                        color: btnTextColor,
                                                        width: 1)
                                                    : Border.all(
                                                        color: textHintColor,
                                                        width: 1),
                                              ),
                                              child: Center(
                                                child: AppText(
                                                  text: homeController
                                                      .tagsList[index]["name"],
                                                  color: homeController
                                                              .current.value ==
                                                          index
                                                      ? whiteColor
                                                      : textHintColor,
                                                  fontSize: 12,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              )),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        child: SizedBox(
                            width: double.infinity,
                            height: 50.sp,
                            child: GetBuilder<HomeController>(
                              builder: (value) => ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: homeController.tagsList.length,
                                  scrollDirection: Axis.horizontal,
                                  controller: homeController.tagsController,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            homeController.current.value =
                                                index;
                                            homeController.tagId.value =
                                                homeController.tagsList[index]
                                                    ["id"];
                                            pageController.animateToPage(
                                              homeController.current.value,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.ease,
                                            );
                                            homeController.update();
                                            await analytics.logEvent(
                                              name: 'tabclick_home_page',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'tabclick_home_page',
                                              },
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin:
                                                EdgeInsets.only(right: 5.sp),
                                            width: 100.sp,
                                            height: 30.sp,
                                            decoration: BoxDecoration(
                                              color: homeController
                                                          .current.value ==
                                                      index
                                                  ? btnTextColor
                                                  : whiteColor,
                                              borderRadius: homeController
                                                          .current.value ==
                                                      index
                                                  ? BorderRadius.circular(20)
                                                  : BorderRadius.circular(20),
                                              border: homeController
                                                          .current.value ==
                                                      index
                                                  ? Border.all(
                                                      color: btnTextColor,
                                                      width: 1)
                                                  : Border.all(
                                                      color: textHintColor,
                                                      width: 1),
                                            ),
                                            child: Center(
                                              child: AppText(
                                                text: homeController
                                                    .tagsList[index]["name"],
                                                color: homeController
                                                            .current.value ==
                                                        index
                                                    ? whiteColor
                                                    : textHintColor,
                                                fontSize: 12,
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            )),
                      ),
          ), */
          /*  Obx(
            () => */ /*  productController.istags.value
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp, bottom: 10.sp, right: 16.sp),
                              child: SizedBox(
                                height: 30.sp,
                                width: double.infinity,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
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
                              )),
                          Padding(
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
                                          color: Colors.black.withOpacity(0.04),
                                        ),
                                      );
                                    }),
                              )),
                          const DummyProductList(text: "Express Delivery")
                        ],
                      ),
                    ),
                  )
                : */
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: callOnchanged,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return HomeScreen(
                    /*  tagId: productController.tagId.value,
                  genderType: widget.genderType, */
                    );
              },
            ),
          ),
          // )
        ],
      ),
    );
  }
}
