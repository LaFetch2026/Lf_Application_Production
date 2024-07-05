// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_vertical_list.dart';
import 'package:lafetch/commonwidget/productvedio.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:video_player/video_player.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/catalogwidgets/bottomfiltters.dart';
import '../../../commonwidget/catalogwidgets/bottomsortby.dart';
import '../../../commonwidget/catalogwidgets/bottomwishlist.dart';
import '../../../commonwidget/doublebtn.dart';
import '../../../controller/product_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';

class ProductVerticalScreen extends StatefulWidget {
  final int categoryId;
  const ProductVerticalScreen({super.key, required this.categoryId});

  @override
  State<ProductVerticalScreen> createState() => ProductVerticalScreenState();
}

class ProductVerticalScreenState extends State<ProductVerticalScreen> {
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late VideoPlayerController videoController;
  //late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    productController.curr.value = 0;
    productController.productCategoryList.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getProductByCategoryData(widget.categoryId, 0, "", []));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductController.addListener(() {
        productController.fetchCategoryProductMoreData(widget.categoryId, 0);
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.categoryProductHasnextpage.value = true;
      productController.categoryProductLoadMore.value = false;
      productController.isCategoryProduct.value = false;
      productController.categoryProductPage.value = 1;
    });
    super.initState();
  }

  @override
  void dispose() {
    productController.isVideoPlaying.value = true;
    videoController.dispose();
    super.dispose();
  }

  bool isImage(String path) {
    print(path);
    return path.contains('product_photo');
  }

  List<Widget> getListForPageView(int index) {
    List<Widget> list = [];
    if (productController.productCategoryList[index]["images"].isNotEmpty) {
      for (var i = 0;
          i < productController.productCategoryList[index]["images"].length;
          i++) {
        if (isImage(productController.productCategoryList[index]["images"][i]
            ["name"])) {
          list.add(Container(
            color: colorSecondary,
            child: CachedNetworkImage(
              cacheManager: CacheManager(Config("customCacheKey",
                  stalePeriod: const Duration(days: 15),
                  maxNrOfCacheObjects: 100)),
              fit: BoxFit.cover,
              imageUrl: productController.productCategoryList[index]["images"]
                  [i]["name"],
              errorWidget: (context, url, error) =>
                  Image.asset(downloadImage, fit: BoxFit.cover),
            ),
          ));
        } else {
          //  productController.isVideoPlaying.value = true;
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(
              productController.productCategoryList[index]["images"][i]["name"],
            ),
          );

          //  _initializeVideoPlayerFuture = videoController.initialize();
          //  videoController.setLooping(true);

          /*   list.add(
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Obx(() => Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: videoController.value.aspectRatio,
                            child: VideoPlayer(videoController),
                          ),
                          IconButton(
                            icon: CircleAvatar(
                              backgroundColor: blue,
                              child: Icon(
                                !productController.isVideoPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                            onPressed: () {
                              if (videoController.value.isPlaying) {
                                videoController.pause();
                                productController.isVideoPlaying.value = true;
                              } else {
                                productController.isVideoPlaying.value = false;
                                videoController.play();
                              }
                            },
                          ),
                        ],
                      ));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
          */

          list.add(ProductVideo(
            videoController: videoController,
          ));
        }
      }
    } else {
      list.add(Image.asset(dummyWishlistImage, fit: BoxFit.cover));
    }
    return list;
  }

  /*   List<Widget> getListSwiper(int index) {
    List<Widget> list = [];
    if (productController.productList[index]["images"].isNotEmpty) {
      for (var i = 0;
          i < productController.productList[index]["images"].length;
          i++) {
        productController.curr.value = 0;
        if (isImage(
            productController.productList[index]["images"][i]['name'])) {
          list.add(Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 6,
              width: 6,
              margin: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: (i == productController.curr.value)
                      ? colorPrimary
                      : colorSecondary),
            ),
          ));
        } else {
          list.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AppText(
              text: '\u{25B6}',
              fontSize: 14,
              color: (i == productController.curr.value)
                  ? colorPrimary
                  : colorSecondary,
            ),
          ));
        }
      }
    }
    return list;
  }
 */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Obx(() => productController.isCategoryProduct.value
            ? const DummyVerticalList()
            : productController.productCategoryList.isNotEmpty
                ? Stack(
                    children: [
                      SingleChildScrollView(
                        controller: productController.categoryProductController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 60),
                              child: GetBuilder<ProductController>(
                                builder: (value) => ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  controller: value.categoryProductController,
                                  padding: EdgeInsets.zero,
                                  physics: const ScrollPhysics(),
                                  itemCount: value.productCategoryList.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    ProductDetailsScreen(
                                                        productId: value
                                                                .productCategoryList[
                                                            index]["id"],
                                                        type: "add")))
                                            .then((value) => setState(
                                                  () {
                                                    value
                                                        .categoryProductHasnextpage
                                                        .value = true;
                                                    value
                                                        .categoryProductLoadMore
                                                        .value = false;
                                                    value.isCategoryProduct
                                                        .value = false;
                                                    value.categoryProductPage
                                                        .value = 1;
                                                    value
                                                        .getProductByCategoryData(
                                                            widget.categoryId,
                                                            0);
                                                  },
                                                ));
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              value.productCategoryList[index]
                                                          ["images"] !=
                                                      null
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 0),
                                                      child: SizedBox(
                                                        height: 400,
                                                        width: double.infinity,
                                                        child: PageView(
                                                            allowImplicitScrolling:
                                                                true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            onPageChanged:
                                                                (number) {
                                                              value.curr.value =
                                                                  number;
                                                              value.index
                                                                      .value =
                                                                  index;
                                                              value
                                                                  .isVideoPlaying
                                                                  .value = true;
                                                              value.update();
                                                            },
                                                            children:
                                                                getListForPageView(
                                                                    index)),
                                                      ))
                                                  : Image.asset(
                                                      dummyWishlistImage,
                                                      height: 400,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover),
                                              GestureDetector(
                                                onTap: () {
                                                  if (value.productCategoryList[
                                                      index]["wishlisted"]) {
                                                    value.callAddProductToWishlist(
                                                        value.productCategoryList[
                                                                index]
                                                            ["wishlist_id"],
                                                        "category",
                                                        value.productCategoryList[
                                                            index]["id"],
                                                        widget.categoryId,
                                                        0,
                                                        [],
                                                        0);
                                                  } else {
                                                    scaffoldKey.currentState
                                                        ?.showBottomSheet((context) =>
                                                            BottomWishlist(
                                                                controller:
                                                                    wishlistController,
                                                                onPressed:
                                                                    (p0) {
                                                                  value.callAddProductToWishlist(
                                                                      p0,
                                                                      "category",
                                                                      value.productCategoryList[
                                                                              index]
                                                                          [
                                                                          "id"],
                                                                      widget
                                                                          .categoryId,
                                                                      0,
                                                                      [],
                                                                      0);
                                                                },
                                                                wishlistList:
                                                                    wishlistController
                                                                        .wishlistList));
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: InkWell(
                                                      child: SizedBox(
                                                        height: 30,
                                                        width: 30,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              whiteColor,
                                                          child: value.productCategoryList[
                                                                      index]
                                                                  ["wishlisted"]
                                                              ? Image.asset(
                                                                  wishlistSelectImage,
                                                                  height: 22,
                                                                  width: 22,
                                                                )
                                                              : Image.asset(
                                                                  heartImage,
                                                                  height: 30,
                                                                  width: 30,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 350),
                                                    color:
                                                        const Color(0xB3F7F7F5),
                                                    height: 26,
                                                    width: 80,
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          starImage,
                                                          height: 24,
                                                          color: bottomnavBack,
                                                          width: 24,
                                                        ),
                                                        AppText(
                                                          text: value.productCategoryList[
                                                                          index]
                                                                      [
                                                                      "aggregated_rating"] !=
                                                                  null
                                                              ? value
                                                                  .productCategoryList[
                                                                      index][
                                                                      "aggregated_rating"]
                                                                  .toString()
                                                              : "",
                                                          color: colorPrimary,
                                                          fontSize: 12.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Container(
                                                            width: 1,
                                                            color:
                                                                textHintColor,
                                                            height: 16,
                                                          ),
                                                        ),
                                                        AppText(
                                                          text: "8",
                                                          color: colorPrimary,
                                                          fontSize: 12.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          value
                                                      .productCategoryList[
                                                          index]["images"]
                                                      .length ==
                                                  1
                                              ? const SizedBox(
                                                  height: 0,
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: Center(
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: List<
                                                                    Widget>.generate(
                                                                value
                                                                    .productCategoryList[
                                                                        index][
                                                                        "images"]
                                                                    .length,
                                                                (int l) {
                                                              if (isImage(value
                                                                              .productCategoryList[
                                                                          index]
                                                                      ["images"]
                                                                  [
                                                                  l]['name'])) {
                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 2),
                                                                  child:
                                                                      AnimatedContainer(
                                                                    duration: const Duration(
                                                                        milliseconds:
                                                                            400),
                                                                    height: 6,
                                                                    width: 6,
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                5),
                                                                        color: (l == value.curr.value &&
                                                                                value.index.value == index)
                                                                            ? colorPrimary
                                                                            : colorSecondary),
                                                                  ),
                                                                );
                                                              } else {
                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          2.0),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        '\u{25B6}',
                                                                    fontSize:
                                                                        14,
                                                                    color: (l == value.curr.value &&
                                                                            value.index.value ==
                                                                                index)
                                                                        ? colorPrimary
                                                                        : colorSecondary,
                                                                  ),
                                                                );
                                                              }
                                                            })),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: AppText(
                                              text: value.productCategoryList[
                                                      index]["name"] ??
                                                  "",
                                              color: nameText,
                                              maxLines: 2,
                                              fontSize: 14.sp,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: AppText(
                                              text: value.productCategoryList[
                                                          index]
                                                      ["short_description"] ??
                                                  "",
                                              color: nameText,
                                              maxLines: 2,
                                              fontSize: 12.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 10, right: 1),
                                            child: Row(
                                              children: [
                                                AppText(
                                                  text:
                                                      "\u{20B9} ${value.productCategoryList[index]["price"] ?? ""}",
                                                  color: deepGreytextColor,
                                                  maxLines: 2,
                                                  fontSize: 14.sp,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    "\u{20B9} ${value.productCategoryList[index]["mrp"] ?? ""}",
                                                    style: TextStyle(
                                                      color: textHintColor,
                                                      fontSize: 11.sp,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 10,
                                                right: 10,
                                                bottom: 30),
                                            child: Row(
                                              children: [
                                                const ImageIcon(
                                                  AssetImage(truckImage),
                                                  color: expressText,
                                                  size: 14,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: AppText(
                                                    text: "Express",
                                                    color: expressText,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            productController.loadMore.value
                                ? const DummyVerticalList()
                                : const SizedBox(
                                    height: 0,
                                  ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, top: 20, left: 4, right: 8),
                          child: DoubleButton(
                            firstText: "Sort By",
                            secondText: "Filters",
                            firstTextColor: deepGreytextColor,
                            secondTextColor: deepGreytextColor,
                            firstBackgroundColor: whiteTextColor,
                            secondBackgroundColor: whiteTextColor,
                            firstBorderColor: deepGreytextColor,
                            secondBorderColor: deepGreytextColor,
                            onPressedFirst: () {
                              scaffoldKey.currentState?.showBottomSheet(
                                  (context) => const BottomSortBy());
                            },
                            onPressedSecond: () {
                              Get.to(const BottomFilters());
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text("No Product Found",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: "Franklin Gothic Regular")),
                    ),
                  )));
  }
}
