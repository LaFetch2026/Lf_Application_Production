// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../common/widget/appbar/saveaddress_appbar.dart';
import '../common/widget/button/doublebutton_new.dart';
import '../common/widget/other/text_field.dart';
import '../common/widget/text/app_text.dart';
import '../common/widget/text/number_widget.dart';
import '../controllers/shipaddress_controller.dart';
import '../core/constant/constants.dart';
import '../core/utils/analytics_helper.dart';
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
  final ShipAddressController shipController =
      Get.isRegistered<ShipAddressController>()
          ? Get.find<ShipAddressController>()
          : Get.put(ShipAddressController());

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Timer? debounce;

  // Geocoding state
  bool _geoLoading = false;
  String? _geoError;
  Timer? _pinDebounce;

  // TODO: keep API key secure in prod
  static const _googleApiKey = 'AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc';

  void _syncTypeFromField() {
    shipController.type.value =
        shipController.addressTypeController.text.trim();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      shipController.nameError.value = "";
      shipController.phoneError.value = "";
      shipController.addressError.value = "";
      shipController.localityError.value = "";
      shipController.addressTypeError.value = "";
    });

    if (widget.cartId != 0) {
      shipController.cartId.value = widget.cartId;
    }

    // Pre-fill
    shipController.stateController.text = widget.stateName;
    shipController.pincodeController.text = widget.pincode;
    shipController.cityController.text = widget.localityName;
    shipController.addressTypeController.addListener(_syncTypeFromField);

    // Listen to PIN changes (no change needed to TextFieldWidget)
    shipController.pincodeController.addListener(_onPinTextChanged);

    if (widget.addressId != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        shipController.getAddressDetails(widget.addressId, 1, widget.cartId);
      });
    } else {
      shipController.nameController.clear();
      shipController.phoneController.clear();
      shipController.addressController.clear();
      shipController.localityController.clear();
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
  }

  @override
  void dispose() {
    shipController.addressTypeController.removeListener(_syncTypeFromField);

    debounce?.cancel();
    _pinDebounce?.cancel();
    super.dispose();
  }

  // ---------- PIN → CITY/STATE ----------
  void _onPinTextChanged() {
    final pin = shipController.pincodeController.text.trim();
    _pinDebounce?.cancel();
    _pinDebounce = Timer(const Duration(milliseconds: 600), () {
      if (pin.length == 6 && int.tryParse(pin) != null) {
        _lookupByPincode(pin);
      } else {
        if (mounted) setState(() => _geoError = null);
      }
    });
  }

  Future<void> _lookupByPincode(String pin) async {
    if (!mounted) return;
    setState(() {
      _geoLoading = true;
      _geoError = null;
    });

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'components': 'postal_code:$pin|country:IN',
        'key': _googleApiKey,
      },
    );

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) {
        setState(() => _geoError = 'Server error: ${resp.statusCode}');
        return;
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      if (data['status'] != 'OK' || results.isEmpty) {
        setState(() => _geoError = 'PIN not found. Try another.');
        return;
      }

      final components =
          (results.first as Map<String, dynamic>)['address_components'] as List;

      String? pick(String type) {
        for (final c in components) {
          final types = List<String>.from(c['types'] ?? const []);
          if (types.contains(type)) return c['long_name'] as String?;
        }
        return null;
      }

      final city = pick('locality') ??
          pick('administrative_area_level_2') ??
          pick('sublocality_level_1');
      final state = pick('administrative_area_level_1');

      shipController.cityController.text = city ?? '';
      shipController.stateController.text = state ?? '';

      setState(() {
        _geoError = (city == null || state == null)
            ? 'Couldn’t find full details.'
            : null;
      });
    } on TimeoutException {
      setState(() => _geoError = 'Network timeout. Please try again.');
    } catch (_) {
      setState(() => _geoError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _geoLoading = false);
    }
  }
  // --------------------------------------

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
                Get.off(() => BottomNavScreen(index: 2));
              },
            ),
            Container(color: dividerColor, height: 1.sp),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () => shipController.isDetails.value
                      ? Padding(
                          padding: EdgeInsets.all(40.0.sp),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with current locality and full address — render only if we have something
                            if (widget.localityName.trim().isNotEmpty ||
                                widget.address.trim().isNotEmpty) ...[
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 16.sp, top: 20.sp),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      locationPinImage,
                                      width: 29.sp,
                                      height: 29.sp,
                                      color: colorPrimary,
                                    ),
                                    SizedBox(width: 6.sp),
                                    Expanded(
                                      child: Text(
                                        widget.localityName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: 'Franklin Gothic',
                                          fontWeight: FontWeight.w500,
                                          color: homeAppBarColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 48.sp,
                                  right: 10.sp,
                                  top: 5.sp,
                                  bottom: 10.sp,
                                ),
                                child: Text(
                                  widget.address,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontFamily: 'Franklin Gothic Regular',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],

                            // Personal details
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
                            if (shipController.nameError.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 2.sp),
                                child: AppText(
                                  text: shipController.nameError.value,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 12,
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(top: 0.sp),
                              child: NumberWidget(
                                readonly: false,
                                login: false,
                                fillColor: whiteColor,
                                onPressedLogin: () {},
                                controller: shipController.phoneController,
                              ),
                            ),
                            if (shipController.phoneError.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 2.sp),
                                child: AppText(
                                  text: shipController.phoneError.value,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 12,
                                ),
                              ),

                            // --- Postal Details below mobile number ---
                            Padding(
                              padding: EdgeInsets.only(left: 16.sp, top: 30.sp),
                              child: AppText(
                                text: "POSTAL DETAILS",
                                fontFamily: "Franklin Gothic Semibold",
                                fontWeight: FontWeight.w600,
                                color: blackColor,
                                fontSize: 12,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.sp),
                              child: TextFieldWidget(
                                hint: "PIN code (6 digits)",
                                controller: shipController.pincodeController,
                                // We listen via controller; no onChanged needed
                              ),
                            ),
                            if (_geoLoading)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 8.sp),
                                child: const LinearProgressIndicator(),
                              ),
                            if (_geoError != null)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 2.sp),
                                child: AppText(
                                  text: _geoError!,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 12,
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12.sp),
                                    child: TextFieldWidget(
                                      hint: "City",
                                      controller: shipController.cityController,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12.sp),
                                    child: TextFieldWidget(
                                      hint: "State",
                                      controller:
                                          shipController.stateController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // --------------------------------------

                            // Address
                            Padding(
                              padding: EdgeInsets.only(top: 20.sp),
                              child: TextFieldWidget(
                                hint:
                                    "Address (House no, building, street, area)",
                                controller: shipController.addressController,
                              ),
                            ),
                            if (shipController.addressError.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 2.sp),
                                child: AppText(
                                  text: shipController.addressError.value,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 12,
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.sp),
                              child: TextFieldWidget(
                                hint: "Locality / Town",
                                controller: shipController.localityController,
                              ),
                            ),
                            if (shipController.localityError.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 2.sp),
                                child: AppText(
                                  text: shipController.localityError.value,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 12,
                                ),
                              ),

                            // Save As
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
                                controller:
                                    shipController.addressTypeController,
                              ),
                            ),
                            if (shipController
                                .addressTypeError.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.sp, right: 20.sp, top: 2.sp),
                                child: AppText(
                                  text: shipController.addressTypeError.value,
                                  fontFamily: "Franklin Gothic Regular",
                                  fontWeight: FontWeight.w400,
                                  color: redColor,
                                  fontSize: 12,
                                ),
                              ),

                            // Default address toggle
                            Obx(() => Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp, vertical: 20.sp),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.sp),
                                          border: Border.all(
                                            width: 2.0.sp,
                                            color: greyBorder,
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
                                          onChanged: (value) async {
                                            final v = value ?? false;
                                            setState(() {
                                              shipController.isCheck.value = v;
                                              shipController.defaultShipping
                                                  .value = v ? 1 : 0;
                                            });
                                            await analytics.logEvent(
                                              name: 'default_addressClick',
                                              parameters: <String, Object>{
                                                'page_name':
                                                    'default_addressClick',
                                              },
                                            );
                                            // AnalyticsHelper.logInitiateCheckout(
                                            //   productId: 'guest_login',
                                            //   value: 0.0,
                                            // );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10.sp),
                                      GestureDetector(
                                        onTap: () async {
                                          final v =
                                              !shipController.isCheck.value;
                                          setState(() {
                                            shipController.isCheck.value = v;
                                            shipController.defaultShipping
                                                .value = v ? 1 : 0;
                                          });
                                          await analytics.logEvent(
                                            name: 'default_addressClick',
                                            parameters: <String, Object>{
                                              'page_name':
                                                  'default_addressClick',
                                            },
                                          );
                                          // AnalyticsHelper.logInitiateCheckout(
                                          //   productId: 'guest_login',
                                          //   value: 0.0,
                                          // );
                                        },
                                        child: const AppText(
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
                            SizedBox(height: 150.sp),
                          ],
                        ),
                ),
              ),
            ),
            // Bottom buttons
            // Bottom buttons
            DoubleButtonNew(
              firstText: "BACK",
              controller: shipController,
              secondText: widget.addressId == 0 ? "SAVE" : "UPDATE",
              onPressedFirst: () {
                Get.back();
              },
              onPressedSecond: () async {
                // AnalyticsHelper.logInitiateCheckout(
                //     productId: 'guest_login', value: 0.0);
                FocusScope.of(context).unfocus();

                // Keep your existing field validation
                if (!shipController.checkvalidation()) return;

                if (widget.addressId != 0) {
                  // UPDATE flow (unchanged)
                  await shipController.callUpdateAddress(
                    addressIdParam: widget.addressId,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    closeAllOnSuccess: true,
                    typeValue: shipController.addressTypeController.text
                        .trim(), // <- here
                  );
                } else {
                  // CREATE flow -> directly hit new /profile/address/ body
                  final ok = await shipController.callSaveAddress(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    typeValue: shipController.addressTypeController.text
                        .trim(), // <- here
                  );
                  // Optional: navigate/refresh after success if you want
                  // if (ok) Get.back();  // or trigger a list refresh
                }

                await analytics.logEvent(
                  name: 'save_address_btnClick',
                  parameters: <String, Object>{
                    'page_name': 'save_address_btnClick'
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
