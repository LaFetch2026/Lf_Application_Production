// ignore_for_file: avoid_print, deprecated_member_use

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lafetch/commonwidget/appbarwidgets/productdetails_appbar.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomwishlist.dart';
//import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/doublebutton_iconnew.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_productdetails.dart';
//import 'package:lafetch/commonwidget/homewidget/dummy_review.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/screens/catalog/productlist/productimage.dart';
//import 'package:lafetch/screens/mapscreen.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../../commonwidget/app_text.dart';
import '../../../commonwidget/bottomsizechart.dart';
import '../../../commonwidget/homewidget/dummy_productImage.dart';
//import '../../../commonwidget/homewidget/dummy_product_list.dart';
//import '../../../commonwidget/homewidget/dummy_saveaddress.dart';
//import '../../../commonwidget/homewidget/horizontal_home_list.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../utils/constants.dart';
//import '../../account/saved_address.dart';
import '../../brandsscreen.dart';
import '../../cartscreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;
  final String type;
  final String brandName;
  final int wishlistProductId;
  final int boardId;
  final String Slug;
  const ProductDetailsScreen(
      {super.key,
      required this.productId,
      required this.brandName,
      required this.type,
      this.boardId = 0,
      this.Slug = "",
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
  int commentId = 0;
  int reviewHelpfulId = 0;
  Map<String, dynamic> selectedProductFabric = {};
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var cartQuantityItems = 0;
  final GlobalKey widgetKey = GlobalKey();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  RegExp regExp = RegExp("");
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  /* final List<Map<String, String>> reviewsCount = [
    {'id': '1', 'title': '5', 'count': '1121', 'total': '2015'},
    {'id': '2', 'title': '4', 'count': '406', 'total': '2015'},
    {'id': '3', 'title': '3', 'count': '250', 'total': '2015'},
    {'id': '4', 'title': '2', 'count': '87', 'total': '2015'},
    {'id': '5', 'title': '1', 'count': '151', 'total': '2015'},
  ]; */

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

  /* Future getPrefrenceValue() async {
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
  } */

  /*  List<Widget> getListForPageView() {
    List<Widget> list = [];
    if (productController
            .productDetails["matrix_images"]
                [productController.productImageindex.value]
            .length >
        0) {
      for (var i = 0;
          i <
              productController
                  .productDetails["matrix_images"]
                      [productController.productImageindex.value]
                  .length;
          i++) {
        if (isImage(productController.productDetails["matrix_images"]
            [productController.productImageindex.value][i])) {
          print(
              "show video=========${isImage(productController.productDetails["matrix_images"][productController.productImageindex.value][i])}");

          list.add(Container(
            color: colorSecondary,
            child: CachedNetworkImage(
              cacheManager: CacheManager(Config("customCacheKey",
                  stalePeriod: const Duration(days: 15),
                  maxNrOfCacheObjects: 100)),
              fit: BoxFit.cover,
              imageUrl: productController.productDetails["matrix_images"]
                  [productController.productImageindex.value][i],
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
              productController.productDetails["matrix_images"]
                  [productController.productImageindex.value][i],
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
      list.add(Image.asset(dummyProductImage, fit: BoxFit.fitHeight));
    }
    return list;
  }
 */

  List<Widget> getListForPageView() {
    List<Widget> list = [];
    if (productController.imageList.isNotEmpty) {
      for (var i = 0; i < productController.imageList.length; i++) {
        if (isImage(productController.imageList[i]["name"])) {
          print(
              "show video=========${isImage(productController.imageList[i]["name"])}");

          list.add(GestureDetector(
            onTap: () {
              Get.to(ProductImageScreen(
                  curr: _curr, list: productController.imageList));
            },
            child: Container(
              color: colorSecondary,
              child: CachedNetworkImage(
                cacheManager: CacheManager(Config("customCacheKey",
                    stalePeriod: const Duration(days: 15),
                    maxNrOfCacheObjects: 100)),
                fit: BoxFit.cover,
                imageUrl: productController.imageList[i]["name"],
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    DummyContainer(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width),
                errorWidget: (context, url, error) =>
                    Image.asset(downloadImage, fit: BoxFit.fitHeight),
              ),
            ),
          ));
        } else {
          productController.isVideoPlaying.value = true;
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(
              productController.imageList[i]["name"],
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
            padding: EdgeInsets.only(top: 12.0.sp, left: 12.sp, right: 12.sp),
            child: productController.sizeInventoryList
                    .where((element) =>
                        int.parse(element['stocks'].toString()) > 0)
                    .toList()
                    .isNotEmpty
                ? Wrap(
                    direction: Axis.horizontal,
                    spacing: 12.0.sp,
                    runSpacing: 8.0.sp,
                    runAlignment: WrapAlignment.spaceEvenly,
                    children: [
                        for (var i in productController.sizeInventoryList.where(
                            (element) =>
                                int.parse(element['stocks'].toString()) > 0))
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  // if (productController.sizeInventoryId == 0) {
                                  productController.selectedProductSize = i;
                                  productController.sizeInventoryId.value =
                                      productController
                                          .selectedProductSize["id"];
                                  productController.colorInventoryId.value = 0;
                                  print(
                                      productController.sizeInventoryId.value);
                                  productController.colorInventoryList =
                                      i["product_matrix_available_colors"];

                                  print(productController
                                      .selectedProductSize["id"]);
                                  print(i['product_matrix_size_name']);

                                  setState(() {});
                                  await analytics.logEvent(
                                    name: 'productDetails_sizeSelect',
                                    parameters: <String, Object>{
                                      'page_name': 'productDetails_sizeSelect',
                                    },
                                  );
                                  //  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: btnTextColor, width: 1.sp),
                                        color: productController
                                                    .selectedProductSize
                                                    .isNotEmpty &&
                                                productController
                                                            .selectedProductSize[
                                                        'id'] ==
                                                    i['id']
                                            ? colorPrimary
                                            : whiteColor),
                                    child: SizedBox(
                                      width: 48.sp,
                                      height: 48.sp,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: AppText(
                                          text: i['product_matrix_size_name']
                                              .toString(),
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: productController
                                                      .selectedProductSize
                                                      .isNotEmpty &&
                                                  productController
                                                              .selectedProductSize[
                                                          'id'] ==
                                                      i['id']
                                              ? whiteColor
                                              : btnTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )),
                              ),
                              int.parse(i['stocks'].toString()) > 10
                                  ? const SizedBox()
                                  : Padding(
                                      padding: EdgeInsets.only(top: 8.0.sp),
                                      child: AppText(
                                        text: '${i['stocks'].toString()} left',
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: redColor,
                                        fontSize: 11,
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
                    fontSize: 11,
                  )));
  }

  /* movetoNextScreen(int id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ProductDetailsScreen(
                  productId: id,
                  type: "add",
                )));
      });
    });
  } */

  SizedBox getListForProductColor() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(top: 12.0.sp, left: 12.sp, right: 12.sp),
          child: productController.colorInventoryList
                  .where(
                      (element) => int.parse(element['stocks'].toString()) > 0)
                  .toList()
                  .isNotEmpty
              ? Wrap(
                  direction: Axis.horizontal,
                  spacing: 12.0.sp,
                  runSpacing: 8.0.sp,
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: [
                      for (var i in productController.colorInventoryList.where(
                          (element) =>
                              int.parse(element['stocks'].toString()) > 0))
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                /*  final prefs =
                                    await SharedPreferences.getInstance(); */
                                productController.selectedProductColor = i;
                                productController.colorInventoryId.value =
                                    productController
                                        .selectedProductColor["id"];
                                productController.sizeInventoryId.value =
                                    productController
                                        .selectedProductColor["id"];
                                productController.productImageindex.value =
                                    productController.sizeInventoryList
                                        .indexWhere((item) =>
                                            item["id"] ==
                                            productController
                                                .selectedProductSize["id"]);
                                _curr = 0;
                                /*   prefs.setInt("inventoryColorId",
                                    selectedProductColor["id"]); */
                                print(productController
                                    .selectedProductColor["id"]);
                                print(
                                    productController.productImageindex.value);
                                print(i['name']);
                                await analytics.logEvent(
                                  name: 'productDetails_colorSelect',
                                  parameters: <String, Object>{
                                    'page_name': 'productDetails_colorSelect',
                                  },
                                );
                                productController.update();
                                setState(() {});
                                productController.getProductImage(
                                    productController
                                        .selectedProductColor["id"]);
                                //   movetoNextScreen(i['product_id']);
                              },
                              child: SizedBox(
                                height: 48.sp,
                                width: 48.sp,
                                child: CircleAvatar(
                                  child: Container(
                                    height: 48.sp,
                                    width: 48.sp,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: searchTextColor, width: 1),
                                        shape: BoxShape.circle,
                                        color:
                                            Color(int.parse(i['color_code']))),
                                    child: Visibility(
                                      visible: productController
                                                  .selectedProductColor
                                                  .isNotEmpty &&
                                              productController
                                                          .selectedProductColor[
                                                      'id'] ==
                                                  i['id']
                                          ? true
                                          : false,
                                      child: Padding(
                                        padding: EdgeInsets.all(4.0.sp),
                                        child: Center(
                                          child: Image.asset(
                                            colorSelectimage,
                                            height: 14,
                                            width: 14,
                                            color:
                                                i['color_code'] == "0xFFFFFFFF"
                                                    ? blackColor
                                                    : whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0.sp),
                              child: AppText(
                                text: '${i['name'].toString()}'.toUpperCase(),
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                                color: blackColor,
                                fontSize: 11,
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
                  fontSize: 11,
                ),
        ));
  }

  SizedBox getListForProductFabric() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(top: 12.0.sp, left: 12.sp, right: 12.sp),
          child: productController.fabricInventoryList
                  .where(
                      (element) => int.parse(element['stocks'].toString()) > 0)
                  .toList()
                  .isNotEmpty
              ? Wrap(
                  direction: Axis.horizontal,
                  spacing: 12.0.sp,
                  runSpacing: 8.0.sp,
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
                                  padding: EdgeInsets.all(4.0.sp),
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
                                    padding: EdgeInsets.only(top: 8.0.sp),
                                    child: AppText(
                                      text: '${i['stocks'].toString()} left',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: redColor,
                                      fontSize: 11,
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
                  fontSize: 11,
                ),
        ));
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
    ));
  }

  @override
  void initState() {
    // setStatusBarColor();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.errorMsg.value = "";
      productController.brandDetails = "";
      productController.defaultAddress = "";
      productController.pincodeController.clear();
      productController.sizeInventoryId.value = 0;
      productController.productImageindex.value = 0;
      productController.colorInventoryId.value = 0;
      productController.addToCart.value = false;
      productController.showSizeList.value = true;
      productController.imageList.clear();
      productController.selectedProductSize = "";
      productController.selectedProductColor = "";
      productController.isExpressDelivery.value = false;
      productController.expressValue.value = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        productController.getProductDetails(widget.productId, widget.Slug));
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.frequentlyBoughtController.addListener(() {
        productController.fetchFrequentlyMoreData(
            "frequently-bought", widget.productId);
        productController.update();
      });
    }); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.frequentlyBoughtHasnextpage.value = true;
      productController.frequentlyBoughtLoadMore.value = false;
      productController.isFrequentlyBought.value = false;
      productController.frequentlyBoughtPage.value = 1;
      productController.inventoryId.value = 0;
    }); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.recommendedController.addListener(() {
        productController.fetchMoreRecommendedProductData(widget.productId);
        productController.update();
      });
    }); */
    /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.recommendedHasnextpage.value = true;
      productController.recommendedLoadMore.value = false;
      productController.isRecommendations.value = false;
      productController.recommendedPage.value = 1;
    }); */
    /*   WidgetsBinding.instance.addPostFrameCallback((_) => productController
        .getFrequentlyProductData("frequently-bought", widget.productId)); */
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => wishlistController.getWishlistProductDetails(widget.productId));
    /* WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductReview(widget.productId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductRecommendations(widget.productId)); */
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          productController.getDefaultAddressData(widget.productId, context));
    });
    super.initState();
  }

  /*  void listClick(GlobalKey widgetKey) async {
    await runAddToCartAnimation(widgetKey);
    await cartKey.currentState!
        .runCartAnimation((++cartQuantityItems).toString());
    //  productController.getProductDetails(widget.productId);
  } */

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
      height: 25.sp,
      width: 25.sp,
      opacity: 0.80,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: whiteColor,
        body: Column(
          children: [
            ProductdetailsAppbar(
              onPressedHeart: () async {
                if (wishlistController.wishListDetails["wishlisted"]) {
                  wishlistController.callAddProductToWishlist(
                      wishlistController.wishListDetails["wishlist_id"],
                      productController.productDetails["id"]);
                  await analytics.logEvent(
                    name: 'productdetails_wishlist_remove',
                    parameters: <String, Object>{
                      'page_name': 'productdetails_wishlist_remove',
                    },
                  );
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet((context) => BottomWishlist(
                          controller: wishlistController,
                          onPressed: (p0) {
                            wishlistController.callAddProductToWishlist(
                                p0, productController.productDetails["id"]);
                          },
                          wishlistList: wishlistController.wishlistList));
                  await analytics.logEvent(
                    name: 'productdetails_wishlist_add',
                    parameters: <String, Object>{
                      'page_name': 'productdetails_wishlist_add',
                    },
                  );
                }
              },
              onPressedShare: () async {
                Share.share(productController.productDetails["share_link"]);
                await analytics.logEvent(
                  name: 'share_product',
                  parameters: <String, Object>{
                    'page_name': 'share_product',
                  },
                );
              },
            ),
            Container(
              height: 1.sp,
              color: dividerColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => productController.isColorimage.value ||
                              productController.isDetails.value
                          ? const DummyProductImage()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Stack(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.sp,
                                              right: 16.sp,
                                              top: 10.sp),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6,
                                            child: PageView(
                                                controller: _pageController,
                                                allowImplicitScrolling: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                onPageChanged: (number) {
                                                  _curr = number;
                                                  print(_curr);
                                                  setState(() {});
                                                  if (videoController
                                                      .value.isPlaying) {
                                                    videoController.pause();
                                                    productController
                                                        .isVideoPlaying
                                                        .value = true;
                                                  }
                                                },
                                                children: getListForPageView()),
                                          )),
                                      /* Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right: 8.sp, top: 20.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 0,
                                              ),
                                              Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      Get.to(
                                                          const CartScreen());
                                                      await analytics.logEvent(
                                                        name: 'cart_page',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'cart_page',
                                                        },
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      height: 36.sp,
                                                      width: 36.sp,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              blackColor,
                                                          child: Image.asset(
                                                            cartNewImage,
                                                            color: whiteColor,
                                                            height: 22.sp,
                                                            width: 22.sp,
                                                          )),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      Share.share(
                                                          productController
                                                                  .productDetails[
                                                              "share_link"]);
                                                      await analytics.logEvent(
                                                        name: 'share_product',
                                                        parameters: <String,
                                                            Object>{
                                                          'page_name':
                                                              'share_product',
                                                        },
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.sp),
                                                      child: SizedBox(
                                                        height: 34.sp,
                                                        width: 34.sp,
                                                        child: CircleAvatar(
                                                            backgroundColor:
                                                                whiteColor,
                                                            child: Image.asset(
                                                              shareImage,
                                                              height: 20.sp,
                                                              width: 20.sp,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ), */
                                      Visibility(
                                        visible:
                                            productController.productDetails[
                                                        "aggregated_rating"] !=
                                                    0
                                                ? true
                                                : false,
                                        child: Positioned(
                                            bottom: 20.sp,
                                            right: 30.sp,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0.sp),
                                              height: 30.sp,
                                              width: 47.sp,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0x80FFFFFF),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.sp))),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 2.sp),
                                                    child: Image.asset(
                                                      ratingImage,
                                                      height: 10.sp,
                                                      width: 10.sp,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 1.sp, left: 2.sp),
                                                    child: AppText(
                                                      text: productController
                                                          .productDetails[
                                                              "aggregated_rating"]
                                                          .toString(),
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: homeAppBarColor,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  /* Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 8.sp),
                                                    child: Container(
                                                      width: 1.sp,
                                                      color: textHintColor,
                                                      height: 16.sp,
                                                    ),
                                                  ),
                                                  AppText(
                                                    text: productController
                                                        .totalReview.value
                                                        .toString(),
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: colorPrimary,
                                                    fontSize: 12,
                                                  ), */
                                                ],
                                              ),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                /*  productController
                                            .productDetails["matrix_images"][
                                                productController
                                                    .productImageindex.value]
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
                                                  .productDetails[
                                                      "matrix_images"][
                                                      productController
                                                          .productImageindex
                                                          .value]
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
                                      ), */
                                productController.imageList.length == 1
                                    ? const SizedBox(
                                        height: 0,
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.sp,
                                            right: 10.sp,
                                            bottom: 18.sp,
                                            top: 18.sp),
                                        child: Center(
                                          child: PageIndicator(
                                            controller: _pageController,
                                            count: productController
                                                .imageList.length,
                                            size: 6.0.sp,
                                            activeColor: Colors.black,
                                            color: Color(0xffE5E7EB),
                                            layout: PageIndicatorLayout.WARM,
                                            scale: 0.65,
                                            space: 8.sp,
                                          ),
                                        ),
                                      )
                                /* Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 22.0.sp,
                                            vertical: 18.0.sp),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List<Widget>.generate(
                                              productController
                                                  .imageList.length,
                                              (index) => Container(
                                                    height: 6.sp,
                                                    width: 40.sp,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.sp),
                                                    decoration: BoxDecoration(
                                                        color: (index == _curr)
                                                            ? colorPrimary
                                                            : colorSecondary),
                                                  )),
                                        ),
                                      ) */
                                ,
                                SizedBox(
                                  height: 12.sp,
                                ),
                              ],
                            ),
                    ),
                    Obx(
                      () => productController.isDetails.value
                          ? const DummyProductDetails()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*  Padding(
                                  padding: EdgeInsets.only(
                                      left: 12.0.sp, top: 12.sp),
                                  child: AppText(
                                    text: "New Season",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: greyTextColor,
                                    fontSize: 12,
                                  ),
                                ), */
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 12.sp, right: 12.sp),
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
                                                "${productController.productDetails["brand_name"]} \n"
                                                    .toUpperCase(),
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                            color: blackColor,
                                            maxLines: 1,
                                            fontSize: 16,
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

                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              BrandsScreen(
                                                                screen:
                                                                    "search",
                                                                logo: productController
                                                                        .brandDetails[
                                                                    "logo"],
                                                                backImage: productController
                                                                            .brandDetails[
                                                                        "background_image"] ??
                                                                    "",
                                                                name: productController
                                                                        .brandDetails[
                                                                    "name"],
                                                                brandId:
                                                                    productController
                                                                            .brandDetails[
                                                                        "id"],
                                                              )));
                                                },
                                                child: Container(
                                                  color: Color(0xFFDFDBFF),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0.sp,
                                                        bottom: 8.0.sp,
                                                        left: 10.sp,
                                                        right: 8.sp),
                                                    child: Row(
                                                      children: [
                                                        AppText(
                                                          text: 'View Brand \n'
                                                              .toUpperCase(),
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              homeAppBarColor,
                                                          maxLines: 1,
                                                          fontSize: 10,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      4.sp),
                                                          child: ImageIcon(
                                                            AssetImage(
                                                                linkArrowImage),
                                                            size: 16.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 0,
                                              )
                                      ],
                                    )),
                                Visibility(
                                  visible: productController
                                              .productDetails["name"] !=
                                          null
                                      ? true
                                      : false,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.sp, vertical: 14.sp),
                                    child: AppText(
                                      text: productController
                                              .productDetails["name"] ??
                                          "",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: subtitleColor,
                                      maxLines: 2,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0.sp, left: 12.sp, right: 12.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Visibility(
                                        visible: productController
                                                    .productDetails["mrp"] !=
                                                null
                                            ? true
                                            : false,
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(right: 10.sp),
                                          child: Text(
                                            "\u{20B9} ${productController.productDetails["mrp"]}",
                                            style: TextStyle(
                                              color: searchTextColor,
                                              fontSize: 16.sp,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 10.0.sp),
                                        child: AppText(
                                          text:
                                              "\u{20B9} ${productController.productDetails["price"] ?? "0"}",
                                          color: nameText,
                                          fontSize: 16,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Visibility(
                                        visible: productController
                                                        .productDetails[
                                                    "discount_percentage"] !=
                                                "0.00%"
                                            ? true
                                            : false,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xffA7F3D0),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 6.sp,
                                                bottom: 6.sp,
                                                left: 8.sp,
                                                right: 8.sp),
                                            child: AppText(
                                              text:
                                                  "${productController.productDetails["discount_percentage"] != null ? productController.productDetails["discount_percentage"].toString() : "0"} OFF",
                                              color: expressText,
                                              fontSize: 12,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 8.sp,
                                      bottom: 6.sp,
                                      left: 16.sp,
                                      right: 16.sp),
                                  child: AppText(
                                    text: "Price inclusive of all taxes",
                                    color: subtitleColor,
                                    fontSize: 12,
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                productController.sizeInventoryList.isNotEmpty
                                    ? Visibility(
                                        visible: productController
                                                .sizeInventoryList
                                                .where((element) =>
                                                    int.parse(element['stocks']
                                                        .toString()) >
                                                    0)
                                                .toList()
                                                .isNotEmpty
                                            ? true
                                            : false,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 30.0.sp,
                                                    bottom: 0.0.sp,
                                                    left: 12.sp,
                                                    right: 12.sp),
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
                                                      text: 'Select size'
                                                          .toUpperCase(),
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: blackColor,
                                                      fontSize: 16,
                                                    ),
                                                    productController
                                                                    .productDetails[
                                                                "productSizeChart"] !=
                                                            null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              scaffoldKey
                                                                  .currentState
                                                                  ?.showBottomSheet(
                                                                      (context) =>
                                                                          BottomSizeChart(
                                                                            productSizeChart:
                                                                                productController.productDetails["productSizeChart"]["image"],
                                                                            productName:
                                                                                productController.productDetails["name"],
                                                                          ));
                                                            },
                                                            child: Text(
                                                              "View Size chart"
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    appBarColor,
                                                                fontSize: 10.sp,
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            height: 0,
                                                          )
                                                  ],
                                                )),
                                            productController.showSizeList.value
                                                ? getListForProductSize()
                                                : Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 12.0.sp,
                                                        left: 12.sp,
                                                        right: 12.sp),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    btnTextColor,
                                                                width: 1.sp),
                                                            color:
                                                                colorPrimary),
                                                        child: SizedBox(
                                                          width: 48.sp,
                                                          height: 48.sp,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: AppText(
                                                              text: "FS",
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: whiteColor,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 0,
                                      ),
                                productController.colorInventoryList.isNotEmpty
                                    ? Visibility(
                                        visible: productController
                                                .colorInventoryList
                                                .where((element) =>
                                                    int.parse(element['stocks']
                                                        .toString()) >
                                                    0)
                                                .toList()
                                                .isNotEmpty
                                            ? true
                                            : false,
                                        child: Column(
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
                                                padding: EdgeInsets.only(
                                                    bottom: 0.0.sp,
                                                    left: 12.sp,
                                                    right: 12.sp),
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
                                                      text: 'Select color'
                                                          .toUpperCase(),
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: blackColor,
                                                      fontSize: 16,
                                                    ),
                                                  ],
                                                )),
                                            getListForProductColor(),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 0,
                                      ),
                                productController.inventoryList.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 14.0.sp,
                                                horizontal: 12.sp),
                                            child: Divider(
                                              color: colorSecondary,
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 0.0.sp,
                                                  left: 12.sp,
                                                  right: 12.sp),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  AppText(
                                                    text: 'Select fabric',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 16,
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
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      child: AppText(
                        text: 'Delivery options'.toUpperCase(),
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: appBarColor,
                        fontSize: 12,
                      ),
                    ),
                    Obx(
                      () => MediaQuery.of(context).size.width < 600
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: 12.sp, left: 12.sp, right: 12.sp),
                              child: SizedBox(
                                width: double.infinity,
                                height: 44.sp,
                                child: RawKeyboardListener(
                                  focusNode: FocusNode(),
                                  onKey: (value) {
                                    print(value);
                                    if (value is RawKeyDownEvent) {
                                      /*    productController.getItBy =
                                          productController.productDetails[
                                              "estimated_delivery_by"]; */
                                    }
                                  },
                                  child: TextField(
                                    controller:
                                        productController.pincodeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteColor,
                                      suffixIcon: TextButton(
                                        onPressed: () async {
                                          if (productController
                                              .checkPinvalidation(
                                                  productController
                                                      .pincodeController.text
                                                      .toString()
                                                      .trim())) {
                                            /* productController.getCheckPincode(
                                          productController
                                              .pincodeController.text
                                              .toString()
                                              .trim()); */
                                            productController.getEstimateDate(
                                                widget.productId,
                                                productController
                                                    .pincodeController.text
                                                    .toString()
                                                    .trim());
                                            FocusScope.of(context).unfocus();
                                            await analytics.logEvent(
                                              name:
                                                  'check_pincode_productdetails',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'check_pincode_productdetails',
                                              },
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 0.sp),
                                          child: productController
                                                  .isEstimateDate.value
                                              ? SizedBox(
                                                  height: 10.sp,
                                                  width: 10.sp,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                )
                                              : Container(
                                                  color: homeAppBarColor,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.sp,
                                                            vertical: 6.sp),
                                                    child: AppText(
                                                      text:
                                                          "Check".toUpperCase(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: whiteColor,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: borderColor)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.sp),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.sp),
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                      ),
                                      counterText: "",
                                      contentPadding:
                                          const EdgeInsets.only(left: 10),
                                      hintText: 'Enter pincode',
                                      hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: textHintColor,
                                          fontFamily: "Franklin Gothic"),
                                    ),
                                    style: TextStyle(
                                        color: blackColor,
                                        fontSize: 16.sp,
                                        fontFamily: "Franklin Gothic"),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: 12.sp, left: 12.sp, right: 12.sp),
                              child: SizedBox(
                                width: double.infinity,
                                height: 44.sp,
                                child: RawKeyboardListener(
                                  focusNode: FocusNode(),
                                  onKey: (value) {
                                    print(value);
                                    if (value is RawKeyDownEvent) {
                                      /*   productController.getItBy.value =
                                          productController.productDetails[
                                              "estimated_delivery_by"]; */
                                    }
                                  },
                                  child: TextField(
                                    controller:
                                        productController.pincodeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteColor,
                                      suffixIcon: TextButton(
                                        onPressed: () async {
                                          if (productController
                                              .checkPinvalidation(
                                                  productController
                                                      .pincodeController.text
                                                      .toString()
                                                      .trim())) {
                                            /* productController.getCheckPincode(
                                          productController
                                              .pincodeController.text
                                              .toString()
                                              .trim()); */
                                            productController.getEstimateDate(
                                                widget.productId,
                                                productController
                                                    .pincodeController.text
                                                    .toString()
                                                    .trim());
                                            FocusScope.of(context).unfocus();
                                            await analytics.logEvent(
                                              name:
                                                  'check_pincode_productdetails',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'check_pincode_productdetails',
                                              },
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 0.sp),
                                          child: productController
                                                  .isEstimateDate.value
                                              ? SizedBox(
                                                  height: 10.sp,
                                                  width: 10.sp,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                )
                                              : Container(
                                                  color: homeAppBarColor,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.sp,
                                                            vertical: 6.sp),
                                                    child: AppText(
                                                      text:
                                                          "Check".toUpperCase(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: whiteColor,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: borderColor)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.sp),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.sp),
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                      ),
                                      counterText: "",
                                      hintText: 'Enter pincode',
                                      hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: textHintColor,
                                          fontFamily: "Franklin Gothic"),
                                    ),
                                    style: TextStyle(
                                        color: blackColor,
                                        fontSize: 16.sp,
                                        fontFamily: "Franklin Gothic"),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    /*   Obx(() => productController.isAddress.value
                        ? const DummySaveAddress(
                            size: 1,
                          )
                        : productController.defaultAddress != ""
                            ? Padding(
                                padding: EdgeInsets.only(
                                  top: 10.sp,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                      color: colorSecondary,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 14.sp,
                                                vertical: 5.sp),
                                            child: AppText(
                                              text: productController
                                                          .defaultAddress[
                                                      "address"] ??
                                                  "",
                                              color: loginText,
                                              fontSize: 14,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.sp,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          const SavedAddressScreen(
                                                            type:
                                                                "product details",
                                                          )))
                                                  .then((value) => setState(
                                                        () {
                                                          productController
                                                              .getDefaultAddressData(
                                                                  widget
                                                                      .productId,
                                                                  context);
                                                          productController
                                                              .getProductDetails(
                                                                  widget
                                                                      .productId,
                                                                  widget.Slug);
                                                        },
                                                      ));

                                              await analytics.logEvent(
                                                name: 'addresslist_page',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'addresslist_page',
                                                },
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              margin:
                                                  EdgeInsets.only(right: 5.sp),
                                              width: 80.sp,
                                              height: 20.sp,
                                              decoration: BoxDecoration(
                                                color: whiteBorderColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.sp),
                                                border: Border.all(
                                                    color: btnTextColor,
                                                    width: 1.sp),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.sp),
                                                child: Center(
                                                  child: AppText(
                                                    text: "Change",
                                                    color: btnTextColor,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.sp, vertical: 2.sp),
                                      child: AppText(
                                        text:
                                            "${productController.defaultAddress["locality"] ?? ""} ,${productController.defaultAddress["city"] != null ? productController.defaultAddress["city"]["name"] : ""}",
                                        color: greyTextColor,
                                        fontSize: 12,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.sp, vertical: 2.sp),
                                      child: AppText(
                                        text: productController
                                            .defaultAddress["zip"]
                                            .toString(),
                                        color: loginText,
                                        fontSize: 12,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const Divider(
                                      color: colorSecondary,
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.sp, vertical: 14.sp),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const MapScreen(
                                                          addressId: 0,
                                                          cartId: 0,
                                                        )))
                                            .then((value) => setState(
                                                  () {
                                                    productController
                                                        .getDefaultAddressData(
                                                            widget.productId,
                                                            context);
                                                  },
                                                ));

                                        await analytics.logEvent(
                                          name: 'mapscreen_page',
                                          parameters: <String, Object>{
                                            'page_name': 'mapscreen_page',
                                          },
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: EdgeInsets.only(right: 5.sp),
                                        width: 100.sp,
                                        height: 24.sp,
                                        decoration: BoxDecoration(
                                          color: whiteBorderColor,
                                          borderRadius:
                                              BorderRadius.circular(20.sp),
                                          border: Border.all(
                                              color: btnTextColor, width: 1.sp),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.sp),
                                          child: Center(
                                            child: AppText(
                                              text: "Add Address",
                                              color: btnTextColor,
                                              fontSize: 12,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    */
                    Obx(
                      () => productController.isEstimateDate.value
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 25.0.sp, left: 12.sp, right: 12.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 12.0.sp),
                                        child: DummyContainer(
                                          height: 18.sp,
                                          width: 18.sp,
                                        ),
                                      ),
                                      DummyContainer(
                                        height: 18.sp,
                                        width: 150.sp,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 18.0.sp, left: 12.sp, right: 12.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 12.0.sp),
                                        child: DummyContainer(
                                          height: 18.sp,
                                          width: 18.sp,
                                        ),
                                      ),
                                      DummyContainer(
                                        height: 18.sp,
                                        width: 150.sp,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 18.0.sp, left: 12.sp, right: 12.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 12.0.sp),
                                        child: DummyContainer(
                                          height: 18.sp,
                                          width: 18.sp,
                                        ),
                                      ),
                                      DummyContainer(
                                        height: 18.sp,
                                        width: 150.sp,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: 25.0.sp, left: 12.sp, right: 12.sp),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  productController.getItBy != "" &&
                                          productController.getItBy != null
                                      ? productController.getItBy[
                                                  "show_shipping_cost"] &&
                                              !productController
                                                  .isExpressDelivery.value
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 12.0.sp),
                                                  child: Image.asset(
                                                    walletBlack,
                                                    height: 22.sp,
                                                    width: 22.sp,
                                                  ),
                                                ),
                                                AppText(
                                                  text: "Shipping Cost :",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w500,
                                                  color: titleColor,
                                                  maxLines: 1,
                                                  fontSize: 14,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                  child: AppText(
                                                    text:
                                                        "\u{20B9} ${productController.getItBy["shipping_cost"].toString()}",
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: titleColor,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    fontSize: 14,
                                                  ),
                                                )
                                              ],
                                            )
                                          : SizedBox(
                                              height: 0,
                                            )
                                      : SizedBox(
                                          height: 0,
                                        )
                                ],
                              ),
                            ),
                    ),
                    Obx(() => productController.isEstimateDate.value
                        ? SizedBox(
                            height: 0,
                          )
                        : productController.getItBy != "" &&
                                productController.getItBy != null
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: 18.0.sp, left: 12.sp, right: 12.sp),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.only(right: 12.0.sp),
                                          child: Image.asset(
                                            getItByIcon,
                                            height: 22.sp,
                                            width: 22.sp,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: AppText(
                                            text: productController
                                                    .getItBy["message"] ??
                                                "Enter your pincode to get estimate delivery date",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w500,
                                            color: titleColor,
                                            maxLines: 2,
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              )),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 18.0.sp, left: 12.sp, right: 12.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 12.0.sp),
                            child: Image.asset(
                              walletBlack,
                              height: 22.sp,
                              width: 22.sp,
                            ),
                          ),
                          AppText(
                            text: "Pay on delivery available",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: titleColor,
                            maxLines: 1,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => productController.isDetails.value
                          ? SizedBox(
                              height: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  top: 18.0.sp, left: 12.sp, right: 12.sp),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*  productController.productDetails["has_cod"]
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 18.0.sp),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 12.0.sp),
                                                child: Image.asset(
                                                  walletBlack,
                                                  height: 18.sp,
                                                  width: 18.sp,
                                                ),
                                              ),
                                              AppText(
                                                text:
                                                    'Pay on delivery available',
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: blackColor,
                                                fontSize: 14,
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  */
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 12.0.sp),
                                        child: Image.asset(
                                          exchangeItemImage,
                                          height: 20.sp,
                                          color: titleColor,
                                          width: 20.sp,
                                        ),
                                      ),
                                      Expanded(
                                        child: AppText(
                                          text: productController
                                                      .productDetails[
                                                  "has_exchange"]
                                              ? 'Easy ${productController.productDetails["exchange_days"]} day return & exchange available'
                                              : 'Exchange not available',
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w500,
                                          maxLines: 1,
                                          color: titleColor,
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                    ),
                    Obx(() => productController.isDetails.value
                        ? SizedBox(
                            height: 0,
                          )
                        : productController.productDetails["express_delivery"]
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: 18.0.sp, left: 12.sp, right: 12.sp),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.only(right: 12.0.sp),
                                          child: Image.asset(
                                            getItByIcon,
                                            height: 22.sp,
                                            width: 22.sp,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: AppText(
                                            text: productController
                                                        .productDetails[
                                                    "express_delivery_estimation"] ??
                                                "",
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w500,
                                            color: titleColor,
                                            maxLines: 2,
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              )),
                    Obx(
                      () => productController.isDetails.value
                          ? SizedBox(
                              height: 0,
                            )
                          : productController.productDetails["express_delivery"]
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: 18.0.sp,
                                    left: 12.sp,
                                    right: 12.sp,
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(right: 12.0.sp),
                                        child: Image.asset(
                                          truckImage,
                                          height: 18.sp,
                                          width: 18.sp,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (productController
                                              .isExpressDelivery.value) {
                                            productController.isExpressDelivery
                                                .value = false;
                                            productController
                                                .expressValue.value = 0;
                                          } else {
                                            productController
                                                .isExpressDelivery.value = true;
                                            productController
                                                .expressValue.value = 1;
                                          }
                                        },
                                        child: AppText(
                                          text: 'Express Delivery',
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w500,
                                          color: titleColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        child: const SizedBox(
                                          width: 0,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0.sp),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3.sp),
                                              border: Border(
                                                top: BorderSide(
                                                    width: 2.0.sp,
                                                    color: greyBorder),
                                                left: BorderSide(
                                                    width: 2.0.sp,
                                                    color: greyBorder),
                                                right: BorderSide(
                                                    width: 2.0.sp,
                                                    color: greyBorder),
                                                bottom: BorderSide(
                                                    width: 2.0.sp,
                                                    color: greyBorder),
                                              ),
                                            ),
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                              value: productController
                                                  .isExpressDelivery.value,
                                              checkColor: btnTextColor,
                                              activeColor: whiteBorderColor,
                                              side: const BorderSide(
                                                  color: btnTextColor,
                                                  width: 0),
                                              onChanged: (value) {
                                                setState(() {
                                                  productController
                                                      .isExpressDelivery
                                                      .value = value!;
                                                  if (productController
                                                      .isExpressDelivery
                                                      .value) {
                                                    productController
                                                        .expressValue.value = 1;
                                                  } else {
                                                    productController
                                                        .expressValue.value = 0;
                                                  }
                                                });
                                              },
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                    ),
                    Obx(
                      () => productController.isDetails.value
                          ? SizedBox(
                              height: 0,
                            )
                          : productController.productDetails["express_delivery"]
                              ? !productController.isExpressDelivery.value
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 18.0.sp,
                                          left: 12.sp,
                                          right: 12.sp),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 12.0.sp),
                                                child: Image.asset(
                                                  walletBlack,
                                                  height: 22.sp,
                                                  width: 22.sp,
                                                ),
                                              ),
                                              AppText(
                                                text: "Express Delivery Cost :",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: blackColor,
                                                maxLines: 1,
                                                fontSize: 14,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                child: AppText(
                                                  text:
                                                      "\u{20B9} ${productController.productDetails["express_delivery_fee"]}",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w500,
                                                  color: titleColor,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                              : SizedBox(
                                  height: 0,
                                ),
                    ),
                    Obx(
                      () => productController.isDetails.value
                          ? /* Padding(
                              padding: EdgeInsets.all(40.0.sp),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            ) */
                          SizedBox(
                              height: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 20.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  productController
                                              .productDetails['description'] !=
                                          null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
                                              child: const Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  title: AppText(
                                                    text: 'More Details',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w500,
                                                    color: colorPrimary,
                                                    fontSize: 16,
                                                  ),
                                                  tilePadding:
                                                      EdgeInsets.all(0.sp),
                                                  childrenPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 4.0.sp),
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: AppText(
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
                                                        fontSize: 12,
                                                      ),
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
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
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
                                                    fontSize: 16,
                                                  ),
                                                  tilePadding:
                                                      EdgeInsets.all(0.sp),
                                                  childrenPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 4.0.sp),
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: AppText(
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
                                                        fontSize: 12,
                                                      ),
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
                                  productController
                                          .returnPolicyDetails.value.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
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
                                                    fontSize: 16,
                                                  ),
                                                  tilePadding:
                                                      EdgeInsets.all(0.sp),
                                                  childrenPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 4.0.sp),
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: AppText(
                                                        text: Bidi.stripHtmlIfNeeded(
                                                            productController
                                                                .returnPolicyDetails
                                                                .value),
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        maxLines: 20,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: colorPrimary,
                                                        fontSize: 12,
                                                      ),
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
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
                                              child: Divider(
                                                color: colorSecondary,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp),
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
                                                    fontSize: 16,
                                                  ),
                                                  tilePadding:
                                                      EdgeInsets.all(0.sp),
                                                  childrenPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 4.0.sp),
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: AppText(
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
                                                        fontSize: 12,
                                                      ),
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
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: Divider(
                        color: colorSecondary,
                      ),
                    ),
                    Obx(
                      () => productController.errorMsg.value != ""
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp,
                                  right: 16.sp,
                                  top: 16.sp,
                                  bottom: 16.sp),
                              child: AppText(
                                text: productController.errorMsg.value,
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: deepRed,
                                maxLines: 5,
                                fontSize: 12,
                              ),
                            )
                          : SizedBox(
                              height: 0,
                            ),
                    ),
                    SizedBox(
                      height: 20.sp,
                    )
                    /*  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 30.0.sp, horizontal: 12.0.sp),
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
                            fontSize: 16,
                          ),
                          Obx(
                            () => productController.isDetails.value
                                ? SizedBox(
                                    height: 0,
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.0.sp, horizontal: 16.0.sp),
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
                                              fontSize: 24,
                                            ),
                                            AppText(
                                              text:
                                                  '${productController.productDetails["reviews_count"] ?? ""} verified buyers',
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w500,
                                              color: textHintColor,
                                              fontSize: 12,
                                            ),
                                          ],
                                        ),
                                        /*    Column(
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
                                      */
                                      ],
                                    ),
                                  ),
                          ),
                          Obx(
                            () => productController.isReview.value
                                ? DummyReview()
                                : SizedBox(
                                    width: double.infinity,
                                    //  height: MediaQuery.of(context).size.height * 0.7,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount:
                                            productController.reviewList.length,
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
                                                        EdgeInsets.all(4.0.sp),
                                                    child: Text(
                                                      ' ${productController.reviewList[index]['rating'] != null ? productController.reviewList[index]['rating'].toString() : ""} \u{2605} ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: whiteColor,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  AppText(
                                                    text:
                                                        '${productController.reviewList[index]['created'] ?? ""}',
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: textHintColor,
                                                    fontSize: 12,
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0.sp),
                                                child: AppText(
                                                  text:
                                                      '${productController.reviewList[index]['comment'] ?? ""}',
                                                  maxLines: commentId ==
                                                          productController
                                                                  .reviewList[
                                                              index]['id']
                                                      ? 4
                                                      : 1,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: greyTextColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  regExp
                                                              .allMatches(
                                                                  productController
                                                                              .reviewList[
                                                                          index]
                                                                      [
                                                                      'comment'])
                                                              .length >
                                                          30
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 20.sp),
                                                          child: Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (commentId ==
                                                                      productController
                                                                              .reviewList[index]
                                                                          [
                                                                          'id']) {
                                                                    commentId =
                                                                        0;
                                                                  } else {
                                                                    commentId =
                                                                        productController.reviewList[index]
                                                                            [
                                                                            'id'];
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: AppText(
                                                                  text: commentId ==
                                                                          productController.reviewList[index]
                                                                              [
                                                                              'id']
                                                                      ? "Show less"
                                                                      : 'Read more  ',
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      bottomnavBack,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (commentId ==
                                                                      productController
                                                                              .reviewList[index]
                                                                          [
                                                                          'id']) {
                                                                    commentId =
                                                                        0;
                                                                  } else {
                                                                    commentId =
                                                                        productController.reviewList[index]
                                                                            [
                                                                            'id'];
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    ImageIcon(
                                                                  AssetImage(
                                                                      dropdownImage),
                                                                  color:
                                                                      nameText,
                                                                  size: 16.sp,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 0,
                                                        ),
                                                  productController.reviewList[
                                                                  index]
                                                              ["upvotes"] ==
                                                          1
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            reviewHelpfulId = 0;
                                                            setState(() {});
                                                            productController.callReviewVote(
                                                                productController
                                                                        .reviewList[
                                                                    index]['id'],
                                                                0,
                                                                widget.productId);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              right: 20.sp,
                                                            ),
                                                            child:
                                                                AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          5.sp),
                                                              width: 80.sp,
                                                              height: 25.sp,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    whiteColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                border: Border.all(
                                                                    color:
                                                                        btnTextColor,
                                                                    width: 1),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.sp),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              2.sp),
                                                                      child:
                                                                          ImageIcon(
                                                                        AssetImage(
                                                                            likeImage),
                                                                        color:
                                                                            nameText,
                                                                        size: 16
                                                                            .sp,
                                                                      ),
                                                                    ),
                                                                    AppText(
                                                                      text:
                                                                          "helpful",
                                                                      color:
                                                                          btnTextColor,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          "Franklin Gothic",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            right: 20.sp,
                                                          ),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              reviewHelpfulId =
                                                                  productController
                                                                          .reviewList[
                                                                      index]['id'];
                                                              setState(() {});
                                                              productController.callReviewVote(
                                                                  productController
                                                                              .reviewList[
                                                                          index]
                                                                      ['id'],
                                                                  1,
                                                                  widget
                                                                      .productId);
                                                            },
                                                            child:
                                                                AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          5.sp),
                                                              width: 80.sp,
                                                              height: 25.sp,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    whiteColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.sp),
                                                                border: Border.all(
                                                                    color: reviewHelpfulId ==
                                                                            productController.reviewList[index][
                                                                                'id']
                                                                        ? btnTextColor
                                                                        : greyTextColor,
                                                                    width:
                                                                        1.sp),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.sp),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              2.sp),
                                                                      child:
                                                                          ImageIcon(
                                                                        AssetImage(reviewHelpfulId ==
                                                                                productController.reviewList[index]['id']
                                                                            ? likeImage
                                                                            : dislikeImage),
                                                                        color: reviewHelpfulId ==
                                                                                productController.reviewList[index]['id']
                                                                            ? btnTextColor
                                                                            : greyTextColor,
                                                                        size: 16
                                                                            .sp,
                                                                      ),
                                                                    ),
                                                                    AppText(
                                                                      text:
                                                                          "helpful",
                                                                      color: reviewHelpfulId ==
                                                                              productController.reviewList[index]['id']
                                                                          ? btnTextColor
                                                                          : greyTextColor,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          "Franklin Gothic",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0.sp),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText(
                                                      text:
                                                          '${productController.reviewList[index]['user']['name'] ?? ""}',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: bottomnavBack,
                                                      fontSize: 11,
                                                    ),
                                                    AppText(
                                                      text:
                                                          '${productController.reviewList[index]["upvotes"].toString()} found this helpful',
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: bottomnavBack,
                                                      fontSize: 11,
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
                              ? const DummyProductList(
                                  text: "Recommended for you")
                              : productController.recommendedList.isNotEmpty
                                  ? Column(
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
                                          height: 250.sp,
                                          controller: productController
                                              .recommendedController,
                                          leftPadding: 0,
                                          list:
                                              productController.recommendedList,
                                          visibleExpress: true,
                                          visibleheart: true,
                                          onPressedHeart: (p0, p1) async {
                                            if (productController
                                                    .recommendedList[p1]
                                                ["wishlisted"]) {
                                              /*  productController
                                                      .recommendedList[p1]
                                                  ["wishlisted"] = false;
                                              setState(() {}); */
                                              productController
                                                  .callAddProductToWishlist(
                                                      productController
                                                              .recommendedList[
                                                          p1]["wishlist_id"],
                                                      "recommended",
                                                      p0,
                                                      0,
                                                      0,
                                                      [],
                                                      [],
                                                      widget.productId,
                                                      0,
                                                      0);
                                            } else {
                                              scaffoldKey.currentState
                                                  ?.showBottomSheet((context) =>
                                                      BottomWishlist(
                                                          controller:
                                                              wishlistController,
                                                          onPressed: (p0) {
                                                            /*  productController
                                                                    .recommendedList[p1]
                                                                [
                                                                "wishlisted"] = true;
                                                            setState(() {}); */
                                                            productController.callAddProductToWishlist(
                                                                p0,
                                                                "recommended",
                                                                productController
                                                                        .recommendedList[
                                                                    p1]["id"],
                                                                0,
                                                                0,
                                                                [],
                                                                [],
                                                                widget
                                                                    .productId,
                                                                0,
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
                                          onPressed: (p0, p1) async {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ProductDetailsScreen(
                                                                brandName: p1,
                                                                productId: p0,
                                                                type: "add")));
                                            await analytics.logEvent(
                                              name:
                                                  'recommended_productdetails',
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
                                    )
                                  : SizedBox(
                                      height: 0,
                                    )),
                          Obx(() => productController.isFrequentlyBought.value
                              ? const DummyProductList(
                                  text: "Frequently bought with")
                              : productController
                                      .frequentlyProductList.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        HorizontalHomeList(
                                          text: "Frequently bought with",
                                          height: 250.sp,
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
                                              /*  productController
                                                      .frequentlyProductList[p1]
                                                  ["wishlisted"] = false;
                                              setState(() {}); */
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
                                                      [],
                                                      widget.productId,
                                                      0,
                                                      0);
                                            } else {
                                              scaffoldKey.currentState
                                                  ?.showBottomSheet((context) =>
                                                      BottomWishlist(
                                                          controller:
                                                              wishlistController,
                                                          onPressed: (p0) {
                                                            /*   productController
                                                                    .frequentlyProductList[p1]
                                                                [
                                                                "wishlisted"] = true;
                                                            setState(() {}); */
                                                            productController.callAddProductToWishlist(
                                                                p0,
                                                                "frequently",
                                                                productController
                                                                        .frequentlyProductList[
                                                                    p1]["id"],
                                                                0,
                                                                0,
                                                                [],
                                                                [],
                                                                widget
                                                                    .productId,
                                                                0,
                                                                0);
                                                          },
                                                          wishlistList:
                                                              wishlistController
                                                                  .wishlistList));
                                            }
                                            await analytics.logEvent(
                                              name:
                                                  'frequently_product_wishlist',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'frequently_product_wishlist',
                                              },
                                            );
                                          },
                                          onPressed: (p0, p1) async {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ProductDetailsScreen(
                                                                brandName: p1,
                                                                productId: p0,
                                                                type: "add")));
                                            await analytics.logEvent(
                                              name:
                                                  'frequently_product_details',
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
                                    )
                                  : SizedBox(
                                      height: 0,
                                    )),
                          
                        ],
                      ),
                    ) */
                  ],
                ),
              ),
            ),
            /*    SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 80.sp,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*   Obx(
                    () => wishlistController.isProductWishlist.value
                        ? Padding(
                            padding: EdgeInsets.all(10.0.sp),
                            child:
                                // Center(child: CircularProgressIndicator()),
                                DummyContainer(
                              height: 46.sp,
                              width: 44.sp,
                            ))
                        : wishlistController.wishListDetails["wishlisted"]
                            ? Container(
                                height: 46.sp,
                                width: 44.sp,
                                margin: EdgeInsets.only(left: 10.0.sp),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: btnTextColor, width: 1.sp),
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
                                        name: 'productdetails_wishlist_remove',
                                        parameters: <String, Object>{
                                          'page_name':
                                              'productdetails_wishlist_remove',
                                        },
                                      );
                                    },
                                    icon: Image.asset(wishlistSelectImage)))
                            : Container(
                                height: 46.sp,
                                width: 44.sp,
                                margin: EdgeInsets.only(left: 10.0.sp),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: btnTextColor, width: 1.sp),
                                ),
                                child: IconButton(
                                    onPressed: () async {
                                      scaffoldKey.currentState?.showBottomSheet(
                                          (context) => BottomWishlist(
                                              controller: wishlistController,
                                              onPressed: (p0) {
                                                wishlistController
                                                    .callAddProductToWishlist(
                                                        p0,
                                                        productController
                                                                .productDetails[
                                                            "id"]);
                                              },
                                              wishlistList: wishlistController
                                                  .wishlistList));
                                      await analytics.logEvent(
                                        name: 'productdetails_wishlist_add',
                                        parameters: <String, Object>{
                                          'page_name':
                                              'productdetails_wishlist_add',
                                        },
                                      );
                                    },
                                    icon: Image.asset(
                                      heartIcon24,
                                      height: 30.sp,
                                      width: 30.sp,
                                    ))),
                  ),
                 */
                  Obx(
                    () => productController.isDetails.value
                        ? const SizedBox(
                            height: 0,
                          )
                        : Expanded(
                            flex: 1,
                            child: productController
                                        .productDetails["total_stock_count"] ==
                                    0
                                ? getSingleButton(
                                    label: "Out of Stock",
                                    textColor: whiteBorderColor,
                                    right: 12,
                                    left: 12,
                                    backgroundColor: colorPrimary,
                                    controller: productController,
                                    borderColor: colorPrimary)
                                : getSingleButton(
                                    label: widget.type == "add"
                                        ? "Add to bag"
                                        : "Move to bag",
                                    textColor: whiteBorderColor,
                                    fontSize: 13,
                                    right: productController
                                            .productDetails["added_to_cart"]
                                        ? 8
                                        : 16,
                                    left: 8,
                                    backgroundColor: colorPrimary,
                                    controller: productController,
                                    onPressed: () async {
                                      if (widget.type == "add") {
                                        if (productController
                                            .checkDetailsValidation()) {
                                          productController.callAddtoCart(
                                              1, "");
                                          //  listClick(widgetKey);
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
                                          productController.addToCart.value =
                                              true;
                                          //  listClick(widgetKey);
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
                          ),
                  ),
                  Obx(
                    () => productController.isDetails.value
                        ? const SizedBox(
                            height: 0,
                          )
                        : productController.productDetails["added_to_cart"] ||
                                productController.addToCart.value
                            ? Expanded(
                                flex: 1,
                                child: Stack(
                                  children: [
                                    getSingleButton(
                                        label: "Go to bag",
                                        left: 0,
                                        right: 16,
                                        fontSize: 13,
                                        textColor: whiteBorderColor,
                                        backgroundColor: colorPrimary,
                                        //  controller: productController,
                                        onPressed: () async {
                                          Get.to(CartScreen());
                                          await analytics.logEvent(
                                            name: 'productDetails_btnGotocart',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'productDetails_btnGotocart',
                                            },
                                          );
                                          productController.addToCart.value =
                                              false;
                                        },
                                        borderColor: colorPrimary),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                  )
                ],
              ),
            ),
           */
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 2.sp),
              child: Obx(() => productController.isDetails.value
                  ? const SizedBox(
                      height: 0,
                    )
                  : productController.productDetails["total_stock_count"] == 0
                      ? SizedBox(
                          height: 50.sp,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0.sp),
                                child: Image.asset(
                                  cartNewImage,
                                  color: homeAppBarColor,
                                  height: 18.sp,
                                  width: 18.sp,
                                ),
                              ),
                              AppText(
                                text: "Out of stock".toUpperCase(),
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                                color: homeAppBarColor,
                                maxLines: 2,
                                fontSize: 13,
                              )
                            ],
                          ),
                        )
                      : productController.productDetails["added_to_cart"] ||
                              productController.addToCart.value
                          ? DoubleButtonIconNew(
                              firstText: "Go to BAG".toUpperCase(),
                              secondText: "Buy Now".toUpperCase(),
                              onPressedFirst: () async {
                                Get.to(CartScreen());
                                await analytics.logEvent(
                                  name: 'productDetails_btnGotocart',
                                  parameters: <String, Object>{
                                    'page_name': 'productDetails_btnGotocart',
                                  },
                                );
                                productController.addToCart.value = false;
                              },
                              onPressedSecond: () {
                                if (productController
                                    .checkDetailsValidation()) {
                                  productController.callAddtoCart(1, "buy now");
                                }
                              },
                              controller: productController)
                          : DoubleButtonIconNew(
                              firstText: widget.type == "add"
                                  ? "Add to bag".toUpperCase()
                                  : "Move to bag".toUpperCase(),
                              secondText: "Buy Now".toUpperCase(),
                              onPressedFirst: () async {
                                if (widget.type == "add") {
                                  if (productController
                                      .checkDetailsValidation()) {
                                    productController.callAddtoCart(1, "");
                                  }
                                } else {
                                  if (productController
                                      .checkDetailsValidation()) {
                                    wishlistController.callMovetoCart(
                                        widget.boardId,
                                        widget.wishlistProductId,
                                        productController.sizeInventoryId.value,
                                        1);
                                    productController.addToCart.value = true;
                                    //  listClick(widgetKey);
                                  }
                                }
                                await analytics.logEvent(
                                  name: 'productDetails_btnaddtocart',
                                  parameters: <String, Object>{
                                    'page_name': 'productDetails_btnaddtocart',
                                  },
                                );
                              },
                              onPressedSecond: () {
                                if (productController
                                    .checkDetailsValidation()) {
                                  productController.callAddtoCart(1, "buy now");
                                }
                              },
                              controller: productController)),
            ),
          ],
        ),
      ),
    );
  }
}
