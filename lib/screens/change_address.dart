// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_saveaddress.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
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
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ShippingAddressScreen(
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 30),
                                              child: getSingleButton(
                                                  label: "Select Address",
                                                  textColor: btnTextColor,
                                                  backgroundColor: whiteColor,
                                                  controller: shipController,
                                                  onPressed: () {
                                                    shipController.addressId
                                                        .value = controller
                                                            .addressList[index]
                                                        ["id"];
                                                    shipController.cartId
                                                        .value = widget.cartId;
                                                    shipController
                                                        .callCartAddressUpdate(
                                                            "update");
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
