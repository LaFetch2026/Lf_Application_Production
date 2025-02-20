// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/cartwidgets/bottomCoupon.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../screens/paymentsuccessscreen.dart';
import '../utils/constants.dart';

class CartController extends BaseController {
  RxBool isOrder = false.obs;
  RxBool isCoupan = false.obs;
  RxBool isPayment = false.obs;
  RxBool isRemoveCoupan = false.obs;
  List orderList = [].obs;
  RxInt cartId = 0.obs;
  RxString couponError = "".obs;
  dynamic cartDetails = "".obs;
  RxString mrp = "".obs;
  RxString expressDelivery = "".obs;
  RxString discount = "".obs;
  RxString coupanDiscount = "".obs;
  RxString convenienceFee = "".obs;
  RxString tax = "".obs;
  RxString total = "".obs;
  RxString couponText = "Apply Coupon".obs;
  RxString couponSave = "".obs;
  final couponController = TextEditingController();
  List couponList = [].obs;
  RxBool isExpress = false.obs;
  RxInt expressValue = 0.obs;
  RxInt couponlength = 0.obs;
  RxDouble lat = 0.0.obs;
  RxInt cartTotalValue = 0.obs;
  RxDouble lng = 0.0.obs;
  RxString qtyText = "".obs;
  RxString stockErrorText = "".obs;
  RxInt qtyProductId = 0.obs;
  List categoryList = [].obs;
  List tagsList = [].obs;
  List<bool> selected = List.generate(50, (i) => false).obs;
  /* List<Map<String, dynamic>> couponList = [
    {'id': '22', "coupan": 'ECoupan'},
    {'id': '73', "coupan": 'AXIS20'},
    {'id': '13', "coupan": 'MASTERCARD30'}
  ].obs; */

  getCartData() async {
    isOrder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/orders/cart?latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      cartTotalValue.value = orderList.length;
      if (response.statusCode == 200) {
        orderList.clear();
        var responseData = json.decode(response.body);
        if (responseData != null) {
          cartDetails = responseData;
          orderList = responseData["order_lines"];
          print(orderList);
          cartId.value = responseData["id"];
          qtyProductId.value = 0;
          qtyText.value = "";
          cartTotalValue.value = orderList.length;
          orderList.forEach((i) {
            if (i["inventory"]['stocks'] == 0) {
              stockErrorText.value = "Few items are unavailable for checkout";
            } else {
              stockErrorText.value = "";
            }
          });
          if (responseData["discount"] != null) {
            couponText.value = responseData["discount"]["code"];
            couponSave.value =
                responseData["discount"]["saved_total"].toString();
          } else {
            couponText.value = "Apply Coupon";
            couponSave.value = "";
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        /*  Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get order failed");
      }
    } catch (e) {
      print("error$e");
    }
    isOrder.value = false;
  }

  getExpressCartData() async {
    isOrder.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/orders/cart?latitude=${lat.value}&longitude=${lng.value}&type=express"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      cartTotalValue.value = orderList.length;
      if (response.statusCode == 200) {
        orderList.clear();
        var responseData = json.decode(response.body);
        if (responseData != null) {
          cartDetails = responseData;
          orderList = responseData["order_lines"];
          print(orderList);
          cartId.value = responseData["id"];
          qtyProductId.value = 0;
          qtyText.value = "";
          cartTotalValue.value = orderList.length;
          orderList.forEach((i) {
            if (i["inventory"]['stocks'] == 0) {
              stockErrorText.value = "Few items are unavailable for checkout";
            } else {
              stockErrorText.value = "";
            }
          });
          if (responseData["discount"] != null) {
            couponText.value = responseData["discount"]["code"];
            couponSave.value =
                responseData["discount"]["saved_total"].toString();
          } else {
            couponText.value = "Apply Coupon";
            couponSave.value = "";
          }
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        /*  Get.offAll(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        getSnackBar("Authentication failed"); */
        print(response.statusCode);
      } else {
        getSnackBar("get order failed");
      }
    } catch (e) {
      print("error$e");
    }
    isOrder.value = false;
  }

  getCouponData(Color backColor) async {
    isCoupan.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (backColor == whiteColor) {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/discounts"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/discounts?type=express"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          couponList = responseData;
          couponlength.value = 0;
          for (var i = 0; i < couponList.length; i++) {
            if (couponList[i]["applicable"]) {
              couponlength = couponlength++;
            }
          }
          Get.to(BottomCoupon(
            list: couponList,
            backColor: backColor,
            onPressed: (p0) {
              couponText.value = p0;
              callAddCoupon(
                p0,
                "cart",
                backColor,
              );
            },
          ));
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        Get.to(
          () => const LoginScreen(
            initialTab: 0,
          ),
        );
        print(response.statusCode);
        // getSnackBar("Authentication failed");
      } else {
        getSnackBar("get coupan failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCoupan.value = false;
  }

  callDeleteCart(Color backgroundColor) async {
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
        // getSnackBar("Cart cleared");
        orderList.clear();
        if (backgroundColor == whiteColor) {
          getCartData();
        } else {
          getExpressCartData();
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete cart failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  callAddtoCart(int quantity, String page, int inventoryId, int productId,
      int expressValue, int type, Color backColor) async {
    if (page == "quantity" || page == "size") {
      showLoading();
    }
    isExpress.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "quantity": quantity,
        "inventory_id": inventoryId,
        "product_id": productId,
        "order_id": cartId.value,
        "express_delivery": expressValue,
        "update_inventory": type,
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
          // getSnackBar("Product added to bag");
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "remove") {
          print("remove");
          Get.close(1);
          orderList.clear();
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "wishlist") {
          print("wishlist");
          orderList.clear();
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "quantity") {
          //getSnackBar("Quantity updated");
          Get.close(1);
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "size") {
          //  getSnackBar("Size updated");
          Get.close(1);
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "express") {
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
          selected.clear();
          selected = List.generate(50, (i) => false).obs;
        } else {
          Get.close(1);
        }
      } else if (response.statusCode == 201) {
        if (page == "addproduct") {
          print("addproduct");
          getSnackBar("Product added to bag");
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "remove") {
          print("remove");
          Get.close(1);
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "wishlist") {
          print("wishlist");
          orderList.clear();
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else if (page == "express") {
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else {
          Get.close(1);
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
        print(response.body);
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    if (page == "quantity" || page == "size") {
      hideLoading();
    }
    isExpress.value = false;
  }

  callInitiatePayment(int addressId, Razorpay razorpay) async {
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
        var options = {
          'key': ApiConstants.razorPayKey,
          'amount': double.parse(responseData["payment"]["amount"]) * 100,
          'name': 'Lafetch',
          'order_id': responseData["payment"]["transaction_id"],
          'description': 'Lafetch Customer',
          'timeout': 60,
          'theme': {
            'color': '#070707',
          },
          'fullscreen': true,
          'prefill': {
            'contact': '9002973232',
            'email': 'sonamagrahari11@gmail.com'
          }
        };
        razorpay.open(options);
        /*  Navigator.of(context)
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
                    ShipCost: shipCost,
                    lafetchtax: lafetchTax)))
            .then((value) => (value) {
                  getCartData();
                }); */
      } else if (response.statusCode == 400) {
        print(response.body);
        /*   if (responseData["errors"].isNotEmpty) {
          getSnackBar(responseData["errors"][0]);
        } */
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
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

  callAddCoupon(String code, String type, Color backColor) async {
    if (type == "cart") {
      showLoading();
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "code": code,
      };
      dynamic response;
      if (backColor == whiteColor) {
        response = await http.post(
            Uri.parse("${ApiConstants.baseUrl}/discounts/apply"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json;charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            },
            body: json.encode(sendData));
      } else {
        response = await http.post(
            Uri.parse("${ApiConstants.baseUrl}/discounts/apply?type=express"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json;charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            },
            body: json.encode(sendData));
      }

      if (response.statusCode == 200) {
        if (type == "cart") {
          Get.back();
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        } else {
          Get.back();
          if (backColor == whiteColor) {
            getCartData();
          } else {
            getExpressCartData();
          }
        }
        couponError.value = "";
      } else if (response.statusCode == 400) {
        couponError.value = "Coupon does not exist";
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    if (type == "cart") {
      hideLoading();
    }
  }

  callRemoveCoupon(Color backColor) async {
    isRemoveCoupan.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "code": "",
      };
      var response =
          await http.post(Uri.parse("${ApiConstants.baseUrl}/discounts/apply"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                'Content-Type': 'application/json;charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              },
              body: json.encode(sendData));
      if (response.statusCode == 200) {
        couponText.value = "Apply Coupon";
        if (backColor == whiteColor) {
          getCartData();
        } else {
          getExpressCartData();
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
    isRemoveCoupan.value = false;
  }

  callProcessPayment(
      int cartId, String paymentId, String orderId, String signature) async {
    isPayment.value = true;
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
        Get.to(PaymentSuccessScreen(
            text1: "Order Placed Successfully",
            orderId: cartId,
            text2: "Thank you for placing your order",
            image: orderSucessImage));
      } else if (response.statusCode == 400) {
        print(response.body);
        Get.to(const PaymentSuccessScreen(
            text1: "Payment Failed",
            orderId: 0,
            text2: "",
            image: paymentFailImage));
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    isPayment.value = false;
  }

  callEnableExpressDelivery(Color backColor) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "express_delivery": expressValue.value,
      };
      var response = await http.put(
          Uri.parse(
              "${ApiConstants.baseUrl}/orders/${cartId.value}/delivery-option"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (backColor == whiteColor) {
          getCartData();
        } else {
          getExpressCartData();
        }
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Please try again");
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
}
