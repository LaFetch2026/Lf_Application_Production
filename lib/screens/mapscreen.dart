// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/shipaddress_controller.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  final int addressId;
  final int cartId;
  const MapScreen({
    super.key,
    required this.addressId,
    required this.cartId,
  });

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final shipController = Get.put(ShipAddressController());
  Completer<GoogleMapController> googleMapController = Completer();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String draggedAddress = "";
  late String mapStyle;
  bool showAddress = false;
  Placemark? address;
  List<Placemark>? placeMarks;

  @override
  void initState() {
    if (widget.addressId != 0) {
      shipController.getAddressDetails(widget.addressId, 2, widget.cartId);
    } else {
      _init();
    }
    rootBundle.loadString('assets/map_style.json').then((string) {
      mapStyle = string;
    });
    super.initState();
  }

  _init() {
    showAddress = true;
    _gotoUserCurrentPosition();
    shipController.cameraPosition.value =
        CameraPosition(target: shipController.defaultLatLng.value, zoom: 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        body: Obx(() => shipController.isDetails.value
            ? Padding(
                padding: EdgeInsets.all(40.0.sp),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          _getMap(),
                          Padding(
                            padding: EdgeInsets.only(top: 40.0.sp, left: 10.sp),
                            child: InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Image.asset(
                                  backWhiteArrow,
                                  height: 16.sp,
                                  width: 16.sp,
                                  color: colorPrimary,
                                )),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                _gotoUserCurrentPosition();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.sp, vertical: 30.sp),
                                child: Icon(
                                  Icons.location_disabled_sharp,
                                  size: 20.sp,
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                          _getCustomPin(),
                        ],
                      )),
                  Expanded(
                      flex: 0,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(30.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5.sp,
                                  blurRadius: 7.sp,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: _showDraggedAddress(),
                          ),
                        ],
                      ))
                ],
              )));
  }

  Widget _showDraggedAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.sp, right: 10.sp, top: 15.sp),
          child: Row(
            children: [
              Image.asset(
                locationIcon,
                width: 25.sp,
                height: 25.sp,
                color: colorPrimary,
              ),
              SizedBox(width: 6.sp),
              Text("Address",
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30.sp, right: 10.sp, top: 15.sp),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: <Widget>[
                    Shimmer.fromColors(
                      enabled: false,
                      baseColor: Colors.black,
                      highlightColor: Colors.grey,
                      child: showAddress
                          ? DummyContainer(height: 20, width: double.infinity)
                          : Text(draggedAddress,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: "Gilroy",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 50.sp,
            child: ElevatedButton(
              onPressed: () async {
                if (shipController.checkLocationValidation()) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ShippingAddressScreen(
                          addressId: widget.addressId,
                          cartId: widget.cartId,
                          latitude: shipController.lat.value,
                          longitude: shipController.lng.value)));
                  await analytics.logEvent(
                    name: 'shipAddress_page',
                    parameters: <String, Object>{
                      'page_name': 'shipAddress_page',
                    },
                  );
                } else {
                  _determineUserCurrentPosition();
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(colorPrimary),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              child: Text("Next",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontFamily: 'Franklin Gothic')),
            ),
          ),
        )
      ],
    );
  }

  Widget _getMap() {
    return GoogleMap(
      initialCameraPosition: shipController.cameraPosition.value,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      onCameraIdle: () {
        _getAddress(shipController.draggedLatLng.value);
      },
      onCameraMove: (cameraPosition) {
        shipController.draggedLatLng.value = cameraPosition.target;
      },
      onMapCreated: (GoogleMapController controller) {
        if (!googleMapController.isCompleted) {
          googleMapController.complete(controller);
          controller.setMapStyle(mapStyle);
        }
      },
    );
  }

  Widget _getCustomPin() {
    return Center(
      child: SizedBox(
        width: 150.sp,
        child: Lottie.asset(locationAnim, width: 100.sp, height: 100.sp),
      ),
    );
  }

  /// get address from dragged pin
  Future _getAddress(LatLng position) async {
    shipController.lat.value = position.latitude;
    shipController.lng.value = position.longitude;
    placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    address = placeMarks![0];
    String addressString =
        "${address!.street},${address!.locality},${address!.administrativeArea}, ${address!.country}";
    setState(() {
      showAddress = false;
      draggedAddress = addressString;
    });
  }

  Future _gotoUserCurrentPosition() async {
    Position currentPosition = await _determineUserCurrentPosition();
    _gotoSpecificPosition(
        LatLng(currentPosition.latitude, currentPosition.longitude));
  }

  Future _gotoSpecificPosition(LatLng position) async {
    GoogleMapController mapController = await googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15)));
    await _getAddress(position);
  }

  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      debugPrint("user don't enable location permission");
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        debugPrint("user denied location permission");
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      debugPrint("user denied permission forever");
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
