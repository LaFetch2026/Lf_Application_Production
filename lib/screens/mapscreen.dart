// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lafetch/commonwidget/app_text.dart';
import 'package:lafetch/commonwidget/appbarwidgets/saveaddress_appbar.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
//import 'package:lottie/lottie.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String draggedAddress = "";
  String localityName = "";
  String stateName = "";
  String pincode = "";
  late String mapStyle;
  bool showAddress = false;
  Placemark? address;
  List<Placemark>? placeMarks;
  Timer? debounce;
  static const kGoogleApiKey = "AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc";
  TextEditingController controller = TextEditingController();
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc');

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => (timeStamp) {
          shipController.locationList.clear();
          shipController.locationController.clear();
        });

    if (widget.addressId != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          shipController.getAddressDetails(widget.addressId, 2, widget.cartId));
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

  /*  void searchLocation(String value) async {
    List<Location> locations = await locationFromAddress(value);
    if (locations.isNotEmpty) {
      onLocationSelected(
          LatLng(locations.first.latitude, locations.first.longitude));
    }
  }

  void onLocationSelected(LatLng location) async {
    GoogleMapController mapController = await googleMapController.future;
    mapController.animateCamera(CameraUpdate.newLatLng(location));
  } */

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 100), () {
      // searchLocation(query);
      shipController.getSearchLocation(query);
    });
  }

  /*  Future<void> searchPlaces() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      components: [Component(Component.country, 'in')],
      mode: Mode.overlay,
      radius: 10000000,
      types: [],
      language: "en",
    );

    if (p != null) {
      // Safely handle the nullable Prediction
      Prediction prediction = p; // This is safe because we checked for null.
      print("Selected place: ${prediction.description}");
    } else {
      print("No place selected");
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
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
                          /*  Padding(
                            padding: EdgeInsets.only(top: 50.0.sp, left: 10.sp),
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
                          ), */
                          /*  Padding(
                            padding:
                                EdgeInsets.only(top: 100.0.sp, left: 10.sp),
                            child: GestureDetector(
                              onTap: () {
                                searchPlaces();
                              },
                              child: SizedBox(
                                height: 30.sp,
                                width: 30.sp,
                                child: CircleAvatar(
                                  backgroundColor: blackColor,
                                  child: Image.asset(
                                    searchImage,
                                    color: whiteBack,
                                    height: 20.sp,
                                    width: 20.sp,
                                  ),
                                ),
                              ),
                            ),
                          ), */
                          _getCustomPin(),
                          SaveAddressAppbar(
                            text: "Select Address",
                            onPressedWishlist: () {
                              Get.off(BottomNavScreen(
                                index: 2,
                              ));
                            },
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 90.sp),
                            child: Divider(
                              color: dividerColor,
                              height: 1.sp,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 91.sp),
                            height: 12.sp,
                            color: whiteColor,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 120.sp),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 16.sp,
                                right: 16.sp,
                              ),
                              child: MediaQuery.of(context).size.width < 600
                                  ? SizedBox(
                                      height: 40.sp,
                                      child: RawKeyboardListener(
                                        focusNode: FocusNode(),
                                        onKey: (value) {
                                          print(value);
                                          if (value is RawKeyDownEvent) {}
                                        },
                                        child: TextField(
                                          controller:
                                              shipController.locationController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: titleColor,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                          ),
                                          onChanged: (value) {
                                            onSearchChanged(value);
                                          },
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            filled: true,
                                            isDense: true,
                                            fillColor: whiteColor,
                                            prefixIcon: Icon(Icons.search,
                                                size: 20.sp, color: titleColor),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: borderColor)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              borderSide: const BorderSide(
                                                  color: borderColor),
                                            ),
                                            counterText: "",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10.sp),
                                            hintText:
                                                "Search for building, street name, or area",
                                            hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                color: searchTextColor,
                                                fontFamily:
                                                    "Franklin Gothic Regular"),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 40.sp,
                                      child: RawKeyboardListener(
                                        focusNode: FocusNode(),
                                        onKey: (value) {
                                          print(value);
                                          if (value is RawKeyDownEvent) {}
                                        },
                                        child: TextField(
                                          controller:
                                              shipController.locationController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: titleColor,
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                          ),
                                          onChanged: (value) {
                                            onSearchChanged(value);
                                          },
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            filled: true,
                                            isDense: true,
                                            fillColor: whiteColor,
                                            prefixIcon: Icon(Icons.search,
                                                size: 20.sp, color: titleColor),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: borderColor)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                              borderSide: const BorderSide(
                                                  color: borderColor),
                                            ),
                                            counterText: "",
                                            hintText:
                                                "Search for building, street name, or area",
                                            hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                color: searchTextColor,
                                                fontFamily:
                                                    "Franklin Gothic Regular"),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 160.sp, left: 16.sp, right: 16.sp),
                            child: Container(
                              // height: 200.sp,
                              child: shipController.isLocation.value
                                  ? Container(
                                      color: whiteColor,
                                      child: Center(
                                          child: CircularProgressIndicator()))
                                  : ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      itemCount:
                                          shipController.locationList.length,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (ctx, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                shipController
                                                    .locationController
                                                    .clear();
                                                PlacesDetailsResponse details =
                                                    await places.getDetailsByPlaceId(
                                                        shipController
                                                                .locationList[
                                                            index]["place_id"]);
                                                double latitude = details.result
                                                    .geometry!.location.lat;
                                                double longitude = details
                                                    .result
                                                    .geometry!
                                                    .location
                                                    .lng;
                                                shipController.locationList
                                                    .clear();
                                                print(" $latitude  $longitude");
                                                GoogleMapController
                                                    mapController =
                                                    await googleMapController
                                                        .future;
                                                mapController.animateCamera(
                                                    CameraUpdate
                                                        .newCameraPosition(
                                                            CameraPosition(
                                                                target: LatLng(
                                                                    latitude,
                                                                    longitude),
                                                                zoom: 15)));
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                              },
                                              child: Container(
                                                color: whiteColor,
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10.sp,
                                                                horizontal:
                                                                    16.sp),
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          6.sp),
                                                              child: ImageIcon(
                                                                AssetImage(
                                                                    locationIcon),
                                                                color: nameText,
                                                                size: 20.sp,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                shipController
                                                                            .locationList[
                                                                        index][
                                                                    "description"],
                                                                maxLines: 5,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color:
                                                                      nameText,
                                                                  fontFamily:
                                                                      "Franklin Gothic Regular",
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    index ==
                                                            shipController
                                                                    .locationList
                                                                    .length -
                                                                1
                                                        ? SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height: 5.sp,
                                                          )
                                                        : Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16.sp,
                                                                    vertical:
                                                                        2.sp),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              color:
                                                                  colorSecondary,
                                                              height: 1.sp,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                            ),
                          ),
                          shipController.locationList.isNotEmpty
                              ? SizedBox(
                                  height: 0,
                                )
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                    onTap: () {
                                      _gotoUserCurrentPosition();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.sp, vertical: 20.sp),
                                      child: Container(
                                        height: 40.sp,
                                        decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.sp))),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.sp),
                                          child: Row(
                                            children: [
                                              ImageIcon(
                                                AssetImage(currentLocationIcon),
                                                color: homeAppBarColor,
                                                size: 20.sp,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.sp),
                                                child: AppText(
                                                  text:
                                                      "Use my current location",
                                                  color: homeAppBarColor,
                                                  fontSize: 16,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                              /*  borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(30.0)), */
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
          padding: EdgeInsets.only(left: 16.sp, top: 20.sp),
          child: Row(
            children: [
              Image.asset(
                locationPinImage,
                width: 29.sp,
                height: 29.sp,
                color: colorPrimary,
              ),
              SizedBox(width: 6.sp),
              showAddress
                  ? DummyContainer(height: 20, width: 100.sp)
                  : Text(localityName,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16.sp,
                          fontFamily: 'Franklin Gothic',
                          fontWeight: FontWeight.w500,
                          color: homeAppBarColor)),
              Expanded(child: SizedBox(width: 0.sp)),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: MediaQuery.of(context).size.height.sp,
                    ),
                    builder: (ctx) {
                      return ShippingAddressScreen(
                          addressId: widget.addressId,
                          cartId: widget.cartId,
                          stateName: stateName,
                          pincode: pincode,
                          address: draggedAddress,
                          localityName: localityName,
                          latitude: shipController.lat.value,
                          longitude: shipController.lng.value);
                    },
                  );
                  await analytics.logEvent(
                    name: 'shipAddress_page',
                    parameters: <String, Object>{
                      'page_name': 'shipAddress_page',
                    },
                  );
                },
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 2.sp),
                    child: Text(
                      "Change".toUpperCase(),
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w400,
                        color: appBarColor,
                        fontSize: 10.sp,
                      ),
                    )),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 48.sp, right: 10.sp, top: 5.sp, bottom: 10.sp),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: <Widget>[
                    Shimmer.fromColors(
                      enabled: false,
                      baseColor: subtitleColor,
                      highlightColor: subtitleColor,
                      child: showAddress
                          ? DummyContainer(height: 20, width: double.infinity)
                          : Text(draggedAddress,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: subtitleColor,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Franklin Gothic Regular',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            if (shipController.checkLocationValidation()) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: MediaQuery.of(context).size.height.sp,
                ),
                builder: (ctx) {
                  return ShippingAddressScreen(
                      addressId: widget.addressId,
                      cartId: widget.cartId,
                      pincode: pincode,
                      stateName: stateName,
                      address: draggedAddress,
                      localityName: localityName,
                      latitude: shipController.lat.value,
                      longitude: shipController.lng.value);
                },
              );
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
          child: Container(
            width: double.infinity,
            height: 80.sp,
            color: homeAppBarColor,
            margin: EdgeInsets.only(top: 20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.sp),
                  child: Text("Confirm Location".toUpperCase(),
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontFamily: 'Franklin Gothic')),
                ),
                Container(
                  height: 5.sp,
                  width: 140.sp,
                  margin: EdgeInsets.only(top: 34.sp),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(5.sp)),
                )
              ],
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
        child: /*  Lottie.asset(
          locationAnim,
          width: 100.sp,
          height: 100.sp,
        ) */
            Image.asset(
          locationPinImage,
          width: 50.sp,
          height: 50.sp,
          color: colorPrimary,
        ),
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
        "${address!.street},${address!.locality},${address!.administrativeArea}, ${address!.postalCode}";
    setState(() {
      showAddress = false;
      draggedAddress = addressString;
      localityName = "${address!.locality}";
      pincode = "${address!.postalCode}";
      stateName = "${address!.administrativeArea}";
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
