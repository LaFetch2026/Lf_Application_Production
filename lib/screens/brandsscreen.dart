// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/brand_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../utils/constants.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {
  final brandController = Get.put(BrandController());

  @override
  void initState() {
    brandController.showAllBrand.value = false;
    brandController.searchController.clear();
    brandController.queryText.value = "";
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => brandController.showAllBrand.value
        ? AllBrandScreen(title: brandController.brandName.value)
        : Scaffold(
            backgroundColor: colorSecondary,
            body: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeAppbar(
                      onPressedSearch: () {
                        Get.to(const SearchScreen());
                      },
                      onPressedCatalog: () {
                        Get.to(const CatalogScreen());
                      },
                      onPressedCart: () {
                        Get.to(const CartScreen());
                      },
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: colorPrimary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Container(
                          color: loginText,
                          height: 50,
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              color: colorSecondary,
                              fontFamily: "Franklin Gothic Regular",
                            ),
                            controller: brandController.searchController,
                            onChanged: (value) {
                              brandController.queryText.value = value;
                              brandController.getBrandData();
                            },
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: loginText,
                              prefixIcon: const Icon(Icons.search,
                                  size: 20, color: colorSecondary),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                                borderSide:
                                    const BorderSide(color: colorSecondary),
                              ),
                              counterText: "",
                              hintText: "Search for brands & products",
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: colorSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 20, right: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Brand Style Catalog",
                            color: colorPrimary,
                            fontSize: 22.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                          const Expanded(
                            child: SizedBox(
                              width: 0,
                            ),
                          ),
                          Obx(
                            () => GestureDetector(
                              onTap: () {
                                if (brandController.text.value ==
                                    "Expand All") {
                                  brandController.text.value = "Collapse All";
                                  brandController.selected.clear();
                                  brandController.selected = List.generate(
                                      brandController.brandList.length,
                                      (i) => true);
                                  brandController.update();
                                } else {
                                  brandController.text.value = "Expand All";
                                  brandController.selected.clear();
                                  brandController.selected = List.generate(
                                      brandController.brandList.length,
                                      (i) => false);
                                  brandController.update();
                                }
                              },
                              child: AppText(
                                text: brandController.text.value,
                                color: blackColor,
                                fontSize: 12.sp,
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    brandController.isBrand.value
                        ? const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : brandController.brandList.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 10, top: 10),
                                child: GetBuilder<BrandController>(
                                  builder: (value) => ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      controller: value.listController,
                                      physics: const ScrollPhysics(),
                                      itemCount: value.brandList.length,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (ctx, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                                onTap: () {},
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(1),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: value.selected[
                                                                    index]
                                                                ? greyTextColor
                                                                : whiteBorderColor),
                                                        color:
                                                            whiteBorderColor),
                                                    child: Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            brandController
                                                                .showAllBrand
                                                                .value = true;
                                                            brandController
                                                                .brandId
                                                                .value = value
                                                                    .brandList[
                                                                index]["id"];
                                                            brandController
                                                                .update();
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                /* FadeInImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: 32,
                                                                    width: 32,
                                                                    image: NetworkImage(
                                                                        value.brandList[
                                                                                index]
                                                                            [
                                                                            "logo"]),
                                                                    placeholder:
                                                                        const AssetImage(
                                                                            chanelLogoImage)), */
                                                                Image.asset(
                                                                    chanelLogoImage,
                                                                    height: 32,
                                                                    width: 32,
                                                                    fit: BoxFit
                                                                        .cover),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10),
                                                                  child:
                                                                      AppText(
                                                                    text: value.brandList[index]
                                                                            [
                                                                            "name"] ??
                                                                        "",
                                                                    color:
                                                                        colorPrimary,
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 0,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    value.selected[
                                                                        index] = !value
                                                                            .selected[
                                                                        index];
                                                                    /*  value
                                                                        .categoryList
                                                                        .clear(); */
                                                                    if (index ==
                                                                        2) {
                                                                      value.getCategoryData(
                                                                          1);
                                                                    } else {
                                                                      value.getCategoryData(
                                                                          value.brandList[index]
                                                                              [
                                                                              "id"]);
                                                                    }

                                                                    value
                                                                        .update();
                                                                  },
                                                                  child: Image.asset(
                                                                      upArrowIcon,
                                                                      height:
                                                                          20,
                                                                      width: 20,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        value.selected[index]
                                                            ? value.isCategory
                                                                    .value
                                                                ? const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            40.0),
                                                                    child: Center(
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                  )
                                                                : value.categoryList
                                                                        .isNotEmpty
                                                                    ? Column(
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 16, right: 16),
                                                                            child:
                                                                                /*   GetBuilder<BrandController>(
                                                                              builder: (val) => */
                                                                                GridView.count(
                                                                              shrinkWrap: true,
                                                                              crossAxisCount: 3,
                                                                              scrollDirection: Axis.vertical,
                                                                              padding: EdgeInsets.zero,
                                                                              childAspectRatio: 0.8,
                                                                              physics: const ScrollPhysics(),
                                                                              crossAxisSpacing: 1,
                                                                              mainAxisSpacing: 0,
                                                                              children: List.generate(
                                                                                value.categoryList.length,
                                                                                (i) {
                                                                                  return GestureDetector(
                                                                                    onTap: () {},
                                                                                    child: Container(
                                                                                      alignment: Alignment.center,
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Image.asset(backImage, height: 70, width: 90, fit: BoxFit.cover),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                                            child: Center(
                                                                                              child: AppText(
                                                                                                textAlign: TextAlign.center,
                                                                                                text: value.categoryList[i]["name"] ?? "",
                                                                                                color: greyTextColor,
                                                                                                fontSize: 10.sp,
                                                                                                maxLines: 2,
                                                                                                fontFamily: "Franklin Gothic Regular",
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          //  ),
                                                                        ],
                                                                      )
                                                                    : const SizedBox(
                                                                        height:
                                                                            50,
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            Center(
                                                                          child: Text(
                                                                              "No Category Found",
                                                                              style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: "Franklin Gothic Regular")),
                                                                        ),
                                                                      )
                                                            : const SizedBox(
                                                                height: 0,
                                                              )
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        );
                                      }),
                                ),
                              )
                            : const SizedBox(
                                height: 400,
                                width: double.infinity,
                                child: Center(
                                  child: Text("No Brand Found",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily:
                                              "Franklin Gothic Regular")),
                                ),
                              ),
                    brandController.loadMore.value
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
          ));
  }
}
