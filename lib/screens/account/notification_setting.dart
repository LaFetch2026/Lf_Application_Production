// ignore_for_file: avoid_print

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/backbutton_appbar.dart';
import 'package:lafetch/controller/notification_controller.dart';
import 'package:lafetch/utils/constants.dart';

import '../../commonwidget/app_text.dart';
import '../../commonwidget/common_widgets.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({
    super.key,
  });

  @override
  State<NotificationSettingScreen> createState() =>
      NotificationSettingScreenState();
}

class NotificationSettingScreenState extends State<NotificationSettingScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Notifications & Settings",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (controller.isOrder.value) {
                                controller.isOrder.value = false;
                                controller.orderValue.value = 0;
                              } else {
                                controller.isOrder.value = true;
                                controller.orderValue.value = 1;
                              }
                              /* await analytics.logEvent(
                                name: 'default_addressClick',
                                parameters: <String, Object>{
                                  'page_name': 'default_addressClick',
                                },
                              ); */
                            },
                            child: AppText(
                              text: "Order notification ",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 14.sp,
                            ),
                          ),
                          Expanded(
                            child: const SizedBox(
                              width: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
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
                                  value: controller.isOrder.value,
                                  checkColor: btnTextColor,
                                  activeColor: whiteBorderColor,
                                  side: const BorderSide(
                                      color: btnTextColor, width: 0),
                                  onChanged: (value) {
                                    setState(() {
                                      controller.isOrder.value = value!;
                                      if (controller.isOrder.value) {
                                        controller.orderValue.value = 1;
                                      } else {
                                        controller.orderValue.value = 0;
                                      }
                                    });
                                  },
                                )),
                          ),
                        ],
                      ),
                    )),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (controller.isOffer.value) {
                                controller.isOffer.value = false;
                                controller.offerValue.value = 0;
                              } else {
                                controller.isOffer.value = true;
                                controller.offerValue.value = 1;
                              }
                              /*  await analytics.logEvent(
                                name: 'default_addressClick',
                                parameters: <String, Object>{
                                  'page_name': 'default_addressClick',
                                },
                              ); */
                            },
                            child: AppText(
                              text: "Offers notification ",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 14.sp,
                            ),
                          ),
                          Expanded(
                            child: const SizedBox(
                              width: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
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
                                  value: controller.isOffer.value,
                                  checkColor: btnTextColor,
                                  activeColor: whiteBorderColor,
                                  side: const BorderSide(
                                      color: btnTextColor, width: 0),
                                  onChanged: (value) {
                                    setState(() {
                                      controller.isOffer.value = value!;
                                      if (controller.isOffer.value) {
                                        controller.offerValue.value = 1;
                                      } else {
                                        controller.offerValue.value = 0;
                                      }
                                    });
                                  },
                                )),
                          ),
                        ],
                      ),
                    )),
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (controller.isPermotion.value) {
                                controller.isPermotion.value = false;
                                controller.permotionValue.value = 0;
                              } else {
                                controller.isPermotion.value = true;
                                controller.permotionValue.value = 1;
                              }
                              /*  await analytics.logEvent(
                                name: 'default_addressClick',
                                parameters: <String, Object>{
                                  'page_name': 'default_addressClick',
                                },
                              ); */
                            },
                            child: AppText(
                              text: "Promotional notification ",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 14.sp,
                            ),
                          ),
                          Expanded(
                            child: const SizedBox(
                              width: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
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
                                  value: controller.isPermotion.value,
                                  checkColor: btnTextColor,
                                  activeColor: whiteBorderColor,
                                  side: const BorderSide(
                                      color: btnTextColor, width: 0),
                                  onChanged: (value) {
                                    setState(() {
                                      controller.isPermotion.value = value!;
                                      if (controller.isPermotion.value) {
                                        controller.permotionValue.value = 1;
                                      } else {
                                        controller.permotionValue.value = 0;
                                      }
                                    });
                                  },
                                )),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: getSingleButton(
                label: "Submit",
                textColor: whiteBorderColor,
                backgroundColor: btnTextColor,
                //  controller: otpController,
                onPressed: () {},
                borderColor: btnTextColor),
          )
        ],
      ),
    );
  }
}
