// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import 'package:lafetch/screens/shippingaddressscreen.dart';
import 'package:shimmer/shimmer.dart';

import '../common/widget/appbar/saveaddress_appbar.dart';
import '../common/widget/lists/dummy_container.dart';
import '../common/widget/text/app_text.dart';
import '../controllers/shipaddress_controller.dart';
import '../core/constant/constants.dart';

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
  final Completer<GoogleMapController> googleMapController = Completer();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String draggedAddress = "";
  String localityName = "";
  String stateName = "";
  String pincode = "";

  String? _mapStyle; // nullable until loaded
  Timer? _debounce;

  Placemark? address;
  List<Placemark>? placeMarks;

  static const kGoogleApiKey = "AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc";
  final TextEditingController controller = TextEditingController();
  final places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Clear location state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shipController.locationList.clear();
      shipController.locationController.clear();
    });

    // Set system UI colors after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: homeAppBarColor,
      ));
    });

    // Either fetch existing address or init to user location
    if (widget.addressId != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        shipController.getAddressDetails(widget.addressId, 2, widget.cartId);
      });
    } else {
      _init();
    }

    _loadMapStyle();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    _searchFocusNode.dispose(); // ✅ dispose what you created
    super.dispose();
  }

  void _init() {
    _gotoUserCurrentPosition();
    shipController.cameraPosition.value =
        CameraPosition(target: shipController.defaultLatLng.value, zoom: 15);
  }

  Future<void> _loadMapStyle() async {
    try {
      final string = await rootBundle.loadString('assets/map_style.json');
      if (!mounted) return;
      _mapStyle = string;

      // Apply immediately if map is already created
      if (googleMapController.isCompleted) {
        final c = await googleMapController.future;
        await c.setMapStyle(_mapStyle);
      }
    } catch (e, st) {
      debugPrint('Failed to load map style asset: $e\n$st');
      _mapStyle = null; // fall back to default style
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      shipController.getSearchLocation(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: whiteColor,
      body: Obx(
        () => shipController.isDetails.value
            ? Padding(
                padding: EdgeInsets.all(40.0.sp),
                child: const Center(child: CircularProgressIndicator()),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        _getMap(),
                        _getCustomPin(),
                        SaveAddressAppbar(
                          text: "Select Address",
                          onPressedWishlist: () {
                            Get.off(BottomNavScreen(index: 2));
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 90.sp),
                          child: Divider(color: dividerColor, height: 1.sp),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 91.sp),
                          height: 12.sp,
                          color: whiteColor,
                        ),
                        // Search box
                        Container(
                          margin: EdgeInsets.only(top: 120.sp),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
                            child: SizedBox(
                              height: 40.sp,
                              child: RawKeyboardListener(
                                focusNode:
                                    _searchFocusNode, // ✅ use the persistent node
                                onKey: (_) {},
                                child: TextField(
                                  controller: shipController.locationController,
                                  textCapitalization: TextCapitalization.words,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: titleColor,
                                    fontFamily: "Clash Display Regular",
                                  ),
                                  onChanged: onSearchChanged,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    fillColor: whiteColor,
                                    prefixIcon:
                                        MediaQuery.of(context).size.width < 600
                                            ? IconButton(
                                                icon: SvgPicture.asset(
                                                  searchSvgImage,
                                                  color: titleColor,
                                                  height: 17.sp,
                                                  width: 17.sp,
                                                  fit: BoxFit.cover,
                                                ),
                                                onPressed: () {},
                                              )
                                            : Icon(Icons.search,
                                                size: 20.sp, color: titleColor),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: borderColor),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1),
                                      borderSide:
                                          const BorderSide(color: borderColor),
                                    ),
                                    counterText: "",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.sp),
                                    hintText:
                                        "Search for building, street name, or area",
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: searchTextColor,
                                      fontFamily: "Clash Display Regular",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Autocomplete results
                        Padding(
                          padding: EdgeInsets.only(
                              top: 160.sp, left: 16.sp, right: 16.sp),
                          child: shipController.isLocation.value
                              ? Container(
                                  color: whiteColor,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                )
                              : ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: shipController.locationList.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (ctx, index) {
                                    final item =
                                        shipController.locationList[index];
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            shipController.locationController
                                                .clear();
                                            try {
                                              final details = await places
                                                  .getDetailsByPlaceId(
                                                      item["place_id"]);
                                              final geo =
                                                  details.result.geometry;

                                              String? part(String type) =>
                                                  details
                                                      .result.addressComponents
                                                      .firstWhereOrNull(
                                                          (ac) => ac.types
                                                              .contains(type))
                                                      ?.longName;

                                              final cityName = part(
                                                      'locality') ??
                                                  part(
                                                      'administrative_area_level_2');
                                              final stateName = part(
                                                  'administrative_area_level_1');

                                              // Try to resolve cityId now
                                              await shipController.ensureCityId(
                                                  cityName: cityName,
                                                  stateName: stateName);

                                              if (geo != null) {
                                                final lat = geo.location.lat;
                                                final lng = geo.location.lng;
                                                shipController.locationList
                                                    .clear();
                                                final mapC =
                                                    await googleMapController
                                                        .future;
                                                await mapC.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                    CameraPosition(
                                                        target:
                                                            LatLng(lat, lng),
                                                        zoom: 15),
                                                  ),
                                                );
                                                if (mounted)
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          FocusNode());
                                              }
                                            } catch (e, st) {
                                              debugPrint(
                                                  'Failed to get place details: $e\n$st');
                                            }
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 10.sp,
                                                      horizontal: 16.sp,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 6.sp),
                                                          child: ImageIcon(
                                                            AssetImage(
                                                                locationIcon),
                                                            color: nameText,
                                                            size: 20.sp,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            item["description"],
                                                            maxLines: 5,
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: nameText,
                                                              fontFamily:
                                                                  "Clash Display Regular",
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (index !=
                                                    shipController.locationList
                                                            .length -
                                                        1)
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16.sp,
                                                            vertical: 2.sp),
                                                    child: Container(
                                                      width: double.infinity,
                                                      color: colorSecondary,
                                                      height: 1.sp,
                                                    ),
                                                  )
                                                else
                                                  SizedBox(height: 5.sp),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        // "Use my current location"
                        if (shipController.locationList.isEmpty)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: _gotoUserCurrentPosition,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.sp, vertical: 20.sp),
                                child: Container(
                                  height: 40.sp,
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.sp),
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          myLocationSvgImage,
                                          height: 18.sp,
                                          width: 18.sp,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10.sp, top: 2.sp),
                                          child: AppText(
                                            text: "Use my current location",
                                            color: homeAppBarColor,
                                            fontSize: 16,
                                            fontFamily: "Clash Display",
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
                    ),
                  ),
                  // Bottom address panel
                  _bottomAddressPanel(),
                ],
              ),
      ),
    );
  }

  Widget _bottomAddressPanel() {
    return Expanded(
      flex: 0,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5.sp,
                  blurRadius: 7.sp,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _showDraggedAddress(),
          ),
        ],
      ),
    );
  }

  Widget _showDraggedAddress() {
    final showAddress = draggedAddress.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.sp, top: 24.sp),
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
                  : Text(
                      localityName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Clash Display',
                        fontWeight: FontWeight.w500,
                        color: homeAppBarColor,
                      ),
                    ),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: MediaQuery.of(context).size.height.sp,
                    ),
                    builder: (ctx) => ShippingAddressScreen(
                      addressId: widget.addressId,
                      cartId: widget.cartId,
                      stateName: stateName,
                      pincode: pincode,
                      address: draggedAddress,
                      localityName: localityName,
                      latitude: shipController.lat.value,
                      longitude: shipController.lng.value,
                    ),
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
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w400,
                      color: appBarColor,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 50.sp, right: 10.sp, bottom: 16.sp),
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
                          ? DummyContainer(height: 20, width: 150)
                          : SizedBox(
                              width: MediaQuery.of(context).size.width - 150.sp,
                              child: Text(
                                draggedAddress,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  height: 1.5.sp,
                                  color: subtitleColor,
                                  fontFamily: 'Clash Display Regular',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
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
            if (!shipController.checkLocationValidation()) {
              await _determineUserCurrentPosition();
              return;
            }

            // Prefill text fields
            shipController.addressController.text = draggedAddress;
            shipController.localityController.text = localityName;
            shipController.pincodeController.text = pincode;
            shipController.stateController.text = stateName;

            // If we don't have cityId yet, try resolving from map locality/state
            if (shipController.selectedCityId.value == 0) {
              await shipController.ensureCityId(
                cityName: localityName,
                stateName: stateName,
              );
            }

            // If we have cityId now, save directly; else open the address form
            if (shipController.selectedCityId.value != 0) {
              final ok = await shipController.callSaveAddress(
                latitude: shipController.lat.value,
                longitude: shipController.lng.value,
              );
              if (ok && mounted) Get.back(result: true);
            } else {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: MediaQuery.of(context).size.height.sp,
                ),
                builder: (ctx) => ShippingAddressScreen(
                  addressId: widget.addressId,
                  cartId: widget.cartId,
                  pincode: pincode,
                  stateName: stateName,
                  address: draggedAddress,
                  localityName: localityName,
                  latitude: shipController.lat.value,
                  longitude: shipController.lng.value,
                ),
              );
            }

            await analytics.logEvent(
              name: 'confirmlocation_btnclick',
              parameters: <String, Object>{
                'page_name': 'confirmlocation_btnclick'
              },
            );
          },
          child: Container(
            width: double.infinity,
            height: 70.sp,
            color: homeAppBarColor,
            margin: EdgeInsets.only(top: 20.sp),
            alignment: Alignment.center,
            child: Text(
              "Confirm Location".toUpperCase(),
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontFamily: 'Clash Display',
              ),
            ),
          ),
        ),
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
      onMapCreated: (GoogleMapController controller) async {
        if (!googleMapController.isCompleted) {
          googleMapController.complete(controller);
        }
        // Apply style if/when available
        if (_mapStyle != null) {
          await controller.setMapStyle(_mapStyle);
        }
      },
    );
  }

  Widget _getCustomPin() {
    return Center(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 64.sp,
              left: MediaQuery.of(context).size.width / 2 - 4.sp,
            ),
            child: ClipRRect(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightPurpleColor,
                ),
                height: 10.sp,
                width: 10.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 25.sp,
              left: MediaQuery.of(context).size.width / 2 - 24.sp,
            ),
            child: Image.asset(
              locationPinImage,
              width: 50.sp,
              height: 50.sp,
              color: colorPrimary,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.sp),
            child: Container(
              width: MediaQuery.of(context).size.width.sp,
              height: 58.sp,
              decoration: BoxDecoration(
                color: homeAppBarColor,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.sp, vertical: 8.sp),
                child: Column(
                  children: const [
                    AppText(
                      text: "Order will be delivered here",
                      fontFamily: "Clash Display",
                      fontWeight: FontWeight.w500,
                      color: whiteColor,
                      fontSize: 16,
                    ),
                    SizedBox(height: 4),
                    AppText(
                      text: "Move the pin to  change location",
                      fontFamily: "Clash Display Regular",
                      fontWeight: FontWeight.w500,
                      color: whiteColor,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reverse-geocode from dragged pin
  Future<void> _getAddress(LatLng position) async {
    try {
      shipController.lat.value = position.latitude;
      shipController.lng.value = position.longitude;

      final marks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (marks.isEmpty) return;

      final a = marks.first;
      final addr = "${a.street?.trim().isNotEmpty == true ? a.street : ''}"
          "${a.street?.trim().isNotEmpty == true ? ',' : ''}"
          "${a.locality ?? ''}"
          "${(a.locality ?? '').isNotEmpty ? ',' : ''}"
          "${a.administrativeArea ?? ''}"
          "${(a.postalCode ?? '').isNotEmpty ? ', ' : ''}"
          "${a.postalCode ?? ''}";

      if (!mounted) return;
      setState(() {
        draggedAddress = addr;
        localityName = a.locality ?? '';
        pincode = a.postalCode ?? '';
        stateName = a.administrativeArea ?? '';
      });
    } catch (e, st) {
      debugPrint('Reverse geocoding failed: $e\n$st');
    }
  }

  Future<void> _gotoUserCurrentPosition() async {
    final currentPosition = await _determineUserCurrentPosition();
    await _gotoSpecificPosition(
      LatLng(currentPosition.latitude, currentPosition.longitude),
    );
  }

  Future<void> _gotoSpecificPosition(LatLng position) async {
    try {
      final mapController = await googleMapController.future;
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15),
        ),
      );
      await _getAddress(position);
    } catch (e, st) {
      debugPrint('Failed to move camera: $e\n$st');
    }
  }

  Future<Position> _determineUserCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("User denied location permission");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("User denied location permission forever");
    }

    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
