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
  RxBool isMostSearch = false.obs;
  RxBool isCategoryProduct = false.obs;
  RxBool istagsProduct = false.obs;
  RxBool isBannerTag = false.obs;
  RxBool isBrandExpressProduct = false.obs;
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
  dynamic brandDetails = "".obs;
  dynamic compositionDetails = "".obs;
  dynamic returnPolicyDetails = "".obs;
  RxBool isRecommendations = false.obs;
  List tagProductList = [].obs;
  List productList = [].obs;
  List mostSeachList = [].obs;
  List expressProductList = [].obs;
  List productCategoryList = [].obs;
  List productExpressBrandList = [].obs;
  RxInt total = 0.obs;
  RxInt curr = 0.obs;
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
  ScrollController categoryProductController = ScrollController();
  RxBool categoryProductLoadMore = false.obs;
  RxBool categoryProductHasnextpage = true.obs;
  RxInt categoryProductPage = 1.obs;
  ScrollController brandExpressProductController = ScrollController();
  RxBool brandExpressLoadMore = false.obs;
  RxBool brandExpressHasnextpage = true.obs;
  RxInt brandExpressPage = 1.obs;
  ScrollController tagsProductController = ScrollController();
  RxBool tagsLoadMore = false.obs;
  RxBool tagsHasnextpage = true.obs;
  RxInt tagsPage = 1.obs;
  ScrollController mostViewController = ScrollController();
  RxBool mostViewLoadMore = false.obs;
  RxBool mostViewHasnextpage = true.obs;
  RxInt mostViewPage = 1.obs;
  ScrollController bannerTagController = ScrollController();
  RxBool bannerTagLoadMore = false.obs;
  RxBool bannerTagHasnextpage = true.obs;
  RxInt bannerTagPage = 1.obs;
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
    if (sizeInventoryId.value == 0 && sizeInventoryList.isNotEmpty) {
      getSnackBar(
        "Select Size",
      );
      return false;
    }
    if (colorInventoryId.value == 0 && colorInventoryList.isNotEmpty) {
      getSnackBar(
        "Select color",
      );
      return false;
    }
    if (fabricInventoryId.value == 0 && fabricInventoryList.isNotEmpty) {
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
          if (type == "relevant") {
            total.value = responseData["meta"]["total"];
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
        getSnackBar("get product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isProduct.value = false;
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

  getTagsProductData(int tagId) async {
    istagsProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/products?tag_ids[]=$tagId"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          tagProductList = responseData["data"];
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
        getSnackBar("get tag product failed");
      }
    } catch (e) {
      print("error$e");
    }
    istagsProduct.value = false;
  }

  fetchMoreTagsProductData(int tagId) async {
    if (tagsHasnextpage.value == true &&
        istagsProduct.value == false &&
        tagsLoadMore.value == false) {
      tagsLoadMore.value = true;
      tagsPage.value += 1;
      print(page.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?tag_ids[]=$tagId&page=${tagsPage.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              tagProductList.addAll(responseData['data']);
            } else {
              tagsHasnextpage.value = false;
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
          getSnackBar("fetch tag product failed");
        }
      } catch (e) {
        print("error$e");
      }
      tagsLoadMore.value = false;
    }
  }

  getTagsBannerData(List list) async {
    isCategoryProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
        Uri.parse(
            "${ApiConstants.baseUrl}/products?tag_ids[]=${list.join(',')}"),
        headers: <String, String>{
          'Accept': 'application/json; charset=UTF-8',
          "Authorization": "Bearer ${prefs.getString('token')} ",
        },
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productCategoryList = responseData["data"];
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
        getSnackBar("get banner tag product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isCategoryProduct.value = false;
  }

  fetchMoreBannerTagProductData(List list) async {
    if (bannerTagHasnextpage.value == true &&
        isCategoryProduct.value == false &&
        bannerTagLoadMore.value == false) {
      bannerTagLoadMore.value = true;
      bannerTagPage.value += 1;
      print(bannerTagPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?page=${bannerTagPage.value}&tag_ids[]=${list.join(',')}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              productCategoryList.addAll(responseData['data']);
            } else {
              bannerTagHasnextpage.value = false;
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
          getSnackBar("fetch banner tag product failed");
        }
      } catch (e) {
        print("error$e");
      }
      bannerTagLoadMore.value = false;
    }
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

  getBrandExpressProductData(int brandId) async {
    isBrandExpressProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (brandId != 0) {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=express&brand_id=$brandId"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse("${ApiConstants.baseUrl}/products?type=express"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productExpressBrandList = responseData["data"];
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
    isBrandExpressProduct.value = false;
  }

  fetchBrandExpressMoreData(int brandId) async {
    if (brandExpressHasnextpage.value == true &&
        isBrandExpressProduct.value == false &&
        brandExpressLoadMore.value == false) {
      brandExpressLoadMore.value = true;
      brandExpressPage.value += 1;
      print(brandExpressPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (brandId != 0) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=express&brand_id=$brandId&page=${brandExpressPage.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?type=express&page=${brandExpressPage.value}"),
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
              productExpressBrandList.addAll(responseData['data']);
            } else {
              brandExpressHasnextpage.value = false;
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
          getSnackBar("fetch category product failed");
        }
      } catch (e) {
        print("error$e");
      }
      brandExpressLoadMore.value = false;
    }
  }

  getProductByCategoryData(int categoryId, int brandId) async {
    isCategoryProduct.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic response;
      if (brandId != 0) {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?category_id=$categoryId&brand_id=$brandId"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      } else {
        response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?category_id=$categoryId"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
      }
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          productCategoryList = responseData["data"];
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
    isCategoryProduct.value = false;
  }

  fetchCategoryProductMoreData(int categoryId, int brandId) async {
    if (categoryProductHasnextpage.value == true &&
        isCategoryProduct.value == false &&
        categoryProductLoadMore.value == false) {
      categoryProductLoadMore.value = true;
      categoryProductPage.value += 1;
      print(categoryProductPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        dynamic response;
        if (brandId != 0) {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?category_id=$categoryId&brand_id=$brandId&page=${categoryProductPage.value}"),
              headers: <String, String>{
                'Accept': 'application/json; charset=UTF-8',
                "Authorization": "Bearer ${prefs.getString('token')} ",
              });
        } else {
          response = await http.get(
              Uri.parse(
                  "${ApiConstants.baseUrl}/products?category_id=$categoryId&page=${categoryProductPage.value}"),
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
              productCategoryList.addAll(responseData['data']);
            } else {
              categoryProductHasnextpage.value = false;
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
          getSnackBar("fetch category product failed");
        }
      } catch (e) {
        print("error$e");
      }
      categoryProductLoadMore.value = false;
    }
  }

  getMostViewProductData() async {
    isMostSearch.value = true;
    final prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/products?type=most-searched"),
          headers: <String, String>{
            'Accept': 'application/json; charset=UTF-8',
            "Authorization": "Bearer ${prefs.getString('token')} ",
          });
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData["data"] != null) {
          mostSeachList = responseData["data"];
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
        getSnackBar("get most search product failed");
      }
    } catch (e) {
      print("error$e");
    }
    isMostSearch.value = false;
  }

  fetchMostSearchMoreData() async {
    if (mostViewHasnextpage.value == true &&
        isMostSearch.value == false &&
        mostViewLoadMore.value == false) {
      mostViewLoadMore.value = true;
      mostViewPage.value += 1;
      print(mostViewPage.value);
      final prefs = await SharedPreferences.getInstance();
      try {
        var response = await http.get(
            Uri.parse(
                "${ApiConstants.baseUrl}/products?type=most-searched&page=${mostViewPage.value}"),
            headers: <String, String>{
              'Accept': 'application/json; charset=UTF-8',
              "Authorization": "Bearer ${prefs.getString('token')} ",
            });
        var responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData["data"] != null) {
            if (responseData["data"].isNotEmpty) {
              print(responseData);
              mostSeachList.addAll(responseData['data']);
            } else {
              mostViewHasnextpage.value = false;
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
          getSnackBar("fetch most search product failed");
        }
      } catch (e) {
        print("error$e");
      }
      mostViewLoadMore.value = false;
    }
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

          if (responseData["brand"] != null) {
            brandDetails = responseData["brand"];
          }
          if (responseData["composition"] != null) {
            compositionDetails = responseData["composition"];
          }
          if (responseData["return_policy"] != null) {
            returnPolicyDetails = responseData["return_policy"];
          }
          print('Product Details====>${productDetails["images"]}');
          //  inventoryList = responseData["inventories"];
          sizeInventoryList = responseData["inventories"]["size"];
          colorInventoryList = responseData["inventories"]["color"];
          /*  sizeInventoryList = inventoryList
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
              .toList(); */
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

  callAddtoCart(int quantity) async {
    showLoading();
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> sendData = {
        "quantity": quantity,
        "inventory_id": sizeInventoryId.value == 0
            ? colorInventoryId.value
            : sizeInventoryId.value
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
        //  getSnackBar("Product added to bag");
        // Get.close(1);
      } else if (response.statusCode == 201) {
        // getSnackBar("Product added to bag");
        //Get.close(1);
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

  callAddProductToWishlist(int wishlistId, String type, int id, int categoryId,
      int brandId, List list) async {
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
        } else if (type == "category") {
          getProductByCategoryData(categoryId, brandId);
        } else if (type == "tags") {
          getTagsProductData(prefs.getInt('tagId')!);
        } else if (type == "brand") {
          getBrandExpressProductData(brandId);
        } else if (type == "bannerTag") {
          getTagsBannerData(list);
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
