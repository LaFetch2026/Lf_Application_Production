// ignore_for_file: avoid_print

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomwishlist.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_productdetails.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/homewidget/horizontal_home_list.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';
import '../../brandsscreen.dart';
import '../../cartscreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String type;
  final int wishlistProductId;
  final int boardId;
  final bool color;
  const ProductDetailsScreen(
      {super.key,
      required this.productId,
      required this.type,
      this.boardId = 0,
      this.color = false,
      this.wishlistProductId = 0});

  @override
  State<ProductDetailsScreen> createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController controller = PageController();
  final productController = Get.put(ProductController());
  final wishlistController = Get.put(WishlistController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late VideoPlayerController videoController;
  late Future<void> _initializeVideoPlayerFuture;
  int _curr = 0;
  Map<String, dynamic> selectedProductSize = {};
  Map<String, dynamic> selectedProductColor = {};
  Map<String, dynamic> selectedProductFabric = {};
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var cartQuantityItems = 0;
  final GlobalKey widgetKey = GlobalKey();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Map<String, String>> reviewsCount = [
    {'id': '1', 'title': '5', 'count': '1121', 'total': '2015'},
    {'id': '2', 'title': '4', 'count': '406', 'total': '2015'},
    {'id': '3', 'title': '3', 'count': '250', 'total': '2015'},
    {'id': '4', 'title': '2', 'count': '87', 'total': '2015'},
    {'id': '5', 'title': '1', 'count': '151', 'total': '2015'},
  ];

  Color getColorForReview(reviewTitle) {
    switch (reviewTitle) {
      case '5':
        return color5StartReview;
      case '4':
        return color4StartReview;
      case '3':
        return color3StartReview;
      case '2':
        return color2StartReview;
      case '1':
        return color1StartReview;
      default:
        return colorPrimary;
    }
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('inventorySizeId') != null) {
      selectedProductSize["id"] = prefs.getInt('inventorySizeId')!;
    }
    if (prefs.getInt('inventoryColorId') != null) {
      productController.sizeInventoryId.value =
          prefs.getInt('inventoryColorId')!;
      selectedProductColor["id"] = prefs.getInt('inventoryColorId')!;
    }
    print("prefrences call ${productController.sizeInventoryId.value}");
  }

  List<Widget> getListForPageView() {
    List<Widget> list = [];
    if (productController.productDetails["images"].isNotEmpty) {
      for (var i = 0;
          i < productController.productDetails["images"].length;
          i++) {
        if (isImage(productController.productDetails["images"][i]["name"])) {
          print(
              "show video=========${isImage(productController.productDetails["images"][i]["name"])}");

          list.add(Container(
            color: colorSecondary,
            child: CachedNetworkImage(
              cacheManager: CacheManager(Config("customCacheKey",
                  stalePeriod: const Duration(days: 15),
                  maxNrOfCacheObjects: 100)),
              fit: BoxFit.cover,
              imageUrl: productController.productDetails["images"][i]["name"],
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  DummyContainer(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width),
              errorWidget: (context, url, error) =>
                  Image.asset(downloadImage, fit: BoxFit.fitHeight),
            ),
          ));
        } else {
          productController.isVideoPlaying.value = true;
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(
              productController.productDetails["images"][i]["name"],
            ),
          );

          _initializeVideoPlayerFuture = videoController.initialize();

          // Use the controller to loop the video.
          videoController.setLooping(true);
          // videoController.play();
          // videoController.setVolume(0);

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
      list.add(Image.asset(dummyWishlistImage, fit: BoxFit.fitHeight));
    }
    return list;
  }

  bool isImage(String path) {
    print(path);
    return path.contains('product_photo');
  }

  SizedBox getListForProductSize() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
          child: productController.sizeInventoryList
                  .where(
                      (element) => int.parse(element['stocks'].toString()) > 0)
                  .toList()
                  .isNotEmpty
              ? Wrap(
                  direction: Axis.horizontal,
                  spacing: 12.0,
                  runSpacing: 8.0,
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: [
                      for (var i in productController.sizeInventoryList.where(
                          (element) =>
                              int.parse(element['stocks'].toString()) > 0))
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                selectedProductSize = i;
                                productController.sizeInventoryId.value =
                                    selectedProductSize["id"];
                                print(productController.sizeInventoryId.value);
                                productController.colorInventoryList =
                                    i["product_matrix_available_colors"];
                                prefs.setInt("inventorySizeId",
                                    selectedProductSize["id"]);
                                print(selectedProductSize["id"]);
                                print(i['product_matrix_size_name']);
                                prefs.remove("inventoryColorId");
                                setState(() {});
                                await analytics.logEvent(
                                  name: 'productDetails_sizeSelect',
                                  parameters: <String, Object>{
                                    'page_name': 'productDetails_sizeSelect',
                                  },
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: btnTextColor, width: 1),
                                      color: selectedProductSize.isNotEmpty &&
                                              selectedProductSize['id'] ==
                                                  i['id']
                                          ? colorPrimary
                                          : whiteColor),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: AppText(
                                        text: i['product_matrix_size_name']
                                            .toString(),
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: selectedProductSize.isNotEmpty &&
                                                selectedProductSize['id'] ==
                                                    i['id']
                                            ? whiteColor
                                            : btnTextColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  )),
                            ),
                            int.parse(i['stocks'].toString()) > 10
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: AppText(
                                      text: '${i['stocks'].toString()} left',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: redColor,
                                      fontSize: 11.sp,
                                    ),
                                  )
                          ],
                        ),
                    ])
              : AppText(
                  text: 'N/A',
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: redColor,
                  fontSize: 11.sp,
                ),
        ));
  }

  movetoNextScreen(int id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ProductDetailsScreen(
                  productId: id,
                  type: "add",
                  color: true,
                )));
      });
    });
  }

  SizedBox getListForProductColor() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
          child: productController.colorInventoryList
                  .where(
                      (element) => int.parse(element['stocks'].toString()) > 0)
                  .toList()
                  .isNotEmpty
              ? Wrap(
                  direction: Axis.horizontal,
                  spacing: 12.0,
                  runSpacing: 8.0,
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: [
                      for (var i in productController.colorInventoryList.where(
                          (element) =>
                              int.parse(element['stocks'].toString()) > 0))
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                selectedProductColor = i;
                                productController.colorInventoryId.value =
                                    selectedProductColor["id"];
                                productController.sizeInventoryId.value =
                                    selectedProductColor["id"];
                                prefs.setInt("inventoryColorId",
                                    selectedProductColor["id"]);
                                print(selectedProductColor["id"]);
                                print(i['name']);
                                await analytics.logEvent(
                                  name: 'productDetails_colorSelect',
                                  parameters: <String, Object>{
                                    'page_name': 'productDetails_colorSelect',
                                  },
                                );
                                setState(() {});
                                //   movetoNextScreen(i['product_id']);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: btnTextColor, width: 1),
                                    color: selectedProductColor.isNotEmpty &&
                                            selectedProductColor['id'] ==
                                                i['id']
                                        ? colorPrimary
                                        : whiteColor),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: AppText(
                                    text: i['name'].toString(),
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: selectedProductColor.isNotEmpty &&
                                            selectedProductColor['id'] ==
                                                i['id']
                                        ? whiteColor
                                        : btnTextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                            int.parse(i['stocks'].toString()) > 10
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: AppText(
                                      text: '${i['stocks'].toString()} left',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: redColor,
                                      fontSize: 11.sp,
                                    ),
                                  )
                          ],
                        ),
                    ])
              : AppText(
                  text: 'N/A',
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: redColor,
                  fontSize: 11.sp,
                ),
        ));
  }

  SizedBox getListForProductFabric() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
          child: productController.fabricInventoryList
                  .where(
                      (element) => int.parse(element['stocks'].toString()) > 0)
                  .toList()
                  .isNotEmpty
              ? Wrap(
                  direction: Axis.horizontal,
                  spacing: 12.0,
                  runSpacing: 8.0,
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: [
                      for (var i in productController.fabricInventoryList.where(
                          (element) =>
                              int.parse(element['stocks'].toString()) > 0))
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                selectedProductFabric = i;
                                productController.fabricInventoryId.value =
                                    selectedProductFabric["id"];
                                print(
                                    productController.fabricInventoryId.value);
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: btnTextColor, width: 1),
                                    color: selectedProductFabric.isNotEmpty &&
                                            selectedProductFabric['id'] ==
                                                i['id']
                                        ? colorPrimary
                                        : whiteColor),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: AppText(
                                    text:
                                        i['product_matrix']['name'].toString(),
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: selectedProductFabric.isNotEmpty &&
                                            selectedProductFabric['id'] ==
                                                i['id']
                                        ? whiteColor
                                        : btnTextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                            int.parse(i['stocks'].toString()) > 10
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: AppText(
                                      text: '${i['stocks'].toString()} left',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: redColor,
                                      fontSize: 11.sp,
                                    ),
                                  )
                          ],
                        ),
                    ])
              : AppText(
                  text: 'N/A',
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: redColor,
                  fontSize: 11.sp,
                ),
        ));
  }

  @override
  void initState() {
    productController.brandDetails = "";
    productController.pincodeController.clear();
    productController.sizeInventoryId.value = 0;
    productController.colorInventoryId.value = 0;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductDetails(widget.productId));
    if (widget.color) {
      getPrefrenceValue();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.frequentlyBoughtController.addListener(() {
        productController.fetchFrequentlyMoreData(
            "frequently-bought", widget.productId);
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.frequentlyBoughtHasnextpage.value = true;
      productController.frequentlyBoughtLoadMore.value = false;
      productController.isFrequentlyBought.value = false;
      productController.frequentlyBoughtPage.value = 1;
      productController.inventoryId.value = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.recommendedController.addListener(() {
        productController.fetchMoreRecommendedProductData(widget.productId);
        productController.update();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.recommendedHasnextpage.value = true;
      productController.recommendedLoadMore.value = false;
      productController.isRecommendations.value = false;
      productController.recommendedPage.value = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getFrequentlyProductData("frequently-bought", widget.productId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => wishlistController.getWishlistProductDetails(widget.productId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductReview(widget.productId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductRecommendations(widget.productId));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    super.initState();
  }

  void listClick(GlobalKey widgetKey) async {
    await runAddToCartAnimation(widgetKey);
    await cartKey.currentState!
        .runCartAnimation((++cartQuantityItems).toString());
    //  productController.getProductDetails(widget.productId);
  }

  @override
  void dispose() {
    productController.isVideoPlaying.value = true;
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey,
      height: 25,
      width: 25,
      opacity: 0.80,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => productController.isDetails.value
                            ? const DummyProductDetails()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Stack(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.7,
                                              child: PageView(
                                                  allowImplicitScrolling: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  onPageChanged: (number) {
                                                    if (videoController
                                                        .value.isPlaying) {
                                                      videoController.pause();
                                                      productController
                                                          .isVideoPlaying
                                                          .value = true;
                                                    }
                                                    setState(() {
                                                      _curr = number;
                                                    });
                                                  },
                                                  children:
                                                      getListForPageView()),
                                            )),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15,
                                          // height: 80,
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                IconButton(
                                                  icon: Image.asset(arrowBack),
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                ),
                                                Column(
                                                  children: [
                                                    /*   IconButton(
                                                      icon: CircleAvatar(
                                                          backgroundColor:
                                                              colorPrimary,
                                                          child: Image.asset(
                                                              cartIconWhite)),
                                                      onPressed: () {
                                                        Get.to(
                                                            const CartScreen());
                                                      },
                                                    ), */
                                                    GestureDetector(
                                                      onTap: () async {
                                                        Get.to(
                                                            const CartScreen());
                                                        await analytics
                                                            .logEvent(
                                                          name: 'cart_page',
                                                          parameters: <String,
                                                              Object>{
                                                            'page_name':
                                                                'cart_page',
                                                          },
                                                        );
                                                      },
                                                      child: AddToCartIcon(
                                                        key: cartKey,
                                                        icon: CircleAvatar(
                                                            backgroundColor:
                                                                colorPrimary,
                                                            child: Image.asset(
                                                                cartIconWhite)),
                                                        badgeOptions:
                                                            const BadgeOptions(
                                                          active: false,
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    /*  IconButton(
                                                      icon: CircleAvatar(
                                                          backgroundColor:
                                                              whiteColor,
                                                          child: Image.asset(
                                                              shareImage)),
                                                      onPressed: () async {
                                                        Share.share(
                                                            'https://la-fetch.com/privacy-policy/');
                                                        await analytics
                                                            .logEvent(
                                                          name: 'share_product',
                                                          parameters: <String,
                                                              Object>{
                                                            'page_name':
                                                                'share_product',
                                                          },
                                                        );
                                                      },
                                                    ), */
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            bottom: 30,
                                            right: 16,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              height: 30,
                                              color: const Color(0xB3F7F7F5),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    starImage,
                                                    height: 24,
                                                    color: bottomnavBack,
                                                    width: 24,
                                                  ),
                                                  AppText(
                                                    text: productController
                                                        .productDetails[
                                                            "aggregated_rating"]
                                                        .toString(),
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: colorPrimary,
                                                    fontSize: 12.sp,
                                                  ),
                                                  const VerticalDivider(
                                                      color: colorSecondary),
                                                  AppText(
                                                    text: '8',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: colorPrimary,
                                                    fontSize: 12.sp,
                                                  ),
                                                ],
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  productController.productDetails["images"]
                                              .length ==
                                          1
                                      ? const SizedBox(
                                          height: 0,
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22.0, vertical: 18.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List<Widget>.generate(
                                                productController
                                                    .productDetails["images"]
                                                    .length,
                                                (index) => Container(
                                                      height: 6,
                                                      width: 40,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          color: (index ==
                                                                  _curr)
                                                              ? colorPrimary
                                                              : colorSecondary),
                                                    )),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: AppText(
                                      text: "New Season",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: greyTextColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0,
                                          bottom: 5.0,
                                          left: 12,
                                          right: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: AppText(
                                              text:
                                                  "${productController.productDetails["name"]} \n",
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w600,
                                              color: colorPrimary,
                                              maxLines: 2,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          productController.brandDetails !=
                                                      null &&
                                                  productController
                                                          .brandDetails !=
                                                      ""
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    await analytics.logEvent(
                                                      name:
                                                          'productdetails_explorebrand',
                                                      parameters: <String,
                                                          Object>{
                                                        'page_name':
                                                            'productdetails_explorebrand',
                                                      },
                                                    );
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      setState(() {
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        BrandsScreen(
                                                                          screen:
                                                                              "search",
                                                                          logo:
                                                                              productController.brandDetails["logo"],
                                                                          backImage:
                                                                              productController.brandDetails["background_image"] ?? "",
                                                                          name:
                                                                              productController.brandDetails["name"],
                                                                          brandId:
                                                                              productController.brandDetails["id"],
                                                                        )));
                                                      });
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: AppText(
                                                      text: 'Explore Brand \n',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: colorPrimary,
                                                      maxLines: 2,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 0,
                                                )
                                        ],
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: AppText(
                                      text: productController.productDetails[
                                              "short_description"] ??
                                          "",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: greyTextColor,
                                      maxLines: 4,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12.0, left: 12, right: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          "\u{20B9} ${productController.productDetails["mrp"] ?? "0"}",
                                          style: TextStyle(
                                            color: textHintColor,
                                            fontSize: 16.sp,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: AppText(
                                            text:
                                                "\u{20B9} ${productController.productDetails["price"] ?? "0"}",
                                            color: colorPrimary,
                                            fontSize: 16.sp,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: greyBack,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 6,
                                                bottom: 6,
                                                left: 8,
                                                right: 8),
                                            child: AppText(
                                              text:
                                                  "${productController.productDetails["discount_percentage"] != null ? productController.productDetails["discount_percentage"].toString() : "0"} OFF",
                                              color: expressText,
                                              fontSize: 12.sp,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  productController.sizeInventoryList.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 30.0,
                                                    bottom: 0.0,
                                                    left: 12,
                                                    right: 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    AppText(
                                                      text: 'Select size',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 16.sp,
                                                    ),
                                                    AppText(
                                                      text: 'View Size chart',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: colorPrimary,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                )),
                                            getListForProductSize(),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  productController
                                          .colorInventoryList.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 14.0,
                                                  horizontal: 12),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0.0,
                                                    left: 12,
                                                    right: 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    AppText(
                                                      text: 'Select color',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ],
                                                )),
                                            getListForProductColor(),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  productController.inventoryList.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 14.0,
                                                  horizontal: 12),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0.0,
                                                    left: 12,
                                                    right: 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    AppText(
                                                      text: 'Select fabric',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ],
                                                )),
                                            getListForProductFabric(),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 12),
                                    child: Divider(
                                      color: colorSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: AppText(
                          text: 'Delivery options',
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w500,
                          color: colorPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.only(
                              top: 12, left: 12, right: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: TextField(
                              controller: productController.pincodeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: whiteColor,
                                suffixIcon: TextButton(
                                  onPressed: () async {
                                    if (productController.checkPinvalidation(
                                        productController.pincodeController.text
                                            .toString()
                                            .trim())) {
                                      productController.getCheckPincode(
                                          productController
                                              .pincodeController.text
                                              .toString()
                                              .trim());
                                      await analytics.logEvent(
                                        name: 'check_pincode_productdetails',
                                        parameters: <String, Object>{
                                          'page_name':
                                              'check_pincode_productdetails',
                                        },
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 6, bottom: 0),
                                    child: productController.isPincode.value
                                        ? const SizedBox(
                                            height: 10,
                                            width: 10,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          )
                                        : const AppText(
                                            text: 'Check',
                                            textAlign: TextAlign.center,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                            color: blackColor,
                                            fontSize: 14,
                                          ),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: borderColor)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  borderSide:
                                      const BorderSide(color: borderColor),
                                ),
                                counterText: "",
                                contentPadding: const EdgeInsets.only(left: 10),
                                hintText: 'Enter pincode',
                                hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: textHintColor,
                                    fontFamily: "Franklin Gothic Regular"),
                              ),
                              style: const TextStyle(
                                  color: colorPrimary, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 18.0, bottom: 40.0, left: 12, right: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Image.asset(getItByIcon),
                                ),
                                AppText(
                                  text: 'Get it by Fri, 21 Jul',
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w500,
                                  color: blackColor,
                                  fontSize: 14.sp,
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Image.asset(walletBlack),
                                  ),
                                  AppText(
                                    text: 'Pay on delivery available',
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 14.sp,
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Image.asset(exchangeItemImage),
                                  ),
                                  AppText(
                                    text:
                                        'Easy 10 day return & exchange available',
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w500,
                                    color: blackColor,
                                    fontSize: 14.sp,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => productController.isDetails.value
                            ? const Padding(
                                padding: EdgeInsets.all(40.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  productController
                                              .productDetails['description'] !=
                                          null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(
                                              color: colorSecondary,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  title: AppText(
                                                    text: 'Product Description',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 16.sp,
                                                  ),
                                                  tilePadding:
                                                      const EdgeInsets.all(0),
                                                  childrenPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4.0),
                                                  children: [
                                                    AppText(
                                                      text: Bidi.stripHtmlIfNeeded(
                                                          productController
                                                                      .productDetails[
                                                                  'description'] ??
                                                              ""),
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      maxLines: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  productController.compositionDetails !=
                                              null &&
                                          productController
                                                  .compositionDetails !=
                                              ""
                                      ? Column(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  title: AppText(
                                                    text: 'Composition & Care',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 16.sp,
                                                  ),
                                                  tilePadding:
                                                      const EdgeInsets.all(0),
                                                  childrenPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4.0),
                                                  children: [
                                                    AppText(
                                                      text: Bidi.stripHtmlIfNeeded(
                                                          productController
                                                                      .compositionDetails[
                                                                  "description"] ??
                                                              ""),
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      maxLines: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  productController.returnPolicyDetails !=
                                              null &&
                                          productController
                                                  .returnPolicyDetails !=
                                              ""
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  title: AppText(
                                                    text: 'Delivery & Returns',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 16.sp,
                                                  ),
                                                  tilePadding:
                                                      const EdgeInsets.all(0),
                                                  childrenPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4.0),
                                                  children: [
                                                    AppText(
                                                      text: Bidi.stripHtmlIfNeeded(
                                                          productController
                                                                      .returnPolicyDetails[
                                                                  "description"] ??
                                                              ""),
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      maxLines: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  productController.brandDetails != null &&
                                          productController.brandDetails != ""
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  title: AppText(
                                                    text: 'About the Brand',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 16.sp,
                                                  ),
                                                  tilePadding:
                                                      const EdgeInsets.all(0),
                                                  childrenPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4.0),
                                                  children: [
                                                    AppText(
                                                      text: Bidi.stripHtmlIfNeeded(
                                                          productController
                                                                      .brandDetails[
                                                                  "description"] ??
                                                              ""),
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      maxLines: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorPrimary,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                ],
                              ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Divider(
                          color: colorSecondary,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        heightFactor: 2.0,
                        child: AppText(
                          text: 'LaFetch ID: 27384720',
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w500,
                          color: textHintColor,
                          fontSize: 12.sp,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: backWhite,
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: AppText(
                          text:
                              'You will earn 10 LaFetch coins on this purchase',
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w500,
                          color: expressText,
                          fontSize: 12.sp,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            AppText(
                              text: 'Customer Reviews',
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w500,
                              color: colorPrimary,
                              fontSize: 16.sp,
                            ),
                            Obx(
                              () => productController.isDetails.value
                                  ? const Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0, horizontal: 16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText(
                                                text:
                                                    '${productController.productDetails["aggregated_rating"] ?? ""} \u{2605}',
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: blackColor,
                                                fontSize: 24.sp,
                                              ),
                                              AppText(
                                                text:
                                                    '${productController.productDetails["reviews_count"] ?? ""} verified buyers',
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: textHintColor,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ...reviewsCount
                                                  .map((e) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 2.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            AppText(
                                                              text:
                                                                  '${e['title']} \u{2605}  ',
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: blackColor,
                                                              fontSize: 10.sp,
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.33,
                                                              child:
                                                                  LinearProgressIndicator(
                                                                value: (int.parse(
                                                                        e['count']
                                                                            .toString()) /
                                                                    int.parse(e[
                                                                            'total']
                                                                        .toString())),
                                                                backgroundColor:
                                                                    colorSecondary,
                                                                color: getColorForReview(
                                                                    e['title']),
                                                              ),
                                                            ),
                                                            AppText(
                                                              text:
                                                                  '  ${e['count']}',
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: blackColor,
                                                              fontSize: 10.sp,
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                            Obx(
                              () => productController.isReview.value
                                  ? const Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      //  height: MediaQuery.of(context).size.height * 0.7,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: productController
                                              .reviewList.length,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (ctx, index) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      color: color5StartReview,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        ' ${productController.reviewList[index]['rating'] != null ? productController.reviewList[index]['rating'].toString() : ""} \u{2605} ',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: whiteColor,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    AppText(
                                                      text:
                                                          '${productController.reviewList[index]['created'] ?? ""}',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textHintColor,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0),
                                                  child: AppText(
                                                    text:
                                                        '${productController.reviewList[index]['comment'] ?? ""}',
                                                    maxLines: 4,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: greyTextColor,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text: 'Read more  ',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: bottomnavBack,
                                                      fontSize: 12.sp,
                                                    ),
                                                    const ImageIcon(
                                                      AssetImage(dropdownImage),
                                                      color: nameText,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AppText(
                                                        text:
                                                            '${productController.reviewList[index]['user']['name'] ?? ""}',
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: bottomnavBack,
                                                        fontSize: 11.sp,
                                                      ),
                                                      AppText(
                                                        text:
                                                            '${0} found this helpful',
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: bottomnavBack,
                                                        fontSize: 11.sp,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Divider(
                                                  color: colorSecondary,
                                                )
                                              ],
                                            );
                                          }),
                                    ),
                            ),
                            Obx(() => productController.isRecommendations.value
                                ? const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /* Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: AppText(
                                          text: "Recommended for you",
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                          color: blackColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 250,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: productController
                                                  .recommendedList.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (ctx, index) {
                                                return Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: AnimatedContainer(
                                                        duration: const Duration(
                                                            milliseconds: 300),
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 5),
                                                        width: 122,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Stack(children: [
                                                              Image.asset(
                                                                  backImage,
                                                                  height: 150,
                                                                  width: 122,
                                                                  fit: BoxFit
                                                                      .cover),
                                                              Positioned(
                                                                right: 0,
                                                                child: IconButton(
                                                                  icon: CircleAvatar(
                                                                      radius:
                                                                          12.0,
                                                                      backgroundColor:
                                                                          whiteColor,
                                                                      child: Image
                                                                          .asset(
                                                                              heartImage)),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              ),
                                                            ]),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5),
                                                              child: AppText(
                                                                text: productController
                                                                                .recommendedList[
                                                                            index]
                                                                        [
                                                                        "name"] ??
                                                                    "",
                                                                color: nameText,
                                                                maxLines: 2,
                                                                fontSize: 11.sp,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      left: 10,
                                                                      right: 10),
                                                              child: Row(
                                                                children: [
                                                                  AppText(
                                                                    text:
                                                                        "\u{20B9} ${productController.recommendedList[index]["price"] ?? "0"}",
                                                                    color:
                                                                        deepGreytextColor,
                                                                    maxLines: 2,
                                                                    fontSize:
                                                                        11.sp,
                                                                    fontFamily:
                                                                        "Franklin Gothic",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left: 10),
                                                                    child: Text(
                                                                      "\u{20B9} ${productController.recommendedList[index]["mrp"] ?? "0"}",
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            textHintColor,
                                                                        fontSize:
                                                                            11.sp,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .lineThrough,
                                                                        fontFamily:
                                                                            "Franklin Gothic Regular",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      left: 10,
                                                                      right: 10),
                                                              child: Row(
                                                                children: [
                                                                  const ImageIcon(
                                                                    AssetImage(
                                                                        truckImage),
                                                                    color:
                                                                        expressText,
                                                                    size: 14,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                    child:
                                                                        AppText(
                                                                      text:
                                                                          "Express",
                                                                      color:
                                                                          expressText,
                                                                      maxLines: 2,
                                                                      fontSize:
                                                                          11.sp,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                      ),
                                      */
                                      HorizontalHomeList(
                                        text: "Recommended for you",
                                        height: 250,
                                        controller: productController
                                            .recommendedController,
                                        leftPadding: 0,
                                        list: productController.recommendedList,
                                        visibleExpress: true,
                                        visibleheart: true,
                                        onPressedHeart: (p0, p1) async {
                                          if (productController
                                                  .recommendedList[p1]
                                              ["wishlisted"]) {
                                            productController
                                                .callAddProductToWishlist(
                                                    productController
                                                            .recommendedList[p1]
                                                        ["wishlist_id"],
                                                    "recommended",
                                                    p0,
                                                    0,
                                                    0,
                                                    [],
                                                    widget.productId,
                                                    0);
                                          } else {
                                            scaffoldKey.currentState
                                                ?.showBottomSheet((context) =>
                                                    BottomWishlist(
                                                        controller:
                                                            wishlistController,
                                                        onPressed: (p0) {
                                                          productController
                                                              .callAddProductToWishlist(
                                                                  p0,
                                                                  "recommended",
                                                                  productController
                                                                          .recommendedList[
                                                                      p1]["id"],
                                                                  0,
                                                                  0,
                                                                  [],
                                                                  widget
                                                                      .productId,
                                                                  0);
                                                        },
                                                        wishlistList:
                                                            wishlistController
                                                                .wishlistList));
                                          }
                                          await analytics.logEvent(
                                            name:
                                                'recommended_product_wishlist',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'recommended_product_wishlist',
                                            },
                                          );
                                        },
                                        onPressed: (p0) async {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ProductDetailsScreen(
                                                              productId: p0,
                                                              type: "add")));
                                          await analytics.logEvent(
                                            name: 'recommended_productdetails',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'recommended_productdetails',
                                            },
                                          );
                                        },
                                      ),
                                      const Divider(
                                        color: colorSecondary,
                                      ),
                                    ],
                                  )),
                            Obx(() => productController.isFrequentlyBought.value
                                ? const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HorizontalHomeList(
                                        text: "Frequently bought with",
                                        height: 250,
                                        leftPadding: 0,
                                        controller: productController
                                            .frequentlyBoughtController,
                                        list: productController
                                            .frequentlyProductList,
                                        visibleExpress: true,
                                        visibleheart: true,
                                        onPressedHeart: (p0, p1) async {
                                          if (productController
                                                  .frequentlyProductList[p1]
                                              ["wishlisted"]) {
                                            productController
                                                .callAddProductToWishlist(
                                                    productController
                                                            .frequentlyProductList[
                                                        p1]["wishlist_id"],
                                                    "frequently",
                                                    p0,
                                                    0,
                                                    0,
                                                    [],
                                                    widget.productId,
                                                    0);
                                          } else {
                                            scaffoldKey.currentState
                                                ?.showBottomSheet((context) =>
                                                    BottomWishlist(
                                                        controller:
                                                            wishlistController,
                                                        onPressed: (p0) {
                                                          productController
                                                              .callAddProductToWishlist(
                                                                  p0,
                                                                  "frequently",
                                                                  productController
                                                                          .frequentlyProductList[
                                                                      p1]["id"],
                                                                  0,
                                                                  0,
                                                                  [],
                                                                  widget
                                                                      .productId,
                                                                  0);
                                                        },
                                                        wishlistList:
                                                            wishlistController
                                                                .wishlistList));
                                          }
                                          await analytics.logEvent(
                                            name: 'frequently_product_wishlist',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'frequently_product_wishlist',
                                            },
                                          );
                                        },
                                        onPressed: (p0) async {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ProductDetailsScreen(
                                                              productId: p0,
                                                              type: "add")));
                                          await analytics.logEvent(
                                            name: 'frequently_product_details',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'frequently_product_details',
                                            },
                                          );
                                        },
                                      ),
                                      const Divider(
                                        color: colorSecondary,
                                      ),
                                    ],
                                  )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => wishlistController.isProductWishlist.value
                          ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : wishlistController.wishListDetails["wishlisted"]
                              ? Container(
                                  margin: const EdgeInsets.only(left: 10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: btnTextColor, width: 1),
                                  ),
                                  child: IconButton(
                                      onPressed: () async {
                                        wishlistController
                                            .callAddProductToWishlist(
                                                wishlistController
                                                        .wishListDetails[
                                                    "wishlist_id"],
                                                productController
                                                    .productDetails["id"]);
                                        await analytics.logEvent(
                                          name:
                                              'productdetails_wishlist_remove',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'productdetails_wishlist_remove',
                                          },
                                        );
                                      },
                                      icon: Image.asset(wishlistSelectImage)))
                              : Container(
                                  margin: const EdgeInsets.only(left: 10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: btnTextColor, width: 1),
                                  ),
                                  child: IconButton(
                                      onPressed: () async {
                                        scaffoldKey.currentState
                                            ?.showBottomSheet((context) =>
                                                BottomWishlist(
                                                    controller:
                                                        wishlistController,
                                                    onPressed: (p0) {
                                                      wishlistController
                                                          .callAddProductToWishlist(
                                                              p0,
                                                              productController
                                                                      .productDetails[
                                                                  "id"]);
                                                    },
                                                    wishlistList:
                                                        wishlistController
                                                            .wishlistList));
                                        await analytics.logEvent(
                                          name: 'productdetails_wishlist_add',
                                          parameters: <String, Object>{
                                            'page_name':
                                                'productdetails_wishlist_add',
                                          },
                                        );
                                      },
                                      icon: Image.asset(heartIcon24))),
                    ),
                    Obx(
                      () => Expanded(
                        child: Stack(
                          children: [
                            productController.isDetails.value
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : isImage(productController.productDetails["images"]
                                        [0]["name"])
                                    ? Container(
                                        height: 40,
                                        width: 40,
                                        margin:
                                            const EdgeInsets.only(left: 150),
                                        key: widgetKey,
                                        color: colorSecondary,
                                        child: Image.network(
                                            productController
                                                    .productDetails["images"][0]
                                                ["name"],
                                            fit: BoxFit.fitHeight))
                                    : Container(
                                        height: 40,
                                        width: 40,
                                        margin:
                                            const EdgeInsets.only(left: 150),
                                        key: widgetKey,
                                        color: colorSecondary,
                                        child: Image.network(
                                            productController
                                                    .productDetails["images"][1]
                                                ["name"],
                                            fit: BoxFit.fitHeight)),
                            productController.isDetails.value
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : productController
                                        .productDetails["added_to_cart"]
                                    ? getSingleButton(
                                        label: "Go to bag",
                                        textColor: whiteBorderColor,
                                        backgroundColor: colorPrimary,
                                        controller: productController,
                                        onPressed: () async {
                                          Get.to(CartScreen());
                                          await analytics.logEvent(
                                            name: 'productDetails_btnGotocart',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'productDetails_btnGotocart',
                                            },
                                          );
                                        },
                                        borderColor: colorPrimary)
                                    : getSingleButton(
                                        label: widget.type == "add"
                                            ? "Add to bag"
                                            : "Move to bag",
                                        textColor: whiteBorderColor,
                                        backgroundColor: colorPrimary,
                                        controller: productController,
                                        onPressed: () async {
                                          if (widget.type == "add") {
                                            if (productController
                                                .checkDetailsValidation()) {
                                              productController
                                                  .callAddtoCart(1);
                                              listClick(widgetKey);
                                            }
                                          } else {
                                            if (productController
                                                .checkDetailsValidation()) {
                                              wishlistController.callMovetoCart(
                                                  widget.boardId,
                                                  widget.wishlistProductId,
                                                  productController
                                                      .sizeInventoryId.value,
                                                  1);
                                              listClick(widgetKey);
                                            }
                                          }
                                          await analytics.logEvent(
                                            name: 'productDetails_btnaddtocart',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'productDetails_btnaddtocart',
                                            },
                                          );
                                        },
                                        borderColor: colorPrimary),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
