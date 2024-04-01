// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/commonwidget/common_widgets.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/loginwidgets/number_widget.dart';
import '../commonwidget/text_field.dart';
import '../utils/constants.dart';

class ShippingAddressScreen extends StatefulWidget {
  final int addressId;
  const ShippingAddressScreen({super.key, required this.addressId});

  @override
  State<ShippingAddressScreen> createState() => ShippingAddressScreenState();
}

class ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final shipController = Get.put(ShipAddressController());

  List<String> items = [
    "Home",
    "Work",
  ];

  int? current;

  @override
  void initState() {
    if (widget.addressId != 0) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          shipController.showList.value = false;
        });
      },
      child: Scaffold(
        backgroundColor: whiteTextColor,
        body: Column(
          children: [
            BackButtonAppbar(
              text: "Shipping Address",
              threeDot: false,
              icon: threeDotImage,
              onPressedThreeDot: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: TextFieldWidget(
                        hint: "Name",
                        controller: shipController.nameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: NumberWidget(
                          readonly: false,
                          controller: shipController.phoneController),
                    ),
                    /*  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFieldWidget(
                        hint: "Pin Code",
                        controller: shipController.pincodeController,
                      ),
                    ), */
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 10),
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: shipController.pincodeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: whiteTextColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            hintText: "Pin Code",
                            counterText: "",
                            hintStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 30),
                      child: AppText(
                        text: "Address",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        fontSize: 14.sp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFieldWidget(
                        hint: "Address (House no, building, street, area)",
                        controller: shipController.addressController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFieldWidget(
                        hint: "Locality / Town",
                        controller: shipController.localityController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFieldWidget(
                        hint: "City / District",
                        controller: shipController.cityController,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 10, right: 16),
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          textCapitalization: TextCapitalization.words,
                          readOnly: true,
                          onTap: () {
                            if (shipController.showList.value) {
                              shipController.showList.value = false;
                            } else {
                              shipController.showList.value = true;
                            }
                          },
                          style: const TextStyle(
                            color: textColor,
                            fontFamily: "Franklin Gothic Regular",
                          ),
                          controller: shipController.stateController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            suffixIcon: const ImageIcon(
                              AssetImage(dropdownImage),
                              color: nameText,
                              size: 30,
                            ),
                            fillColor: whiteTextColor,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            counterText: "",
                            hintText: "Select State",
                            hintStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => shipController.showList.value
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: shipController.stateList.length,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            shipController
                                                    .stateController.text =
                                                shipController.stateList[index];
                                            shipController.showList.value =
                                                false;
                                          },
                                          child: Container(
                                            color: whiteTextColor,
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10),
                                                    child: Text(
                                                      shipController
                                                          .stateList[index],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: nameText,
                                                        fontFamily:
                                                            "Franklin Gothic Regular",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                index == 2
                                                    ? const SizedBox(
                                                        width: double.infinity,
                                                        height: 5,
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 16,
                                                                vertical: 2),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          color: colorSecondary,
                                                          height: 1,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 40, right: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: AppText(
                              text: "Use as Billing address",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 16.sp,
                            ),
                          ),
                          Obx(() => shipController.onButton.value
                              ? GestureDetector(
                                  onTap: () {
                                    shipController.onButton.value = false;
                                    shipController.defaultBilling.value = 0;
                                  },
                                  child: Image.asset(
                                    switchOnImage,
                                    width: 40,
                                    height: 24,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    shipController.onButton.value = true;
                                    shipController.defaultBilling.value = 1;
                                  },
                                  child: Image.asset(
                                    switchOffImage,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 24,
                                  ),
                                ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 24),
                      child: AppText(
                        text: "Save Address as",
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: loginText,
                        fontSize: 14.sp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: items.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        current = index;
                                        if (index == 0) {
                                          shipController.type.value = "Home";
                                        } else {
                                          shipController.type.value = "Work";
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(right: 5),
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: current == index
                                            ? btnTextColor
                                            : whiteBorderColor,
                                        borderRadius: current == index
                                            ? BorderRadius.circular(20)
                                            : BorderRadius.circular(20),
                                        border: current == index
                                            ? Border.all(
                                                color: btnTextColor, width: 1)
                                            : Border.all(
                                                color: textHintColor, width: 1),
                                      ),
                                      child: Center(
                                        child: AppText(
                                          text: items[index],
                                          color: current == index
                                              ? whiteBorderColor
                                              : textHintColor,
                                          fontSize: 12.sp,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: const Border(
                                      top: BorderSide(
                                          width: 2.0, color: greyBorder),
                                      left: BorderSide(
                                          width: 2.0, color: greyBorder),
                                      right: BorderSide(
                                          width: 2.0, color: greyBorder),
                                      bottom: BorderSide(
                                          width: 2.0, color: greyBorder),
                                    ),
                                  ),
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: shipController.isCheck.value,
                                    checkColor: btnTextColor,
                                    activeColor: whiteBorderColor,
                                    side: const BorderSide(
                                        color: btnTextColor, width: 0),
                                    onChanged: (value) {
                                      setState(() {
                                        shipController.isCheck.value = value!;
                                        if (shipController.isCheck.value) {
                                          shipController.defaultShipping.value =
                                              1;
                                        } else {
                                          shipController.defaultShipping.value =
                                              0;
                                        }
                                      });
                                    },
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (shipController.isCheck.value) {
                                    shipController.isCheck.value = false;
                                    shipController.defaultShipping.value = 0;
                                  } else {
                                    shipController.isCheck.value = true;
                                    shipController.defaultShipping.value = 1;
                                  }
                                },
                                child: AppText(
                                  text: "Make this my default address",
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: loginText,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => Container(
                  color: whiteBorderColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: getSingleButton(
                            label: "Save and Continue",
                            controller: shipController,
                            textColor: whiteBorderColor,
                            backgroundColor: colorPrimary,
                            onPressed: () {
                              if (shipController.checkvalidation(shipController
                                  .phoneController.text
                                  .toString()
                                  .trim())) {
                                shipController.phonenumber.value =
                                    "+91${shipController.phoneController.text.toString().trim()}";
                                shipController.callSaveAddress();
                              }
                            },
                            borderColor: colorPrimary),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
