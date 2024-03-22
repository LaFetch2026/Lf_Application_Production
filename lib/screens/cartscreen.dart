// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/cart_appbar.dart';
import 'package:lafetch/commonwidget/cartwidgets/cartwidgets.dart';
import 'package:lafetch/commonwidget/smallbtn.dart';
import 'package:lafetch/screens/checkoutscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/common_widgets.dart';
import '../commonwidget/singlebtn.dart';
import '../controller/base_controller.dart';
import '../controller/cart_controller.dart';
import '../controller/product_controller.dart';
import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final controller = Get.put(CartController());
  final productController = Get.put(ProductController());
  List<String> items = [
    "1",
    "2",
    "3",
  ];

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getCartData(1));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => productController.getProductData("relevant"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          CartAppbar(
            text: "Shopping Bag",
            threeDot: true,
            icon: bigHeartImage,
            onPressedHeart: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*  Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CartWidget(
                        image: shopBagImage,
                        text1: "There is still room for more",
                        text2:
                            "Looking for items you previously saved?\nSign in to pick up where you left out",
                        btntext: "Continue Shopping",
                        visible: true),
                  ), */
                  Obx(
                    () => controller.isOrder.value
                        ? const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "Shopping Bag",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: blackColor,
                                          fontSize: 16.sp,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              AppText(
                                                text:
                                                    "${controller.orderList.length} items",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: textHintColor,
                                                fontSize: 12.sp,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Container(
                                                  width: 1,
                                                  color: textHintColor,
                                                  height: 16,
                                                ),
                                              ),
                                              AppText(
                                                text: "\u{20B9} ${125.0}",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: textHintColor,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 0,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const ImageIcon(
                                              AssetImage(deleteIcon),
                                              color: colorPrimary,
                                              size: 16,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: AppText(
                                                text: "Clear Bag",
                                                fontFamily: "Franklin Gothic",
                                                fontWeight: FontWeight.w500,
                                                color: colorPrimary,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10, top: 5),
                                  child: GetBuilder<CartController>(
                                    builder: (value) => ListView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: value.orderList.length,
                                        padding: EdgeInsets.zero,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (ctx, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, left: 16, right: 16),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Image.asset(
                                                              backImage,
                                                              height: 78,
                                                              width: 64,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                AppText(
                                                                  text: value
                                                                          .orderList[
                                                                              index]
                                                                              [
                                                                              "order_lines"]
                                                                          .isNotEmpty
                                                                      ? value.orderList[
                                                                              index]["order_lines"][0]["product"]
                                                                          [
                                                                          "name"]
                                                                      : "",
                                                                  maxLines: 1,
                                                                  fontFamily:
                                                                      "Franklin Gothic",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      14.sp,
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                                  child:
                                                                      AppText(
                                                                    text: value.orderList[index]["order_lines"][0]["product"]
                                                                            [
                                                                            "short_description"] ??
                                                                        "",
                                                                    color:
                                                                        nameText,
                                                                    maxLines: 2,
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                AppText(
                                                                  text: value.orderList[index]["order_lines"][0]
                                                                              [
                                                                              "product"]
                                                                          [
                                                                          "description"] ??
                                                                      "",
                                                                  color:
                                                                      textHintColor,
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        color:
                                                                            colorSecondary,
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            70,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                                              child: AppText(
                                                                                text: "Size : S",
                                                                                color: blackColor,
                                                                                fontSize: 10.sp,
                                                                                fontFamily: "Franklin Gothic Regular",
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),
                                                                            const ImageIcon(
                                                                              AssetImage(dropdownImage),
                                                                              color: nameText,
                                                                              size: 16,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                5,
                                                                            bottom:
                                                                                5),
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              colorSecondary,
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              70,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                                                child: AppText(
                                                                                  text: "Qty : ${value.orderList[index]["order_lines"][0]["quantity"] ?? "0"}",
                                                                                  color: blackColor,
                                                                                  fontSize: 10.sp,
                                                                                  fontFamily: "Franklin Gothic Regular",
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                              ),
                                                                              const ImageIcon(
                                                                                AssetImage(dropdownImage),
                                                                                color: nameText,
                                                                                size: 16,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                                  child: Row(
                                                                    children: [
                                                                      AppText(
                                                                        text:
                                                                            "\u{20B9} ${value.orderList[index]["order_lines"][0]["product"]["mrp"] ?? "0"}",
                                                                        color:
                                                                            blackColor,
                                                                        fontSize:
                                                                            12.sp,
                                                                        fontFamily:
                                                                            "Franklin Gothic Regular",
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 10),
                                                                        child:
                                                                            Text(
                                                                          "\u{20B9} ${value.orderList[index]["order_lines"][0]["product"]["price"] ?? "0"}",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                textHintColor,
                                                                            fontSize:
                                                                                12.sp,
                                                                            decoration:
                                                                                TextDecoration.lineThrough,
                                                                            fontFamily:
                                                                                "Franklin Gothic Regular",
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 10),
                                                                        child:
                                                                            Text(
                                                                          "${value.orderList[index]["order_lines"][0]["product"]["discount_percentage"] ?? "0 %"} OFF",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                blackColor,
                                                                            fontSize:
                                                                                12.sp,
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
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              barrierColor:
                                                                  Colors
                                                                      .black26,
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return showDoubleBtnDailog(
                                                                    click1: () {
                                                                      Get.back();
                                                                    },
                                                                    click2: () {
                                                                      productController.callAddtoCart(
                                                                          value.orderList[index]["order_lines"][0]["product"]
                                                                              [
                                                                              "id"],
                                                                          0,
                                                                          "remove");
                                                                      value.getCartData(
                                                                          1);
                                                                      value
                                                                          .update();
                                                                    },
                                                                    btncolor:
                                                                        colorPrimary,
                                                                    text:
                                                                        "Are you sure you want to remove this item?",
                                                                    btn1Text:
                                                                        "Cancel",
                                                                    btn2Text:
                                                                        "Remove");
                                                              },
                                                            );
                                                          },
                                                          child: Image.asset(
                                                              blackCrossImage,
                                                              height: 10,
                                                              width: 10,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8),
                                                      child: Container(
                                                        width: double.infinity,
                                                        color: colorSecondary,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          );
                                        }),
                                  )),
                            ],
                          ),
                  ),
                  Obx(
                    () => productController.isProduct.value
                        ? const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, left: 16),
                                child: AppText(
                                  text: "You may also like",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: colorPrimary,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: SizedBox(
                                    width: double.infinity,
                                    height: 310,
                                    child: GetBuilder<ProductController>(
                                      builder: (value) => ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: value.productList.length,
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
                                                            right: 8),
                                                    color: whiteColor,
                                                    width: 122,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.asset(backImage,
                                                            height: 150,
                                                            width: 122,
                                                            fit: BoxFit.cover),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: AppText(
                                                            text: value.productList[
                                                                        index]
                                                                    ["name"] ??
                                                                "",
                                                            color: nameText,
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 3),
                                                          child: AppText(
                                                            text: value.productList[
                                                                        index][
                                                                    "short_description"] ??
                                                                "",
                                                            color: nameText,
                                                            maxLines: 2,
                                                            fontSize: 11.sp,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                                    "\u{20B9} ${value.productList[index]["price"] ?? "0"}",
                                                                color:
                                                                    deepGreytextColor,
                                                                maxLines: 2,
                                                                fontSize: 11.sp,
                                                                fontFamily:
                                                                    "Franklin Gothic",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10),
                                                                child: Text(
                                                                  "\u{20B9} ${value.productList[index]["mrp"] ?? "0"}",
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
                                                                  top: 10),
                                                          child: getSmallButton(
                                                              controller:
                                                                  productController,
                                                              label:
                                                                  "Add to bag",
                                                              onPressed: () {
                                                                productController.callAddtoCart(
                                                                    value.productList[
                                                                            index]
                                                                        ["id"],
                                                                    1,
                                                                    "addproduct");
                                                                controller
                                                                    .getCartData(
                                                                        1);
                                                              },
                                                              textColor:
                                                                  btnTextColor,
                                                              backgroundColor:
                                                                  whiteColor,
                                                              borderColor:
                                                                  btnTextColor,
                                                              width: 122),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                    )),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Coupons",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: colorPrimary,
                            fontSize: 12.sp,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: borderColor, width: 1),
                                  borderRadius: BorderRadius.circular(1)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Row(
                                        children: [
                                          const ImageIcon(
                                            AssetImage(coupanImage),
                                            color: colorPrimary,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: AppText(
                                              text: "Apply Coupon",
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 0,
                                      ),
                                    ),
                                    AppText(
                                      text: "Select",
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: AppText(
                              text: "Price Details",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: colorPrimary,
                              fontSize: 12.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              width: double.infinity,
                              color: colorSecondary,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Total MRP",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${2537.00}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Express Delivery Charges",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${112.32}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Discount on MRP",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${-36.00}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Coupon Discount",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${-36.00}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: AppText(
                                        text: "Convenience Fee",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: textColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Image.asset(questionIcon,
                                        height: 16,
                                        width: 16,
                                        fit: BoxFit.cover)
                                  ],
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "Free",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: greenText,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: AppText(
                                        text: "Tax & Charges",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: textColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Image.asset(questionIcon,
                                        height: 16,
                                        width: 16,
                                        fit: BoxFit.cover)
                                  ],
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${36}",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              width: double.infinity,
                              color: colorSecondary,
                              height: 1.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: AppText(
                                    text: "Bill total",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: colorPrimary,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 0,
                                  ),
                                ),
                                AppText(
                                  text: "\u{20B9} ${2501}",
                                  fontFamily: "Franklin Gothic Bold",
                                  fontWeight: FontWeight.w700,
                                  color: colorPrimary,
                                  fontSize: 18.sp,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: backWhite,
                    height: 34,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 6, bottom: 6),
                      child: Center(
                        child: AppText(
                          text:
                              "You will earn 100 LaFetch coins on this purchase",
                          fontFamily: "Franklin Gothic Regular",
                          fontWeight: FontWeight.w400,
                          color: deepPurple,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: whiteBorderColor,
                                borderRadius: BorderRadius.circular(1)),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Return/Refund Policy",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: nameText,
                                    fontSize: 14.sp,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: AppText(
                                      text:
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nibh augue, commodo eget pulvinar ac, pretium a ipsum.",
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      maxLines: 3,
                                      color: greyTextColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  AppText(
                                    text: "READ POLICY",
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: greyTextColor,
                                    fontSize: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Image.asset(deliveredImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "Delivered in\n6 hours",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(qualityImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "100% Quality\nassured",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(locationBaseImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "Location based\nDeliveries",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(exchangeImage,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: AppText(
                                        text: "2 exchanges\nwithin 2 days",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: greyTextColor,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        fontSize: 10.sp,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            color: whiteColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                  child: AppText(
                    text: "3 items in shopping bag",
                    textAlign: TextAlign.center,
                    fontFamily: "Franklin Gothic Regular",
                    fontWeight: FontWeight.w400,
                    color: blackColor,
                    fontSize: 12.sp,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleButton(
                      label: "Proceed to checkout",
                      textColor: whiteBorderColor,
                      backgroundColor: colorPrimary,
                      onPressed: () {
                        Get.to(const CheckoutScreen());
                      },
                      borderColor: colorPrimary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
