import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/screens/accountscreen.dart';
import 'package:lafetch/screens/expressshopscreen.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import 'package:lafetch/screens/homescreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:lafetch/utils/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class BottomNavScreen extends StatefulWidget {
  final int? index;
  const BottomNavScreen({super.key, this.index});

  @override
  State<BottomNavScreen> createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int _currentIndex = 0;
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
      const HomeScreen(),
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
      AccountScreen(onPressed: changeTab),
      const ExpressShoppingScreen(),
    ];
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
    super.initState();
  }

  void changeTab() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
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
          height: 70.sp,
          width: 70.sp,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
                              vertical: 2.0.sp, horizontal: 8.sp),
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
                              vertical: 2.0.sp, horizontal: 8.sp),
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
                              vertical: 2.0.sp, horizontal: 8.sp),
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
                              vertical: 2.0.sp, horizontal: 8.sp),
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
      /*  bottomNavigationBar: BottomAppBar(
        notchMargin: -15.sp,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        color: colorPrimary,
        height: MediaQuery.of(context).size.height * 0.084, //0.074
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084, //0.068
                color: _currentIndex == 0 ? colorSecondary : colorPrimary,
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
                      ImageIcon(
                        AssetImage(
                            _currentIndex == 0 ? homeIcon : homeUnselectImage),
                        color:
                            _currentIndex == 0 ? bottomnavBack : greyTextColor,
                        size: 22.sp,
                      ),
                      Text(
                        "Home",
                        style: TextStyle(
                            color: _currentIndex == 0
                                ? bottomnavBack
                                : greyTextColor,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                color: _currentIndex == 1 ? colorSecondary : colorPrimary,
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
                      ImageIcon(
                        AssetImage(
                            _currentIndex == 1 ? brandSelectImage : brandsIcon),
                        color:
                            _currentIndex == 1 ? bottomnavBack : greyTextColor,
                        size: 22.sp,
                      ),
                      Text(
                        "Brands",
                        style: TextStyle(
                            color: _currentIndex == 1
                                ? bottomnavBack
                                : greyTextColor,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width/4,
            // ),
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                color: _currentIndex == 2 ? colorSecondary : colorPrimary,
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
                      ImageIcon(
                        AssetImage(_currentIndex == 2
                            ? wishlistSelectImage
                            : wishlistIcon),
                        color:
                            _currentIndex == 2 ? bottomnavBack : greyTextColor,
                        size: 22.sp,
                      ),
                      Text(
                        "Wishlist",
                        style: TextStyle(
                            color: _currentIndex == 2
                                ? bottomnavBack
                                : greyTextColor,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.084,
                color: _currentIndex == 3 ? colorSecondary : colorPrimary,
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
                      ImageIcon(
                        AssetImage(_currentIndex == 3
                            ? accountSelectImage
                            : accountIcon),
                        color:
                            _currentIndex == 3 ? bottomnavBack : greyTextColor,
                        size: 22.sp,
                      ),
                      Text(
                        "Account",
                        style: TextStyle(
                            color: _currentIndex == 3
                                ? bottomnavBack
                                : greyTextColor,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
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
      body: screen[_currentIndex],
    );
  }
}
