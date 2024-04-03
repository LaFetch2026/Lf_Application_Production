// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/doublebtn.dart';
import '../../controller/product_controller.dart';
import '../../utils/constants.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  final productController = Get.put(ProductController());

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
        body: Obx(() => productController.isProduct.value
            ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : productController.productList.isNotEmpty
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 10, bottom: 90),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  scrollDirection: Axis.vertical,
                                  padding: EdgeInsets.zero,
                                  childAspectRatio: 0.5,
                                  physics: const ScrollPhysics(),
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 0,
                                  children: List.generate(
                                    productController.productList.length,
                                    (index) {
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Center(
                                                      child: Image.asset(
                                                          backImage,
                                                          height: 190,
                                                          width: 152,
                                                          fit: BoxFit.cover),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16,
                                                          vertical: 10),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: InkWell(
                                                          child: SizedBox(
                                                            height: 24,
                                                            width: 24,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              child:
                                                                  Image.asset(
                                                                heartImage,
                                                                height: 16,
                                                                color:
                                                                    bottomnavBack,
                                                                width: 16,
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
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 140),
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
                                                                text: productController.productList[index]
                                                                            [
                                                                            "aggregated_rating"] !=
                                                                        null
                                                                    ? productController
                                                                        .productList[
                                                                            index]
                                                                            [
                                                                            "aggregated_rating"]
                                                                        .toString()
                                                                    : "aggregated_rating",
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
                                                                child:
                                                                    Container(
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
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: AppText(
                                                    text: productController
                                                                .productList[
                                                            index]["name"] ??
                                                        "",
                                                    color: nameText,
                                                    maxLines: 2,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: AppText(
                                                    text: productController
                                                                    .productList[
                                                                index][
                                                            "short_description"] ??
                                                        "",
                                                    color: nameText,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      AppText(
                                                        text:
                                                            "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                                        color:
                                                            deepGreytextColor,
                                                        maxLines: 2,
                                                        fontSize: 11.sp,
                                                        fontFamily:
                                                            "Franklin Gothic",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          "\u{20B9} ${productController.productList[index]["mrp"] ?? ""}",
                                                          style: TextStyle(
                                                            color:
                                                                textHintColor,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      const ImageIcon(
                                                        AssetImage(truckImage),
                                                        color: expressText,
                                                        size: 14,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30, top: 20),
                          child: DoubleButton(
                            firstText: "Sort By",
                            secondText: "Filters",
                            firstTextColor: deepGreytextColor,
                            secondTextColor: deepGreytextColor,
                            firstBackgroundColor: backWhite,
                            secondBackgroundColor: backWhite,
                            firstBorderColor: deepGreytextColor,
                            secondBorderColor: deepGreytextColor,
                            onPressedFirst: () {},
                            onPressedSecond: () {
                              /*  Get.to(
                          () => const LoginScreen(),
                        ); */
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
