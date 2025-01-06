// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_saveaddress.dart';
import 'package:lafetch/controller/product_controller.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import 'package:lafetch/screens/mapscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
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
  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getAddressData());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shipController.selected.clear();
      shipController.selected = List.generate(50, (i) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Address",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.sp,
                  ),
                  widget.cartId != 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: 10.sp, left: 16.sp, right: 16.sp),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          MapScreen(
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
                        )
                      : SizedBox(
                          height: 0.sp,
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
                                            shipController.selected[index]
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.sp,
                                                        bottom: 30.sp),
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
                                                        bottom: 30.sp),
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
