// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/mapscreen.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';

import '../../common/widget/appbar/saveaddress_appbar.dart';
import '../../common/widget/lists/dummy_container.dart';
import '../../common/widget/other/common_widget.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/shipaddress_controller.dart';
import '../../core/constant/constants.dart';

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
  String draggedAddress = "";
  String localityName = "";
  String stateName = "";
  String pincode = "";

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

  // small helper to normalize whatever we have on the address item
  Map<String, dynamic> _normalizeAddress(Map item) {
    final cityName = item["city"] is Map ? item["city"]["name"] : item["city"];
    final stateName =
        item["state"] is Map ? item["state"]["name"] : item["state"];
    final full = [
      (item["address"] ?? item["line1"] ?? "").toString(),
      (item["locality"] ?? item["line2"] ?? "").toString(),
      (cityName ?? "").toString(),
      (stateName ?? "").toString(),
      (item["zip"] ?? item["postalCode"] ?? "").toString(),
    ].where((e) => e.trim().isNotEmpty).join(", ");

    return {
      "id": item["id"],
      "name": (item["name"] ?? item["type"] ?? "Address").toString(),
      "phone": (item["phone"] ?? "").toString(),
      "line1": (item["address"] ?? item["line1"] ?? "").toString(),
      "locality": (item["locality"] ?? item["line2"] ?? "").toString(),
      "city": (cityName ?? "").toString(),
      "state": (stateName ?? "").toString(),
      "pincode": (item["zip"] ?? item["postalCode"] ?? "").toString(),
      "latitude": double.tryParse("${item["latitude"]}") ?? 0.0,
      "longitude": double.tryParse("${item["longitude"]}") ?? 0.0,
      "full": full,
      // passthrough raw in case you need other keys upstream
      "_raw": item,
    };
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
                  SizedBox(height: 10.sp),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.sp, vertical: 10.sp),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (value) {
                        if (value is RawKeyDownEvent) {
                          controller.queryText.value = "";
                          controller.getAddressData();
                        }
                      },
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                            color: titleColor,
                            fontFamily: "Clash Display Regular",
                            fontSize: 14.sp),
                        controller: shipController.searchAddressController,
                        onChanged: onSearchChanged,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          isDense: true,
                          fillColor: whiteColor,
                          prefixIcon: IconButton(
                            icon: SvgPicture.asset(
                              searchSvgImage,
                              color: titleColor,
                              height: 17.sp,
                              width: 17.sp,
                              fit: BoxFit.fill,
                            ),
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
                              fontFamily: "Clash Display Regular"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),

                  // Hide quick actions on "product details" mode (kept from your code)
                  widget.type == "product details"
                      ? const SizedBox.shrink()
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
                                  .then((value) => setState(() {
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
                                      }));
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
                                SvgPicture.asset(
                                  myLocationSvgImage,
                                  height: 18.sp,
                                  width: 18.sp,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 7.sp, top: 2.sp),
                                  child: AppText(
                                    text: "Use my current location",
                                    color: homeAppBarColor,
                                    fontSize: 16,
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  widget.type == "product details"
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 5.sp),
                          child: const Divider(color: dividerColor),
                        ),
                  widget.type == "product details"
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(
                              top: 5.sp, left: 16.sp, right: 16.sp),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ShippingAddressScreen(
                                  addressId: 0,
                                  cartId: 0,
                                  pincode: pincode,
                                  stateName: stateName,
                                  address: draggedAddress,
                                  localityName: localityName,
                                  latitude: shipController.lat.value,
                                  longitude: shipController.lng.value,
                                ),
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
                                SvgPicture.asset(
                                  addNewSvgImage,
                                  height: 14.sp,
                                  width: 14.sp,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 7.sp),
                                  child: AppText(
                                    text: "Add new address",
                                    color: homeAppBarColor,
                                    textAlign: TextAlign.center,
                                    fontSize: 16,
                                    fontFamily: "Clash Display",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  widget.type == "product details"
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 5.sp),
                          child: const Divider(color: dividerColor),
                        ),

                  Padding(
                    padding:
                        EdgeInsets.only(top: 30.sp, left: 16.sp, right: 16.sp),
                    child: AppText(
                      text: "Saved Address".toUpperCase(),
                      color: homeAppBarColor,
                      fontSize: 14,
                      fontFamily: "Clash Display",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
                    child: const Divider(color: dividerColor),
                  ),

                  // Address list
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
                                padding:
                                    EdgeInsets.only(top: 10.sp, bottom: 20.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          left: 16.sp, right: 16.sp, top: 8.sp),
                                      child: const DummyContainer(
                                          height: 20, width: 100),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16.sp, right: 16.sp, top: 4.sp),
                                      child: DummyContainer(
                                        height: 20,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
                                    final item =
                                        controller.addressList[index] as Map;

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
                                                      width: 130.sp,
                                                      decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.5),
                                                          ),
                                                        ],
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    4.sp)),
                                                        border: Border.all(
                                                          width: 1.sp,
                                                          color: dividerColor,
                                                        ),
                                                      ),
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
                                                                                addressId: item["id"],
                                                                                cartId: 0,
                                                                              )))
                                                                  .then((value) =>
                                                                      setState(
                                                                          () {
                                                                        controller
                                                                            .getAddressData();
                                                                        shipController
                                                                            .dailogSelected
                                                                            .clear();
                                                                        shipController.dailogSelected = List.generate(
                                                                            50,
                                                                            (i) =>
                                                                                false);
                                                                        SystemChrome
                                                                            .setSystemUIOverlayStyle(
                                                                          const SystemUiOverlayStyle(
                                                                            statusBarColor:
                                                                                statusBarColor,
                                                                            systemNavigationBarColor:
                                                                                statusBarColor,
                                                                          ),
                                                                        );
                                                                      }));
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
                                                                    topRight: Radius
                                                                        .circular(
                                                                            4.0.sp)),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal: 12
                                                                            .sp,
                                                                        vertical:
                                                                            8.sp),
                                                                child: Row(
                                                                  children: [
                                                                    ImageIcon(
                                                                      AssetImage(
                                                                          editAddressIcon),
                                                                      color:
                                                                          titleColor,
                                                                      size:
                                                                          18.sp,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              8.sp),
                                                                      child:
                                                                          AppText(
                                                                        text: "Edit"
                                                                            .toUpperCase(),
                                                                        color:
                                                                            titleColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            "Clash Display Semibold",
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

                                                              final id =
                                                                  item["id"]
                                                                      as int;

                                                              final confirmed =
                                                                  await Get.dialog<
                                                                          bool>(
                                                                        AlertDialog(
                                                                          title:
                                                                              const Text('Delete address?'),
                                                                          content:
                                                                              const Text('This action cannot be undone.'),
                                                                          actions: [
                                                                            TextButton(
                                                                                onPressed: () => Get.back(result: false),
                                                                                child: const Text('Cancel')),
                                                                            TextButton(
                                                                                onPressed: () => Get.back(result: true),
                                                                                child: const Text('Delete')),
                                                                          ],
                                                                        ),
                                                                      ) ??
                                                                      false;
                                                              if (!confirmed)
                                                                return;

                                                              final ok = await shipController
                                                                  .callDeleteAddress(
                                                                      addressId:
                                                                          id);
                                                              if (ok) {
                                                                await controller
                                                                    .getAddressData();
                                                              }
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
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal: 12
                                                                            .sp,
                                                                        vertical:
                                                                            8.sp),
                                                                child: Row(
                                                                  children: [
                                                                    ImageIcon(
                                                                      AssetImage(
                                                                          deleteAddressIcon),
                                                                      color:
                                                                          titleColor,
                                                                      size:
                                                                          18.sp,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              8.sp),
                                                                      child:
                                                                          AppText(
                                                                        text: "Delete"
                                                                            .toUpperCase(),
                                                                        color:
                                                                            titleColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            "Clash Display Semibold",
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
                                              : const SizedBox.shrink(),

                                          // ===== Address Card =====
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
                                                      text: (item["type"] ?? "")
                                                          .toString(),
                                                      color: titleColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Clash Display Semibold",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  (item["default_shipping"] ==
                                                          true)
                                                      ? Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      14.sp),
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
                                                            width: 120.sp,
                                                            height: 20.sp,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: titleColor,
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          5.sp),
                                                              child: Center(
                                                                child: AppText(
                                                                  text: "Currently selected"
                                                                      .toUpperCase(),
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 10,
                                                                  fontFamily:
                                                                      "Clash Display",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(
                                                          height: 0),
                                                  const Spacer(),
                                                  widget.type ==
                                                          "product details"
                                                      ? const SizedBox.shrink()
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10.sp),
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
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          16.sp,
                                                                      left: 16
                                                                          .sp),
                                                              child: SvgPicture
                                                                  .asset(
                                                                threeDotSvgImage,
                                                                height: 16.sp,
                                                                width: 4.sp,
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
                                                        (item["address"] ?? "")
                                                            .toString(),
                                                    color: subtitleColor,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Clash Display Regular",
                                                    fontWeight: FontWeight.w400,
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
                                                        "${(item["locality"] ?? "").toString()} ,${item["city"] != null ? (item["city"]["name"] ?? "").toString() : ""}",
                                                    color: subtitleColor,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        "Clash Display Regular",
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
                                                  text: (item["zip"] ?? "")
                                                      .toString(),
                                                  color: subtitleColor,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      "Clash Display Regular",
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),

                                              // ===== Select Address Button (UPDATED) =====
                                              widget.type == 'address'
                                                  ? const SizedBox.shrink()
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
                                                          // IMPORTANT:
                                                          // When user taps "Select Address", we RETURN the selected address
                                                          // to the previous screen (e.g., ProductDetailsScreen).
                                                          // Product screen will then handle Razorpay on next Buy Now tap.

                                                          final normalized =
                                                              _normalizeAddress(
                                                                  item);

                                                          // If you ALSO want to set this as default shipping on server,
                                                          // you can call your controller here (kept optional to stay snappy):
                                                          // await shipController.callUpdateAddress(
                                                          //   addressIdParam: item["id"] as int,
                                                          //   latitude: normalized["latitude"],
                                                          //   longitude: normalized["longitude"],
                                                          //   typeValue: (item["type"] ?? "").toString(),
                                                          //   closeAllOnSuccess: false,
                                                          // );

                                                          Get.back(
                                                              result:
                                                                  normalized);

                                                          await analytics
                                                              .logEvent(
                                                            name:
                                                                'select_address',
                                                            parameters: <String,
                                                                Object>{
                                                              'page_name':
                                                                  'select_address',
                                                              'address_id':
                                                                  '${item["id"]}',
                                                            },
                                                          );
                                                        },
                                                        borderColor:
                                                            btnTextColor,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  EdgeInsets.only(top: 30.sp, bottom: 10.sp),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 200.sp,
                                child: Center(
                                  child: Text(
                                    "No Address Found",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                      fontFamily: "Clash Display Regular",
                                    ),
                                  ),
                                ),
                              ),
                            )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
