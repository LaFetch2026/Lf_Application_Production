import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/catalogwidgets/filterbutton.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/product_controller.dart';
import '../../utils/constants.dart';

class BottomFilters extends StatefulWidget {
  final Function(int, int) onClick;
  final Function btnclearAll;
  final int containerHeight;
  final int listHeight;
  final Color backgroundColor;
  const BottomFilters({
    required this.onClick,
    required this.btnclearAll,
    this.backgroundColor = whiteColor,
    this.containerHeight = 396,
    this.listHeight = 350,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomFilters> createState() => BottomFiltersState();
}

class BottomFiltersState extends State<BottomFilters> {
  final productController = Get.put(ProductController());
  List<String> brands = [
    "Brand",
    "Price Range",
    "Size",
    "Color",
    /*"Material",
    "Style",
    "Ocassion",
    "Features",*/
  ];
  List<bool> selected = List.generate(50, (i) => false);
  List<bool> brandSelected = List.generate(50, (i) => false);
  List<bool> colorSelected = List.generate(50, (i) => false);
  List<bool> sizeSelected = List.generate(50, (i) => false);
  String type = "brands";
  bool isPriceLoading = true;
  bool brandSelectAll = false;
  bool colorSelectAll = false;
  bool sizeSelectAll = false;
  String lowerValue = "500";
  String UpperValue = "500000";
  RangeValues values = RangeValues(500, 500000);

  @override
  void initState() {
    getPrefrenceValue();
    selected[0] = !selected[0];
    productController.isPrice.value = false;
    /*  productController.size_ids.clear();
    productController.color_ids.clear();
    productController.brand_ids.clear(); */
    productController.filterList.clear();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => productController.getFilterData("brands"));
    setState(() {});
    super.initState();
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('brandList') != null) {
      brandSelected.clear();
      brandSelected =
          // ignore: sdk_version_since
          prefs.getStringList('brandList')!.map((i) => bool.parse(i)).toList();
      brandSelectAll =
          brandSelected.length == productController.brand_ids.length
              ? true
              : false;
    }
    if (prefs.getStringList('colorList') != null) {
      colorSelected.clear();
      colorSelected =
          // ignore: sdk_version_since
          prefs.getStringList('colorList')!.map((i) => bool.parse(i)).toList();
    }
    if (prefs.getStringList('sizeList') != null) {
      sizeSelected.clear();
      sizeSelected =
          // ignore: sdk_version_since
          prefs.getStringList('sizeList')!.map((i) => bool.parse(i)).toList();
    }
    if (prefs.getString('upper') != null) {
      UpperValue = prefs.getString('upper')!;
    }
    if (prefs.getString('lower') != null) {
      lowerValue = prefs.getString('lower')!;
    }
    if (prefs.getString('lower') != null && prefs.getString('upper') != null) {
      values = RangeValues(double.parse(lowerValue), double.parse(UpperValue));
    }
    isPriceLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    RangeLabels labels =
        RangeLabels(values.start.toString(), values.end.toString());
    return Container(
      height: 500.sp,
      constraints: BoxConstraints.expand(),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: widget.backgroundColor == whiteColor
                      ? Color(0xFFF9FAFB)
                      : lightPurpleColor,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 16.sp, right: 16.sp, top: 10.sp),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
                          child: Text(
                            "Filters".toUpperCase(),
                            style: TextStyle(
                              color: widget.backgroundColor == whiteColor
                                  ? blackColor
                                  : whiteColor,
                              fontSize: 16.sp,
                              decoration: TextDecoration.none,
                              fontFamily: "Franklin Gothic Semibold",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: SizedBox(
                            width: 0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            brandSelected = List.generate(50, (i) => false);
                            sizeSelected = List.generate(50, (i) => false);
                            colorSelected = List.generate(50, (i) => false);
                            brandSelectAll = false;
                            colorSelectAll = false;
                            sizeSelectAll = false;
                            lowerValue = "500";
                            UpperValue = "500000";
                            values = RangeValues(500, 500000);
                            setState(() {});
                            widget.btnclearAll.call();
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 20.sp,
                                  left: 20.sp,
                                  top: 15.sp,
                                  bottom: 15.sp),
                              child: Text(
                                "Clear All".toUpperCase(),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: widget.backgroundColor == whiteColor
                                      ? subtitleColor
                                      : whiteColor,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      color: widget.backgroundColor == whiteColor
                          ? Color(0xFFF3F4F6)
                          : cardBg,
                      width: 150.sp,
                      height: widget.containerHeight.sp,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.sp),
                        child: SizedBox(
                          height: 150.sp,
                          child: ListView.builder(
                              physics: const ScrollPhysics(),
                              itemCount: brands.length,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          selected.clear();
                                          selected =
                                              List.generate(50, (i) => false);
                                          selected[index] = !selected[index];
                                          if (index == 0) {
                                            productController
                                                .getFilterData("brands");
                                            type = "brands";
                                            productController.isPrice.value =
                                                false;
                                            brandSelectAll =
                                                brandSelected.length ==
                                                        productController
                                                            .brand_ids.length
                                                    ? true
                                                    : false;
                                          } else if (index == 3) {
                                            productController
                                                .getFilterData("color");
                                            type = "color";
                                            productController.isPrice.value =
                                                false;
                                            colorSelectAll =
                                                colorSelected.length ==
                                                        productController
                                                            .color_ids.length
                                                    ? true
                                                    : false;
                                          } else if (index == 1) {
                                            productController.filterList
                                                .clear();
                                            type = "";
                                            productController.isPrice.value =
                                                true;
                                          } else {
                                            productController
                                                .getFilterData("size");
                                            type = "size";
                                            productController.isPrice.value =
                                                false;
                                            sizeSelectAll =
                                                sizeSelected.length ==
                                                        productController
                                                            .size_ids.length
                                                    ? true
                                                    : false;
                                          }
                                          setState(() {});
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: selected[index]
                                              ? widget.backgroundColor ==
                                                      whiteColor
                                                  ? whiteColor
                                                  : homeAppBarColor
                                              : widget.backgroundColor ==
                                                      whiteColor
                                                  ? Color(0xFFF3F4F6)
                                                  : cardBg,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.sp),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16.sp,
                                                  top: 2.sp,
                                                  bottom: 2.sp),
                                              child: Text(
                                                brands[index],
                                                style: TextStyle(
                                                  color: selected[index]
                                                      ? widget.backgroundColor ==
                                                              whiteColor
                                                          ? homeAppBarColor
                                                          : dividerColor
                                                      : widget.backgroundColor ==
                                                              whiteColor
                                                          ? appBarColor
                                                          : dividerColor,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 14.sp,
                                                  fontFamily: selected[index]
                                                      ? "Franklin Gothic Semibold"
                                                      : "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ),
                    Container(
                      color: widget.backgroundColor == whiteColor
                          ? whiteColor
                          : homeAppBarColor,
                      width: MediaQuery.of(context).size.width - 150.sp,
                      height: widget.containerHeight.sp,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 8.sp),
                        child: Obx(
                          () => productController.isPrice.value
                              ? isPriceLoading
                                  ? SizedBox(
                                      height: 20.sp,
                                      width: 20.sp,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      child: SizedBox(
                                        height: widget.listHeight.sp,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.sp),
                                              child: Text(
                                                "Selected Price Range",
                                                style: TextStyle(
                                                  color:
                                                      widget.backgroundColor ==
                                                              whiteColor
                                                          ? textColor
                                                          : dividerColor,
                                                  fontSize: 14.sp,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.sp),
                                              child: SizedBox(
                                                width: double.maxFinite,
                                                child: Material(
                                                  color:
                                                      widget.backgroundColor ==
                                                              whiteColor
                                                          ? whiteColor
                                                          : homeAppBarColor,
                                                  child: RangeSlider(
                                                    values: values,
                                                    min: 500,
                                                    max: 500000,
                                                    // divisions: 5,
                                                    inactiveColor: Colors.grey,
                                                    activeColor:
                                                        widget.backgroundColor ==
                                                                whiteColor
                                                            ? btnTextColor
                                                            : lightPurpleColor,
                                                    labels: labels,
                                                    onChanged: (newValue) {
                                                      productController
                                                          .pricelist
                                                          .clear();
                                                      values = newValue;
                                                      var l = newValue.start
                                                          .toString()
                                                          .split('.');
                                                      var u = newValue.end
                                                          .toString()
                                                          .split('.');
                                                      lowerValue = l[0];
                                                      UpperValue = u[0];
                                                      productController
                                                          .pricelist = [
                                                        lowerValue,
                                                        UpperValue
                                                      ];
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.sp),
                                                  child: Text(
                                                    "\u{20B9} ${lowerValue} - \u{20B9} ${UpperValue}",
                                                    style: TextStyle(
                                                      color:
                                                          widget.backgroundColor ==
                                                                  whiteColor
                                                              ? textColor
                                                              : dividerColor,
                                                      fontSize: 14.sp,
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontFamily:
                                                          "Franklin Gothic",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                              : productController.isFilter.value
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.sp),
                                      child: SizedBox(
                                        height: widget.listHeight.sp,
                                        child: ListView.builder(
                                            physics: const ScrollPhysics(),
                                            itemCount: 8,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, index) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.sp),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.sp),
                                                            child:
                                                                DummyContainer(
                                                                    height: 14,
                                                                    width: 14)),
                                                        DummyContainer(
                                                            height: 16,
                                                            width: 80)
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.sp),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.sp),
                                                  child: Row(
                                                    children: [
                                                      if (type == "brands") ...[
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Material(
                                                            color:
                                                                widget.backgroundColor ==
                                                                        whiteColor
                                                                    ? whiteColor
                                                                    : cardBg,
                                                            child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: widget
                                                                              .backgroundColor ==
                                                                          whiteColor
                                                                      ? whiteColor
                                                                      : cardBg,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                  border:
                                                                      Border(
                                                                    top: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    left: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    right: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    bottom: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                  ),
                                                                ),
                                                                width: 20,
                                                                height: 20,
                                                                child: Checkbox(
                                                                  value:
                                                                      brandSelectAll,
                                                                  checkColor: brandSelectAll
                                                                      ? whiteColor
                                                                      : titleColor,
                                                                  activeColor:
                                                                      brandSelectAll
                                                                          ? titleColor
                                                                          : whiteColor,
                                                                  side: const BorderSide(
                                                                      color:
                                                                          titleColor,
                                                                      width: 0),
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      brandSelectAll =
                                                                          !brandSelectAll;
                                                                    });
                                                                    if (brandSelectAll ==
                                                                        true) {
                                                                      for (int i =
                                                                              0;
                                                                          i < productController.filterList.length;
                                                                          i++) {
                                                                        productController
                                                                            .brand_ids
                                                                            .add(productController.filterList[i]["id"]);
                                                                      }
                                                                      brandSelected = List.generate(
                                                                          productController
                                                                              .filterList
                                                                              .length,
                                                                          (i) =>
                                                                              true);
                                                                    } else {
                                                                      brandSelected = List.generate(
                                                                          productController
                                                                              .filterList
                                                                              .length,
                                                                          (i) =>
                                                                              false);
                                                                      productController
                                                                          .brand_ids
                                                                          .clear();
                                                                    }
                                                                    print(productController
                                                                        .brand_ids);
                                                                  },
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                      if (type == "color") ...[
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5.sp),
                                                          child: Material(
                                                            color:
                                                                widget.backgroundColor ==
                                                                        whiteColor
                                                                    ? whiteColor
                                                                    : cardBg,
                                                            child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: widget
                                                                              .backgroundColor ==
                                                                          whiteColor
                                                                      ? whiteColor
                                                                      : cardBg,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                  border:
                                                                      Border(
                                                                    top: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    left: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    right: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    bottom: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                  ),
                                                                ),
                                                                width: 20,
                                                                height: 20,
                                                                child: Checkbox(
                                                                  value:
                                                                      colorSelectAll,
                                                                  checkColor: colorSelectAll
                                                                      ? whiteColor
                                                                      : titleColor,
                                                                  activeColor:
                                                                      colorSelectAll
                                                                          ? titleColor
                                                                          : whiteColor,
                                                                  side: const BorderSide(
                                                                      color:
                                                                          btnTextColor,
                                                                      width: 0),
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      colorSelectAll =
                                                                          !colorSelectAll;
                                                                    });
                                                                    if (colorSelectAll ==
                                                                        true) {
                                                                      for (int i =
                                                                              0;
                                                                          i < productController.filterList.length;
                                                                          i++) {
                                                                        productController
                                                                            .color_ids
                                                                            .add(productController.filterList[i]["id"]);
                                                                      }
                                                                      colorSelected = List.generate(
                                                                          productController
                                                                              .filterList
                                                                              .length,
                                                                          (i) =>
                                                                              true);
                                                                    } else {
                                                                      colorSelected = List.generate(
                                                                          productController
                                                                              .filterList
                                                                              .length,
                                                                          (i) =>
                                                                              false);
                                                                      productController
                                                                          .color_ids
                                                                          .clear();
                                                                    }
                                                                    print(productController
                                                                        .color_ids);
                                                                  },
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                      if (type == "size") ...[
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5.sp),
                                                          child: Material(
                                                            color:
                                                                widget.backgroundColor ==
                                                                        whiteColor
                                                                    ? whiteColor
                                                                    : cardBg,
                                                            child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: widget
                                                                              .backgroundColor ==
                                                                          whiteColor
                                                                      ? whiteColor
                                                                      : cardBg,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                  border:
                                                                      Border(
                                                                    top: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    left: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    right: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                    bottom: BorderSide(
                                                                        width: 2.0
                                                                            .sp,
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : cardBg),
                                                                  ),
                                                                ),
                                                                width: 20,
                                                                height: 20,
                                                                child: Checkbox(
                                                                  value:
                                                                      sizeSelectAll,
                                                                  checkColor: sizeSelectAll
                                                                      ? whiteColor
                                                                      : titleColor,
                                                                  activeColor:
                                                                      sizeSelectAll
                                                                          ? titleColor
                                                                          : whiteColor,
                                                                  side: const BorderSide(
                                                                      color:
                                                                          btnTextColor,
                                                                      width: 0),
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      sizeSelectAll =
                                                                          !sizeSelectAll;
                                                                    });
                                                                    if (sizeSelectAll ==
                                                                        true) {
                                                                      sizeSelected = List.generate(
                                                                          productController
                                                                              .filterList
                                                                              .length,
                                                                          (i) =>
                                                                              true);
                                                                      for (int i =
                                                                              0;
                                                                          i < productController.filterList.length;
                                                                          i++) {
                                                                        productController
                                                                            .size_ids
                                                                            .add(productController.filterList[i]["id"]);
                                                                      }
                                                                    } else {
                                                                      sizeSelected = List.generate(
                                                                          productController
                                                                              .filterList
                                                                              .length,
                                                                          (i) =>
                                                                              false);
                                                                      productController
                                                                          .size_ids
                                                                          .clear();
                                                                    }
                                                                    print(productController
                                                                        .size_ids);
                                                                  },
                                                                )),
                                                          ),
                                                        ),
                                                      ],
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 2.sp),
                                                        child: Text(
                                                          "Select All",
                                                          style: TextStyle(
                                                            color: widget
                                                                        .backgroundColor ==
                                                                    whiteColor
                                                                ? titleColor
                                                                : dividerColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            fontSize: 12.sp,
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
                                                SizedBox(
                                                  height: 320.sp,
                                                  child: ListView.builder(
                                                      physics:
                                                          const ScrollPhysics(),
                                                      itemCount:
                                                          productController
                                                              .filterList
                                                              .length,
                                                      padding: EdgeInsets.zero,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        return Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.sp),
                                                              child: Row(
                                                                children: [
                                                                  if (type ==
                                                                      "brands") ...[
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              5),
                                                                      child:
                                                                          Material(
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? whiteColor
                                                                            : cardBg,
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              color: widget.backgroundColor == whiteColor ? whiteColor : cardBg,
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: Border(
                                                                                top: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                left: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                right: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                bottom: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                              ),
                                                                            ),
                                                                            width: 20,
                                                                            height: 20,
                                                                            child: Checkbox(
                                                                              value: brandSelected[index],
                                                                              checkColor: brandSelected[index] ? whiteColor : titleColor,
                                                                              activeColor: brandSelected[index] ? titleColor : whiteColor,
                                                                              side: const BorderSide(color: titleColor, width: 0),
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  brandSelected[index] = !brandSelected[index];
                                                                                });
                                                                                if (brandSelected[index] == true) {
                                                                                  productController.brand_ids.add(productController.filterList[index]["id"]);
                                                                                } else {
                                                                                  productController.brand_ids.removeWhere((item) => item == productController.filterList[index]["id"]);
                                                                                }
                                                                                print(productController.brand_ids);
                                                                              },
                                                                            )),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  if (type ==
                                                                      "color") ...[
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              5.sp),
                                                                      child:
                                                                          Material(
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? whiteColor
                                                                            : cardBg,
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              color: widget.backgroundColor == whiteColor ? whiteColor : cardBg,
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: Border(
                                                                                top: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                left: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                right: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                bottom: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                              ),
                                                                            ),
                                                                            width: 20,
                                                                            height: 20,
                                                                            child: Checkbox(
                                                                              value: colorSelected[index],
                                                                              checkColor: colorSelected[index] ? whiteColor : titleColor,
                                                                              activeColor: colorSelected[index] ? titleColor : whiteColor,
                                                                              side: const BorderSide(color: btnTextColor, width: 0),
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  colorSelected[index] = !colorSelected[index];
                                                                                });
                                                                                if (colorSelected[index] == true) {
                                                                                  productController.color_ids.add(productController.filterList[index]["id"]);
                                                                                } else {
                                                                                  productController.color_ids.removeWhere((item) => item == productController.filterList[index]["id"]);
                                                                                }
                                                                                print(productController.color_ids);
                                                                              },
                                                                            )),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  if (type ==
                                                                      "size") ...[
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              5.sp),
                                                                      child:
                                                                          Material(
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? whiteColor
                                                                            : cardBg,
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              color: widget.backgroundColor == whiteColor ? whiteColor : cardBg,
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: Border(
                                                                                top: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                left: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                right: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                                bottom: BorderSide(width: 2.0.sp, color: widget.backgroundColor == whiteColor ? titleColor : cardBg),
                                                                              ),
                                                                            ),
                                                                            width: 20,
                                                                            height: 20,
                                                                            child: Checkbox(
                                                                              value: sizeSelected[index],
                                                                              checkColor: sizeSelected[index] ? whiteColor : titleColor,
                                                                              activeColor: sizeSelected[index] ? titleColor : whiteColor,
                                                                              side: const BorderSide(color: btnTextColor, width: 0),
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  sizeSelected[index] = !sizeSelected[index];
                                                                                });
                                                                                if (sizeSelected[index] == true) {
                                                                                  productController.size_ids.add(productController.filterList[index]["id"]);
                                                                                } else {
                                                                                  productController.size_ids.removeWhere((item) => item == productController.filterList[index]["id"]);
                                                                                }
                                                                                print(productController.size_ids);
                                                                              },
                                                                            )),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 2
                                                                            .sp),
                                                                    child: Text(
                                                                      productController
                                                                              .filterList[index]
                                                                          [
                                                                          "name"],
                                                                      style:
                                                                          TextStyle(
                                                                        color: widget.backgroundColor ==
                                                                                whiteColor
                                                                            ? titleColor
                                                                            : dividerColor,
                                                                        decoration:
                                                                            TextDecoration.none,
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
                                                        );
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          FilterButton(
            lineColor: widget.backgroundColor == whiteColor
                ? dividerColor
                : homeAppBarColor,
            onPresedApply: () async {
              final prefs = await SharedPreferences.getInstance();
              List<String> brandList =
                  brandSelected.map((i) => i.toString()).toList();
              prefs.setStringList("brandList", brandList);
              List<String> colorList =
                  colorSelected.map((i) => i.toString()).toList();
              prefs.setStringList("colorList", colorList);
              List<String> sizeList =
                  sizeSelected.map((i) => i.toString()).toList();
              prefs.setStringList("sizeList", sizeList);
              prefs.setString("lower", lowerValue);
              prefs.setString("upper", UpperValue);
              widget.onClick.call(int.parse(lowerValue), int.parse(UpperValue));
            },
          ),
        ],
      ),
    );
  }
}
