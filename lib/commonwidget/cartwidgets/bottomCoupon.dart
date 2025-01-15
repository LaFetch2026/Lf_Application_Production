// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/saveaddress_appbar.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import '../../screens/Brands/categoryproduct.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class BottomCoupon extends StatefulWidget {
  final List list;
  final Function(String) onPressed;

  const BottomCoupon({
    Key? key,
    required this.list,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<BottomCoupon> createState() => BottomCouponState();
}

class BottomCouponState extends State<BottomCoupon> {
  List<bool> selected = List.generate(50, (i) => false);
  final controller = Get.put(CartController());
  Timer? debounce;
  int? i;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {});
  }

  @override
  void initState() {
    super.initState();
    controller.couponError.value = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SaveAddressAppbar(
            text: "Apply Coupon",
            onPressedWishlist: () {
              Get.off(BottomNavScreen(
                index: 2,
              ));
            },
          ),
          Divider(
            color: dividerColor,
            height: 1.sp,
          ),
          Expanded(
            child: widget.list.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20.sp,
                        ),
                        MediaQuery.of(context).size.width < 600
                            ? SizedBox(
                                height: 40.sp,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 16.sp,
                                    right: 16.sp,
                                  ),
                                  child: RawKeyboardListener(
                                    focusNode: FocusNode(),
                                    onKey: (value) {
                                      print(value);
                                      if (value is RawKeyDownEvent) {
                                        controller.couponError.value = "";
                                      }
                                    },
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: textColor,
                                        fontFamily: "Franklin Gothic Regular",
                                      ),
                                      controller: controller.couponController,
                                      onChanged: onSearchChanged,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        isDense: true,
                                        fillColor: whiteColor,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            controller.callAddCoupon(
                                                controller.couponController.text
                                                    .toString()
                                                    .trim(),
                                                "coupon");
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.sp,
                                                vertical: 5.sp),
                                            child: Container(
                                              width: 80.sp,
                                              height: 25.sp,
                                              decoration: BoxDecoration(
                                                color: btnTextColor,
                                                border: Border.all(
                                                    color: homeAppBarColor,
                                                    width: 1.sp),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.sp),
                                                child: Center(
                                                  child: AppText(
                                                    text: "Apply",
                                                    color: whiteColor,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.sp),
                                          child: ImageIcon(
                                            AssetImage(coupanImage),
                                            color: titleColor,
                                            size: 20.sp,
                                          ),
                                        ),
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
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10.sp),
                                        hintText: "Apply Coupon",
                                        hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: titleColor,
                                          fontFamily: "Franklin Gothic Regular",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 40.sp,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 16.sp, right: 16.sp),
                                  child: RawKeyboardListener(
                                    focusNode: FocusNode(),
                                    onKey: (value) {
                                      print(value);
                                      if (value is RawKeyDownEvent) {
                                        controller.couponError.value = "";
                                      }
                                    },
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: textColor,
                                        fontFamily: "Franklin Gothic Regular",
                                      ),
                                      controller: controller.couponController,
                                      onChanged: onSearchChanged,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        isDense: true,
                                        fillColor: whiteColor,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            controller.callAddCoupon(
                                                controller.couponController.text
                                                    .toString()
                                                    .trim(),
                                                "coupon");
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.sp,
                                                vertical: 5.sp),
                                            child: Container(
                                              width: 80.sp,
                                              height: 25.sp,
                                              decoration: BoxDecoration(
                                                color: btnTextColor,
                                                border: Border.all(
                                                    color: homeAppBarColor,
                                                    width: 1.sp),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.sp),
                                                child: Center(
                                                  child: AppText(
                                                    text: "Apply",
                                                    color: whiteBack,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.sp),
                                          child: ImageIcon(
                                            AssetImage(coupanImage),
                                            color: titleColor,
                                            size: 20.sp,
                                          ),
                                        ),
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
                                        hintText: "Apply Coupon",
                                        hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: titleColor,
                                          fontFamily: "Franklin Gothic Regular",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 8.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Visibility(
                                    visible: controller.couponError.value != ""
                                        ? true
                                        : false,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.sp, left: 2.sp),
                                      child: AppText(
                                        text: controller.couponError.value,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: redColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 20.sp, left: 2.sp),
                                child: AppText(
                                  text: "Available coupons",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: appBarColor,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.sp, left: 2.sp),
                                child: AppText(
                                  text: widget.list.length == 1
                                      ? "${widget.list.length} coupon"
                                      : "${widget.list.length} coupons",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: appBarColor,
                                  fontSize: 10,
                                ),
                              ),
                              ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: widget.list.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        color: whiteColor,
                                        margin: EdgeInsets.only(
                                            bottom: 10.sp, top: 20.sp),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 10.sp,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Material(
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: whiteColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                          border: Border(
                                                            top: BorderSide(
                                                                width: 2.0.sp,
                                                                color: selected[
                                                                        index]
                                                                    ? titleColor
                                                                    : greyTextColor),
                                                            left: BorderSide(
                                                                width: 2.0.sp,
                                                                color: selected[
                                                                        index]
                                                                    ? titleColor
                                                                    : greyTextColor),
                                                            right: BorderSide(
                                                                width: 2.0.sp,
                                                                color: selected[
                                                                        index]
                                                                    ? titleColor
                                                                    : greyTextColor),
                                                            bottom: BorderSide(
                                                                width: 2.0.sp,
                                                                color: selected[
                                                                        index]
                                                                    ? titleColor
                                                                    : greyTextColor),
                                                          ),
                                                        ),
                                                        width: 20,
                                                        height: 20,
                                                        child: Checkbox(
                                                          value:
                                                              selected[index],
                                                          checkColor:
                                                              selected[index]
                                                                  ? whiteColor
                                                                  : titleColor,
                                                          activeColor:
                                                              selected[index]
                                                                  ? titleColor
                                                                  : whiteColor,
                                                          side: BorderSide(
                                                              color: selected[
                                                                      index]
                                                                  ? titleColor
                                                                  : greyTextColor,
                                                              width: 0),
                                                          onChanged: (value) {
                                                            if (selected[
                                                                index]) {
                                                              selected.clear();
                                                              selected =
                                                                  List.generate(
                                                                      50,
                                                                      (i) =>
                                                                          false);
                                                              i = null;
                                                            } else {
                                                              selected.clear();
                                                              selected =
                                                                  List.generate(
                                                                      50,
                                                                      (i) =>
                                                                          false);
                                                              selected[index] =
                                                                  !selected[
                                                                      index];
                                                              print(widget.list[
                                                                      index]
                                                                  ["code"]);
                                                              i = index;
                                                            }

                                                            setState(() {});
                                                          },
                                                        )),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 14.sp,
                                                        ),
                                                        child: DottedBorder(
                                                          borderType:
                                                              BorderType.RRect,
                                                          dashPattern: [5, 5],
                                                          color:
                                                              homeAppBarColor,
                                                          strokeWidth: 1,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        14.sp,
                                                                    vertical:
                                                                        5.sp),
                                                            child: AppText(
                                                              text: widget
                                                                  .list[index]
                                                                      ["code"]
                                                                  .toUpperCase(),
                                                              color:
                                                                  homeAppBarColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  "Franklin Gothic",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  /* selected[index]
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 30.sp,
                                                                  right: 40.sp),
                                                          child: Center(
                                                            child: SizedBox(
                                                              height: 16.sp,
                                                              width: 16.sp,
                                                              child: Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                            ),
                                                          ),
                                                        )
                                                      : GestureDetector(
                                                          onTap: () {
                                                            selected[index] =
                                                                !selected[
                                                                    index];
                                                            setState(() {});
                                                            widget.onPressed.call(
                                                                widget.list[
                                                                        index]
                                                                    ["code"]);
                                                          },
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 14.sp,
                                                            ),
                                                            child:
                                                                AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          5.sp),
                                                              width: 80.sp,
                                                              height: 30.sp,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    btnTextColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.sp),
                                                                border: Border.all(
                                                                    color:
                                                                        btnTextColor,
                                                                    width:
                                                                        1.sp),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.sp),
                                                                child: Center(
                                                                  child:
                                                                      AppText(
                                                                    text:
                                                                        "Apply",
                                                                    color:
                                                                        whiteBack,
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        "Franklin Gothic",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                */
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30.sp,
                                                    top: 20.sp,
                                                    right: 16.sp),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text: "Save",
                                                      color: subtitleColor,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          "Franklin Gothic Semibold",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.sp),
                                                      child: AppText(
                                                        text:
                                                            "\u{20B9}${widget.list[index]["saved_total"].toString()}",
                                                        color:
                                                            color5StartReview,
                                                        fontSize: 12,
                                                        fontFamily:
                                                            "Franklin Gothic Semibold",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30.sp,
                                                    top: 5.sp,
                                                    right: 16.sp),
                                                child: AppText(
                                                  text: widget.list[index]
                                                              ["type"] ==
                                                          1
                                                      ? "${widget.list[index]["type_label"].toString()}${widget.list[index]["value"].toString()} off on orders above Rs.${widget.list[index]["minimum_purchase_amount"].toString()}"
                                                      : "${widget.list[index]["value"].toString()}${widget.list[index]["type_label"].toString()} off on orders above Rs.${widget.list[index]["minimum_purchase_amount"].toString()}",
                                                  color: subtitleColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30.sp,
                                                    top: 5.sp,
                                                    right: 16.sp),
                                                child: AppText(
                                                  text:
                                                      "Valid until: ${widget.list[index]["ends_at"]}",
                                                  color: subtitleColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10.sp, left: 32.sp),
                                                child: DottedLine(
                                                  direction: Axis.horizontal,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  lineLength: double.infinity,
                                                  lineThickness: 1.0,
                                                  dashLength: 5.0,
                                                  dashColor: dividerColor,
                                                  dashRadius: 0.0,
                                                  dashGapLength: 4.0,
                                                  dashGapColor:
                                                      Colors.transparent,
                                                  dashGapRadius: 0.0,
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget.list[index][
                                                            "add_items_worth"] !=
                                                        null
                                                    ? true
                                                    : false,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 30.sp,
                                                      top: 30.sp,
                                                      right: 16.sp),
                                                  child: AppText(
                                                    text: widget.list[index][
                                                            "add_items_worth"] ??
                                                        "",
                                                    color: titleColor,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  controller.categoryList
                                                      .clear();
                                                  controller.tagsList.clear();
                                                  for (var i = 0;
                                                      i <
                                                          widget
                                                              .list[index]
                                                                  ["tags"]
                                                              .length;
                                                      i++) {
                                                    controller.tagsList.add(
                                                        widget.list[index]
                                                            ["tags"][i]["id"]);
                                                  }
                                                  for (var i = 0;
                                                      i <
                                                          widget
                                                              .list[index]
                                                                  ["categories"]
                                                              .length;
                                                      i++) {
                                                    controller.categoryList.add(
                                                        widget.list[index]
                                                                ["categories"]
                                                            [i]["id"]);
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      scaleIn(
                                                        CategoryProductScreen(
                                                          categoryName: "",
                                                          categoryId: 0,
                                                          brandId: 0,
                                                          genderName: "",
                                                          genderType: 0,
                                                          tagIds: controller
                                                              .tagsList,
                                                          categoryList:
                                                              controller
                                                                  .categoryList,
                                                        ),
                                                      ));
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 30.sp,
                                                      top: 5.sp,
                                                      right: 16.sp),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Browse Collection",
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              homeAppBarColor,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 2.sp,
                                                                right: 5.sp),
                                                        child: Image.asset(
                                                            rightArrowImage,
                                                            color:
                                                                homeAppBarColor,
                                                            height: 10.sp,
                                                            width: 10.sp,
                                                            fit: BoxFit.cover),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height - 200.sp,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text("No Coupon Found",
                          style: TextStyle(
                              fontSize: 14.sp,
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontFamily: "Franklin Gothic Regular")),
                    ),
                  ),
          ),
          widget.list.isNotEmpty && i != null
              ? Container(
                  color: Color(0xffF3F4F6),
                  height: 110.sp,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 24.sp,
                                left: 20.sp,
                                right: 8.sp,
                                bottom: 16.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "Maximum savings:",
                                  textAlign: TextAlign.center,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: appBarColor,
                                  fontSize: 12,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 2.sp),
                                  child: AppText(
                                    text:
                                        "\u{20B9} ${widget.list[i!]["saved_total"]}",
                                    textAlign: TextAlign.center,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                    color: titleColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(() => Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 20.sp, bottom: 16.sp),
                                  child: getSingleButton(
                                      label: "Apply".toUpperCase(),
                                      textColor: whiteColor,
                                      backgroundColor: homeAppBarColor,
                                      controller: controller,
                                      onPressed: () async {
                                        if (i != null) {
                                          widget.onPressed
                                              .call(widget.list[i!]["code"]);
                                        }
                                      },
                                      borderColor: homeAppBarColor),
                                ),
                              )),
                        ],
                      ),
                      Container(
                        height: 5.sp,
                        width: 140.sp,
                        margin: EdgeInsets.only(top: 5.sp),
                        decoration: BoxDecoration(
                            color: homeAppBarColor,
                            borderRadius: BorderRadius.circular(5.sp)),
                      )
                    ],
                  ),
                )
              : SizedBox(
                  height: 0,
                )
        ],
      ),
    );
  }
}
