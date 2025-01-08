// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/base_controller.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lafetch/commonwidget/common_widgets.dart';
import '../screens/wishlist/createboardscreen.dart';
import '../utils/constants.dart';

class WishlistController extends BaseController {
  RxBool isWishlist = false.obs;
  RxBool isDetails = false.obs;
  RxBool isProductWishlist = false.obs;
  dynamic wishListDetails = "".obs;
  dynamic wishlistDetails = "".obs;
  List wishlistList = [].obs;
  List deleteidList = [].obs;
  List addList = [].obs;
  List productList = [].obs;
  List wishListProduct = [].obs;
  RxInt addItem = 0.obs;
  RxInt totalBoard = 0.obs;
  final boardNameController = TextEditingController();
  List<bool> selected = List.generate(50, (i) => false).obs;
  List deleteId = [].obs;
  RxBool loadMore = false.obs;
  RxBool hasnextpage = true.obs;
  RxInt page = 1.obs;
  RxString boardError = "".obs;
  ScrollController wishlistListController = ScrollController();
  RxBool pLoadMore = false.obs;
  RxBool pHasnextpage = true.obs;
  RxInt productPage = 1.obs;
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  ScrollController productListController = ScrollController();

  /*  final List<Map<String, String>> wishlistList = [
    {'id': '1', "name": 'All item'},
    {'id': '2', "name": 'Bag'},
    {'id': '3', "name": 'All Item'},
    {'id': '4', "name": 'Watch'},
  ].obs; */

  /*  @override
  void onInit() async {
    getWishlistData();
    super.onInit();
  } */

  bool checkIdvalidation() {
    if (addItem.value == 0) {
      getSnackBar(
        "Select item",
      );
      return false;
    }
    return true;
  }

  bool checkIdNamevalidation(String name) {
    if (name.isEmpty) {
      /*  getSnackBar(
        "Enter Board Name",
      ); */
      boardError.value = "Enter Board Name";
      return false;
    }
    return true;
  }

  getWishlistData() async {
    isWishlist.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/wishlists"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          wishlistList = responseData["data"];
          totalBoard.value = responseData["meta"]["total"];
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
        getSnackBar("get wishlist failed");
      }
    } catch (e) {
      print("error$e");
    }
    isWishlist.value = false;
  }

  fetchMoreData() async {
    if (hasnextpage.value == true &&
        isWishlist.value == false &&
        loadMore.value == false) {
      loadMore.value = true;
      page.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/wishlists?page=${page.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              wishlistList.addAll(responseData['data']);
              print(wishlistList.length);
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
          getSnackBar("fetch brand failed");
        }
      } catch (e) {
        print("error$e");
      }
      loadMore.value = false;
    }
  }

  getProductData(String type) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/products?type=$type&latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          wishListProduct.clear();
          wishListProduct = responseData["data"];
          selected.clear();
          selected = List.generate(responseData['meta']["total"], (i) => false);
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
    isDetails.value = false;
  }

  fetchProductMoreData(String type) async {
    if (pHasnextpage.value == true &&
        isDetails.value == false &&
        pLoadMore.value == false) {
      pLoadMore.value = true;
      productPage.value += 1;
      print(productPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=$type&page=${productPage.value}&latitude=${lat.value}&longitude=${lng.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              wishListProduct.addAll(responseData['data']);
              /*  selected.clear();
              selected =
                  List.generate(responseData['meta']["total"], (i) => false); */
            } else {
              pHasnextpage.value = false;
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
      pLoadMore.value = false;
    }
  }

  getWishlistDetails(int wishlistId, int value) async {
    isDetails.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse(
              "${ApiConstants.baseUrl}/wishlists/$wishlistId?latitude=${lat.value}&longitude=${lng.value}"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        if (responseData != null) {
          wishlistDetails = responseData;
          wishListProduct.clear();
          if (responseData["products"].isNotEmpty) {
            wishListProduct = responseData["products"];
            if (value == 1) {
              deleteidList.clear();
              addList.clear();
              deleteId.clear();
              for (var i = 0; i < wishListProduct.length; i++) {
                deleteidList.add(wishListProduct[i]["id"]);
                addList.add(wishListProduct[i]["id"]);
                deleteId.add(wishListProduct[i]["id"]);
              }
              print("object delete $deleteidList");
              print("object add $deleteidList");
              print("object remain $addList");
            }
            selected.clear();
            selected = List.generate(wishListProduct.length, (i) => false);
          } else {
            addList.clear();
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
        getSnackBar("get wishlist details failed");
      }
    } catch (e) {
      print("error$e");
    }
    isDetails.value = false;
  }

  callCreateWishlist(String name) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/wishlists?name=$name"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        print(responseData);
        // getSnackBar("Board Created");
        boardError.value = "";
        Get.off(
          () => CreateBoardScreen(
            btnText: "Add",
            wishlistId: responseData["id"],
            type: "add",
          ),
        );
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("create wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callUpdateWishlist(String name, int id) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/wishlists/$id?name=$name"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        boardError.value = "";
        // getSnackBar("Board Updated");
        Get.close(2);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("update wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callDeleteWishlist(int wishlistId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          'Content-Type': 'application/json;charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      if (response.statusCode == 200) {
        // getSnackBar("Board deleted");
        addList.clear();
        Get.close(3);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete wishlist failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /* callDeleteProduct(int wishlistId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "product_ids": deleteidList,
        "wishlist_id": wishlistId,
      };
      var response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/wishlists/delete/products"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      if (response.statusCode == 200) {
        deleteidList.clear();
        getSnackBar("Product deleted");
        Get.close(4);
      } else if (response.statusCode == 400) {
        print(response.body);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        print("delete product failed");
      }
    } catch (e) {
      print(e.toString());
    }
  } */

  /*  callAddProductWishlist(int wishlistId, int id) async {
    showLoading();
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
      if (response.statusCode == 200) {
        getSnackBar("item added");
        Get.close(2);
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
    hideLoading();
  } */

  getWishlistProductDetails(int productId) async {
    isProductWishlist.value = true;
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
          wishListDetails = responseData;
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
        getSnackBar("get product details 2 failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProductWishlist.value = false;
  }

  callAddProductToWishlist(int wishlistId, int id) async {
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
          // getSnackBar("product added to the wishlist");
        } else {
          //  getSnackBar("product removed from the wishlist");
        }
        getWishlistProductDetails(responseData["id"]);
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

  callAddWishlist(int wishlistId, String type) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "product_ids": addList,
      };
      var response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId/products"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));

      if (response.statusCode == 200) {
        addList.clear();
        getWishlistData();
        // getSnackBar("Item added");
        if (type == "add") {
          Get.close(1);
        } else {
          Get.close(2);
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
    hideLoading();
  }

  callDeleteProductWishlist(int wishlistId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (deleteidList.isNotEmpty) {
        final Map<String, dynamic> sendData = {
          "product_ids": deleteidList,
        };
        response = await http.put(
            Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId/products"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json;charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            },
            body: json.encode(sendData));
      } else {
        response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId/products"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
        );
      }
      if (response.statusCode == 200) {
        deleteidList.clear();
        // getSnackBar("Product deleted");
        Get.close(3);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("product delete failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callDeleteSingleProduct(int wishlistId) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (deleteId.isNotEmpty) {
        final Map<String, dynamic> sendData = {
          "product_ids": deleteId,
        };
        response = await http.put(
            Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId/products"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              'Content-Type': 'application/json;charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            },
            body: json.encode(sendData));
      } else {
        response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/wishlists/$wishlistId/products"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
        );
      }
      if (response.statusCode == 200) {
        deleteId.clear();
        // getSnackBar("Product deleted");
        Get.close(1);
        getWishlistDetails(wishlistId, 1);
      } else if (response.statusCode == 500) {
        getSnackBar("Server Error");
      } else if (response.statusCode == 401) {
        getSnackBar("Authentication failed");
      } else {
        getSnackBar("product delete failed");
      }
    } catch (e) {
      print(e.toString());
    }
    hideLoading();
  }

  callMovetoCart(
      int wishlistId, int productId, int inventoryId, int qty) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "wishlist_id": wishlistId,
        "inventory_id": inventoryId,
        "quantity": qty
      };
      var response = await http.put(
          Uri.parse("${ApiConstants.baseUrl}/products/$productId/move-to-cart"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json;charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          },
          body: json.encode(sendData));
      if (response.statusCode == 200) {
        // getSnackBar("Product moved to bag");
        wishListProduct.clear();
        addList.clear();
        deleteidList.clear();
        getWishlistDetails(wishlistId, 1);
      } else if (response.statusCode == 201) {
        //  getSnackBar("Product moved to bag");
        wishListProduct.clear();
        addList.clear();
        deleteidList.clear();
        getWishlistDetails(wishlistId, 1);
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
}
