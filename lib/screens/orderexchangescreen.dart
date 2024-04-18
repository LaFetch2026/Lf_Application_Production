// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/doubleiconbtn.dart';
import 'package:lafetch/commonwidget/singleiconbtn.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import 'package:lafetch/screens/reviewproducts.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/singlebtn.dart';
import '../controller/order_controller.dart';
import '../utils/constants.dart';

class OrderExchangeScreen extends StatefulWidget {
  const OrderExchangeScreen({super.key});

  @override
  State<OrderExchangeScreen> createState() => OrderExchangeScreenState();
}

class OrderExchangeScreenState extends State<OrderExchangeScreen> {
  final orderController = Get.put(OrderController());
  String? filter;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      orderController.listController.addListener(() {
        orderController.fetchMoreData();
        orderController.update();
      });
    });
    orderController.hasnextpage.value = true;
    orderController.loadMore.value = false;
    orderController.isOrder.value = false;
    orderController.page.value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => orderController.getOrderData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: Column(
          children: [
            const BackButtonAppbar(
              text: "Orders & Exchanges",
              threeDot: false,
              backgroundColor: whiteColor,
              icon: threeDotImage,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: orderController.listController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: whiteColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            /* Container(
                              height: 40,
                              width: 180,
                              decoration: BoxDecoration(
                                  color: whiteBorderColor,
                                  borderRadius: BorderRadius.circular(1),
                                  border: Border.all(color: borderColor, width: 1)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 10),
                                child: Row(
                                  children: [
                                    const ImageIcon(
                                      AssetImage(searchImage),
                                      color: textHintColor,
                                      size: 14,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 5),
                                      child: AppText(
                                        text: "Search",
                                        color: textHintColor,
                                        fontSize: 14.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ), */
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: const TextStyle(
                                      color: textColor,
                                      fontFamily: "Franklin Gothic Regular",
                                    ),
                                    onChanged: (value) {
                                      orderController.queryText.value = value;
                                      orderController.getOrderData();
                                    },
                                    controller:
                                        orderController.searchController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteColor,
                                      prefixIcon: const Icon(Icons.search,
                                          size: 20, color: Colors.grey),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: borderColor)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(1),
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                      ),
                                      counterText: "",
                                      hintText: "Search",
                                      hintStyle: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: 130,
                              child: DropdownButtonFormField2(
                                value: filter,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: whiteColor,
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                    borderSide:
                                        const BorderSide(color: borderColor),
                                  ),
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.only(left: 10, right: 0),
                                  hintText: 'Filter',
                                  hintStyle: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Franklin Gothic Regular"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                isExpanded: true,
                                items: orderController.filterList
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: textColor,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select Types.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  filter = value;
                                  print(orderController.filterId[orderController
                                      .filterList
                                      .indexOf(filter.toString())]);
                                  orderController.status.value =
                                      orderController.filterId[orderController
                                          .filterList
                                          .indexOf(filter.toString())];
                                  orderController.getOrderData();
                                },
                                onSaved: (value) {},
                                buttonStyleData: const ButtonStyleData(
                                  height: 60,
                                  padding: EdgeInsets.only(right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: ImageIcon(AssetImage(dropdownImage)),
                                  iconSize: 10,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    color: whiteTextColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => orderController.isOrder.value
                          ? const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  controller: orderController.listController,
                                  physics: const ScrollPhysics(),
                                  itemCount: orderController.orderList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(OrderDetailsScreen(
                                                orderId: orderController
                                                    .orderList[index]["id"],
                                              ));
                                            },
                                            child: Container(
                                              color: whiteColor,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 16),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 1,
                                                                child: orderController.orderList[index]["order_lines"][0]["product"] !=
                                                                        null
                                                                    ? orderController.orderList[index]["order_lines"][0]["product"]["images"].isNotEmpty &&
                                                                            orderController.orderList[index]["order_lines"][0]["product"]["images"] !=
                                                                                null
                                                                        ? SizedBox(
                                                                            height:
                                                                                85,
                                                                            width:
                                                                                70,
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
                                                                              fit: BoxFit.cover,
                                                                              imageUrl: orderController.orderList[index]["order_lines"][0]["product"]["images"][0]["name"],
                                                                              progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                                                child: CircularProgressIndicator(value: downloadProgress.progress),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                dummyWishlistImage,
                                                                                fit: BoxFit.cover,
                                                                                height: 85,
                                                                                width: 70,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Image.asset(
                                                                            dummyWishlistImage,
                                                                            height:
                                                                                85,
                                                                            width:
                                                                                70,
                                                                            fit: BoxFit
                                                                                .cover)
                                                                    : Image.asset(
                                                                        dummyWishlistImage,
                                                                        height: 85,
                                                                        width: 70,
                                                                        fit: BoxFit.cover)),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5,
                                                                        left:
                                                                            12),
                                                                    child:
                                                                        AppText(
                                                                      text: orderController.orderList[index]["order_lines"][0]["product"] !=
                                                                              null
                                                                          ? orderController.orderList[index]["order_lines"][0]["product"]
                                                                              [
                                                                              "name"]
                                                                          : "",
                                                                      maxLines:
                                                                          1,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14.sp,
                                                                      color:
                                                                          nameText,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5,
                                                                        left:
                                                                            12,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                    child:
                                                                        AppText(
                                                                      text: orderController.orderList[index]["order_lines"][0]["product"] !=
                                                                              null
                                                                          ? orderController.orderList[index]["order_lines"][0]["product"]
                                                                              [
                                                                              "short_description"]
                                                                          : "",
                                                                      color:
                                                                          greyTextColor,
                                                                      maxLines:
                                                                          2,
                                                                      fontSize:
                                                                          12.sp,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5,
                                                                        left:
                                                                            12,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                    child: Row(
                                                                      children: [
                                                                        AppText(
                                                                          text:
                                                                              "Size :M",
                                                                          color:
                                                                              greyTextColor,
                                                                          maxLines:
                                                                              2,
                                                                          fontSize:
                                                                              12.sp,
                                                                          fontFamily:
                                                                              "Franklin Gothic Regular",
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10),
                                                                            child:
                                                                                AppText(
                                                                              text: "Qty :${orderController.orderList[index]["order_lines"][0]["quantity"] ?? "0"}",
                                                                              color: greyTextColor,
                                                                              maxLines: 2,
                                                                              fontSize: 12.sp,
                                                                              fontFamily: "Franklin Gothic Regular",
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        AppText(
                                                                          text:
                                                                              "\u{20B9} ${orderController.orderList[index]["order_lines"][0]["total"] ?? "0"}",
                                                                          color:
                                                                              greyTextColor,
                                                                          fontSize:
                                                                              12.sp,
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          fontFamily:
                                                                              "Franklin Gothic Regular",
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10,
                                                                horizontal: 16),
                                                        child: Row(
                                                          children: [
                                                            if (orderController
                                                                            .orderList[
                                                                        index][
                                                                    "status"] ==
                                                                6) ...[
                                                              AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      lightGreen,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color:
                                                                          textHintColor,
                                                                      width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 2),
                                                                          child:
                                                                              ImageIcon(
                                                                            AssetImage(checkImage),
                                                                            color:
                                                                                deepGreen,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 5,
                                                                              right: 2),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Delivered",
                                                                            color:
                                                                                deepGreen,
                                                                            fontSize:
                                                                                12.sp,
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ] else if (orderController
                                                                            .orderList[
                                                                        index][
                                                                    "status"] ==
                                                                5) ...[
                                                              AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      deeptYellow,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color:
                                                                          textHintColor,
                                                                      width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 2),
                                                                          child:
                                                                              ImageIcon(
                                                                            AssetImage(shippedImage),
                                                                            color:
                                                                                deeptYellow,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 5,
                                                                              right: 2),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Shipped",
                                                                            color:
                                                                                deeptYellow,
                                                                            fontSize:
                                                                                12.sp,
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ] else if (orderController
                                                                            .orderList[
                                                                        index][
                                                                    "status"] ==
                                                                3) ...[
                                                              AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      lightPurple,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color:
                                                                          textHintColor,
                                                                      width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 2),
                                                                          child:
                                                                              ImageIcon(
                                                                            AssetImage(confirmOrderImage),
                                                                            color:
                                                                                deepPurple,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 5,
                                                                              right: 2),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Order Confirmed",
                                                                            color:
                                                                                deepPurple,
                                                                            fontSize:
                                                                                12.sp,
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ] else if (orderController
                                                                            .orderList[
                                                                        index][
                                                                    "status"] ==
                                                                7) ...[
                                                              AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      lightback,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color:
                                                                          textHintColor,
                                                                      width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 2),
                                                                          child:
                                                                              ImageIcon(
                                                                            AssetImage(cancelImage),
                                                                            color:
                                                                                deepRed,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 5,
                                                                              right: 2),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Cancelled",
                                                                            color:
                                                                                deepRed,
                                                                            fontSize:
                                                                                12.sp,
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ] else ...[
                                                              AnimatedContainer(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5),
                                                                height: 30,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      lightGreen,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      color:
                                                                          textHintColor,
                                                                      width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 2),
                                                                          child:
                                                                              ImageIcon(
                                                                            AssetImage(checkImage),
                                                                            color:
                                                                                deepGreen,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 5,
                                                                              right: 2),
                                                                          child:
                                                                              AppText(
                                                                            text:
                                                                                "Cart",
                                                                            color:
                                                                                deepGreen,
                                                                            fontSize:
                                                                                12.sp,
                                                                            fontFamily:
                                                                                "Franklin Gothic",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ],
                                                            const Expanded(
                                                              child: SizedBox(
                                                                width: 0,
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          5),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Delivered on",
                                                                    color:
                                                                        greyTextColor,
                                                                    fontSize:
                                                                        11.sp,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          5),
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Jul 24, at 3:30 PM",
                                                                    color:
                                                                        greyTextColor,
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
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      orderController.orderList[
                                                                      index]
                                                                  ["status"] ==
                                                              6
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                Get.to(const ReviewProductScreen(
                                                                    productName:
                                                                        "Topman super skinny suit jacket and trousers in light blue"));
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        5),
                                                                child: AppText(
                                                                  text:
                                                                      "Write a Review",
                                                                  color: blue,
                                                                  fontSize:
                                                                      11.sp,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(
                                                              height: 0,
                                                            ),
                                                      Column(
                                                        children: [
                                                          if (orderController
                                                                          .orderList[
                                                                      index]
                                                                  ["status"] ==
                                                              6) ...[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      bottom:
                                                                          20),
                                                              child: DoubleIconButton(
                                                                  firstText:
                                                                      "Exchange Item",
                                                                  secondText:
                                                                      "Rate Order",
                                                                  firstTextColor:
                                                                      btnTextColor,
                                                                  secondTextColor:
                                                                      btnTextColor,
                                                                  firstBackgroundColor:
                                                                      whiteColor,
                                                                  secondBackgroundColor:
                                                                      whiteColor,
                                                                  firstBorderColor:
                                                                      btnTextColor,
                                                                  secondBorderColor:
                                                                      btnTextColor,
                                                                  firstIcon:
                                                                      exchangeItemImage,
                                                                  onPressedFirst:
                                                                      () {},
                                                                  onPressedSecond:
                                                                      () {},
                                                                  secondIcon:
                                                                      rateOrderImage),
                                                            )
                                                          ] else if (orderController
                                                                          .orderList[
                                                                      index]
                                                                  ["status"] ==
                                                              3) ...[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      bottom:
                                                                          20),
                                                              child: DoubleIconButton(
                                                                  firstText:
                                                                      "Cancel Item",
                                                                  secondText:
                                                                      "Track Order",
                                                                  firstTextColor:
                                                                      btnTextColor,
                                                                  secondTextColor:
                                                                      btnTextColor,
                                                                  firstBackgroundColor:
                                                                      whiteColor,
                                                                  secondBackgroundColor:
                                                                      whiteColor,
                                                                  firstBorderColor:
                                                                      btnTextColor,
                                                                  secondBorderColor:
                                                                      btnTextColor,
                                                                  firstIcon:
                                                                      blackCrossImage,
                                                                  onPressedFirst:
                                                                      () {},
                                                                  onPressedSecond:
                                                                      () {},
                                                                  secondIcon:
                                                                      locationIcon),
                                                            )
                                                          ] else if (orderController
                                                                          .orderList[
                                                                      index]
                                                                  ["status"] ==
                                                              5) ...[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 16,
                                                                      right: 16,
                                                                      top: 10,
                                                                      bottom:
                                                                          30),
                                                              child: SingleIconButton(
                                                                  label:
                                                                      "Track Order",
                                                                  textColor:
                                                                      btnTextColor,
                                                                  backgroundColor:
                                                                      whiteColor,
                                                                  onPressed:
                                                                      () {},
                                                                  borderColor:
                                                                      btnTextColor,
                                                                  icon:
                                                                      locationIcon),
                                                            )
                                                          ] else if (orderController
                                                                          .orderList[
                                                                      index]
                                                                  ["status"] ==
                                                              7) ...[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          30),
                                                              child:
                                                                  SingleButton(
                                                                      label:
                                                                          "View details",
                                                                      height:
                                                                          40,
                                                                      textColor:
                                                                          btnTextColor,
                                                                      backgroundColor:
                                                                          whiteColor,
                                                                      onPressed:
                                                                          () {
                                                                        Get.to(
                                                                            OrderDetailsScreen(
                                                                          orderId:
                                                                              orderController.orderList[index]["id"],
                                                                        ));
                                                                      },
                                                                      borderColor:
                                                                          btnTextColor),
                                                            )
                                                          ] else ...[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          30),
                                                              child:
                                                                  SingleButton(
                                                                      label:
                                                                          "View details",
                                                                      height:
                                                                          40,
                                                                      textColor:
                                                                          btnTextColor,
                                                                      backgroundColor:
                                                                          whiteColor,
                                                                      onPressed:
                                                                          () {
                                                                        Get.to(
                                                                            OrderDetailsScreen(
                                                                          orderId:
                                                                              orderController.orderList[index]["id"],
                                                                        ));
                                                                      },
                                                                      borderColor:
                                                                          btnTextColor),
                                                            )
                                                          ],
                                                        ],
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                    ),
                    orderController.loadMore.value
                        ? const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
