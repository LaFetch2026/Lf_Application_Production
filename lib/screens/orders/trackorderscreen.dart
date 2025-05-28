import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widget/appbar/backbutton_appbar.dart';
import '../../common/widget/lists/dummy_ordertrack.dart';
import '../../common/widget/text/app_text.dart';
import '../../controllers/order_controller.dart';
import '../../core/constant/constants.dart';

class TrackOrderScreen extends StatefulWidget {
  final int orderId;

  const TrackOrderScreen({super.key, required this.orderId});

  @override
  State<TrackOrderScreen> createState() => TrackOrderScreenState();
}

class TrackOrderScreenState extends State<TrackOrderScreen> {
  final orderController = Get.put(OrderController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => orderController.getTrackorder(widget.orderId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const BackButtonAppbar(
            text: "Track Order",
            threeDot: false,
            backgroundColor: whiteColor,
            icon: threeDotImage,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => orderController.isTrack.value
                        ? const DummyOrderTrack()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20.sp,
                              ),
                              orderController.shipmentDetails["tracking_data"]
                                      .containsKey('error')
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 5.sp),
                                      child: Row(
                                        children: [
                                          AppText(
                                            text: "Status:",
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                            color: loginText,
                                            fontSize: 14,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.sp),
                                            child: AppText(
                                              text:
                                                  "Order ${orderController.shipmentDetails["tracking_data"]["shipment_track"][0]["current_status"]}",
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w500,
                                              color: greyTextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              orderController.shipmentDetails["tracking_data"]
                                      .containsKey('error')
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 5.sp),
                                      child: Row(
                                        children: [
                                          AppText(
                                            text: "Estimate Delivery Date:",
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w500,
                                            color: loginText,
                                            fontSize: 14,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.sp),
                                            child: AppText(
                                              text:
                                                  "${orderController.shipmentDetails["tracking_data"]["shipment_track"][0]["edd"] ?? ""}",
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w500,
                                              color: greyTextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              orderController.shipmentDetails["tracking_data"]
                                              ["shipment_track_activities"] !=
                                          null &&
                                      !orderController
                                          .shipmentDetails["tracking_data"]
                                          .containsKey('error')
                                  ? Container(
                                      color: whiteColor,
                                      width: double.infinity,
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.sp,
                                              vertical: 16.sp),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.sp, top: 16.sp),
                                                child: ListView.builder(
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const ScrollPhysics(),
                                                    itemCount: orderController
                                                        .shipmentDetails[
                                                            "tracking_data"][
                                                            "shipment_track_activities"]
                                                        .length,
                                                    padding: EdgeInsets.zero,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemBuilder: (ctx, index) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset(
                                                                  greenCheckImage,
                                                                  height: 24.sp,
                                                                  fit: BoxFit
                                                                      .cover),
                                                              index ==
                                                                      orderController
                                                                              .shipmentDetails["tracking_data"]["shipment_track_activities"]
                                                                              .length -
                                                                          1
                                                                  ? const SizedBox(
                                                                      height: 0,
                                                                    )
                                                                  : Container(
                                                                      width:
                                                                          2.sp,
                                                                      height:
                                                                          60.sp,
                                                                      color:
                                                                          greyBack,
                                                                    )
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12.sp),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                AppText(
                                                                  text: orderController.shipmentDetails["tracking_data"]
                                                                              [
                                                                              "shipment_track_activities"]
                                                                          [
                                                                          index]
                                                                      [
                                                                      "activity"],
                                                                  fontFamily:
                                                                      "Franklin Gothic",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      loginText,
                                                                  fontSize: 14,
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          top: 8
                                                                              .sp),
                                                                  child:
                                                                      AppText(
                                                                    text: orderController.shipmentDetails["tracking_data"]["shipment_track_activities"]
                                                                            [
                                                                            index]
                                                                        [
                                                                        "location"],
                                                                    fontFamily:
                                                                        "Franklin Gothic Regular",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        textHintColor,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    }),
                                              ),
                                            ],
                                          )),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                              orderController.shipmentDetails["tracking_data"]
                                      .containsKey('error')
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.sp,
                                          left: 16.sp,
                                          right: 16.sp),
                                      child: Center(
                                        child: Text(
                                            orderController.shipmentDetails[
                                                "tracking_data"]["error"],
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.red,
                                                fontFamily:
                                                    "Franklin Gothic Regular")),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    )
                            ],
                          ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
