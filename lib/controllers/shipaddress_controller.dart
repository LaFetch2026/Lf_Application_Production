// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/widget/other/common_widget.dart';
import '../core/constant/constants.dart';
import '../screens/loginscreen.dart';
import 'base_controller.dart';

class ShipAddressController extends BaseController {
  RxBool showList = false.obs;
  RxInt selectedCityId = 0.obs;
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
  RxList<dynamic> cityList = <dynamic>[].obs;
  List estimateDeliveryList = [].obs;
  List locationList = [].obs;
  RxInt current = 3.obs;
  RxInt cityId = 0.obs;
  RxInt cartId = 0.obs;
  RxInt addressId = 0.obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxList<dynamic> countryList = <dynamic>[].obs;
  RxList<dynamic> stateList = <dynamic>[].obs;
  List<bool> dailogSelected = List.generate(50, (i) => false).obs;
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
  final searchAddressController = TextEditingController();
  final addressTypeController = TextEditingController();
  RxString nameError = "".obs;
  RxString phoneError = "".obs;
  RxString addressError = "".obs;
  RxString localityError = "".obs;
  RxString addressTypeError = "".obs;

  /// Ensure selectedCityId is set from city/state names. Returns true if set.
  Future<bool> ensureCityId({String? cityName, String? stateName}) async {
    final c = (cityName ?? '').trim().toLowerCase();
    final s = (stateName ?? '').trim().toLowerCase();

    if (selectedCityId.value != 0) return true;

    int? matchLocal() {
      if (cityList.isEmpty) return null;
      final m = cityList.firstWhereOrNull((e) {
        final name = ('${e['name'] ?? e['city'] ?? ''}').toLowerCase();
        final st = (e['state'] is Map
                ? (e['state']['name'] ?? '')
                : (e['state'] ?? ''))
            .toString()
            .toLowerCase();
        final okCity = c.isNotEmpty && (name == c || name.contains(c));
        final okState = s.isEmpty || st == s || st.contains(s);
        return okCity && okState;
      });
      return (m != null && m['id'] is int) ? m['id'] as int : null;
    }

    final local = matchLocal();
    if (local != null) {
      selectedCityId.value = local;
      return true;
    }

    // If you have a cities endpoint, you can fetch here; otherwise return false.
    return false;
  }

  void handleErrorResponse(
      http.Response response, Map<String, dynamic> responseData) {
    if (response.statusCode == 400) {
      getSnackBar(responseData["message"] ?? "Invalid input.");
    } else if (response.statusCode == 401) {
      getSnackBar("Authentication failed");
      Get.offAll(() => const LoginScreen(initialTab: 0));
    } else if (response.statusCode == 500) {
      getSnackBar("Server error. Please try again.");
    } else {
      getSnackBar("Unexpected error (${response.statusCode}).");
    }
  }

  /// Attempts to resolve selectedCityId from known lists using city/state name.
  /// Return true if it set a non-zero id; false otherwise.
  Future<bool> tryResolveCityIdByName({
    required String cityName,
    String? stateName,
  }) async {
    // Normalize
    final c = cityName.trim().toLowerCase();
    final s = (stateName ?? '').trim().toLowerCase();

    // If you already have a populated `cityList` like:
    // [{ "id": 2, "name": "Gurugram", "state": {"name": "Haryana"} }, ...]
    // try matching by name (and state, if available).
    if (cityList.isNotEmpty) {
      final match = cityList.firstWhereOrNull((e) {
        final name = ('${e['name'] ?? e['city'] ?? ''}').toLowerCase();
        final st = (e['state'] is Map
                ? (e['state']['name'] ?? '')
                : (e['state'] ?? ''))
            .toString()
            .toLowerCase();
        final okCity = name == c || name.contains(c);
        final okState = s.isEmpty || st == s || st.contains(s);
        return okCity && okState;
      });

      if (match != null && match['id'] is int) {
        selectedCityId.value = match['id'] as int;
        return selectedCityId.value != 0;
      }
    }

    // TODO: If you have a backend search endpoint for cities, call it here
    // and set selectedCityId from the response. Example:
    //
    // final found = await fetchCityFromServerByName(cityName, stateName);
    // if (found != null) { selectedCityId.value = found.id; return true; }

    return false; // let caller prompt user to pick a city
  }

  bool checkvalidation() {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (nameController.text.toString().trim().isEmpty) {
      // getSnackBar("Enter Name");
      nameError.value = "Enter Name";
      return false;
    }
    if (phoneController.text.toString().trim().isEmpty) {
      // getSnackBar("Enter Phone Number");
      phoneError.value = "Enter Phone Number";
      nameError.value = "";
      return false;
    }
    if (phoneController.text.toString().trim().length < 10) {
      /* getSnackBar(
        "Enter 10 digit Phone Number",
      ); */
      phoneError.value = "Enter 10 digit Phone Number";
      nameError.value = "";
      return false;
    }
    if (!regExp.hasMatch(phoneController.text.toString().trim())) {
      /* getSnackBar(
        "Enter valid Phone Number",
      ); */
      phoneError.value = "Enter valid Phone Number";
      nameError.value = "";
      return false;
    }
    /* if (pincodeController.text.toString().trim().isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      //phoneError.value = "Enter valid Phone Number";
      return false;
    } */
    /* if (pincodeController.text.toString().trim().length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      //pincodeError.value = "The pincode must be 6 digit.";
      return false;
    } */
    if (addressController.text.toString().trim().isEmpty) {
      // getSnackBar("Enter Address");
      addressError.value = "Enter Address";
      nameError.value = "";
      phoneError.value = "";
      return false;
    }
    if (localityController.text.toString().trim().isEmpty) {
      // getSnackBar("Enter Locality");
      localityError.value = "Enter Locality";
      nameError.value = "";
      phoneError.value = "";
      addressError.value = "";
      return false;
    }
    /* if (cityController.text.toString().trim().isEmpty) {
      getSnackBar("Enter City");
      return false;
    } */
    /* if (stateController.text.toString().trim().isEmpty) {
      getSnackBar("Select City");
      //cityError.value = "Select City";
      return false;
    } */
    if (addressTypeController.text.toString().trim().isEmpty) {
      // getSnackBar("Enter Address Type");
      addressTypeError.value = "Select Address Type";
      nameError.value = "";
      phoneError.value = "";
      addressError.value = "";
      localityError.value = "";
      return false;
    }

    addressTypeError.value = "";
    nameError.value = "";
    phoneError.value = "";
    addressError.value = "";
    localityError.value = "";
    return true;
  }

  bool checkLocationValidation() {
    if (lat.value == 0.0 && lng.value == 0.0) {
      // getSnackBar("Select Location");
      return false;
    }
    return true;
  }

  Future<void> getLocationData({
    required String fetchType, // 'countries', 'states', 'cities'
    int? countryId,
    int? stateId,
    String searchQuery = "",
    int page = 1,
    int limit = 20,
    bool isRefresh = false,
  }) async {
    isCity.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      // Build query params
      final queryParams = <String, String>{
        'fetch': fetchType,
        'page': page.toString(),
        'limit': limit.toString(),
        if (searchQuery.isNotEmpty) 'q': searchQuery,
        if (fetchType == 'states' && countryId != null)
          'country_id': countryId.toString(),
        if (fetchType == 'cities' && stateId != null)
          'state_id': stateId.toString(),
      };

      // Safer URI construction that doesn't accidentally produce an invalid path
      final base = ApiConstants
          .baseUrl; // e.g. http://65.0.153.196:8080 or http://host/api
      final baseUri = Uri.parse(base);

      // If your API is actually under a prefix (e.g. /api), keep it.
      // We'll append "location" WITHIN that prefix.
      final normalizedPath = (() {
        final p = baseUri.path;
        if (p.isEmpty || p == '/') return '/location';
        // ensure single slash between
        return p.endsWith('/') ? '${p}location' : '$p/location';
      })();

      final uri =
          baseUri.replace(path: normalizedPath, queryParameters: queryParams);

      debugPrint("➡️ GET $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if ((prefs.getString('token') ?? '').isNotEmpty)
            'Authorization': "Bearer ${prefs.getString('token')}",
        },
      );

      debugPrint("⬅️ Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse JSON only on 200
        Map<String, dynamic> responseData;
        try {
          responseData = json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint("❌ JSON parse error: $e");
          getSnackBar("Failed to read $fetchType data. Please try again.");
          return;
        }

        final List<dynamic> data = (responseData['data'] as List?) ?? const [];

        switch (fetchType) {
          case 'countries':
            if (isRefresh || page == 1) {
              countryList.value = data;
            } else {
              countryList.addAll(data);
            }
            break;
          case 'states':
            if (isRefresh || page == 1) {
              stateList.value = data;
            } else {
              stateList.addAll(data);
            }
            break;
          case 'cities':
            if (isRefresh || page == 1) {
              cityList.value = data;
            } else {
              cityList.addAll(data);
            }
            break;
        }
      } else if (response.statusCode == 401) {
        getSnackBar("Session expired. Please login again.");
        Get.offAll(() => const LoginScreen(initialTab: 0));
      } else {
        // Do NOT json.decode here; could be HTML (as in your log)
        final preview = response.body.isNotEmpty
            ? response.body.substring(0, response.body.length.clamp(0, 300))
            : '<empty body>';
        debugPrint("❌ Non-200 body preview:\n$preview");
        getSnackBar(
            "Failed to fetch $fetchType (HTTP ${response.statusCode}).");
      }
    } catch (e) {
      debugPrint("❌ Error fetching $fetchType: $e");
      getSnackBar("Something went wrong while fetching $fetchType.");
    } finally {
      isCity.value = false;
    }
  }

// ADD ADDRESS
  Future<bool> callSaveAddress({
    required double latitude,
    required double longitude,
    String typeValue = "",
  }) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();

    final url = Uri.parse("${ApiConstants.baseUrl}/profile/address/");
    final token = prefs.getString('token') ?? '';

    try {
      final userId = prefs.getInt('userId');
      if (userId == null) {
        getSnackBar("User not logged in.");
        return false;
      }

      // Build request body EXACTLY as per your required schema
      final Map<String, dynamic> sendData = {
        "userId": userId,
        "contactName": nameController.text.trim(),
        "contactPhone": phoneController.text.trim(),
        "line1": addressController.text.trim(),
        "line2": localityController.text.trim(),
        "country": "India",
        "state": stateController.text.trim(),
        "city": cityController.text.trim(),
        "postalCode": pincodeController.text.trim(),
        "isDefaultAddress": isCheck.value == true,
        "latitude": latitude,
        "longitude": longitude,
        "type": (typeValue.isNotEmpty
            ? typeValue
            : addressTypeController.text.trim()), // <- guarantee
      };

// helpful prints
      const pretty = JsonEncoder.withIndent('  ');
      debugPrint("📤 /profile/address/ body:\n${pretty.convert(sendData)}");

      // Pretty JSON for logs
      debugPrint("📦 [ADD] POST $url");
      debugPrint("🔐 Token present: ${token.isNotEmpty}");
      debugPrint("📤 Request Body:\n${pretty.convert(sendData)}");

      final sw = Stopwatch()..start();
      final resp = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer $token",
        },
        body: json.encode(sendData),
      );
      sw.stop();

      Map<String, dynamic> body = {};
      try {
        if (resp.body.isNotEmpty) {
          body = json.decode(resp.body) as Map<String, dynamic>;
        }
      } catch (_) {
        // keep body as {} if server doesn't return JSON
      }

      debugPrint(
        "📥 [ADD] (${resp.statusCode}) in ${sw.elapsedMilliseconds}ms\n"
        "${resp.body.isEmpty ? '<no body>' : pretty.convert(body)}",
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // Try to read new ID from common shapes
        int? newId;
        if (body['id'] is int) {
          newId = body['id'] as int;
        } else if (body['data'] is Map && (body['data']['id'] is int)) {
          newId = body['data']['id'] as int;
        } else if (body['address'] is Map && (body['address']['id'] is int)) {
          newId = body['address']['id'] as int;
        }

        if (newId != null) {
          addressId.value = newId;
          if (cartId.value != 0) {
            await callCartAddressUpdate("create");
          }
        }

        getSnackBar(body['message']?.toString() ?? "Address added.");
        if (Get.isOverlaysOpen) {
          try {
            Get.close(2);
          } catch (_) {}
        }
        return true;
      } else {
        handleErrorResponse(resp, body);
        return false;
      }
    } catch (e, st) {
      debugPrint("❌ Exception in callSaveAddress: $e\n$st");
      getSnackBar("Something went wrong: $e");
      return false;
    } finally {
      hideLoading();
    }
  }

  Future<bool> callDeleteAddress({
    required int addressId,
    bool closeOnSuccess = false,
  }) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();

    final base = ApiConstants.baseUrl; // or laFetchBaseUrl
    // 🔧 trailing slash matters
    final url = Uri.parse("$base/profile/address/$addressId/");
    final token = prefs.getString('token') ?? '';

    try {
      debugPrint("🗑 [DEL] DELETE $url");
      final sw = Stopwatch()..start();
      final resp = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));
      sw.stop();

      final contentType = resp.headers['content-type'] ?? '';
      debugPrint(
          "↩ status=${resp.statusCode}, ct=$contentType, ${sw.elapsedMilliseconds}ms");

      Map<String, dynamic> bodyJson = {};
      String bodyText = resp.body;

      if (bodyText.isNotEmpty && contentType.contains('application/json')) {
        try {
          bodyJson = json.decode(bodyText) as Map<String, dynamic>;
        } catch (e) {
          debugPrint("⚠️ JSON parse failed, body was not valid JSON.");
        }
      } else {
        // Helpful preview when server sends HTML or plain text
        final preview =
            bodyText.length > 300 ? "${bodyText.substring(0, 300)}…" : bodyText;
        debugPrint("📝 Non-JSON body preview:\n$preview");
      }

      // Success codes for DELETE
      if (resp.statusCode == 200 ||
          resp.statusCode == 202 ||
          resp.statusCode == 204) {
        getSnackBar(bodyJson['message']?.toString() ?? "Address deleted.");
        if (closeOnSuccess && Get.isOverlaysOpen) {
          try {
            Get.close(1);
          } catch (_) {}
        }
        return true;
      }

      // Common redirect hint (usually missing trailing slash)
      if (resp.statusCode == 301 ||
          resp.statusCode == 302 ||
          resp.statusCode == 308) {
        getSnackBar(
            "Delete endpoint redirected. Check URL (trailing slash) or auth.");
        return false;
      }

      // Fallback error
      final msg = bodyJson['message']?.toString() ??
          "Failed to delete (HTTP ${resp.statusCode}).";
      getSnackBar(msg);
      return false;
    } catch (e, st) {
      debugPrint("❌ callDeleteAddress error: $e\n$st");
      getSnackBar("Failed to delete address: $e");
      return false;
    } finally {
      hideLoading();
    }
  }

// UPDATE ADDRESS
  Future<bool> callUpdateAddress({
    required int addressIdParam,
    double latitude = 0.0,
    double longitude = 0.0,
    bool closeAllOnSuccess = true,
    String typeValue = "",
  }) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();

    try {
      final userId = prefs.getInt('userId');
      if (userId == null) {
        getSnackBar("User not logged in.");
        return false;
      }

      final Map<String, dynamic> sendData = {
        "addressId": addressIdParam,
        "userId": userId,
        "line1": addressController.text.trim(),
        "line2": localityController.text.trim(),
        "city": cityController.text.trim(),
        "state": stateController.text.trim(),
        "country": "india",
        "postalCode": pincodeController.text.trim(),
        "isDefaultAddress": isCheck.value,
        "type": typeValue,
        if (latitude != 0.0) "latitude": latitude,
        if (longitude != 0.0) "longitude": longitude,
      };

      final resp = await http
          .put(
            Uri.parse("${ApiConstants.baseUrl}/profile/address/"),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': "Bearer ${prefs.getString('token') ?? ''}",
            },
            body: json.encode(sendData),
          )
          .timeout(const Duration(seconds: 12));

      final Map<String, dynamic> body = resp.body.isNotEmpty
          ? (json.decode(resp.body) as Map<String, dynamic>)
          : {};

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        int? updatedId;
        if (body['id'] is int)
          updatedId = body['id'] as int;
        else if (body['data'] is Map && (body['data']['id'] is int))
          updatedId = body['data']['id'] as int;
        else if (body['address'] is Map && (body['address']['id'] is int))
          updatedId = body['address']['id'] as int;

        if (updatedId != null) addressId.value = updatedId;

        if (cartId.value != 0 && (updatedId ?? addressId.value) != 0) {
          await callCartAddressUpdate("update");
        }

        getSnackBar(body['message']?.toString() ?? "Address updated.");
        if (closeAllOnSuccess) {
          try {
            Get.close(2);
          } catch (_) {}
        } else {
          try {
            Get.close(1);
          } catch (_) {}
        }
        return true;
      } else {
        handleErrorResponse(resp, body);
        return false;
      }
    } on TimeoutException {
      getSnackBar("Request timed out. Please try again.");
      return false;
    } catch (e, st) {
      debugPrint("❌ Exception: $e\n$st");
      getSnackBar("An error occurred: $e");
      return false;
    } finally {
      hideLoading();
    }
  }

  Future<bool> callCartAddressUpdate(String type) async {
    if (addressId.value == 0) {
      debugPrint("⚠️ Skipping cart address update: addressId is 0/unknown.");
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse(
          "${ApiConstants.baseUrl}/orders/${cartId.value}/addresses/${addressId.value}");
      debugPrint("📤 [CART-ADDR] PUT $uri");

      final resp = await http.put(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );

      final Map<String, dynamic> body = resp.body.isNotEmpty
          ? (json.decode(resp.body) as Map<String, dynamic>)
          : {};

      debugPrint(
          "📥 [CART-ADDR] (${resp.statusCode}) ${body.isEmpty ? '<no body>' : body}");

      if (resp.statusCode == 200) {
        if (type == "update") {
          // If you want to just go back one screen on update:
          try {
            Get.back();
          } catch (_) {}
        }
        // Rehydrate form/coords with server source of truth if needed
        final addrId =
            (body["address"] is Map) ? body["address"]["id"] : addressId.value;
        final orderId = body["id"] is int ? body["id"] as int : cartId.value;
        await getAddressDetails(
            addrId is int ? addrId : addressId.value, 1, orderId);
        return true;
      }

      if (resp.statusCode == 400) {
        debugPrint(resp.body);
        getSnackBar("Unable to set cart address.");
        return false;
      }
      if (resp.statusCode == 401) {
        getSnackBar("Authentication failed");
        return false;
      }
      if (resp.statusCode == 500) {
        return false;
      }
      debugPrint("⚠️ Unexpected status: ${resp.statusCode}");
      return false;
    } catch (e) {
      debugPrint("❌ callCartAddressUpdate error: $e");
      return false;
    }
  }

// --- GET ADDRESS DETAILS ---
  Future<bool> getAddressDetails(int id, int value, int cartIdParam) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/profile/addresses/$id");
      debugPrint("➡️ [GET] $uri");

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': "Bearer ${prefs.getString('token')}",
        },
      );

      final Map<String, dynamic> responseData = response.body.isNotEmpty
          ? (json.decode(response.body) as Map<String, dynamic>)
          : {};

      debugPrint("⬅️ [GET] (${response.statusCode}) $responseData");

      if (response.statusCode == 200 && responseData.isNotEmpty) {
        addressDetails = responseData;

        if (cartIdParam != 0) {
          // Optionally: await getEstimateDelivery(cartIdParam);
        }

        if (value == 1) {
          // fill form
          addressController.text = responseData["line1"] ?? "";
          localityController.text = responseData["line2"] ?? "";
          cityController.text = responseData["city"] ?? "";
          stateController.text = responseData["state"] ?? "";
          pincodeController.text = responseData["postalCode"]?.toString() ?? "";
          isCheck.value = responseData["isDefaultAddress"] == true;

          // optional fields
          nameController.text = responseData["name"] ?? "";
          phoneController.text = responseData["phone"] ?? "";
          addressTypeController.text = responseData["type"] ?? "";

          defaultShipping.value = isCheck.value ? 1 : 0;
        } else {
          // map-center case
          if (responseData["latitude"] != null &&
              responseData["longitude"] != null) {
            lat.value =
                double.tryParse(responseData["latitude"].toString()) ?? 0.0;
            lng.value =
                double.tryParse(responseData["longitude"].toString()) ?? 0.0;

            defaultLatLng.value = LatLng(lat.value, lng.value);
            draggedLatLng.value = defaultLatLng.value;
            cameraPosition.value =
                CameraPosition(target: defaultLatLng.value, zoom: 15);
          }
        }
        return true;
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(() => const LoginScreen(initialTab: 0));
        return false;
      } else if (response.statusCode == 500) {
        getSnackBar("Server error, please try again.");
        return false;
      } else {
        getSnackBar("Failed to fetch address details.");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception in getAddressDetails: $e");
      getSnackBar("An error occurred: $e");
      return false;
    } finally {
      isDetails.value = false;
    }
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
