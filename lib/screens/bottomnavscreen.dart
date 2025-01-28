import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/screens/accountscreen.dart';
import 'package:lafetch/screens/expressshopscreen.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import 'package:lafetch/screens/home/women/homescreen.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/product_controller.dart';

class BottomNavScreen extends StatefulWidget {
  final int? index;
  const BottomNavScreen({super.key, this.index});

  @override
  State<BottomNavScreen> createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final productController = Get.put(ProductController());
  int _currentIndex = 0;
  bool? skipValue;
  var screen = [
    const HomeScreen(),
    const BrandsScreen(
      screen: "home",
    ),
    const WishlistScreen(),
    const AccountScreen(),
    const ExpressShoppingScreen(),
  ];

  @override
  void initState() {
    analytics.setAnalyticsCollectionEnabled(true);
    screen = [
      HomeScreen(
        onPressed: (p0) {
          changeTab(p0);
        },
      ),
      const BrandsScreen(
        screen: "home",
      ),
      WishlistScreen(
        onPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      AccountScreen(onPressed: () {
        changeTab(2);
      }),
      const ExpressShoppingScreen(),
    ];
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
    getPrefrenceValue();
    super.initState();
  }

  Future getPrefrenceValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("skip") == true) {
      skipValue = true;
      setState(() {});
    }
  }

  void changeTab(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homeAppBarColor,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      /* floatingActionButton: GestureDetector(
        onTap: () async {
          setState(() {
            _currentIndex = 4;
          });
          await analytics.logEvent(
            name: 'express_page',
            parameters: <String, Object>{
              'page_name': 'express_page',
              'page_index': _currentIndex,
            },
          );
        },
        child: Image.asset(
          _currentIndex == 4 ? boltWhiteImage : expressNewImage,
          height: _currentIndex == 4 ? 70.sp : 58.sp,
          width: _currentIndex == 4 ? 70.sp : 58.sp,
          fit: BoxFit.contain,
        ),
      ), */
      /*   bottomNavigationBar: BottomAppBar(
        notchMargin: -15.sp,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        color: whiteColor,
        height: MediaQuery.of(context).size.height * 0.084,
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                onPressed: () async {
                  setState(() {
                    _currentIndex = 0;
                    /*  productController.current.value = 50;
                    productController.getExpressProductData(0, 3);
                    productController.getTagsProductData(0, 3, 0);
                    productController.update(); */
                  });
                  await analytics.logEvent(
                    name: 'home_page',
                    parameters: <String, Object>{
                      'page_name': 'home_page',
                      'page_index': _currentIndex,
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.sp),
                            color: _currentIndex == 0 ? greyback : whiteColor),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0.sp, horizontal: 10.sp),
                          child: ImageIcon(
                            AssetImage(homeNewImage),
                            color:
                                _currentIndex == 0 ? blackColor : greyTextColor,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.sp),
                        child: Text(
                          "Home",
                          style: TextStyle(
                              color: _currentIndex == 0
                                  ? blackColor
                                  : greyTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Franklin Gothic"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                onPressed: () async {
                  setState(() {
                    _currentIndex = 1;
                  });
                  await analytics.logEvent(
                    name: 'brand_page',
                    parameters: <String, Object>{
                      'page_name': 'brand_page',
                      'page_index': _currentIndex,
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.sp),
                            color: _currentIndex == 1 ? greyback : whiteColor),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0.sp, horizontal: 10.sp),
                          child: ImageIcon(
                            AssetImage(shopNewImage),
                            color:
                                _currentIndex == 1 ? blackColor : greyTextColor,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.sp),
                        child: Text(
                          "Brands",
                          style: TextStyle(
                              color: _currentIndex == 1
                                  ? blackColor
                                  : greyTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Franklin Gothic"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                onPressed: () async {
                  setState(() {
                    _currentIndex = 2;
                  });
                  await analytics.logEvent(
                    name: 'wishlist_page',
                    parameters: <String, Object>{
                      'page_name': 'wishlist_page',
                      'page_index': _currentIndex,
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.sp),
                            color: _currentIndex == 2 ? greyback : whiteColor),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0.sp, horizontal: 10.sp),
                          child: ImageIcon(
                            AssetImage(wishlistNewImage),
                            color:
                                _currentIndex == 2 ? blackColor : greyTextColor,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.sp),
                        child: Text(
                          "Wishlist",
                          style: TextStyle(
                              color: _currentIndex == 2
                                  ? blackColor
                                  : greyTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Franklin Gothic"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                onPressed: () async {
                  setState(() {
                    _currentIndex = 3;
                  });
                  await analytics.logEvent(
                    name: 'account_page',
                    parameters: <String, Object>{
                      'page_name': 'account_page',
                      'page_index': _currentIndex,
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.sp),
                            color: _currentIndex == 3 ? greyback : whiteColor),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0.sp, horizontal: 10.sp),
                          child: ImageIcon(
                            AssetImage(accountNewImage),
                            color:
                                _currentIndex == 3 ? blackColor : greyTextColor,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.sp),
                        child: Text(
                          "Account",
                          style: TextStyle(
                              color: _currentIndex == 3
                                  ? blackColor
                                  : greyTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Franklin Gothic"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
     */
      bottomNavigationBar: BottomAppBar(
        // notchMargin: -15.sp,
        // shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        color: homeAppBarColor,
        height: 80.sp, //0.074
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              height: 80.sp,
              color: homeAppBarColor,
              minWidth: MediaQuery.of(context).size.width % 5.sp,
              onPressed: () async {
                setState(() {
                  _currentIndex = 0;
                });
                await analytics.logEvent(
                  name: 'home_page',
                  parameters: <String, Object>{
                    'page_name': 'home_page',
                    'page_index': _currentIndex,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _currentIndex == 0 ? homeBottomIcon : homeBottomIcon,
                      color:
                          _currentIndex == 0 ? whiteColor : Color(0xFF9CA3AF),
                      height: 16.sp,
                      width: 16.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7.sp),
                      child: Text(
                        "Home".toUpperCase(),
                        style: TextStyle(
                            color: _currentIndex == 0
                                ? whiteColor
                                : Color(0xFF9CA3AF),
                            fontSize: 8.sp,
                            fontFamily: "Franklin Gothic"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
              height: 80.sp,
              minWidth: MediaQuery.of(context).size.width % 5.sp,
              color: homeAppBarColor,
              onPressed: () async {
                setState(() {
                  _currentIndex = 1;
                });
                await analytics.logEvent(
                  name: 'shop_page',
                  parameters: <String, Object>{
                    'page_name': 'brand_page',
                    'page_index': _currentIndex,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _currentIndex == 1 ? shopBottomIcon : shopBottomIcon,
                      color:
                          _currentIndex == 1 ? whiteColor : Color(0xFF9CA3AF),
                      height: 16.sp,
                      width: 16.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7.sp),
                      child: Text(
                        "Shop".toUpperCase(),
                        style: TextStyle(
                            color: _currentIndex == 1
                                ? whiteColor
                                : Color(0xFF9CA3AF),
                            fontSize: 8.sp,
                            fontFamily: "Franklin Gothic"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
              height: 80.sp,
              minWidth: MediaQuery.of(context).size.width % 5.sp,
              color: homeAppBarColor,
              onPressed: () async {
                if (skipValue == true) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => const LoginScreen(
                            initialTab: 0,
                          )));
                } else {
                  setState(() {
                    _currentIndex = 4;
                  });
                }
                await analytics.logEvent(
                  name: 'express_page',
                  parameters: <String, Object>{
                    'page_name': 'brand_page',
                    'page_index': _currentIndex,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _currentIndex == 4 ? expressImage : expressImage,
                      color: _currentIndex == 4
                          ? Color(0xFFDFC5FE)
                          : Color(0xFFDFC5FE),
                      height: 18.sp,
                      width: 18.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7.sp),
                      child: Text(
                        "Express".toUpperCase(),
                        style: TextStyle(
                            color: _currentIndex == 4
                                ? Color(0xFFDFC5FE)
                                : Color(0xFFDFC5FE),
                            fontSize: 8.sp,
                            fontFamily: "Franklin Gothic"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
              height: 80.sp,
              minWidth: MediaQuery.of(context).size.width % 5.sp,
              color: homeAppBarColor,
              onPressed: () async {
                setState(() {
                  _currentIndex = 2;
                });
                await analytics.logEvent(
                  name: 'wishlist_page',
                  parameters: <String, Object>{
                    'page_name': 'wishlist_page',
                    'page_index': _currentIndex,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _currentIndex == 2
                          ? wishlistBottomIcon
                          : wishlistBottomIcon,
                      color:
                          _currentIndex == 2 ? whiteColor : Color(0xFF9CA3AF),
                      height: 16.sp,
                      width: 16.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7.sp),
                      child: Text(
                        "Wishlist".toUpperCase(),
                        style: TextStyle(
                            color: _currentIndex == 2
                                ? whiteColor
                                : Color(0xFF9CA3AF),
                            fontSize: 8.sp,
                            fontFamily: "Franklin Gothic"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
              height: 80.sp,
              minWidth: MediaQuery.of(context).size.width % 5.sp,
              color: homeAppBarColor,
              onPressed: () async {
                if (skipValue == true) {
                  Get.to(
                    () => const LoginScreen(
                      initialTab: 0,
                    ),
                  );
                } else {
                  setState(() {
                    _currentIndex = 3;
                  });
                }
                await analytics.logEvent(
                  name: 'account_page',
                  parameters: <String, Object>{
                    'page_name': 'account_page',
                    'page_index': _currentIndex,
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _currentIndex == 3 ? shopBottomIcon : shopBottomIcon,
                      color:
                          _currentIndex == 3 ? whiteColor : Color(0xFF9CA3AF),
                      height: 16.sp,
                      width: 16.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7.sp),
                      child: Text(
                        "Account".toUpperCase(),
                        style: TextStyle(
                            color: _currentIndex == 3
                                ? whiteColor
                                : Color(0xFF9CA3AF),
                            fontSize: 8.sp,
                            fontFamily: "Franklin Gothic"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: screen[_currentIndex],
    );
  }
}
