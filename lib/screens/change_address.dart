// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/saveaddress_appbar.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/mapscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class ChangeAddressScreen extends StatefulWidget {
  final int cartId;
  const ChangeAddressScreen({super.key, required this.cartId});

  @override
  State<ChangeAddressScreen> createState() => ChangeAddressScreenState();
}

class ChangeAddressScreenState extends State<ChangeAddressScreen> {
  final controller = Get.put(ProfileController());
  final shipController = Get.put(ShipAddressController());
  final productController = Get.put(ProductController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? debounce;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getAddressData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shipController.selected.clear();
      shipController.selected = List.generate(50, (i) => false);
      controller.queryText.value = "";
    });
    super.initState();
  }

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      controller.queryText.value = query;
      controller.getAddressData();
      await analytics.logEvent(
        name: 'address_search',
        parameters: <String, Object>{
          'page_name': 'address_search',
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        children: [
          Visibility(
            visible: widget.cartId != 0 ? true : false,
            child: SaveAddressAppbar(
              text: "Select Address",
              onPressedWishlist: () {
                Get.off(BottomNavScreen(
                  index: 2,
                ));
              },
            ),
          ),
          Visibility(
            visible: widget.cartId != 0 ? true : false,
            child: const Divider(
              color: dividerColor,
            ),
          ),
          Visibility(
            visible: widget.cartId == 0 ? true : false,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16.sp, top: 20.sp, right: 16.sp, bottom: 16.sp),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "SELECT ADDRESS",
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 16.sp,
                        fontFamily: "Franklin Gothic Semibold",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: SvgPicture.asset(crossSearchImage,
                          color: subtitleColor,
                          height: 13.sp,
                          width: 13.sp,
                          fit: BoxFit.cover),
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
                  /*   Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.sp, vertical: 10.sp),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (value) {
                        print(value);
                        if (value is RawKeyDownEvent) {
                          controller.queryText.value = "";
                          controller.getAddressData();
                        }
                      },
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                            color: titleColor,
                            fontFamily: "Franklin Gothic Regular",
                            fontSize: 14.sp),
                        controller: shipController.searchAddressController,
                        onChanged: onSearchChanged,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          isDense: true,
                          fillColor: whiteColor,
                          prefixIcon: Icon(Icons.search,
                              size: 24.sp, color: titleColor),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1.sp),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1.sp),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          counterText: "",
                          hintText: "Try chandni chowk",
                          hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: searchTextColor,
                              fontFamily: "Franklin Gothic Regular"),
                        ),
                      ),
                    ),
                  ),
                  */
                  SizedBox(
                    height: 10.sp,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) => MapScreen(
                                      addressId: 0,
                                      cartId: widget.cartId,
                                    )))
                            .then((value) => setState(
                                  () {
                                    controller.getAddressData();
                                  },
                                ));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            myLocationSvgImage,
                            height: 18.sp,
                            width: 18.sp,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 7.sp, top: 2.sp),
                            child: AppText(
                              text: "Use my current location",
                              color: homeAppBarColor,
                              fontSize: 16,
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
                    child: const Divider(
                      color: dividerColor,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 5.sp, left: 16.sp, right: 16.sp),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (BuildContext context) => MapScreen(
                                      addressId: 0,
                                      cartId: widget.cartId,
                                    )))
                            .then((value) => setState(
                                  () {
                                    controller.getAddressData();
                                    shipController.dailogSelected.clear();
                                    shipController.dailogSelected =
                                        List.generate(50, (i) => false);
                                  },
                                ));
                        await analytics.logEvent(
                          name: 'map_page',
                          parameters: <String, Object>{
                            'page_name': 'map_page',
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2.sp),
                            child: SvgPicture.asset(
                              addNewSvgImage,
                              height: 14.sp,
                              width: 14.sp,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 7.sp),
                            child: AppText(
                              text: "Add new address",
                              color: homeAppBarColor,
                              fontSize: 16,
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
                    child: const Divider(
                      color: dividerColor,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 30.sp, left: 16.sp, right: 16.sp),
                    child: GestureDetector(
                      onTap: () async {},
                      child: AppText(
                        text: "Saved Address".toUpperCase(),
                        color: homeAppBarColor,
                        fontSize: 14,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
                    child: const Divider(
                      color: dividerColor,
                    ),
                  ),
                  Obx(() => controller.isAddress.value
                      ? Padding(
                          padding: EdgeInsets.only(top: 10.sp),
                          child: ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: 3,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (ctx, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.sp, bottom: 20.sp),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp, right: 16.sp),
                                        child: DummyContainer(
                                            height: 20,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            right: 16.sp,
                                            top: 8.sp),
                                        child: DummyContainer(
                                            height: 20, width: 100),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.sp,
                                            right: 16.sp,
                                            top: 4.sp),
                                        child: DummyContainer(
                                            height: 20,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        )
                      : controller.addressList.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 10.sp),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: controller.addressList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Container(
                                      color: whiteColor,
                                      margin: EdgeInsets.only(bottom: 10.sp),
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
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 16.sp),
                                                  child: AppText(
                                                    text: controller
                                                                .addressList[
                                                            index]["type"] ??
                                                        "",
                                                    color: titleColor,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        "Franklin Gothic Semibold",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                controller.addressList[index]
                                                        ["default_shipping"]
                                                    ? Padding(
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
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 5.sp),
                                                          width: 120.sp,
                                                          height: 20.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: titleColor,
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.sp),
                                                            child: Center(
                                                              child: AppText(
                                                                text: controller
                                                                            .addressList[index]
                                                                        [
                                                                        "default_shipping"]
                                                                    ? "Currently selected"
                                                                        .toUpperCase()
                                                                    : "",
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                                fontFamily:
                                                                    "Franklin Gothic",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                      ),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 0,
                                                  ),
                                                ),
                                                shipController.selected[index]
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5.sp,
                                                                right: 30.sp,
                                                                bottom: 5.sp),
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
                                                        onTap: () async {
                                                          if (widget.cartId ==
                                                              0) {
                                                            shipController
                                                                        .selected[
                                                                    index] =
                                                                !shipController
                                                                        .selected[
                                                                    index];
                                                            shipController
                                                                .update();
                                                            setState(() {});
                                                            productController
                                                                    .lat.value =
                                                                double.parse(controller
                                                                            .addressList[
                                                                        index][
                                                                    "latitude"]);
                                                            productController
                                                                    .lng.value =
                                                                double.parse(controller
                                                                            .addressList[
                                                                        index][
                                                                    "longitude"]);
                                                            final prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            prefs.setDouble(
                                                                "latitude",
                                                                productController
                                                                    .lat.value);
                                                            prefs.setDouble(
                                                                "longitude",
                                                                productController
                                                                    .lng.value);
                                                            productController.callSaveAddress(
                                                                "change address",
                                                                controller.addressList[index]
                                                                    ["id"],
                                                                controller.addressList[index]
                                                                    ["name"],
                                                                controller.addressList[index]
                                                                    ["phone"],
                                                                controller.addressList[index]
                                                                        ["city"]
                                                                    ["name"],
                                                                controller.addressList[index]
                                                                    ["type"],
                                                                controller.addressList[index]
                                                                    ["address"],
                                                                controller
                                                                    .addressList[index]
                                                                        ["zip"]
                                                                    .toString(),
                                                                controller.addressList[index][
                                                                    "locality"],
                                                                controller.addressList[index]
                                                                            ["city"]
                                                                        ["state"]
                                                                    ["name"],
                                                                double.parse(
                                                                    controller.addressList[index]
                                                                        ["latitude"]),
                                                                double.parse(controller.addressList[index]["longitude"]),
                                                                context);
                                                          } else {
                                                            shipController
                                                                        .selected[
                                                                    index] =
                                                                !shipController
                                                                        .selected[
                                                                    index];
                                                            shipController
                                                                .update();
                                                            setState(() {});
                                                            shipController
                                                                .addressId
                                                                .value = controller
                                                                    .addressList[
                                                                index]["id"];
                                                            shipController
                                                                    .cartId
                                                                    .value =
                                                                widget.cartId;
                                                            /*   shipController
                                                                .callCartAddressUpdate(
                                                                    "update"); */
                                                            productController.callSaveAddress(
                                                                "",
                                                                controller.addressList[index]
                                                                    ["id"],
                                                                controller.addressList[index]
                                                                    ["name"],
                                                                controller.addressList[index]
                                                                    ["phone"],
                                                                controller.addressList[index]
                                                                        ["city"]
                                                                    ["name"],
                                                                controller.addressList[index]
                                                                    ["type"],
                                                                controller.addressList[index]
                                                                    ["address"],
                                                                controller
                                                                    .addressList[index]
                                                                        ["zip"]
                                                                    .toString(),
                                                                controller.addressList[index][
                                                                    "locality"],
                                                                controller.addressList[index]
                                                                            ["city"]
                                                                        ["state"]
                                                                    ["name"],
                                                                double.parse(
                                                                    controller.addressList[index]
                                                                        ["latitude"]),
                                                                double.parse(controller.addressList[index]["longitude"]),
                                                                context);
                                                          }

                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'changeAddress_btnclick',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'changeAddress_btnclick',
                                                            },
                                                          );
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
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right:
                                                                        5.sp),
                                                            width: 80.sp,
                                                            height: 20.sp,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: whiteColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.sp),
                                                              border: Border.all(
                                                                  color:
                                                                      btnTextColor,
                                                                  width: 1.sp),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          5.sp),
                                                              child: Center(
                                                                child: AppText(
                                                                  text:
                                                                      "Select",
                                                                  color:
                                                                      btnTextColor,
                                                                  fontSize: 12,
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
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16.sp,
                                                  right: 16.sp,
                                                  top: 8.sp),
                                              child: AppText(
                                                text: controller
                                                            .addressList[index]
                                                        ["address"] ??
                                                    "",
                                                color: subtitleColor,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.sp,
                                              height: 20.sp,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16.sp,
                                                    right: 16.sp,
                                                    top: 4.sp),
                                                child: AppText(
                                                  text:
                                                      "${controller.addressList[index]["locality"] ?? ""} ,${controller.addressList[index]["city"] != null ? controller.addressList[index]["city"]["name"] : ""}",
                                                  color: subtitleColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16.sp,
                                                  right: 16.sp,
                                                  top: 4.sp),
                                              child: AppText(
                                                text: controller
                                                    .addressList[index]["zip"]
                                                    .toString(),
                                                color: subtitleColor,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            /*   Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 14.sp,
                                                            vertical: 5.sp),
                                                    child: AppText(
                                                      text: controller
                                                                  .addressList[
                                                              index]["name"] ??
                                                          "",
                                                      color: loginText,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                controller.addressList[index]
                                                        ["default_shipping"]
                                                    ? Padding(
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
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 5.sp),
                                                          width: 80.sp,
                                                          height: 20.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                whiteBorderColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.sp),
                                                            border: Border.all(
                                                                color:
                                                                    btnTextColor,
                                                                width: 1.sp),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.sp),
                                                            child: Center(
                                                              child: AppText(
                                                                text: controller
                                                                            .addressList[index]
                                                                        [
                                                                        "default_shipping"]
                                                                    ? "Default"
                                                                    : "",
                                                                color:
                                                                    btnTextColor,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    "Franklin Gothic",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                      ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.sp,
                                                  vertical: 2.sp),
                                              child: AppText(
                                                text: controller
                                                            .addressList[index]
                                                        ["address"] ??
                                                    "",
                                                color: greyTextColor,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.sp,
                                                  vertical: 2.sp),
                                              child: AppText(
                                                text:
                                                    "${controller.addressList[index]["locality"] ?? ""} ,${controller.addressList[index]["city"] != null ? controller.addressList[index]["city"]["name"] : ""}",
                                                color: greyTextColor,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.sp,
                                                  vertical: 2.sp),
                                              child: AppText(
                                                text: controller
                                                            .addressList[index]
                                                        ["type"] ??
                                                    "",
                                                color: loginText,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.sp,
                                                  vertical: 2.sp),
                                              child: AppText(
                                                text: controller
                                                    .addressList[index]["zip"]
                                                    .toString(),
                                                color: loginText,
                                                fontSize: 12,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            */
                                            /*  shipController.selected[index]
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.sp,
                                                        bottom: 10.sp),
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
                                                : Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.sp,
                                                        bottom: 10.sp),
                                                    child: getSingleButton(
                                                        label: "Select Address",
                                                        textColor: btnTextColor,
                                                        backgroundColor:
                                                            whiteColor,
                                                        onPressed: () async {
                                                          if (widget.cartId ==
                                                              0) {
                                                            productController
                                                                    .lat.value =
                                                                double.parse(controller
                                                                            .addressList[
                                                                        index][
                                                                    "latitude"]);
                                                            productController
                                                                    .lng.value =
                                                                double.parse(controller
                                                                            .addressList[
                                                                        index][
                                                                    "longitude"]);
                                                            final prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            prefs.setDouble(
                                                                "latitude",
                                                                productController
                                                                    .lat.value);
                                                            prefs.setDouble(
                                                                "longitude",
                                                                productController
                                                                    .lng.value);
                                                            productController.callSaveAddress(
                                                                "change address",
                                                                controller.addressList[index]
                                                                    ["id"],
                                                                controller.addressList[index]
                                                                    ["name"],
                                                                controller.addressList[index]
                                                                    ["phone"],
                                                                controller.addressList[index]
                                                                        ["city"]
                                                                    ["id"],
                                                                controller.addressList[index]
                                                                    ["type"],
                                                                controller.addressList[index]
                                                                    ["address"],
                                                                controller
                                                                    .addressList[index]
                                                                        ["zip"]
                                                                    .toString(),
                                                                controller.addressList[index][
                                                                    "locality"],
                                                                controller.addressList[index][
                                                                    "default_billing"],
                                                                double.parse(controller.addressList[index]
                                                                    ["latitude"]),
                                                                double.parse(controller.addressList[index]["longitude"]));
                                                          } else {
                                                            shipController
                                                                        .selected[
                                                                    index] =
                                                                !shipController
                                                                        .selected[
                                                                    index];
                                                            shipController
                                                                .update();
                                                            setState(() {});
                                                            shipController
                                                                .addressId
                                                                .value = controller
                                                                    .addressList[
                                                                index]["id"];
                                                            shipController
                                                                    .cartId
                                                                    .value =
                                                                widget.cartId;
                                                            shipController
                                                                .callCartAddressUpdate(
                                                                    "update");
                                                          }

                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'changeAddress_btnclick',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'changeAddress_btnclick',
                                                            },
                                                          );
                                                        },
                                                        borderColor:
                                                            btnTextColor),
                                                  )
                                          */
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text("No Address Found",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                        fontFamily: "Franklin Gothic Regular")),
                              ),
                            ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
