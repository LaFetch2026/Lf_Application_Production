// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_saveaddress.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import 'package:lafetch/screens/mapscreen.dart';
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
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.sp, bottom: 30.sp),
                                              child: getSingleButton(
                                                  label: "Select Address",
                                                  textColor: btnTextColor,
                                                  backgroundColor: whiteColor,
                                                  controller: shipController,
                                                  onPressed: () async {
                                                    shipController.addressId
                                                        .value = controller
                                                            .addressList[index]
                                                        ["id"];
                                                    shipController.cartId
                                                        .value = widget.cartId;
                                                    shipController
                                                        .callCartAddressUpdate(
                                                            "update");
                                                    await analytics.logEvent(
                                                      name:
                                                          'changeAddress_btnclick',
                                                      parameters: <String,
                                                          Object>{
                                                        'page_name':
                                                            'changeAddress_btnclick',
                                                      },
                                                    );
                                                  },
                                                  borderColor: btnTextColor),
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
