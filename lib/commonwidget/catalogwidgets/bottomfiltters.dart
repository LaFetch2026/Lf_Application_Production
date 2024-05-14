import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/catalogwidgets/filterbutton.dart';

import '../../utils/constants.dart';

class BottomFilters extends StatefulWidget {
  final List<String>? list;

  const BottomFilters({
    Key? key,
    this.list,
  }) : super(key: key);

  @override
  State<BottomFilters> createState() => BottomFiltersState();
}

class BottomFiltersState extends State<BottomFilters> {
  List<String> items = [
    "Salwar Suits",
    "Printed",
    "Clothing",
    "Duffle bags",
    "Tuxedos",
    "Salwar Suits",
    "Printed",
    "Clothing",
    "Duffle bags",
    "Tuxedos",
    "Salwar Suits",
    "Printed",
    "Clothing",
    "Duffle bags",
    "Tuxedos",
    "Salwar Suits",
    "Printed",
    "Clothing",
    "Duffle bags",
    "Tuxedos"
  ];
  List<String> brands = [
    "Price Range",
    "Brand",
    "Color",
    "Size",
    "Material",
    "Style",
    "Ocassion",
    "Feature",
  ];
  List<bool> selected = List.generate(50, (i) => false);

  @override
  Widget build(BuildContext context) {
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
                          // Get.back();
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
                      child:
                          /*  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Price Range",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  decoration: TextDecoration.none,
                                  fontSize: 14.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                colorChangeBack = btnTextColor;
                                textColor = whiteBorderColor;
                                setState(() {});
                              },
                              child: Container(
                                color: colorChangeBack,
                                width: 150,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: Text(
                                    "Brand",
                                    style: TextStyle(
                                      color: textColor,
                                      decoration: TextDecoration.none,
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Size",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  decoration: TextDecoration.none,
                                  fontSize: 14.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Color",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.none,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Material",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.none,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Style",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  decoration: TextDecoration.none,
                                  fontSize: 14.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Occasion",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  decoration: TextDecoration.none,
                                  fontSize: 14.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: Text(
                                "Feature",
                                style: TextStyle(
                                  color: bottomnavBack,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.none,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ]
                          ), */
                          Padding(
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
                      height: MediaQuery.of(context).size.height - 115,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select All",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11.sp,
                                  decoration: TextDecoration.none,
                                  fontFamily: "Franklin Gothic",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 172,
                                  child: ListView.builder(
                                      physics: const ScrollPhysics(),
                                      itemCount: items.length,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (ctx, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                                onTap: () {},
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: Row(
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: ImageIcon(
                                                          AssetImage(
                                                              checkImage),
                                                          color: textColor,
                                                          size: 14,
                                                        ),
                                                      ),
                                                      Text(
                                                        items[index],
                                                        style: TextStyle(
                                                          color: textColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontSize: 14.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
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
                  ],
                )
              ],
            ),
          ),
          FilterButton(list: items)
        ],
      ),
    );
  }
}
