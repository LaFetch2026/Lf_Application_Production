// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/checkoutscreen.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../screens/paymentsuccessscreen.dart';
import '../utils/constants.dart';

class CartController extends BaseController {
  RxBool isOrder = false.obs;
  List orderList = [].obs;
  RxInt cartId = 0.obs;
  dynamic cartDetails = "".obs;
  RxString mrp = "".obs;
  RxString expressDelivery = "".obs;
  RxString discount = "".obs;
  RxString coupanDiscount = "".obs;
  RxString convenienceFee = "".obs;
  RxString tax = "".obs;
  RxString total = "".obs;

  getCartData() async {
    isOrder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/orders/cart"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          cartDetails = responseData;
          orderList = responseData["order_lines"];
          print(orderList);
          cartId.value = responseData["id"];
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
        getSnackBar("get order failed");
      }
    } catch (e) {
      print("error$e");
    }
    isOrder.value = false;
  }

  callDeleteCart() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/orders/${cartId.value}"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        Get.close(1);
        getSnackBar("Cart cleared");
        orderList.clear();
        getCartData();
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete cart failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callAddtoCart(int productId, int quantity, String page) async {
    if (page == "quantity") {
      showLoading();
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "product_id": productId,
        "quantity": quantity,
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/orders"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 200) {
        if (page == "addproduct") {
          print("addproduct");
          getSnackBar("Product added to bag");
          getCartData();
        } else if (page == "remove") {
          print("remove");
          Get.close(1);
          getCartData();
        } else if (page == "quantity") {
          getSnackBar("Quantity updated");
          Get.close(1);
          getCartData();
        } else {
          Get.close(1);
        }
      } else if (response.statusCode == 201) {
        if (page == "addproduct") {
          print("addproduct");
          getSnackBar("Product added to bag");
          getCartData();
        } else if (page == "remove") {
          print("remove");
          Get.close(1);
          getCartData();
        } else {
          Get.close(1);
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
        print(response.body);
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    if (page == "quantity") {
      hideLoading();
    }
  }

  callInitiatePayment(int addressId, dynamic context) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/orders/${cartId.value}/payment"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        /*  Get.to(CheckoutScreen(
          orderId: responseData["payment"]["transaction_id"],
          amount: responseData["payment"]["amount"],
          cartId: responseData["id"],
          mrp: mrp.value,
          expressDelivery: expressDelivery.value,
          convenienceFee: convenienceFee.value,
          coupanDiscount: coupanDiscount.value,
          discount: discount.value,
          tax: tax.value,
          total: total.value,
          addressId: addressId,
        )); */
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (BuildContext context) => CheckoutScreen(
                      orderId: responseData["payment"]["transaction_id"],
                      amount: responseData["payment"]["amount"],
                      cartId: responseData["id"],
                      mrp: mrp.value,
                      expressDelivery: expressDelivery.value,
                      convenienceFee: convenienceFee.value,
                      coupanDiscount: coupanDiscount.value,
                      discount: discount.value,
                      tax: tax.value,
                      total: total.value,
                      addressId: addressId,
                    )))
            .then((value) => (value) {
                  getCartData();
                });
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

  callProcessPayment(
      int cartId, String paymentId, String orderId, String signature) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "razorpay_payment_id": paymentId,
        "razorpay_order_id": orderId,
        "razorpay_signature": signature,
      };
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/orders/$cartId/process-payment"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      if (response.statusCode == 200) {
        print(response.body);
        Get.to(const PaymentSuccessScreen(
            text1: "Order Placed Successfully",
            text2: "Thank you for placing your order",
            image: orderSucessImage));
      } else if (response.statusCode == 400) {
        print(response.body);
        Get.to(const PaymentSuccessScreen(
            text1: "Payment Failed",
            text2: "Thank you for placing your order",
            image: paymentFailImage));
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
}
