// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_saveaddress.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/screens/mapscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/common_widgets.dart';
import '../../commonwidget/doubleiconbtn.dart';
import '../../controller/shipaddress_controller.dart';
import '../../utils/constants.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getAddressData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Saved Address",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  widget.type == "product details"
                      ? SizedBox(
                          height: 0,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 16, right: 16),
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
                                  fontSize: 12.sp,
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    width: 0,
                                  ),
                                ),
                                const Icon(
                                  Icons.add,
                                  color: blackColor,
                                  size: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: AppText(
                                    text: "New Address",
                                    color: blackColor,
                                    fontSize: 12.sp,
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
                              padding: const EdgeInsets.only(top: 10),
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
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10,
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 14,
                                                        vertical: 5),
                                                    child: AppText(
                                                      text: controller
                                                                  .addressList[
                                                              index]["name"] ??
                                                          "",
                                                      color: loginText,
                                                      fontSize: 16.sp,
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
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 14,
                                                        ),
                                                        child:
                                                            AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 5),
                                                          width: 80,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                whiteBorderColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                                color:
                                                                    btnTextColor,
                                                                width: 1),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5),
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
                                                                fontSize: 12.sp,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 2),
                                              child: AppText(
                                                text: controller
                                                            .addressList[index]
                                                        ["address"] ??
                                                    "",
                                                color: greyTextColor,
                                                fontSize: 12.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 2),
                                              child: AppText(
                                                text:
                                                    "${controller.addressList[index]["locality"] ?? ""} ,${controller.addressList[index]["city"] != null ? controller.addressList[index]["city"]["name"] : ""}",
                                                color: greyTextColor,
                                                fontSize: 12.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 2),
                                              child: AppText(
                                                text: controller
                                                            .addressList[index]
                                                        ["type"] ??
                                                    "",
                                                color: loginText,
                                                fontSize: 12.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 2),
                                              child: AppText(
                                                text: controller
                                                    .addressList[index]["zip"]
                                                    .toString(),
                                                color: loginText,
                                                fontSize: 12.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            widget.type == 'address'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14,
                                                            right: 14,
                                                            bottom: 10),
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10),
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
                              child: const Center(
                                child: Text("No Address Found",
                                    style: TextStyle(
                                        fontSize: 14,
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
