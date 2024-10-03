import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/catalogwidgets/filterbutton.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

import '../../controller/product_controller.dart';
import '../../utils/constants.dart';

class BottomFilters extends StatefulWidget {
  final Function(int, int) onClick;
  final Function btnclearAll;
  const BottomFilters({
    required this.onClick,
    required this.btnclearAll,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomFilters> createState() => BottomFiltersState();
}

class BottomFiltersState extends State<BottomFilters> {
  final productController = Get.put(ProductController());
  List<String> brands = [
    "Price Range",
    "Brand",
    "Color",
    "Size",
    /*"Material",
    "Style",
    "Ocassion",
    "Feature",*/
  ];
  List<bool> selected = List.generate(50, (i) => false);
  List<bool> brandSelected = List.generate(50, (i) => false);
  List<bool> colorSelected = List.generate(50, (i) => false);
  List<bool> sizeSelected = List.generate(50, (i) => false);
  String type = "";
  String lowerValue = "500";
  String UpperValue = "50000";
  RangeValues values = RangeValues(500, 50000);

  @override
  void initState() {
    selected[0] = !selected[0];
    productController.isPrice.value = true;
    productController.size_ids.clear();
    productController.color_ids.clear();
    productController.brand_ids.clear();
    productController.filterList.clear();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RangeLabels labels =
        RangeLabels(values.start.toString(), values.end.toString());
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 30, bottom: 20),
                  child: Row(
                    children: [
                      Text(
                        "Filters",
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 14.sp,
                          decoration: TextDecoration.none,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
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
                          setState(() {});
                          widget.btnclearAll.call();
                        },
                        child: Text(
                          "Clear All",
                          style: TextStyle(
                            color: greyTextColor,
                            decoration: TextDecoration.none,
                            fontSize: 12.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      color: backWhite,
                      width: 150,
                      height: MediaQuery.of(context).size.height - 120,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          height: 150,
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
                                          if (index == 1) {
                                            productController
                                                .getFilterData("brands");
                                            type = "brands";
                                            productController.isPrice.value =
                                                false;
                                          } else if (index == 2) {
                                            productController
                                                .getFilterData("color");
                                            type = "color";
                                            productController.isPrice.value =
                                                false;
                                          } else if (index == 0) {
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
                                          }
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          color: selected[index]
                                              ? btnTextColor
                                              : backWhite,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, top: 2, bottom: 2),
                                              child: Text(
                                                brands[index],
                                                style: TextStyle(
                                                  color: selected[index]
                                                      ? whiteBorderColor
                                                      : btnTextColor,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 14.sp,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
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
                      color: whiteBorderColor,
                      width: MediaQuery.of(context).size.width - 150,
                      height: MediaQuery.of(context).size.height - 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Obx(
                          () => productController.isPrice.value
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        172,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "Selected Price Range",
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14.sp,
                                              decoration: TextDecoration.none,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: Material(
                                              child: RangeSlider(
                                                values: values,
                                                min: 500,
                                                max: 50000,
                                                // divisions: 5,
                                                inactiveColor: Colors.grey,
                                                activeColor: btnTextColor,
                                                labels: labels,
                                                onChanged: (newValue) {
                                                  productController.pricelist
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
                                                  productController.pricelist =
                                                      [lowerValue, UpperValue];
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                "\u{20B9} ${lowerValue} - \u{20B9} ${UpperValue}",
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 14.sp,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                172,
                                        child: ListView.builder(
                                            physics: const ScrollPhysics(),
                                            itemCount: 8,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, index) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10),
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
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
                                          /*  Text(
                                            productController.filterList.isEmpty
                                                ? ""
                                                : "Select All",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11.sp,
                                              decoration: TextDecoration.none,
                                              fontFamily: "Franklin Gothic",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ), */
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  172,
                                              child: ListView.builder(
                                                  physics:
                                                      const ScrollPhysics(),
                                                  itemCount: productController
                                                      .filterList.length,
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder: (ctx, index) {
                                                    return Column(
                                                      children: [
                                                        GestureDetector(
                                                            onTap: () {},
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          10),
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
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: const Border(
                                                                                top: BorderSide(width: 2.0, color: greyBorder),
                                                                                left: BorderSide(width: 2.0, color: greyBorder),
                                                                                right: BorderSide(width: 2.0, color: greyBorder),
                                                                                bottom: BorderSide(width: 2.0, color: greyBorder),
                                                                              ),
                                                                            ),
                                                                            width: 20,
                                                                            height: 20,
                                                                            child: Checkbox(
                                                                              value: brandSelected[index],
                                                                              checkColor: btnTextColor,
                                                                              activeColor: whiteBorderColor,
                                                                              side: const BorderSide(color: btnTextColor, width: 0),
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
                                                                              5),
                                                                      child:
                                                                          Material(
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: const Border(
                                                                                top: BorderSide(width: 2.0, color: greyBorder),
                                                                                left: BorderSide(width: 2.0, color: greyBorder),
                                                                                right: BorderSide(width: 2.0, color: greyBorder),
                                                                                bottom: BorderSide(width: 2.0, color: greyBorder),
                                                                              ),
                                                                            ),
                                                                            width: 20,
                                                                            height: 20,
                                                                            child: Checkbox(
                                                                              value: colorSelected[index],
                                                                              checkColor: btnTextColor,
                                                                              activeColor: whiteBorderColor,
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
                                                                              5),
                                                                      child:
                                                                          Material(
                                                                        child: Container(
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(3),
                                                                              border: const Border(
                                                                                top: BorderSide(width: 2.0, color: greyBorder),
                                                                                left: BorderSide(width: 2.0, color: greyBorder),
                                                                                right: BorderSide(width: 2.0, color: greyBorder),
                                                                                bottom: BorderSide(width: 2.0, color: greyBorder),
                                                                              ),
                                                                            ),
                                                                            width: 20,
                                                                            height: 20,
                                                                            child: Checkbox(
                                                                              value: sizeSelected[index],
                                                                              checkColor: btnTextColor,
                                                                              activeColor: whiteBorderColor,
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
                                                                  Text(
                                                                    productController
                                                                            .filterList[index]
                                                                        [
                                                                        "name"],
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          textColor,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      fontSize:
                                                                          12.sp,
                                                                      fontFamily:
                                                                          "Franklin Gothic Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ],
                                                    );
                                                  }),
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
            onPresedApply: () {
              widget.onClick.call(int.parse(lowerValue), int.parse(UpperValue));
            },
          )
        ],
      ),
    );
  }
}
