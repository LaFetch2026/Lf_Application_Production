// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';
import '../../../controllers/shipaddress_controller.dart';
import '../../../core/constant/constants.dart';
import '../../../screens/mapscreen.dart';
import '../../../screens/wishlistscreen.dart';
import '../appbar/saveaddress_appbar.dart';
import '../lists/dummy_container.dart';
import '../text/app_text.dart';
import 'common_widget.dart';

class SavedAddressScreen extends StatefulWidget {
  final String type;

  const SavedAddressScreen({required this.type, super.key});

  @override
  State<SavedAddressScreen> createState() => SavedAddressScreenState();
}

class SavedAddressScreenState extends State<SavedAddressScreen> {
  final controller = Get.put(ProfileController());
  final shipController = Get.put(ShipAddressController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? debounce;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getAddressData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shipController.dailogSelected.clear();
      shipController.dailogSelected = List.generate(50, (i) => false);
      controller.queryText.value = "";
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: statusBarColor,
      ));
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
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SaveAddressAppbar(
            text: "Select Address",
            onPressedWishlist: () {
              Get.to(WishlistScreen());
            },
          ),
          Container(
            color: dividerColor,
            height: 1.sp,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.sp,
                  ),
                  Padding(
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
                          prefixIcon: IconButton(
                            icon: SvgPicture.asset(searchSvgImage,
                                color: titleColor,
                                height: 17.sp,
                                width: 17.sp,
                                fit: BoxFit.cover),
                            onPressed: () {},
                          ),
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
                  SizedBox(
                    height: 10.sp,
                  ),
                  widget.type == "product details"
                      ? SizedBox(
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              top: 10.sp, left: 16.sp, right: 16.sp),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const MapScreen(
                                            addressId: 0,
                                            cartId: 0,
                                          )))
                                  .then((value) => setState(
                                        () {
                                          controller.getAddressData();
                                          shipController.dailogSelected.clear();
                                          shipController.dailogSelected =
                                              List.generate(50, (i) => false);
                                          SystemChrome.setSystemUIOverlayStyle(
                                              const SystemUiOverlayStyle(
                                            statusBarColor: statusBarColor,
                                            systemNavigationBarColor:
                                                statusBarColor,
                                          ));
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 0.sp),
                                  child: SvgPicture.asset(
                                    myLocationSvgImage,
                                    height: 18.sp,
                                    width: 18.sp,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 7.sp, top: 2.sp),
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
                  widget.type == "product details"
                      ? SizedBox(
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 5.sp),
                          child: const Divider(
                            color: dividerColor,
                          ),
                        ),
                  widget.type == "product details"
                      ? SizedBox(
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              top: 5.sp, left: 16.sp, right: 16.sp),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const MapScreen(
                                            addressId: 0,
                                            cartId: 0,
                                          )))
                                  .then((value) => setState(
                                        () {
                                          controller.getAddressData();
                                          shipController.dailogSelected.clear();
                                          shipController.dailogSelected =
                                              List.generate(50, (i) => false);
                                          SystemChrome.setSystemUIOverlayStyle(
                                              const SystemUiOverlayStyle(
                                            statusBarColor: statusBarColor,
                                            systemNavigationBarColor:
                                                statusBarColor,
                                          ));
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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    textAlign: TextAlign.center,
                                    fontSize: 16,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  widget.type == "product details"
                      ? SizedBox(
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 5.sp),
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
                              child: GetBuilder<ShipAddressController>(
                                builder: (value) => ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: controller.addressList.length,
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (ctx, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.sp, bottom: 20.sp),
                                        child: Stack(
                                          children: [
                                            value.dailogSelected[index]
                                                ? Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 33.sp),
                                                      child: Container(
                                                        //  height: 80.sp,
                                                        width: 130.sp,
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    whiteColor,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ),
                                                                ],
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(4
                                                                            .sp)),
                                                                border: Border.all(
                                                                    width: 1.sp,
                                                                    color:
                                                                        dividerColor)),
                                                        child: Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () async {
                                                                value
                                                                    .dailogSelected
                                                                    .clear();
                                                                value.dailogSelected =
                                                                    List.generate(
                                                                        50,
                                                                        (i) =>
                                                                            false);
                                                                value.update();
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                        MaterialPageRoute(
                                                                            builder: (BuildContext context) =>
                                                                                MapScreen(
                                                                                  addressId: controller.addressList[index]["id"],
                                                                                  cartId: 0,
                                                                                )))
                                                                    .then((value) =>
                                                                        setState(
                                                                          () {
                                                                            controller.getAddressData();
                                                                            shipController.dailogSelected.clear();
                                                                            shipController.dailogSelected =
                                                                                List.generate(50, (i) => false);
                                                                            SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                                                                              statusBarColor: statusBarColor,
                                                                              systemNavigationBarColor: statusBarColor,
                                                                            ));
                                                                          },
                                                                        ));
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'map_page',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'map_page',
                                                                  },
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      whiteColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(4.0
                                                                              .sp),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              4.0.sp)),
                                                                ),
                                                                // height: 35.sp,
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12.sp,
                                                                      vertical:
                                                                          8.sp),
                                                                  child: Row(
                                                                    children: [
                                                                      ImageIcon(
                                                                        AssetImage(
                                                                            editAddressIcon),
                                                                        color:
                                                                            titleColor,
                                                                        size: 18
                                                                            .sp,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: 8.sp),
                                                                        child:
                                                                            AppText(
                                                                          text:
                                                                              "Edit".toUpperCase(),
                                                                          color:
                                                                              titleColor,
                                                                          fontSize:
                                                                              16,
                                                                          fontFamily:
                                                                              "Franklin Gothic Semibold",
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                value
                                                                    .dailogSelected
                                                                    .clear();
                                                                value.dailogSelected =
                                                                    List.generate(
                                                                        50,
                                                                        (i) =>
                                                                            false);
                                                                value.update();
                                                                controller.callRemoveAddress(
                                                                    controller.addressList[
                                                                            index]
                                                                        ["id"]);
                                                                await analytics
                                                                    .logEvent(
                                                                  name:
                                                                      'remove_addressClick',
                                                                  parameters: <String,
                                                                      Object>{
                                                                    'page_name':
                                                                        'remove_addressClick',
                                                                  },
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      whiteColor,
                                                                  borderRadius: BorderRadius.only(
                                                                      bottomLeft:
                                                                          Radius.circular(4.0
                                                                              .sp),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              4.0.sp)),
                                                                ),
                                                                // height: 35.sp,
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          12.sp,
                                                                      vertical:
                                                                          8.sp),
                                                                  child: Row(
                                                                    children: [
                                                                      ImageIcon(
                                                                        AssetImage(
                                                                            deleteAddressIcon),
                                                                        color:
                                                                            titleColor,
                                                                        size: 18
                                                                            .sp,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: 8.sp),
                                                                        child:
                                                                            AppText(
                                                                          text:
                                                                              "Delete".toUpperCase(),
                                                                          color:
                                                                              titleColor,
                                                                          fontSize:
                                                                              16,
                                                                          fontFamily:
                                                                              "Franklin Gothic Semibold",
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: 0,
                                                  ),
                                            Column(
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    controller.addressList[
                                                                index]
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
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          5.sp),
                                                              width: 120.sp,
                                                              height: 20.sp,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    titleColor,
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.sp),
                                                                child: Center(
                                                                  child:
                                                                      AppText(
                                                                    text: controller.addressList[index]
                                                                            [
                                                                            "default_shipping"]
                                                                        ? "Currently selected"
                                                                            .toUpperCase()
                                                                        : "",
                                                                    color:
                                                                        whiteColor,
                                                                    fontSize:
                                                                        10,
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
                                                    widget.type ==
                                                            "product details"
                                                        ? SizedBox(
                                                            height: 0,
                                                          )
                                                        : Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right:
                                                                        10.sp),
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (value
                                                                        .dailogSelected[
                                                                    index]) {
                                                                  value
                                                                      .dailogSelected
                                                                      .clear();
                                                                  value.dailogSelected =
                                                                      List.generate(
                                                                          50,
                                                                          (i) =>
                                                                              false);
                                                                } else {
                                                                  value
                                                                      .dailogSelected
                                                                      .clear();
                                                                  value.dailogSelected =
                                                                      List.generate(
                                                                          50,
                                                                          (i) =>
                                                                              false);
                                                                  value.dailogSelected[
                                                                          index] =
                                                                      !value.dailogSelected[
                                                                          index];
                                                                }
                                                                value.update();
                                                              },
                                                              child: Container(
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      right:
                                                                          16.sp,
                                                                      left: 16
                                                                          .sp),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    threeDotSvgImage,
                                                                    height:
                                                                        16.sp,
                                                                    width: 4.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                  ],
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
                                                        top: 8.sp),
                                                    child: AppText(
                                                      text:
                                                          controller.addressList[
                                                                      index]
                                                                  ["address"] ??
                                                              "",
                                                      color: subtitleColor,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          "Franklin Gothic Regular",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                        .addressList[index]
                                                            ["zip"]
                                                        .toString(),
                                                    color: subtitleColor,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                widget.type == 'address'
                                                    ? SizedBox(
                                                        height: 0,
                                                      )
                                                    : Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    10.sp),
                                                        child: getSingleButton(
                                                            label:
                                                                "Select Address",
                                                            textColor:
                                                                btnTextColor,
                                                            backgroundColor:
                                                                whiteColor,
                                                            controller:
                                                                shipController,
                                                            onPressed:
                                                                () async {
                                                              shipController
                                                                  .nameController
                                                                  .text = controller
                                                                      .addressList[
                                                                  index]["name"];
                                                              shipController
                                                                  .phoneController
                                                                  .text = controller
                                                                      .addressList[
                                                                  index]["phone"];
                                                              shipController
                                                                  .addressController
                                                                  .text = controller
                                                                      .addressList[
                                                                  index]["address"];
                                                              shipController
                                                                      .pincodeController
                                                                      .text =
                                                                  controller
                                                                      .addressList[
                                                                          index]
                                                                          [
                                                                          "zip"]
                                                                      .toString();
                                                              shipController
                                                                  .localityController
                                                                  .text = controller
                                                                          .addressList[
                                                                      index]
                                                                  ["locality"];
                                                              shipController
                                                                  .cityId
                                                                  .value = controller
                                                                          .addressList[
                                                                      index][
                                                                  "city"]["id"];
                                                              shipController
                                                                  .type
                                                                  .value = controller
                                                                      .addressList[
                                                                  index]["type"];
                                                              shipController
                                                                  .defaultBilling
                                                                  .value = controller
                                                                              .addressList[index]
                                                                          [
                                                                          "default_billing"] ==
                                                                      true
                                                                  ? 1
                                                                  : 0;
                                                              shipController
                                                                  .defaultShipping
                                                                  .value = 1;
                                                              shipController.callUpdateAddress(
                                                                  controller.addressList[
                                                                          index]
                                                                      ["id"],
                                                                  double.parse(controller
                                                                              .addressList[
                                                                          index]
                                                                      [
                                                                      "latitude"]),
                                                                  double.parse(
                                                                      controller
                                                                              .addressList[index]
                                                                          [
                                                                          "longitude"]),
                                                                  2);
                                                            },
                                                            borderColor:
                                                                btnTextColor),
                                                      )
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ))
                          : Padding(
                              padding:
                                  EdgeInsets.only(top: 30.sp, bottom: 10.sp),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 200.sp,
                                child: Center(
                                  child: Text("No Address Found",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontFamily:
                                              "Franklin Gothic Regular")),
                                ),
                              ),
                            ))
                  /*  SizedBox(
                    height: 10.sp,
                  ),
                  widget.type == "product details"
                      ? SizedBox(
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              top: 10.sp, left: 16.sp, right: 16.sp),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const MapScreen(
                                            addressId: 0,
                                            cartId: 0,
                                          )))
                                  .then((value) => setState(
                                        () {
                                          controller.getAddressData();
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
                                AppText(
                                  text: "",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: textHintColor,
                                  fontSize: 12,
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    width: 0,
                                  ),
                                ),
                                Icon(
                                  Icons.add,
                                  color: blackColor,
                                  size: 16.sp,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5.sp),
                                  child: AppText(
                                    text: "New Address",
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: "Franklin Gothic Bold",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  Obx(() => controller.isAddress.value
                      ? const DummySaveAddress()
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
                                            widget.type == 'address'
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 14.sp,
                                                        right: 14.sp,
                                                        bottom: 10.sp),
                                                    child: DoubleIconButton(
                                                        firstText: "Remove",
                                                        secondText: "Edit",
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
                                                            () async {
                                                          controller.callRemoveAddress(
                                                              controller
                                                                      .addressList[
                                                                  index]["id"]);
                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'remove_addressClick',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'remove_addressClick',
                                                            },
                                                          );
                                                        },
                                                        onPressedSecond:
                                                            () async {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          MapScreen(
                                                                            addressId:
                                                                                controller.addressList[index]["id"],
                                                                            cartId:
                                                                                0,
                                                                          )))
                                                              .then((value) =>
                                                                  setState(
                                                                    () {
                                                                      controller
                                                                          .getAddressData();
                                                                    },
                                                                  ));
                                                          await analytics
                                                              .logEvent(
                                                            name: 'map_page',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'map_page',
                                                            },
                                                          );
                                                        },
                                                        secondIcon: editImage))
                                                : Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.sp),
                                                    child: getSingleButton(
                                                        label: "Select Address",
                                                        textColor: btnTextColor,
                                                        backgroundColor:
                                                            whiteColor,
                                                        controller:
                                                            shipController,
                                                        onPressed: () async {
                                                          shipController
                                                              .nameController
                                                              .text = controller
                                                                  .addressList[
                                                              index]["name"];
                                                          shipController
                                                              .phoneController
                                                              .text = controller
                                                                  .addressList[
                                                              index]["phone"];
                                                          shipController
                                                              .addressController
                                                              .text = controller
                                                                  .addressList[
                                                              index]["address"];
                                                          shipController
                                                                  .pincodeController
                                                                  .text =
                                                              controller
                                                                  .addressList[
                                                                      index]
                                                                      ["zip"]
                                                                  .toString();
                                                          shipController
                                                              .localityController
                                                              .text = controller
                                                                  .addressList[
                                                              index]["locality"];
                                                          shipController.cityId
                                                              .value = controller
                                                                  .addressList[
                                                              index]["city"]["id"];
                                                          shipController.type
                                                              .value = controller
                                                                  .addressList[
                                                              index]["type"];
                                                          shipController
                                                              .defaultBilling
                                                              .value = controller
                                                                              .addressList[
                                                                          index]
                                                                      [
                                                                      "default_billing"] ==
                                                                  true
                                                              ? 1
                                                              : 0;
                                                          shipController
                                                              .defaultShipping
                                                              .value = 1;
                                                          shipController.callUpdateAddress(
                                                              controller
                                                                      .addressList[
                                                                  index]["id"],
                                                              double.parse(controller
                                                                          .addressList[
                                                                      index]
                                                                  ["latitude"]),
                                                              double.parse(controller
                                                                          .addressList[
                                                                      index][
                                                                  "longitude"]),
                                                              2);
                                                        },
                                                        borderColor:
                                                            btnTextColor),
                                                  )
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
                */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
