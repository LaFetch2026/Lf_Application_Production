// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
  const ProductVerticalScreen({super.key});

  @override
  State<ProductVerticalScreen> createState() => ProductVerticalScreenState();
}

class ProductVerticalScreenState extends State<ProductVerticalScreen> {
  final productController = Get.find<ProductController>();
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _curr = 0;
  late VideoPlayerController videoController;
  late Future<void> _initializeVideoPlayerFuture;

  /*  final PageController _pageController = PageController(
    initialPage: 0,
  ); */

  /* callOnchanged(int index) {
    setState(() {
      productController.currentpage.value = index;
    });
  } */

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    wishlistController.getWishlistData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.listController.addListener(() {
        productController.fetchMoreData("relevant");
        productController.update();
      });
    });
    productController.hasnextpage.value = true;
    productController.loadMore.value = false;
    productController.isProduct.value = false;
    productController.page.value = 1;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
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
    if (productController.productList[index]["images"].isNotEmpty) {
      for (var i = 0;
          i < productController.productList[index]["images"].length;
          i++) {
        if (isImage(
            productController.productList[index]["images"][i]["name"])) {
          print(
              "show video=========${isImage(productController.productList[index]["images"][i]["name"])}");

          list.add(Container(
              color: colorSecondary,
              child: Image.network(
                  productController.productList[index]["images"][i]["name"],
                  fit: BoxFit.cover)));
        } else {
          productController.isVideoPlaying.value = true;
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(
              productController.productList[index]["images"][i]["name"],
            ),
          );

          _initializeVideoPlayerFuture = videoController.initialize();
          videoController.setLooping(true);

          list.add(
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return Obx(() => Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: videoController.value.aspectRatio,
                            // Use the VideoPlayer widget to display the video.
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
                                // If the video is paused, play it.
                                productController.isVideoPlaying.value = false;
                                videoController.play();
                              }
                              // setState(() {
                              //   // If the video is playing, pause it.
                              //   if (videoController.value.isPlaying) {
                              //     videoController.pause();
                              //   } else {
                              //     // If the video is paused, play it.
                              //     videoController.play();
                              //   }
                              // });
                            },
                          ),
                        ],
                      ));
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
        }
      }
    } else {
      list.add(Image.asset(dummyWishlistImage, fit: BoxFit.cover));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Obx(
          () => productController.isProduct.value
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : productController.productList.isNotEmpty
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          controller: productController.listController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 60),
                                child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  controller: productController.listController,
                                  padding: EdgeInsets.zero,
                                  physics: const ScrollPhysics(),
                                  itemCount:
                                      productController.productList.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(ProductDetailsScreen(
                                              productId: productController
                                                  .productList[index]["id"],
                                            ));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  productController.productList[
                                                                  index]
                                                              ["images"] !=
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 0),
                                                          child: SizedBox(
                                                            height: 400,
                                                            width:
                                                                double.infinity,
                                                            child: PageView(
                                                                allowImplicitScrolling:
                                                                    true,
                                                                scrollDirection:
                                                                    Axis
                                                                        .horizontal,
                                                                onPageChanged:
                                                                    (number) {
                                                                  setState(() {
                                                                    _curr =
                                                                        number;
                                                                  });
                                                                },
                                                                children:
                                                                    getListForPageView(
                                                                        index)),
                                                          ))
                                                      : Image.asset(
                                                          dummyWishlistImage,
                                                          height: 400,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover),
                                                  /*  productController.productList[
                                                                  index]
                                                              ["images"] !=
                                                          null
                                                      ? SizedBox(
                                                          height: 400,
                                                          width:
                                                              double.infinity,
                                                          child:
                                                              PageView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            controller:
                                                                _pageController,
                                                            onPageChanged:
                                                                callOnchanged,
                                                            itemCount:
                                                                productController
                                                                    .productList[
                                                                        index][
                                                                        "images"]
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    int i) {
                                                              return productController
                                                                      .productList[index]
                                                                          [
                                                                          "images"]
                                                                      .isNotEmpty
                                                                  ? SizedBox(
                                                                      height:
                                                                          400,
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        cacheManager: CacheManager(Config(
                                                                            "customCacheKey",
                                                                            stalePeriod:
                                                                                const Duration(days: 15),
                                                                            maxNrOfCacheObjects: 100)),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        imageUrl:
                                                                            productController.productList[index]["images"][0]["name"],
                                                                        progressIndicatorBuilder: (context,
                                                                                url,
                                                                                downloadProgress) =>
                                                                            Center(
                                                                          child:
                                                                              CircularProgressIndicator(value: downloadProgress.progress),
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          dummyWishlistImage,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          height:
                                                                              400,
                                                                          width:
                                                                              double.infinity,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Image.asset(
                                                                      dummyWishlistImage,
                                                                      height:
                                                                          400,
                                                                      width: double
                                                                          .infinity,
                                                                      fit: BoxFit
                                                                          .cover);
                                                            },
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          dummyWishlistImage,
                                                          height: 400,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover), */
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (productController
                                                                  .productList[
                                                              index]
                                                          ["wishlisted"]) {
                                                        productController.callAddProductToWishlist(
                                                            productController
                                                                        .productList[
                                                                    index]
                                                                ["wishlist_id"],
                                                            "product",
                                                            productController
                                                                    .productList[
                                                                index]["id"],
                                                            0,
                                                            0,
                                                            []);
                                                      } else {
                                                        scaffoldKey.currentState
                                                            ?.showBottomSheet((context) =>
                                                                BottomWishlist(
                                                                    controller:
                                                                        wishlistController,
                                                                    onPressed:
                                                                        (p0) {
                                                                      productController.callAddProductToWishlist(
                                                                          p0,
                                                                          "product",
                                                                          productController.productList[index]
                                                                              [
                                                                              "id"],
                                                                          0,
                                                                          0,
                                                                          []);
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
                                                              child: productController
                                                                              .productList[
                                                                          index]
                                                                      [
                                                                      "wishlisted"]
                                                                  ? Image.asset(
                                                                      wishlistSelectImage,
                                                                      height:
                                                                          22,
                                                                      width: 22,
                                                                    )
                                                                  : Image.asset(
                                                                      heartImage,
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 350),
                                                        color: const Color(
                                                            0xB3F7F7F5),
                                                        height: 26,
                                                        width: 80,
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              starImage,
                                                              height: 24,
                                                              color:
                                                                  bottomnavBack,
                                                              width: 24,
                                                            ),
                                                            AppText(
                                                              text: productController
                                                                              .productList[index]
                                                                          [
                                                                          "aggregated_rating"] !=
                                                                      null
                                                                  ? productController
                                                                      .productList[
                                                                          index]
                                                                          [
                                                                          "aggregated_rating"]
                                                                      .toString()
                                                                  : "",
                                                              color:
                                                                  colorPrimary,
                                                              fontSize: 12.sp,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
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
                                                              color:
                                                                  colorPrimary,
                                                              fontSize: 12.sp,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              productController
                                                          .productList[index]
                                                              ["images"]
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
                                                                    productController
                                                                        .productList[
                                                                            index]
                                                                            [
                                                                            "images"]
                                                                        .length,
                                                                    (int l) {
                                                                  if (isImage(productController
                                                                              .productList[index]
                                                                          [
                                                                          "images"][l]
                                                                      [
                                                                      'name'])) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              2),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            const Duration(milliseconds: 400),
                                                                        height:
                                                                            6,
                                                                        width:
                                                                            6,
                                                                        margin:
                                                                            const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              5,
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                5),
                                                                            color: (l == _curr)
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
                                                                        color: (l ==
                                                                                _curr)
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: productController
                                                              .productList[
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: AppText(
                                                  text: productController
                                                                  .productList[
                                                              index][
                                                          "short_description"] ??
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
                                                    top: 10,
                                                    left: 10,
                                                    right: 1),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text:
                                                          "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                      color: deepGreytextColor,
                                                      maxLines: 2,
                                                      fontSize: 14.sp,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        "\u{20B9} ${productController.productList[index]["mrp"] ?? ""}",
                                                        style: TextStyle(
                                                          color: textHintColor,
                                                          fontSize: 11.sp,
                                                          decoration:
                                                              TextDecoration
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
                                                              .symmetric(
                                                          horizontal: 5),
                                                      child: AppText(
                                                        text: "Express",
                                                        color: expressText,
                                                        maxLines: 2,
                                                        fontSize: 11.sp,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              productController.loadMore.value
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
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
                    ),
        ));
  }
}
