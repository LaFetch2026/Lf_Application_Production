// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/catalog/productlist/productdetailsscreen.dart';
import '../../../commonwidget/app_text.dart';
import '../../../controller/product_controller.dart';
import '../../../utils/constants.dart';

class ProductVerticalScreen extends StatefulWidget {
  const ProductVerticalScreen({super.key});

  @override
  State<ProductVerticalScreen> createState() => ProductVerticalScreenState();
}

class ProductVerticalScreenState extends State<ProductVerticalScreen> {
  final productController = Get.find<ProductController>();
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "500",
  ];
  List<String> images = [
    image,
    backImage,
    otpImage,
  ];
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  callOnchanged(int index) {
    productController.currentpage.value = index;
    print("index$index");
    /*  if (productController.currentpage.value == 0) {
      print(1);
    }
    if (productController.currentpage.value == 1) {
      print(2);
    }
    if (productController.currentpage.value == 2) {
      print(3);
    } */
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteTextColor,
        body: Obx(
          () => productController.isProduct.value
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : productController.productList.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const ScrollPhysics(),
                              itemCount: productController.productList.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(const ProductDetailsScreen(
                                          productId: 0,
                                        ));
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              SizedBox(
                                                height: 400,
                                                width: double.infinity,
                                                child: PageView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  controller: _pageController,
                                                  onPageChanged: callOnchanged,
                                                  itemCount: images.length,
                                                  itemBuilder:
                                                      (context, int i) {
                                                    return Image.asset(
                                                        images[i],
                                                        height: 400,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    child: SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            whiteColor,
                                                        child: Image.asset(
                                                          heartImage,
                                                          height: 30,
                                                          width: 30,
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
                                                          text: productController
                                                                              .productList[
                                                                          index]
                                                                      [
                                                                      "aggregated_rating"] !=
                                                                  null
                                                              ? productController
                                                                  .productList[
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
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: /* SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: */
                                                  Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children:
                                                          List<Widget>.generate(
                                                              images.length,
                                                              (int index) {
                                                        return AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        400),
                                                            height: 6,
                                                            width: 6,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: (index ==
                                                                        productController
                                                                            .currentpage
                                                                            .value)
                                                                    ? colorPrimary
                                                                    : colorSecondary));
                                                      })),
                                              //  ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: AppText(
                                              text: productController
                                                          .productList[index]
                                                      ["name"] ??
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
                                              text: productController
                                                          .productList[index]
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
                                                top: 10, left: 10, right: 10),
                                            child: Row(
                                              children: [
                                                AppText(
                                                  text:
                                                      "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                  color: deepGreytextColor,
                                                  maxLines: 2,
                                                  fontSize: 14.sp,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                    "\u{20B9} ${productController.productList[index]["mrp"] ?? ""}",
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
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
