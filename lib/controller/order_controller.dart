// ignore_for_file: avoid_print

import 'dart:convert';
//import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';
//import 'package:path_provider/path_provider.dart';

class OrderController extends BaseController {
  RxBool isOrder = false.obs;
  RxBool isDetails = false.obs;
  RxBool isTrack = false.obs;
  RxBool isInvoice = false.obs;
  RxDouble rating = 0.0.obs;
  final comment = TextEditingController();
  RxBool isUpdateLocation = false.obs;
  dynamic orderDetails = "".obs;
  RxString queryText = "".obs;
  List orderList = [].obs;
  dynamic shipmentDetails = "".obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  Rx<LatLng> deliveryPatnerLatLng = const LatLng(0, 0).obs;
  List trackList = [].obs;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxInt page = 1.obs;
  RxInt status = 0.obs;
  RxInt order_id = 0.obs;
  ScrollController orderListController = ScrollController();
  final searchController = TextEditingController();
  final exchangeComment = TextEditingController();
  List<bool> selected = List.generate(50, (i) => false).obs;
  final List filterList = [
    'All',
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Completed',
    'Exchange',
    'Approved',
    'Rejected',
  ].obs;

  final List filterId = [
    0,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
  ].obs;

  bool checkExchangeValidation() {
    if (exchangeComment.text.toString().trim().isEmpty) {
      getSnackBar(
        "Enter Reason",
      );
      return false;
    }
    return true;
  }

  getOrderData() async {
    isOrder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (status.value == 0) {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/orders?q=${queryText.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/orders?status=${status.value}&q=${queryText.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          orderList = responseData["data"];
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
        getSnackBar("get order failed ${response.statusCode}");
      }
    } catch (e) {
      print("error$e");
    }
    isOrder.value = false;
  }

  fetchMoreData() async {
    if (hasnextpage.value == true &&
        isOrder.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (status.value == 0) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/orders?page=${page.value}&q=${queryText.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/orders?page=${page.value}&status=${status.value}&q=${queryText.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        }

        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              orderList.addAll(responseData['data']);
            } else {
              hasnextpage.value = false;
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
          getSnackBar("fetch order failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getOrderDetails(int orderId) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/orders/$orderId"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (responseData != null) {
          orderDetails = responseData;
          if (responseData["deliveries"] != null) {
            trackList = responseData["deliveries"];
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
        getSnackBar("get order details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }

  getTrackorder(int orderId) async {
    isTrack.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/order/$orderId/tracking"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (responseData != null) {
          shipmentDetails = responseData;
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
        getSnackBar("get order track failed");
      }
    } catch (e) {
      print("error$e");
    }
    isTrack.value = false;
  }

  bool checkReviewValidation() {
    if (rating.value == 0.0) {
      getSnackBar(
        "Rate the product",
      );
      return false;
    }
    if (comment.text.toString().trim().isEmpty) {
      getSnackBar(
        "Enter Review",
      );
      return false;
    }
    return true;
  }

  callAddReview(int id, int orderId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "comment": comment.text.toString().trim(),
        "rating": rating.value,
        "order_id": orderId
      };
      var response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/products/$id/reviews"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      if (response.statusCode == 200) {
        getSnackBar("Review added");
        print(response.body);
        Get.close(1);
        getOrderDetails(orderId);
      } else if (response.statusCode == 201) {
        getSnackBar("Review added");
        print(response.body);
        Get.close(1);
        getOrderDetails(orderId);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  void callCancelOrder(int orderId, int parentOrderId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/orders/$orderId/cancel"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      if (response.statusCode == 200) {
        getOrderDetails(parentOrderId);
        getSnackBar("Order Cancelled");
        selected.clear();
        selected = List.generate(50, (i) => false);
        update();
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
        selected.clear();
        selected = List.generate(50, (i) => false);
        update();
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else {
        getSnackBar("cancel order failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void callExchangeProduct(int orderId, int sizeId, int newId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "order_inventory_id": newId,
        "reason": exchangeComment.text.toString().trim(),
        "exchange_inventory_id": sizeId,
      };
      var response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/orders/$orderId/exchange"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      if (response.statusCode == 201) {
        getSnackBar("Request send");
        Get.close(2);
        getOrderDetails(orderId);
        getOrderData();
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else {
        print("exchange product failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  void getDownloadInvoice(int orderId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/order/$orderId/mail-invoice"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        /* if (Platform.isAndroid) {
          const downloadsFolderPath = '/storage/emulated/0/Download/';
          Directory dir = Directory(downloadsFolderPath);
          final file = File('${dir.path}/OrderId${orderId}_invoice.pdf');
          print('PDF downloaded to: ${file.path}');
          await file.writeAsBytes(response.bodyBytes);
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/invoice.pdf');
          await file.writeAsBytes(response.bodyBytes);
        } */
        getSnackBar(responseData["message"]);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
        Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
      } else {
        print("get invoice failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  getLatLng() async {
    isUpdateLocation.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/order/${order_id.value}/live-track"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        lat.value = double.parse(responseData["delivery_partner"]["latitude"]);
        lng.value = double.parse(responseData["delivery_partner"]["longitude"]);
        deliveryPatnerLatLng.value = LatLng(lat.value, lng.value);
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
        getSnackBar("get lat lng failed");
      }
    } catch (e) {
      print("error$e");
    }
    isUpdateLocation.value = false;
  }
}
