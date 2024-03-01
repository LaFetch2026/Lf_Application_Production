// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool isSearch = false;
  List<String> products = [
    "Salwar Suits",
    "Printed loose t-shirts",
    "Clothing",
    "Duffle bags",
    "Tuxedos"
  ];
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "100",
    "200",
    "300",
    "400",
  ];
  List<String> searchItem = [
    "100",
    "200",
    "300",
    "400",
    "500",
    "400",
    "500",
  ];

  List<String> images = [
    image,
    backImage,
    otpImage,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSearch = false;
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: colorPrimary,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 40, bottom: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: ImageIcon(
                              AssetImage(backWhiteArrow),
                              color: whiteBorderColor,
                              size: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (isSearch) {
                                isSearch = false;
                              } else {
                                isSearch = true;
                              }
                              setState(() {});
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: whiteBorderColor,
                                  borderRadius: BorderRadius.circular(1),
                                  border: Border.all(
                                      color: colorSecondary, width: 1)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
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
                                        text: "Search for brands & products",
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
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 16),
                          child: AppText(
                            text: "Recent Searches",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: bottomnavBack,
                            fontSize: 18.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: ScrollController(),
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 5.0,
                              runSpacing: 9.0,
                              runAlignment: WrapAlignment.spaceEvenly,
                              children: [
                                for (var product in products)
                                  Container(
                                    height: 33,
                                    margin: const EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                        color: whiteTextColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: btnTextColor, width: 1)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 7),
                                      child: Text(
                                        product,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 12.sp,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, left: 16),
                          child: AppText(
                            text: "Most Searched",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: bottomnavBack,
                            fontSize: 16.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 20, right: 16, bottom: 10),
                          child: Center(
                            child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.zero,
                              childAspectRatio: 0.7,
                              physics: const ScrollPhysics(),
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1,
                              children: List.generate(
                                items.length,
                                (index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: SizedBox(
                                          height: 100,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Image.asset(backImage,
                                                    width: 80,
                                                    height: 72,
                                                    fit: BoxFit.cover),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: "Sneakers${index + 1}",
                                                  color: greyTextColor,
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: AppText(
                            text: "Continue Browsing these Brands",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: bottomnavBack,
                            fontSize: 16.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 230,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const BouncingScrollPhysics(),
                                itemCount: items.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 130,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(backImage,
                                                  height: 180,
                                                  width: 130,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: "Balenciaga",
                                                  color: greyTextColor,
                                                  fontSize: 14.sp,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3),
                                                child: AppText(
                                                  text: "Bags",
                                                  color: greyTextColor,
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 16),
                          child: AppText(
                            text: "Items you have viewed",
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                            color: bottomnavBack,
                            fontSize: 16.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 250,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const BouncingScrollPhysics(),
                                itemCount: items.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 122,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(backImage,
                                                  height: 150,
                                                  width: 122,
                                                  fit: BoxFit.cover),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text:
                                                      "Topman super skinny suit jacket and trousers in light blue",
                                                  color: nameText,
                                                  maxLines: 2,
                                                  fontSize: 11.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    left: 10,
                                                    right: 10),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text:
                                                          "\u{20B9} ${items[index]}",
                                                      color: deepGreytextColor,
                                                      maxLines: 2,
                                                      fontSize: 11.sp,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        "\u{20B9} ${items[index]}",
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearch
                ? Container(
                    color: whiteColor,
                    height: 290,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 30, left: 16, right: 16, bottom: 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: const ImageIcon(
                                  AssetImage(backWhiteArrow),
                                  color: colorPrimary,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: const TextStyle(
                                        color: textColor,
                                        fontFamily: "Franklin Gothic Regular",
                                      ),
                                      controller: searchController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: whiteColor,
                                        suffixIcon: Image.asset(
                                          greyCrossImage,
                                          height: 18,
                                          width: 18,
                                        ),
                                        prefixIcon: const Icon(Icons.search,
                                            size: 20, color: Colors.grey),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: borderColor)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          borderSide: const BorderSide(
                                              color: borderColor),
                                        ),
                                        counterText: "",
                                        hintText: "Search",
                                        hintStyle:
                                            const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, top: 8),
                            child: SizedBox(
                              height: 187,
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: searchItem.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.search,
                                              size: 20, color: Colors.grey),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: AppText(
                                                text: "T-shirts Men",
                                                maxLines: 1,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                                color: nameText,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: AppText(
                                              text: "41",
                                              maxLines: 1,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14.sp,
                                              color: greyTextColor,
                                            ),
                                          ),
                                          Image.asset(curveArrowImage,
                                              height: 12,
                                              width: 12,
                                              fit: BoxFit.cover),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}
