// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../commonwidget/doubleiconbtn.dart';
import '../../utils/constants.dart';

class SavedAddressScreen extends StatefulWidget {
  const SavedAddressScreen({super.key});

  @override
  State<SavedAddressScreen> createState() => SavedAddressScreenState();
}

class SavedAddressScreenState extends State<SavedAddressScreen> {
  final controller = Get.put(ProfileController());

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
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const ShippingAddressScreen(
                                      addressId: 0,
                                      cartId: 0,
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
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 5),
                                              child: AppText(
                                                text: "Sonam Agrahari",
                                                color: loginText,
                                                fontSize: 16.sp,
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
                                                  left: 14,
                                                  right: 14,
                                                  bottom: 10),
                                              child: DoubleIconButton(
                                                  firstText: "Remove",
                                                  secondText: "Edit",
                                                  firstTextColor: btnTextColor,
                                                  secondTextColor: btnTextColor,
                                                  firstBackgroundColor:
                                                      whiteColor,
                                                  secondBackgroundColor:
                                                      whiteColor,
                                                  firstBorderColor:
                                                      btnTextColor,
                                                  secondBorderColor:
                                                      btnTextColor,
                                                  firstIcon: blackCrossImage,
                                                  onPressedFirst: () {},
                                                  onPressedSecond: () {
                                                    Get.to(
                                                        ShippingAddressScreen(
                                                      addressId: controller
                                                              .addressList[
                                                          index]["id"],
                                                      cartId: 0,
                                                    ));
                                                  },
                                                  secondIcon: editImage),
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
