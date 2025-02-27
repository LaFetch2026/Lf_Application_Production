// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/accountscreen.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/catalog/women_catalog.dart';
//import 'package:lafetch/screens/expressshopscreen.dart';
import 'package:lafetch/screens/home/women/homescreen.dart';
import 'package:lafetch/screens/loginscreen.dart';
import 'package:lafetch/screens/quickscreen.dart';
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
  final carttController = Get.put(CartController());
  int _currentIndex = 0;
  bool? skipValue;
  var screen = [
    const HomeScreen(),
    const BrandsScreen(
      screen: "home",
    ),
    const WomenCatalogScreen(),
    const AccountScreen(),
    const QuickScreen(),
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
      WomenCatalogScreen(),
      AccountScreen(onPressed: () {
        changeTab(2);
      }),
      const QuickScreen(),
    ];
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
      ));
    });
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
      backgroundColor: whiteColor,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        color: _currentIndex == 4 || _currentIndex == 5
            ? homeAppBarColor
            : whiteColor,
        height: Platform.isIOS ? 50.sp : 60.sp,
        child: _currentIndex == 4 || _currentIndex == 5
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
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
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              color: productSubtitleColor,
                              _currentIndex == 0 ? arrowBack : arrowBack,
                              height: 17.sp,
                              width: 15.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Back".toUpperCase(),
                                style: TextStyle(
                                    color: productSubtitleColor,
                                    fontSize: 10.sp,
                                    fontFamily: "Franklin Gothic"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60.sp,
                    width: 2.sp,
                    color: subtitleColor,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (skipValue == true) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LoginScreen(
                                    initialTab: 0,
                                    hideBack: true,
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
                      child: Container(
                        // height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              _currentIndex == 4
                                  ? quickSelectedSvgImage
                                  : quickSvgImage,
                              color: _currentIndex == 4
                                  ? Color(0xFF988AFF)
                                  : subtitleColor,
                              height: 19.sp,
                              width: 13.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Quick".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex == 4
                                        ? Color(0xFF988AFF)
                                        : subtitleColor,
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
                    child: InkWell(
                      onTap: () async {
                        carttController.orderList.clear();
                        setState(() {
                          _currentIndex = 5;
                        });
                      },
                      child: Container(
                        // height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              bagSvgImage,
                              color: _currentIndex != 5
                                  ? subtitleColor
                                  : lightPurpleColor,
                              height: 24.sp,
                              width: 19.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 2.sp),
                              child: Text(
                                "Bag".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex != 5
                                        ? subtitleColor
                                        : lightPurpleColor,
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
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
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
                      child: Container(
                        // height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*  Image.asset(
                        _currentIndex == 0 ? homeBottomIcon : homeBottomIcon,
                        color:
                            _currentIndex == 0 ? whiteColor : Color(0xFF9CA3AF),
                        height: 16.sp,
                        width: 16.sp,
                      ), */
                            SvgPicture.asset(
                              _currentIndex == 0
                                  ? homeSelectedSvgImage
                                  : homeSvgImage,
                              height: 17.sp,
                              width: 15.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Home".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex == 0
                                        ? homeAppBarColor
                                        : searchTextColor,
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
                    child: InkWell(
                      onTap: () async {
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
                      child: Container(
                        //  height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*  Image.asset(
                        _currentIndex == 1 ? shopBottomIcon : shopBottomIcon,
                        color:
                            _currentIndex == 1 ? whiteColor : Color(0xFF9CA3AF),
                        height: 16.sp,
                        width: 16.sp,
                      ), */
                            SvgPicture.asset(
                              _currentIndex == 1
                                  ? brandSelectedSvgImage
                                  : brandSvgImage,
                              height: 20.sp,
                              width: 20.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Brands".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex == 1
                                        ? homeAppBarColor
                                        : Color(0xFF9CA3AF),
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
                    child: InkWell(
                      onTap: () async {
                        if (skipValue == true) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LoginScreen(
                                    initialTab: 0,
                                    hideBack: true,
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
                      child: Container(
                        // height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*  Image.asset(
                        _currentIndex == 4 ? expressImage : expressImage,
                        color: _currentIndex == 4
                            ? Color(0xFFDFC5FE)
                            : Color(0xFFDFC5FE),
                        height: 18.sp,
                        width: 18.sp,
                      ), */
                            SvgPicture.asset(
                              _currentIndex == 4
                                  ? quickSelectedSvgImage
                                  : quickSvgImage,
                              height: 19.sp,
                              width: 13.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Quick".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex == 4
                                        ? Color(0xFF988AFF)
                                        : Color(0xFF988AFF),
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
                    child: InkWell(
                      onTap: () async {
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
                      child: Container(
                        // height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*  Image.asset(
                        _currentIndex == 2
                            ? wishlistBottomIcon
                            : wishlistBottomIcon,
                        color:
                            _currentIndex == 2 ? whiteColor : Color(0xFF9CA3AF),
                        height: 16.sp,
                        width: 16.sp,
                      ), */
                            SvgPicture.asset(
                              _currentIndex == 2
                                  ? categorySelectedSvgImage
                                  : categorySvgImage,
                              height: 17.sp,
                              width: 17.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Category".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex == 2
                                        ? homeAppBarColor
                                        : Color(0xFF9CA3AF),
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
                    child: InkWell(
                      onTap: () async {
                        if (skipValue == true) {
                          Get.to(
                            () => const LoginScreen(
                              initialTab: 0,
                              hideBack: true,
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
                      child: Container(
                        //  height: 80.sp,
                        padding: EdgeInsets.only(
                            top: 10.sp, bottom: Platform.isIOS ? 0 : 10.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*  Image.asset(
                        _currentIndex == 3 ? shopBottomIcon : shopBottomIcon,
                        color:
                            _currentIndex == 3 ? whiteColor : Color(0xFF9CA3AF),
                        height: 16.sp,
                        width: 16.sp,
                      ), */
                            SvgPicture.asset(
                              _currentIndex == 3
                                  ? profileSelectedSvgImage
                                  : profileSvgImage,
                              height: 17.sp,
                              width: 14.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Text(
                                "Profile".toUpperCase(),
                                style: TextStyle(
                                    color: _currentIndex == 3
                                        ? homeAppBarColor
                                        : Color(0xFF9CA3AF),
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
      body: _currentIndex == 5
          ? CartScreen(
              backgroundcolor: homeAppBarColor,
            )
          : screen[_currentIndex],
    );
  }
}
