// ignore_for_file: avoid_print, deprecated_member_use
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/productlist_appbar.dart';
import 'package:lafetch/commonwidget/brandwidgits/horizontal_category_list.dart';
import 'package:lafetch/commonwidget/catalogwidgets/bottomwishlist.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/controller/wishlist_controller.dart';
import 'package:lafetch/screens/Brands/categoryproduct.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import 'package:lafetch/screens/wishlist/newboardscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../controller/catalog_controller.dart';
import '../../utils/constants.dart';
import '../cartscreen.dart';
import '../searchscreen.dart';

class CatalogDetailsScreen extends StatefulWidget {
  final String title;
  final String catalogText;
  final String catalogImage;
  final int genderType;
  final int catalogId;

  const CatalogDetailsScreen({
    Key? key,
    required this.title,
    required this.catalogText,
    required this.catalogImage,
    required this.genderType,
    required this.catalogId,
  }) : super(key: key);

  @override
  State<CatalogDetailsScreen> createState() => CatalogDetailsScreenState();
}

class CatalogDetailsScreenState extends State<CatalogDetailsScreen> {
  final controller = Get.put(CatalogController());
  final cartController = Get.put(CartController());
  final wishlistController = Get.put(WishlistController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.getCategoryProductData(widget.catalogId));
    /* WidgetsBinding.instance
        .addPostFrameCallback((_) => productController.id.value = 0); */
    WidgetsBinding.instance
        .addPostFrameCallback((_) => wishlistController.getWishlistData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      key: scaffoldKey,
      body: Column(
        children: [
          /*  CatalogAppbar(
            text: widget.title,
            onPressedSearch: () {
              Get.to(const SearchScreen());
            },
            onPressedCart: () {
              Get.to(const CartScreen());
            },
          ), */
          ProductAppbar(
              backColor: statusBarColor,
              text: widget.title.toUpperCase(),
              onPressedSearch: () async {
                Get.to(const SearchScreen())?.then((value) => setState(
                      () {},
                    ));
                analytics
                    .logEvent(name: "search_page", parameters: <String, Object>{
                  "page_name": "search_page",
                });
              },
              isHandPicked: true,
              onPressedHeart: () async {
                Get.to(const WishlistScreen())?.then((value) => setState(
                      () {
                        cartController.getCartData();
                      },
                    ));
                analytics.logEvent(
                    name: "wishlist_page",
                    parameters: <String, Object>{
                      "page_name": "wishlist_page",
                    });
              },
              onPressedCart: () async {
                Get.to(const CartScreen())?.then((value) => setState(
                      () {
                        cartController.getCartData();
                      },
                    ));
                analytics
                    .logEvent(name: "cart_page", parameters: <String, Object>{
                  "page_name": "cart_page",
                });
              }),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*  widget.catalogImage.isNotEmpty
                      ? SizedBox(
                          height: 100.sp,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            cacheManager: CacheManager(Config("customCacheKey",
                                stalePeriod: const Duration(days: 15),
                                maxNrOfCacheObjects: 100)),
                            fit: BoxFit.cover,
                            imageUrl: widget.catalogImage,
                            /*  progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ), */
                            errorWidget: (context, url, error) => Image.asset(
                              downloadImage,
                              height: 210.sp,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 100.sp,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(backImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  Container(
                    height: 65.sp,
                    color: whiteBorderColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText(
                            text: widget.title,
                            color: appbarText,
                            fontSize: 16,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                          const Expanded(
                            child: SizedBox(
                              width: 0,
                            ),
                          ),
                          AppText(
                            text: "For ${widget.catalogText}",
                            color: textHintColor,
                            fontSize: 14,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() => controller.isCategory.value
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: 16.sp, right: 16.sp, top: 22.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DummyContainer(height: 14, width: 80),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.sp),
                                child: DummyContainer(height: 14, width: 80),
                              ),
                            ],
                          ),
                        )
                      : controller.categoryList.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.sp, right: 16.sp, top: 22.sp),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: controller.categoryList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              productController.catalogIndex
                                                  .value = index + 1;
                                              productController.id.value =
                                                  controller.categoryList[index]
                                                      ["id"];
                                              setState(() {});
                                              productController
                                                  .getProductByCategoryData(
                                                      controller.categoryList[
                                                          index]["id"],
                                                      0,
                                                      "Product Vertical",
                                                      controller.categoryList,
                                                      "",
                                                      widget.genderType,
                                                      false,
                                                      widget.catalogId,
                                                      false,
                                                      "catalog");
                                              await analytics.logEvent(
                                                name:
                                                    "catalog_details_${widget.genderType}",
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      "catalog_details_${widget.genderType}",
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 10.sp),
                                              child: Container(
                                                color: productController
                                                            .id.value ==
                                                        controller.categoryList[
                                                            index]["id"]
                                                    ? whiteTextColor
                                                    : whiteColor,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(6.sp),
                                                      child: AppText(
                                                        text: controller
                                                                    .categoryList[
                                                                index]["name"] ??
                                                            "",
                                                        color: greyTextColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                    );
                                  }),
                            )
                          : Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(
                                child: Text("No Category Found",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                        fontFamily: "Franklin Gothic Regular")),
                              ),
                            ))
               */
                  Obx(() => controller.isCategory.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 32.sp),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 16.sp,
                                  right: 16.sp,
                                ),
                                child: DummyContainer(height: 24, width: 100),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16.sp,
                                horizontal: 16.sp,
                              ),
                              child: SizedBox(
                                height: 250.sp,
                                width: double.infinity,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: 5,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return Column(
                                        children: [
                                          Container(
                                            width: 122.sp,
                                            height: 250.sp,
                                            margin:
                                                EdgeInsets.only(right: 5.sp),
                                            color: Colors.white,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 150.sp,
                                                  width: 122.sp,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.04),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.sp,
                                                      vertical: 5.sp),
                                                  child: Container(
                                                    height: 10.sp,
                                                    width: 102.sp,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.04),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.sp,
                                                      left: 10.sp,
                                                      right: 1.sp),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 10.sp,
                                                        width: 50.sp,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.04),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5.sp),
                                                        child: Container(
                                                          height: 10.sp,
                                                          width: 50.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.04),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.sp,
                                                      left: 10.sp,
                                                      right: 10.sp),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 14.sp,
                                                        width: 14.sp,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.04),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.sp),
                                                        child: Container(
                                                          height: 10.sp,
                                                          width: 50.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.04),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 16.sp),
                          child: ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: controller.categoryProductList.length,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (ctx, index) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 16.sp),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          Navigator.push(
                                              context,
                                              scaleIn(CategoryProductScreen(
                                                  categoryName: controller
                                                          .categoryProductList[
                                                      index]["name"],
                                                  genderName:
                                                      widget.catalogText,
                                                  categoryId: controller
                                                          .categoryProductList[
                                                      index]["id"],
                                                  brandId: 0,
                                                  screen: "category",
                                                  genderType: widget.genderType,
                                                  categoryList: [],
                                                  tagIds: const [])));
                                          await analytics.logEvent(
                                            name: 'categories_home_page',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'categories_home_page',
                                            },
                                          );
                                        },
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 16.sp,
                                              right: 16.sp,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2.sp +
                                                      100,
                                                  child: AppText(
                                                    text: controller
                                                        .categoryProductList[
                                                            index]["name"]
                                                        .toUpperCase(),
                                                    color: blackColor,
                                                    fontSize: 20,
                                                    fontFamily:
                                                        "Franklin Gothic Semibold",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: SizedBox(
                                                  width: 0,
                                                )),
                                                Container(
                                                  height: 20.sp,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: SvgPicture.asset(
                                                    color: homeAppBarColor,
                                                    rightArrowSvgImage,
                                                    height: 11.sp,
                                                    width: 7.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.sp),
                                        child: HorizontalCategoryList(
                                          onPressed: (p0, p1) async {
                                            Get.to(ProductDetailsScreen(
                                                    expresshour: "",
                                                    brandName: p1,
                                                    productId: p0,
                                                    type: "add"))
                                                ?.then((value) => setState(
                                                      () {},
                                                    ));
                                            await analytics.logEvent(
                                              name: 'category_product_details',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'category_product_details',
                                              },
                                            );
                                          },
                                          list: controller
                                                  .categoryProductList[index]
                                              ["products"],
                                          onPressedHeart:
                                              (productId, p1) async {
                                            if (controller.categoryProductList[
                                                    index]["products"][p1]
                                                ["wishlisted"]) {
                                              controller.categoryProductList[
                                                      index]["products"][p1]
                                                  ["wishlisted"] = false;
                                              setState(() {});
                                              controller.callAddProductToWishlist(
                                                  controller.categoryProductList[
                                                          index]["products"][p1]
                                                      ["wishlist_id"],
                                                  productId);
                                            } else {
                                              scaffoldKey.currentState?.showBottomSheet(
                                                  (context) => BottomWishlist(
                                                      controller:
                                                          wishlistController,
                                                      onPressedBoard: () {
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        NewBoardScreen(
                                                                          title:
                                                                              "New Board",
                                                                          boardId:
                                                                              0,
                                                                          productId:
                                                                              controller.categoryProductList[index]["products"][p1]["id"],
                                                                          hintName:
                                                                              "Name of the Board",
                                                                          boardName:
                                                                              "",
                                                                          btnText:
                                                                              "Next",
                                                                          categoryId:
                                                                              widget.catalogId,
                                                                        )))
                                                            .then(
                                                              (value) {},
                                                            );
                                                      },
                                                      productImage: controller
                                                                  .categoryProductList[
                                                              index]["products"][p1]
                                                          ["images"][0]["name"],
                                                      onPressed: (p0) {
                                                        controller.categoryProductList[
                                                                    index]
                                                                ["products"][p1]
                                                            [
                                                            "wishlisted"] = true;
                                                        setState(() {});
                                                        controller
                                                            .callAddProductToWishlist(
                                                                p0, productId);
                                                      },
                                                      wishlistList:
                                                          wishlistController
                                                              .wishlistList));
                                              await analytics.logEvent(
                                                name:
                                                    'allbrand_bestseller_wishlist',
                                                parameters: <String, Object>{
                                                  'page_name':
                                                      'allbrand_bestseller_wishlist',
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        color: lightgreyColor,
                                        height: 16.sp,
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
