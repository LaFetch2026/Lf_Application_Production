// ignore_for_file: avoid_print
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/doublebutton_new.dart';
import 'package:lafetch/controller/shipaddress_controller.dart';
import '../commonwidget/app_text.dart';
import '../commonwidget/appbarwidgets/saveaddress_appbar.dart';
import '../commonwidget/loginwidgets/number_widget.dart';
import '../commonwidget/text_field.dart';
import '../utils/constants.dart';
import 'bottomnavscreen.dart';

class ShippingAddressScreen extends StatefulWidget {
  final int addressId;
  final int cartId;
  final String address;
  final String localityName;
  final String stateName;
  final String pincode;
  final double latitude;
  final double longitude;
  const ShippingAddressScreen({
    super.key,
    required this.addressId,
    required this.cartId,
    required this.stateName,
    required this.pincode,
    required this.address,
    required this.localityName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ShippingAddressScreen> createState() => ShippingAddressScreenState();
}

class ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final shipController = Get.put(ShipAddressController());
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Timer? debounce;
  /*  late GoogleMapController googleMapController;
  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);
  Set<Marker> markers = {};
  String cityname = ""; */

  List<String> items = [
    "Home",
    "Work",
  ];

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      shipController.getCitiesData();
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => shipController.getCitiesData());
    if (widget.addressId != 0) {
      shipController.stateController.text = widget.stateName;
      shipController.pincodeController.text = widget.pincode;
      shipController.cityController.text = widget.localityName;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        shipController.getAddressDetails(widget.addressId, 1, widget.cartId);
      });
    } else {
      shipController.stateController.text = widget.stateName;
      shipController.pincodeController.text = widget.pincode;
      shipController.cityController.text = widget.localityName;
      shipController.nameController.clear();
      shipController.phoneController.clear();
      // shipController.pincodeController.clear();
      shipController.addressController.clear();
      shipController.localityController.clear();
      // shipController.stateController.clear();
      shipController.searchController.clear();
      shipController.addressTypeController.clear();
      shipController.defaultBilling.value = 0;
      shipController.defaultShipping.value = 0;
      shipController.type.value = "";
      shipController.cityId.value = 0;
      shipController.current.value = 3;
      shipController.onButton.value = false;
      shipController.isCheck.value = false;
      shipController.showList.value = false;
    }
    if (widget.cartId != 0) {
      shipController.cartId.value = widget.cartId;
    }
    super.initState();
  }

  /*  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Turn on Location")));
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  void apiPosition() async {
    print("api position");
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(shipController.lat.value, shipController.lng.value),
            zoom: 16)));
    markers.clear();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        shipController.lat.value, shipController.lng.value);
    Placemark place1 = placemarks[0];
    cityname = place1.subLocality.toString();
    markers.add(Marker(
        draggable: true,
        onDragEnd: (newPosition) async {
          print(newPosition.latitude);
          print(newPosition.longitude);
          shipController.lat.value = newPosition.latitude;
          shipController.lng.value = newPosition.longitude;
          List<Placemark> placemarks = await placemarkFromCoordinates(
              newPosition.latitude, newPosition.longitude);
          Placemark place1 = placemarks[0];
          cityname = place1.subLocality.toString();
          setState(() {});
        },
        markerId: const MarkerId('1'),
        infoWindow: InfoWindow(title: cityname),
        onDrag: (value) {
          print(value.latitude);
        },
        position: LatLng(shipController.lat.value, shipController.lng.value)));
    setState(() {});
  }
 */
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
        backgroundColor: whiteColor,
        body: Column(
          children: [
            SaveAddressAppbar(
              text: "Select Address",
              onPressedWishlist: () {
                Get.off(BottomNavScreen(
                  index: 2,
                ));
              },
            ),
            Container(
              color: dividerColor,
              height: 1.sp,
            ),
            Expanded(
              child: SingleChildScrollView(
                  child: Obx(
                () => shipController.isDetails.value
                    ? Padding(
                        padding: EdgeInsets.all(40.0.sp),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*   Stack(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: GoogleMap(
                                      initialCameraPosition:
                                          initialCameraPosition,
                                      markers: markers,
                                      zoomControlsEnabled: true,
                                      mapType: MapType.normal,
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        googleMapController = controller;
                                        if (shipController.lat.value != 0.0) {
                                          apiPosition();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 250),
                                    height: 40,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: colorPrimary,
                                        width: 1,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(7)),
                                    ),
                                    child: GestureDetector(
                                      onTap: () async {
                                        Position position =
                                            await determinePosition();
                                        googleMapController.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                    target: LatLng(
                                                        position.latitude,
                                                        position.longitude),
                                                    zoom: 16)));
                                        markers.clear();
                                        List<Placemark> placemarks =
                                            await placemarkFromCoordinates(
                                                position.latitude,
                                                position.longitude);
                                        Placemark place1 = placemarks[0];
                                        cityname = place1.subLocality.toString();
                                        print("cityname $cityname");
                                        markers.add(Marker(
                                            draggable: true,
                                            markerId: const MarkerId('1'),
                                            infoWindow: InfoWindow(
                                              title: cityname,
                                            ),
                                            onDragEnd: (newPosition) async {
                                              print(newPosition.latitude);
                                              print(newPosition.longitude);
                                              shipController.lat.value =
                                                  newPosition.latitude;
                                              shipController.lng.value =
                                                  newPosition.longitude;
                                              List<Placemark> placemarks =
                                                  await placemarkFromCoordinates(
                                                      newPosition.latitude,
                                                      newPosition.longitude);
                                              Placemark place1 = placemarks[0];
                                              cityname =
                                                  place1.subLocality.toString();
                                              setState(() {});
                                            },
                                            position: LatLng(position.latitude,
                                                position.longitude)));
                                        shipController.lat.value =
                                            position.latitude;
                                        shipController.lng.value =
                                            position.longitude;
                                        print(shipController.lat.value);
                                        print(shipController.lng.value);
                                        setState(() {});                                     
                                      },
                                      child: Center(
                                        child: Row(children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            child: const Icon(
                                              Icons.location_disabled_sharp,
                                              size: 20,
                                              color: colorPrimary,
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            child: const Text(
                                              "Use current location",
                                              style:
                                                  TextStyle(color: colorPrimary),
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
                          /*     Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 12.sp),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "CHANGE ADDRESS",
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 16.sp,
                                      fontFamily: "Franklin Gothic Semibold",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Image.asset(blackCrossImage,
                                        height: 18.sp,
                                        width: 18.sp,
                                        color: appBarColor,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ],
                            ),
                          ),
                         */
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
                                Text(widget.localityName,
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 16.sp,
                                        fontFamily: 'Franklin Gothic',
                                        fontWeight: FontWeight.w500,
                                        color: homeAppBarColor)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 48.sp,
                                right: 10.sp,
                                top: 5.sp,
                                bottom: 10.sp),
                            child: Text(
                              widget.address,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: subtitleColor,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Franklin Gothic Regular',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.sp, top: 32.sp),
                            child: Text(
                              "PERSONAL DETAILS",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12.sp,
                                fontFamily: "Franklin Gothic Semibold",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 12.sp),
                            child: TextFieldWidget(
                              hint: "Name",
                              controller: shipController.nameController,
                            ),
                          ),
                          /*  shipController.checkvalidation()
                                ? SizedBox(
                                    height: 0,
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: 20.sp,
                                      right: 20.sp,
                                      top: 2.sp,
                                    ),
                                    child: AppText(
                                      text: shipController.nameError.value,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: redColor,
                                      fontSize: 12,
                                    ),
                                  ), */
                          Padding(
                            padding: EdgeInsets.only(top: 0.sp),
                            child: NumberWidget(
                                readonly: false,
                                login: false,
                                fillColor: whiteColor,
                                onPressedLogin: () {},
                                controller: shipController.phoneController),
                          ),
                          /*    Padding(
                            padding: EdgeInsets.only(
                                left: 16.sp, right: 16.sp, top: 10.sp),
                            child: SizedBox(
                              height: 44.sp,
                              child: RawKeyboardListener(
                                focusNode: FocusNode(),
                                onKey: (value) {
                                  print(value);
                                  if (value is RawKeyDownEvent) {
                                    shipController.stateController.clear();
                                    shipController.cityId.value = 0;
                                  }
                                },
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14.sp,
                                    fontFamily: "Franklin Gothic Regular",
                                  ),
                                  controller: shipController.pincodeController,
                                  onChanged: (value) {
                                    if (value.length == 6) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      shipController.getCitiesData();
                                    } else {
                                      shipController.stateController.clear();
                                      shipController.cityId.value = 0;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: whiteColor,
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: borderColor)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1.sp),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1.sp),
                                      borderSide:
                                          const BorderSide(color: borderColor),
                                    ),
                                    hintText: "Pin Code",
                                    counterText: "",
                                    hintStyle: TextStyle(
                                        fontSize: 14.sp, color: subtitleColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                         */ /*  Padding(
                              padding: EdgeInsets.only(left: 16.sp, top: 30.sp),
                              child: AppText(
                                text: "Address",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: blackColor,
                                fontSize: 14,
                              ),
                            ), */
                          Padding(
                            padding: EdgeInsets.only(top: 20.sp),
                            child: TextFieldWidget(
                              hint:
                                  "Address (House no, building, street, area)",
                              controller: shipController.addressController,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8.sp),
                            child: TextFieldWidget(
                              hint: "Locality / Town",
                              controller: shipController.localityController,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.sp, top: 30.sp),
                            child: AppText(
                              text: "Save As".toUpperCase(),
                              fontFamily: "Franklin Gothic Semibold",
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8.sp),
                            child: TextFieldWidget(
                              hint: "HOME/FLAT/HOUSE/OFFICE",
                              controller: shipController.addressTypeController,
                            ),
                          ),
                          /*   Padding(
                            padding: EdgeInsets.only(
                                left: 16.sp, top: 10.sp, right: 16.sp),
                            child: SizedBox(
                              height: 44.sp,
                              child: TextField(
                                textCapitalization: TextCapitalization.words,
                                readOnly: true,
                                onTap: () {
                                  if (shipController.showList.value) {
                                    shipController.showList.value = false;
                                  } else {
                                    shipController.showList.value = true;
                                    shipController.getCitiesData();
                                    shipController.searchController.clear();
                                  }
                                },
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14.sp,
                                  fontFamily: "Franklin Gothic Regular",
                                ),
                                controller: shipController.stateController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  suffixIcon: ImageIcon(
                                    AssetImage(dropdownImage),
                                    color: nameText,
                                    size: 30.sp,
                                  ),
                                  fillColor: whiteColor,
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: borderColor)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                    borderSide:
                                        const BorderSide(color: borderColor),
                                  ),
                                  counterText: "",
                                  hintText: "Select City",
                                  hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      color: subtitleColor),
                                ),
                              ),
                            ),
                          ),
                          */
                          /*  Obx(
                            () => shipController.showList.value
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 16.sp, right: 16.sp),
                                    child: Container(
                                      color: greyback,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10.sp,
                                          ),
                                          MediaQuery.of(context).size.width <
                                                  600
                                              ? SizedBox(
                                                  height: 30.sp,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 16.sp,
                                                        right: 16.sp),
                                                    child: RawKeyboardListener(
                                                      focusNode: FocusNode(),
                                                      onKey: (value) {
                                                        print(value);
                                                        if (value
                                                            is RawKeyDownEvent) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: TextField(
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: textColor,
                                                          fontSize: 14.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                        ),
                                                        controller: shipController
                                                            .searchController,
                                                        onChanged:
                                                            onSearchChanged,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          isDense: true,
                                                          fillColor: whiteColor,
                                                          prefixIcon: Icon(
                                                              Icons.search,
                                                              size: 20.sp,
                                                              color:
                                                                  Colors.grey),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              borderColor)),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color:
                                                                        borderColor),
                                                          ),
                                                          counterText: "",
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.sp),
                                                          hintText: "Search",
                                                          hintStyle: TextStyle(
                                                              fontSize: 14.sp),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 30.sp,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 16.sp,
                                                        right: 16.sp),
                                                    child: RawKeyboardListener(
                                                      focusNode: FocusNode(),
                                                      onKey: (value) {
                                                        print(value);
                                                        if (value
                                                            is RawKeyDownEvent) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: TextField(
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: textColor,
                                                          fontSize: 14.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                        ),
                                                        controller: shipController
                                                            .searchController,
                                                        onChanged:
                                                            onSearchChanged,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          isDense: true,
                                                          fillColor: whiteColor,
                                                          suffixIcon: InkWell(
                                                            onTap: () {},
                                                            child: ImageIcon(
                                                              AssetImage(
                                                                  greyCrossImage),
                                                              size: 14.sp,
                                                            ),
                                                          ),
                                                          prefixIcon: Icon(
                                                              Icons.search,
                                                              size: 20.sp,
                                                              color:
                                                                  Colors.grey),
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              borderColor)),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color:
                                                                        borderColor),
                                                          ),
                                                          counterText: "",
                                                          hintText: "Search",
                                                          hintStyle: TextStyle(
                                                              fontSize: 14.sp),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: 10.sp),
                                            child: Container(
                                              height: 200.sp,
                                              child: shipController.isCity.value
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : shipController
                                                          .cityList.isNotEmpty
                                                      ? ListView.builder(
                                                          primary: false,
                                                          shrinkWrap: true,
                                                          physics:
                                                              const ScrollPhysics(),
                                                          itemCount:
                                                              shipController
                                                                  .cityList
                                                                  .length,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          itemBuilder:
                                                              (ctx, index) {
                                                            return Column(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    shipController
                                                                        .stateController
                                                                        .text = shipController
                                                                            .cityList[index]
                                                                        [
                                                                        "name"];
                                                                    shipController
                                                                        .cityId
                                                                        .value = shipController
                                                                            .cityList[
                                                                        index]["id"];
                                                                    shipController
                                                                        .showList
                                                                        .value = false;
                                                                    shipController
                                                                        .searchController
                                                                        .clear();
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                            FocusNode());
                                                                    shipController
                                                                        .getCitiesData();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        greyback,
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(vertical: 10.sp),
                                                                            child:
                                                                                Text(
                                                                              shipController.cityList[index]["name"],
                                                                              style: TextStyle(
                                                                                fontSize: 14.sp,
                                                                                color: nameText,
                                                                                fontFamily: "Franklin Gothic Regular",
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        index ==
                                                                                shipController.cityList.length - 1
                                                                            ? SizedBox(
                                                                                width: double.infinity,
                                                                                height: 5.sp,
                                                                              )
                                                                            : Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 2.sp),
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  color: colorSecondary,
                                                                                  height: 1.sp,
                                                                                ),
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          })
                                                      : Center(
                                                          child: AppText(
                                                            text:
                                                                "No city found",
                                                            color: loginText,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                  ),
                          ),
                          */
                          /*   Padding(
                            padding: EdgeInsets.only(
                                left: 16.sp, top: 40.sp, right: 16.sp),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: AppText(
                                    text: "Use as Billing address",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: loginText,
                                    fontSize: 16,
                                  ),
                                ),
                                Obx(() => shipController.onButton.value
                                    ? GestureDetector(
                                        onTap: () async {
                                          shipController.onButton.value = false;
                                          shipController.defaultBilling.value =
                                              0;
                                          await analytics.logEvent(
                                            name: 'billing_addressClick',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'billing_addressClick',
                                            },
                                          );
                                        },
                                        child: Image.asset(
                                          switchOnImage,
                                          width: 40.sp,
                                          height: 24.sp,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          shipController.onButton.value = true;
                                          shipController.defaultBilling.value =
                                              1;
                                        },
                                        child: Image.asset(
                                          switchOffImage,
                                          fit: BoxFit.cover,
                                          width: 40.sp,
                                          height: 24.sp,
                                        ),
                                      ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.sp, top: 24.sp),
                            child: AppText(
                              text: "Save Address as",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: loginText,
                              fontSize: 14,
                            ),
                          ),
                         */
                          /*    Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 16.sp),
                            child: SizedBox(
                              width: double.infinity,
                              height: 40.sp,
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: items.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (ctx, index) {
                                    return Obx(
                                      () => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              shipController.current.value =
                                                  index;
                                              if (index == 0) {
                                                shipController.type.value =
                                                    "Home";
                                              } else {
                                                shipController.type.value =
                                                    "Work";
                                              }
                                              shipController.update();
                                              await analytics.logEvent(
                                                name: 'save_addressAs',
                                                parameters: <String, Object>{
                                                  'page_name': 'save_addressAs',
                                                },
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              margin:
                                                  EdgeInsets.only(right: 5.sp),
                                              width: 60.sp,
                                              height: 30.sp,
                                              decoration: BoxDecoration(
                                                color: shipController
                                                            .current.value ==
                                                        index
                                                    ? btnTextColor
                                                    : whiteBorderColor,
                                                borderRadius: shipController
                                                            .current.value ==
                                                        index
                                                    ? BorderRadius.circular(
                                                        20.sp)
                                                    : BorderRadius.circular(
                                                        20.sp),
                                                border: shipController
                                                            .current.value ==
                                                        index
                                                    ? Border.all(
                                                        color: btnTextColor,
                                                        width: 1)
                                                    : Border.all(
                                                        color: textHintColor,
                                                        width: 1),
                                              ),
                                              child: Center(
                                                child: AppText(
                                                  text: items[index],
                                                  color: shipController
                                                              .current.value ==
                                                          index
                                                      ? whiteBorderColor
                                                      : textHintColor,
                                                  fontSize: 12,
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          */
                          Obx(() => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.sp, vertical: 20.sp),
                                child: Row(
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.sp),
                                          border: Border(
                                            top: BorderSide(
                                                width: 2.0.sp,
                                                color: greyBorder),
                                            left: BorderSide(
                                                width: 2.0.sp,
                                                color: greyBorder),
                                            right: BorderSide(
                                                width: 2.0.sp,
                                                color: greyBorder),
                                            bottom: BorderSide(
                                                width: 2.0.sp,
                                                color: greyBorder),
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
                                              shipController.isCheck.value =
                                                  value!;
                                              if (shipController
                                                  .isCheck.value) {
                                                shipController
                                                    .defaultShipping.value = 1;
                                              } else {
                                                shipController
                                                    .defaultShipping.value = 0;
                                              }
                                            });
                                          },
                                        )),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (shipController.isCheck.value) {
                                          shipController.isCheck.value = false;
                                          shipController.defaultShipping.value =
                                              0;
                                        } else {
                                          shipController.isCheck.value = true;
                                          shipController.defaultShipping.value =
                                              1;
                                        }
                                        await analytics.logEvent(
                                          name: 'default_addressClick',
                                          parameters: <String, Object>{
                                            'page_name': 'default_addressClick',
                                          },
                                        );
                                      },
                                      child: AppText(
                                        text: "Make this my default address",
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                        color: loginText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 150.sp,
                          ),
                        ],
                      ),
              )),
            ),
            DoubleButtonNew(
              firstText: "BACK",
              controller: shipController,
              secondText: widget.addressId == 0 ? "SAVE" : "UPDATE",
              onPressedFirst: () {
                Get.back();
              },
              onPressedSecond: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                if (widget.addressId != 0) {
                  if (shipController.checkvalidation()) {
                    shipController.callUpdateAddress(
                      widget.addressId,
                      widget.latitude,
                      widget.longitude,
                      1,
                    );
                  }
                } else {
                  if (shipController.checkvalidation()) {
                    shipController.callSaveAddress(
                      widget.latitude,
                      widget.longitude,
                    );
                  }
                }
                await analytics.logEvent(
                  name: 'save_address_btnClick',
                  parameters: <String, Object>{
                    'page_name': 'save_address_btnClick',
                  },
                );
              },
            ),
            /*    Obx(() => Container(
                    color: whiteBorderColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.sp),
                          child: getSingleButton(
                              label: widget.addressId == 0
                                  ? "Save and Continue"
                                  : "Update",
                              controller: shipController,
                              textColor: whiteBorderColor,
                              backgroundColor: colorPrimary,
                              onPressed: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                if (widget.addressId != 0) {
                                  if (shipController.checkvalidation()) {
                                    shipController.callUpdateAddress(
                                        widget.addressId,
                                        widget.latitude,
                                        widget.longitude,
                                        1);
                                  }
                                } else {
                                  if (shipController.checkvalidation()) {
                                    shipController.callSaveAddress(
                                        widget.latitude, widget.longitude);
                                  }
                                }
                                await analytics.logEvent(
                                  name: 'save_address_btnClick',
                                  parameters: <String, Object>{
                                    'page_name': 'save_address_btnClick',
                                  },
                                );
                              },
                              borderColor: colorPrimary),
                        ),
                      ],
                    ),
                  ))
            */
          ],
        ),
      ),
    );
  }
}
