import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/homewidget/dummy_ordertrack.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/appbarwidgets/backbutton_appbar.dart';
import '../../controller/order_controller.dart';
import '../../utils/constants.dart';

class TrackOrderScreen extends StatefulWidget {
  final int orderId;
  const TrackOrderScreen({super.key, required this.orderId});

  @override
  State<TrackOrderScreen> createState() => TrackOrderScreenState();
}

class TrackOrderScreenState extends State<TrackOrderScreen> {
  final orderController = Get.put(OrderController());
  List<String> orderItem = ["CONFIRMED", "PACKED", "SHIPPED", "DELIVERED"];
  List<String> trackOrderItem2 = [
    "Order Confirmed",
    "Packed",
    "Shipped",
    "Delivered"
  ];

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
                  /*     Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 500,
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: initialCameraPosition,
                            markers: markers,
                            zoomControlsEnabled: true,
                            mapType: MapType.normal,
                            onMapCreated: (GoogleMapController controller) {
                              googleMapController = controller;
                              if (lat != 0.0) {
                                apiPosition();
                              }
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 430),
                          height: 40,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: colorPrimary,
                              width: 1,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              Position position = await determinePosition();

                              googleMapController.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                      target: LatLng(position.latitude,
                                          position.longitude),
                                      zoom: 14)));

                              markers.clear();

                              markers.add(Marker(
                                  markerId: const MarkerId('currentLocation'),
                                  position: LatLng(
                                      position.latitude, position.longitude)));
                              lat = position.latitude;
                              lng = position.longitude;

                              setState(() {});
                            },
                            child: Center(
                              child: Row(children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: const Icon(
                                    Icons.location_disabled_sharp,
                                    size: 20,
                                    color: colorPrimary,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: const Text(
                                    "Use current location",
                                    style: TextStyle(color: colorPrimary),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                */
                  Obx(() => orderController.isTrack.value
                      ? const DummyOrderTrack()
                      : orderController.trackList.isNotEmpty
                          ? Container(
                              color: whiteColor,
                              width: double.infinity,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 20, top: 16),
                                        child: ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            physics: const ScrollPhysics(),
                                            itemCount: orderItem.length,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (ctx, index) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      orderController.trackList
                                                              .any((map) =>
                                                                  map['status_details'] ==
                                                                  orderItem[
                                                                      index])
                                                          ? Image.asset(
                                                              greenCheckImage,
                                                              height: 24,
                                                              fit: BoxFit.cover)
                                                          : Image.asset(
                                                              whiteCircleImage,
                                                              height: 24,
                                                              fit:
                                                                  BoxFit.cover),
                                                      index == 3
                                                          ? const SizedBox(
                                                              height: 0,
                                                            )
                                                          : Container(
                                                              width: 2,
                                                              height: 60,
                                                              color: greyBack,
                                                            )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 12),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AppText(
                                                          text: orderController
                                                                  .trackList
                                                                  .any((map) =>
                                                                      map['status_details'] ==
                                                                      orderItem[
                                                                          index])
                                                              ? trackOrderItem2[
                                                                  index]
                                                              : trackOrderItem2[
                                                                  index],
                                                          fontFamily:
                                                              "Franklin Gothic",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: loginText,
                                                          fontSize: 14.sp,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 8),
                                                          child: AppText(
                                                            text: orderController
                                                                    .trackList
                                                                    .any((map) =>
                                                                        map['status_details'] ==
                                                                        orderItem[
                                                                            index])
                                                                ? orderController
                                                                            .trackList[
                                                                        index]
                                                                    ["created"]
                                                                : "",
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                textHintColor,
                                                            fontSize: 14.sp,
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
                          : const Padding(
                              padding: EdgeInsets.only(top: 200),
                              child: Center(
                                child: Text("No Information Found",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: "Franklin Gothic Regular")),
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
