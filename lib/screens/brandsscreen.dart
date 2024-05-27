// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/brand_controller.dart';
import 'package:lafetch/screens/Brands/allbrandscreen.dart';
import 'package:lafetch/screens/searchscreen.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/home_appbar.dart';
import '../utils/constants.dart';
import 'Brands/categoryproduct.dart';
import 'cartscreen.dart';
import 'catalogscreen.dart';

class BrandsScreen extends StatefulWidget {
  final String? screen;
  final String? logo;
  final String? backImage;
  final int? brandId;
  final String? name;
  const BrandsScreen(
      {super.key,
      this.screen,
      this.logo,
      this.backImage,
      this.name,
      this.brandId});

  @override
  State<BrandsScreen> createState() => BrandsScreenState();
}

class BrandsScreenState extends State<BrandsScreen> {
  final brandController = Get.put(BrandController());
  Timer? debounce;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      brandController.queryText.value = query;
      brandController.getBrandData();
    });
  }

  @override
  void initState() {
    if (widget.screen == "search") {
      brandController.showAllBrand.value = true;
      brandController.brandlogo.value = widget.logo!;
      brandController.brandbackground.value = widget.backImage!;
      brandController.brandName.value = widget.name!;
      brandController.brandId.value = widget.brandId!;
      brandController.update();
    } else {
      brandController.showAllBrand.value = false;
    }
    brandController.text.value = "Expand All";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      brandController.listController.addListener(() {
        brandController.fetchMoreData();
        brandController.update();
      });
    });
    brandController.hasnextpage.value = true;
    brandController.loadMore.value = false;
    brandController.isBrand.value = false;
    brandController.page.value = 1;
    brandController.searchController.clear();
    brandController.queryText.value = "";
    WidgetsBinding.instance
        .addPostFrameCallback((_) => brandController.getBrandData());
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => brandController.showAllBrand.value
        ? AllBrandScreen(
            title: brandController.brandName.value,
            brandbackground: brandController.brandbackground.value,
            screen: widget.screen!,
          )
        : Scaffold(
            backgroundColor: colorSecondary,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (value) {
                          print(value);
                          if (value is RawKeyDownEvent) {
                            brandController.text.value = "Expand All";
                            brandController.getBrandData();
                          }
                        },
                        child: TextField(
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            color: colorSecondary,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: brandController.searchController,
                          onChanged: onSearchChanged,
                          /*  onChanged: (value) {
                            brandController.queryText.value = value;
                            brandController.getBrandData();
                          }, */
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: brandController.listController,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {});
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, top: 20, right: 16),
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
                                        brandController.text.value =
                                            "Collapse All";
                                        brandController.selected.clear();
                                        brandController.selected =
                                            List.generate(
                                                brandController
                                                    .brandList.length,
                                                (i) => true);
                                        brandController.update();
                                      } else {
                                        brandController.text.value =
                                            "Expand All";
                                        brandController.selected.clear();
                                        brandController.selected =
                                            List.generate(
                                                brandController
                                                    .brandList.length,
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
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : brandController.brandList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          bottom: 10,
                                          top: 10),
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
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1),
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
                                                                      .brandlogo
                                                                      .value = value
                                                                              .brandList[
                                                                          index]
                                                                      ["logo"];
                                                                  brandController
                                                                      .brandbackground
                                                                      .value = value
                                                                              .brandList[index]
                                                                          [
                                                                          "background_image"] ??
                                                                      "";
                                                                  brandController
                                                                      .brandName
                                                                      .value = value
                                                                              .brandList[
                                                                          index]
                                                                      ["name"];
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
                                                                  padding: const EdgeInsets
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
                                                                      value.brandList[index]["logo"] !=
                                                                              null
                                                                          ? FadeInImage(
                                                                              fit: BoxFit
                                                                                  .cover,
                                                                              height:
                                                                                  32,
                                                                              width:
                                                                                  32,
                                                                              image: NetworkImage(value.brandList[index][
                                                                                  "logo"]),
                                                                              placeholder: const AssetImage(
                                                                                  dummyWishlistImage))
                                                                          : Image.asset(
                                                                              dummyWishlistImage,
                                                                              height: 32,
                                                                              width: 32,
                                                                              fit: BoxFit.cover),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 10),
                                                                        child:
                                                                            AppText(
                                                                          text: value.brandList[index]["name"] ??
                                                                              "",
                                                                          color:
                                                                              colorPrimary,
                                                                          fontSize:
                                                                              14.sp,
                                                                          fontFamily:
                                                                              "Franklin Gothic Regular",
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                      const Expanded(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              0,
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          value.selected[index] =
                                                                              !value.selected[index];
                                                                          value
                                                                              .update();
                                                                        },
                                                                        child: Image.asset(
                                                                            upArrowIcon,
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                20,
                                                                            fit:
                                                                                BoxFit.cover),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              value.selected[
                                                                      index]
                                                                  ? value
                                                                          .brandList[
                                                                              index]
                                                                              [
                                                                              "categories"]
                                                                          .isNotEmpty
                                                                      ? Column(
                                                                          children: [
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 16, right: 16),
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
                                                                                  value.brandList[index]["categories"].length,
                                                                                  (i) {
                                                                                    return GestureDetector(
                                                                                      onTap: () {
                                                                                        Get.to(CategoryProductScreen(
                                                                                          categoryId: value.brandList[index]["categories"][i]["id"],
                                                                                          brandId: value.brandList[index]["id"],
                                                                                          tagIds: const [],
                                                                                        ));
                                                                                      },
                                                                                      child: Container(
                                                                                        alignment: Alignment.center,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            value.brandList[index]["categories"][i]["thumbnail"] != null ? FadeInImage(fit: BoxFit.cover, height: 70, width: 90, image: NetworkImage(value.brandList[index]["categories"][i]["thumbnail"]), placeholder: const AssetImage(dummyWishlistImage)) : Image.asset(dummyWishlistImage, height: 70, width: 90, fit: BoxFit.cover),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                                              child: Center(
                                                                                                child: AppText(
                                                                                                  textAlign: TextAlign.center,
                                                                                                  text: value.brandList[index]["categories"][i]["name"] ?? "",
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
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text("No Category Found", style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: "Franklin Gothic Regular")),
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
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox(
                                  height: 0,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
  }
}
