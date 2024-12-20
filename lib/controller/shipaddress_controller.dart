// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../commonwidget/common_widgets.dart';
import '../screens/loginscreen.dart';
import '../utils/constants.dart';

class ShipAddressController extends BaseController {
  RxBool showList = false.obs;
  RxBool isUpdateAddress = false.obs;
  RxBool onButton = false.obs;
  RxBool isCheck = false.obs;
  RxBool isCity = false.obs;
  RxBool isLocation = false.obs;
  RxInt defaultBilling = 0.obs;
  RxInt defaultShipping = 0.obs;
  RxBool isDetails = false.obs;
  RxBool isDelivery = false.obs;
  dynamic addressDetails = "".obs;
  RxString type = "".obs;
  List cityList = [].obs;
  List estimateDeliveryList = [].obs;
  List locationList = [].obs;
  RxInt current = 3.obs;
  RxInt cityId = 0.obs;
  RxInt cartId = 0.obs;
  RxInt addressId = 0.obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  List<bool> selected = List.generate(50, (i) => false).obs;
  Rx<LatLng> defaultLatLng = const LatLng(0.0, 0.0).obs;
  Rx<LatLng> draggedLatLng = const LatLng(0.0, 0.0).obs;
  Rx<CameraPosition> cameraPosition =
      const CameraPosition(target: LatLng(0.0, 0.0), zoom: 15).obs;
  final nameController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final localityController = TextEditingController();
  final searchController = TextEditingController();
  final locationController = TextEditingController();
  RxString nameError = "".obs;
  RxString phoneError = "".obs;
  RxString pincodeError = "".obs;
  RxString addressError = "".obs;
  RxString localityError = "".obs;
  RxString cityError = "".obs;
  RxString addressTypeError = "".obs;
  bool checkvalidation() {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (nameController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Name");
      // nameError.value = "Enter Name";
      return false;
    }
    if (phoneController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Phone Number");
      // phoneError.value = "Enter Phone Number";
      return false;
    }
    if (phoneController.text.toString().trim().length < 10) {
      getSnackBar(
        "Enter 10 digit Phone Number",
      );
      //phoneError.value = "Enter 10 digit Phone Number";
      return false;
    }
    if (!regExp.hasMatch(phoneController.text.toString().trim())) {
      getSnackBar(
        "Enter valid Phone Number",
      );
      // phoneError.value = "Enter valid Phone Number";
      return false;
    }
    if (pincodeController.text.toString().trim().isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      //phoneError.value = "Enter valid Phone Number";
      return false;
    }
    if (pincodeController.text.toString().trim().length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      //pincodeError.value = "The pincode must be 6 digit.";
      return false;
    }
    if (addressController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Address");
      // addressError.value = "Enter Address";
      return false;
    }
    if (localityController.text.toString().trim().isEmpty) {
      getSnackBar("Enter Locality");
      //localityError.value = "Enter Locality";
      return false;
    }
    /*   if (cityController.text.toString().trim().isEmpty) {
      getSnackBar("Enter City");
      return false;
    } */
    if (stateController.text.toString().trim().isEmpty) {
      getSnackBar("Select City");
      //cityError.value = "Select City";
      return false;
    }
    if (type.value.isEmpty) {
      getSnackBar("Select Address Type");
      // addressTypeError.value = "Select Address Type";
      return false;
    }
    return true;
  }

  bool checkLocationValidation() {
    if (lat.value == 0.0 && lng.value == 0.0) {
      getSnackBar("Select Location");
      return false;
    }
    return true;
  }

  getCitiesData() async {
    isCity.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (pincodeController.text.length == 6) {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/cities?zip=${pincodeController.text.toString().trim()}&q=${searchController.text.toString().trim()}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/cities?q=${searchController.text.toString().trim()}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (pincodeController.text.isNotEmpty) {
          cityId.value = responseData["id"];
          stateController.text = responseData["name"];
          update();
        } else {
          if (responseData["data"] != null) {
            cityList = responseData["data"];
          }
        }
      } else if (response.statusCode == 400) {
        print(responseData);
        if (responseData["errors"] != null) {
          getSnackBar(responseData["errors"]["zip"][0]);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get cities failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCity.value = false;
  }

  callSaveAddress(double lat, double lng) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": nameController.text.toString().trim(),
        "phone": phoneController.text.toString().trim(),
        "city_id": cityId.value,
        "type": type.value,
        "address": addressController.text.toString().trim(),
        "zip": pincodeController.text.toString().trim(),
        "locality": localityController.text.toString().trim(),
        "default_billing": defaultBilling.value,
        "default_shipping": defaultShipping.value,
        "latitude": lat,
        "longitude": lng
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/addresses"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        addressId.value = responseData["id"];
        if (cartId.value != 0) {
          callCartAddressUpdate("create");
        }
        Get.close(2);
      } else if (response.statusCode == 201) {
        print(responseData);
        addressId.value = responseData["id"];
        if (cartId.value != 0) {
          callCartAddressUpdate("create");
        }
        Get.close(2);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callUpdateAddress(int id, double lat, double lng, int value) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "name": nameController.text.toString().trim(),
        "phone": phoneController.text.toString().trim(),
        "city_id": cityId.value,
        "type": type.value,
        "address": addressController.text.toString().trim(),
        "zip": pincodeController.text.toString().trim(),
        "locality": localityController.text.toString().trim(),
        "default_billing": defaultBilling.value,
        "default_shipping": defaultShipping.value,
        "latitude": lat,
        "longitude": lng
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/addresses/$id"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        addressId.value = responseData["id"];
        // getSnackBar("Address updated");
        if (value == 1) {
          if (cartId.value != 0) {
            callCartAddressUpdate("create");
          }
          Get.close(2);
        } else {
          Get.close(1);
        }
      } else if (response.statusCode == 201) {
        print(responseData);
        addressId.value = responseData["id"];
        //  getSnackBar("Address updated");
        if (value == 1) {
          if (cartId.value != 0) {
            callCartAddressUpdate("create");
          }
          Get.close(2);
        } else {
          Get.close(1);
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callCartAddressUpdate(String type) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse(
            "${ApiConstants.baseUrl}/orders/${cartId.value}/addresses/${addressId.value}"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (type == "update") {
          Get.back();
        }
        getAddressDetails(responseData["address"]["id"], 1, responseData["id"]);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getAddressDetails(int id, int value, int cartId) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/addresses/$id"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (cartId != 0) {
          getEstimateDelivery(cartId);
        }
        print(responseData);
        if (responseData != null) {
          addressDetails = responseData;
          if (value == 1) {
            nameController.text = responseData["name"] ?? "";
            phoneController.text = responseData["phone"] ?? "";
            pincodeController.text = responseData["zip"].toString();
            addressController.text = responseData["address"];
            localityController.text = responseData["locality"];
            if (responseData["city"] != null) {
              stateController.text = responseData["city"]["name"];
              cityId.value = responseData["city"]["id"];
            }
            isCheck.value = responseData["default_shipping"];
            if (isCheck.value) {
              defaultShipping.value = 1;
              isCheck.value = true;
            } else {
              defaultShipping.value = 0;
              isCheck.value = false;
            }
            if (responseData["type"] == "Work") {
              type.value = "Work";
              current.value = 1;
            } else {
              type.value = "Home";
              current.value = 0;
            }
            if (responseData["default_billing"]) {
              onButton.value = true;
              defaultBilling.value = 1;
            } else {
              onButton.value = false;
              defaultBilling.value = 0;
            }
          } else {
            if (responseData["latitude"] != null) {
              lat.value = double.parse(responseData["latitude"]);
            }
            if (responseData["longitude"] != null) {
              lng.value = double.parse(responseData["longitude"]);
            }
            defaultLatLng.value = LatLng(lat.value, lng.value);
            draggedLatLng.value = defaultLatLng.value;
            cameraPosition.value =
                CameraPosition(target: defaultLatLng.value, zoom: 15);
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get address details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }

  getEstimateDelivery(int cartId) async {
    isDelivery.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/orders/$cartId/estimated-delivery"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        estimateDeliveryList = responseData;
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get estimate delivery failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDelivery.value = false;
  }

  getSearchLocation(String query) async {
    isLocation.value = true;
    try {
      Map<String, dynamic> querys = {
        'input': query,
        'key': "AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc"
      };
      final url = Uri.https(
          "maps.googleapis.com", "maps/api/place/autocomplete/json", querys);
      final response = await http.get(url);
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print("Search location $responseData");
        locationList = responseData["predictions"];
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("get Location failed");
      }
    } catch (e) {
      print("error$e");
    }
    isLocation.value = false;
  }
}
