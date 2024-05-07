// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../utils/constants.dart';

class ProductController extends BaseController {
  RxBool isProduct = false.obs;
  RxBool isExpress = false.obs;
  RxBool isDetails = false.obs;
  RxBool isReview = false.obs;
  RxBool isPincode = false.obs;
  RxInt currentpage = 0.obs;
  RxInt inventoryId = 0.obs;
  RxInt sizeInventoryId = 0.obs;
  RxInt colorInventoryId = 0.obs;
  RxInt fabricInventoryId = 0.obs;
  dynamic productDetails = "".obs;
  RxBool isRecommendations = false.obs;
  List productList = [].obs;
  List expressProductList = [].obs;
  RxInt total = 0.obs;
  RxInt totalExpress = 0.obs;
  List inventoryList = [].obs;
  List sizeInventoryList = [].obs;
  List colorInventoryList = [].obs;
  List fabricInventoryList = [].obs;
  List reviewList = [].obs;
  List recommendedList = [].obs;
  final pincodeController = TextEditingController();
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxInt page = 1.obs;
  ScrollController listController = ScrollController();
  RxBool expressLoadMore = false.obs;
  RxBool expressHasnextpage = true.obs;
  RxInt expressPage = 1.obs;
  ScrollController expressListController = ScrollController();

  RxBool isVideoPlaying = true.obs;

  bool checkPinvalidation(String pin) {
    if (pin.isEmpty) {
      getSnackBar(
        "Enter Pincode",
      );
      return false;
    }
    if (pin.length < 6) {
      getSnackBar(
        "The pincode must be 6 digit.",
      );
      return false;
    }
    return true;
  }

  bool checkDetailsValidation() {
    if (sizeInventoryId.value == 0) {
      getSnackBar(
        "Select Size",
      );
      return false;
    }
    if (colorInventoryId.value == 0) {
      getSnackBar(
        "Select color",
      );
      return false;
    }
    if (fabricInventoryId.value == 0) {
      getSnackBar(
        "Select fabric",
      );
      return false;
    }
    return true;
  }

  getProductData(String type) async {
    isProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products?type=$type"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productList = responseData["data"];
          total.value = responseData["meta"]["total"];
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProduct.value = false;
  }

  getExpressProductData() async {
    isExpress.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products?type=express"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          expressProductList = responseData["data"];
          totalExpress.value = responseData["meta"]["total"];
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isExpress.value = false;
  }

  fetchExpressMoreData() async {
    if (expressHasnextpage.value == true &&
        isExpress.value == false &&
        expressLoadMore.value == false) {
      expressLoadMore.value = true;
      expressPage.value += 1;
      print(expressPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=express&page=${expressPage.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              expressProductList.addAll(responseData['data']);
            } else {
              expressHasnextpage.value = false;
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
          getSnackBar("fetch express product failed");
        }
      } catch (e) {
        print("error$e");
      }
      expressLoadMore.value = false;
    }
  }

  fetchMoreData(String type) async {
    if (hasnextpage.value == true &&
        isProduct.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=$type&page=${page.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              productList.addAll(responseData['data']);
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
          getSnackBar("fetch product failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  checkIfURLisImage(String url) async{
    final imageUrl = Uri.parse(url);
    var imageResponse=await http.head(imageUrl);
      // var responseData = json.decode(imageResponse.body);
    print('checkIfURLisImage=========${url}');

  }

  getProductDetails(int productId) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/$productId?type=relevant"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          productDetails = responseData;
          print('Product Details====>${productDetails["images"]}');
          inventoryList = responseData["inventories"];

          sizeInventoryList = inventoryList
              .where((i) =>
                  i['product_matrix']['product_matrix_group']['name'] == 'Size')
              .toList();

          colorInventoryList = inventoryList
              .where((i) =>
                  i['product_matrix']['product_matrix_group']['name'] ==
                  'Color')
              .toList();

          fabricInventoryList = inventoryList
              .where((i) =>
                  i['product_matrix']['product_matrix_group']['name'] ==
                  'Fabric')
              .toList();
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
        getSnackBar("get product details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }

  getProductReview(int productId) async {
    isReview.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products/$productId/reviews"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          reviewList = responseData["data"];
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
        getSnackBar("get product review failed");
      }
    } catch (e) {
      print("error$e");
    }
    isReview.value = false;
  }

  getProductRecommendations(int productId) async {
    isRecommendations.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products/$productId/recommendations"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          recommendedList = responseData["data"];
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
        getSnackBar("get product recommendation failed");
      }
    } catch (e) {
      print("error$e");
    }
    isRecommendations.value = false;
  }

  getCheckPincode(String pin) async {
    isPincode.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/general/check-pincode?pincode=$pin"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData != null) {
          getSnackBar(responseData["name"]);
        }
      } else if (response.statusCode == 400) {
        if (responseData['errors']['pincode'] != null) {
          getSnackBar(responseData['errors']['pincode'][0]);
        }
      } else if (response.statusCode == 404) {
        getSnackBar(responseData["message"]);
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
        getSnackBar("get pincode failed");
      }
    } catch (e) {
      print("error$e");
    }
    isPincode.value = false;
  }

  callAddtoCart(int productId, int quantity) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "product_id": productId,
        "quantity": quantity,
        "inventory_id": sizeInventoryId.value
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
        getSnackBar("Product added to bag");
        Get.close(1);
      } else if (response.statusCode == 201) {
        getSnackBar("Product added to bag");
        Get.close(1);
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

  callAddProductToWishlist(int wishlistId, String type, int id) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/products/$id/wishlist/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData["wishlisted"]) {
          Get.close(1);
          getSnackBar("product added to the wishlist");
        } else {
          getSnackBar("product removed to the wishlist");
        }
        if (type == "product") {
          getProductData("relevant");
        } else if (type == "express") {
          getProductData("express");
        } else {
          getProductRecommendations(id);
        }
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("item add failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
