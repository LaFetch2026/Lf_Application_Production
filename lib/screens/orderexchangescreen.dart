// ignore_for_file: avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/doubleiconbtn.dart';
import 'package:lafetch/commonwidget/singleiconbtn.dart';
import 'package:lafetch/screens/orderdetailsscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../commonwidget/singlebtn.dart';
import '../utils/constants.dart';

class OrderExchangeScreen extends StatefulWidget {
  const OrderExchangeScreen({super.key});

  @override
  State<OrderExchangeScreen> createState() => OrderExchangeScreenState();
}

class OrderExchangeScreenState extends State<OrderExchangeScreen> {
  String? filter;
  List<int> genderId = [1, 2, 3];
  int genderPos = 0;
  final List<String> filterList = [
    'Fil1',
    'Fil2',
    'Fil3',
  ];
  List<String> items = [
    "Delivered",
    "Shipped",
    "Order Confirmed",
    "Cancelled",
  ];

  Color containerColor(String text) {
    if (text == "Delivered") {
      return lightGreen;
    } else if (text == "Order Confirmed") {
      return lightPurple;
    } else if (text == "Shipped") {
      return lightYellow;
    } else {
      return lightback;
    }
  }

  Color selectedColor(String text) {
    if (text == "Delivered") {
      return deepGreen;
    } else if (text == "Order Confirmed") {
      return deepPurple;
    } else if (text == "Shipped") {
      return deeptYellow;
    } else {
      return deepRed;
    }
  }

  String selectedIcon(String text) {
    if (text == "Delivered") {
      return checkImage;
    } else if (text == "Order Confirmed") {
      return confirmOrderImage;
    } else if (text == "Shipped") {
      return shippedImage;
    } else {
      return cancelImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Orders & Exchanges",
            threeDot: false,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Container(
                            height: 40,
                            width: 180,
                            decoration: BoxDecoration(
                                color: whiteBorderColor,
                                borderRadius: BorderRadius.circular(1),
                                border:
                                    Border.all(color: borderColor, width: 1)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const ImageIcon(
                                    AssetImage(searchImage),
                                    color: textHintColor,
                                    size: 14,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
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
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 120,
                          child: DropdownButtonFormField2(
                            value: filter,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: whiteTextColor,
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                                borderSide:
                                    const BorderSide(color: borderColor),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.only(left: 16),
                              hintText: 'Filter',
                              hintStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Franklin Gothic Regular"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            isExpanded: true,
                            items: filterList
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: textColor,
                                          fontFamily: "Franklin Gothic Regular",
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
                              genderPos = filterList.indexOf(filter.toString());
                              print(genderId[genderPos]);
                              setState(() {});
                            },
                            onSaved: (value) {},
                            buttonStyleData: const ButtonStyleData(
                              height: 60,
                              padding: EdgeInsets.only(right: 10),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: ImageIcon(AssetImage(dropdownImage)),
                              iconSize: 30,
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: items.length,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (ctx, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(const OrderDetailsScreen());
                                  },
                                  child: Container(
                                    color: whiteColor,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Image.asset(backImage,
                                                      height: 85,
                                                      width: 70,
                                                      fit: BoxFit.cover),
                                                ),
                                                Expanded(
                                                  flex: 3,
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
                                                          horizontal: 5,
                                                        ),
                                                        child: AppText(
                                                          text:
                                                              "Topman super skinny suit jacket and trousers in light blue",
                                                          maxLines: 1,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14.sp,
                                                          color: nameText,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        child: AppText(
                                                          text:
                                                              "Jack & Jones Core",
                                                          color: greyTextColor,
                                                          maxLines: 2,
                                                          fontSize: 12.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        child: Row(
                                                          children: [
                                                            AppText(
                                                              text: "Size :M",
                                                              color:
                                                                  greyTextColor,
                                                              maxLines: 2,
                                                              fontSize: 12.sp,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                child: AppText(
                                                                  text:
                                                                      "Qty :1",
                                                                  color:
                                                                      greyTextColor,
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
                                                            ),
                                                            AppText(
                                                              text:
                                                                  "\u{20B9} ${120.00}",
                                                              color:
                                                                  greyTextColor,
                                                              fontSize: 12.sp,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              fontFamily:
                                                                  "Franklin Gothic Regular",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 5),
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: containerColor(
                                                          items[index]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                          color: textHintColor,
                                                          width: 1),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: ImageIcon(
                                                              AssetImage(
                                                                  selectedIcon(
                                                                      items[
                                                                          index])),
                                                              color:
                                                                  selectedColor(
                                                                      items[
                                                                          index]),
                                                              size: 14,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5,
                                                                    right: 2),
                                                            child: AppText(
                                                              text:
                                                                  items[index],
                                                              color:
                                                                  selectedColor(
                                                                      items[
                                                                          index]),
                                                              fontSize: 12.sp,
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    child: SizedBox(
                                                      width: 0,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        child: AppText(
                                                          text: "Delivered on",
                                                          color: greyTextColor,
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
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        child: AppText(
                                                          text:
                                                              "Jul 24, at 3:30 PM",
                                                          color: greyTextColor,
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            DoubleIconButton(
                                                firstText: "Exchange Item",
                                                secondText: "Rate Order",
                                                firstTextColor: btnTextColor,
                                                secondTextColor: btnTextColor,
                                                firstBackgroundColor:
                                                    whiteTextColor,
                                                secondBackgroundColor:
                                                    whiteTextColor,
                                                firstBorderColor: btnTextColor,
                                                secondBorderColor: btnTextColor,
                                                firstIcon: exchangeItemImage,
                                                onPressedFirst: () {},
                                                onPressedSecond: () {},
                                                secondIcon: rateOrderImage),
                                            /*  SingleIconButton(
                                                label: "Track Order",
                                                textColor: btnTextColor,
                                                backgroundColor: whiteTextColor,
                                                onPressed: () {},
                                                borderColor: btnTextColor,
                                                icon: locationIcon) */
                                          ]),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleButton(
                label: "View details",
                textColor: btnTextColor,
                backgroundColor: whiteTextColor,
                onPressed: () {},
                borderColor: btnTextColor),
          )
        ],
      ),
    );
  }
}
