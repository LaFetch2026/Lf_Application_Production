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
      floatingActionButton: /* FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 4;
          });
        },
        backgroundColor: null,
        foregroundColor: null,
        child: Image.asset(
          _currentIndex == 4 ? boltIcon : boltIcon,
          height: 70,
          width: 70,
        ),
      ), */
          GestureDetector(
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
          _currentIndex == 4 ? boltWhiteImage : boltBlackImage,
          height: 70,
          width: 70,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: -15,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        color: colorPrimary,
        height: MediaQuery.of(context).size.height * 0.074,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.068,
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
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        AssetImage(
                            _currentIndex == 0 ? homeIcon : homeUnselectImage),
                        color:
                            _currentIndex == 0 ? bottomnavBack : greyTextColor,
                        size: 22,
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
                height: MediaQuery.of(context).size.height * 0.068,
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
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        AssetImage(
                            _currentIndex == 1 ? brandSelectImage : brandsIcon),
                        color:
                            _currentIndex == 1 ? bottomnavBack : greyTextColor,
                        size: 22,
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
                height: MediaQuery.of(context).size.height * 0.068,
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
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        AssetImage(_currentIndex == 2
                            ? wishlistSelectImage
                            : wishlistIcon),
                        color:
                            _currentIndex == 2 ? bottomnavBack : greyTextColor,
                        size: 22,
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
                height: MediaQuery.of(context).size.height * 0.068,
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
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        AssetImage(_currentIndex == 3
                            ? accountSelectImage
                            : accountIcon),
                        color:
                            _currentIndex == 3 ? bottomnavBack : greyTextColor,
                        size: 22,
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
      body: screen[_currentIndex],
    );
  }
}
