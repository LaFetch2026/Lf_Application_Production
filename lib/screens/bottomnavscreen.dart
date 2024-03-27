import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/screens/accountscreen.dart';
import 'package:lafetch/screens/expressshopscreen.dart';
import 'package:lafetch/screens/brandsscreen.dart';
import 'package:lafetch/screens/homescreen.dart';
import 'package:lafetch/screens/wishlistscreen.dart';
import 'package:lafetch/utils/constants.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  final screen = [
    const HomeScreen(),
    const BrandsScreen(),
    const WishlistScreen(),
    const AccountScreen(),
    const ExpressShoppingScreen(),
  ];
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
        onTap: () {
          setState(() {
            _currentIndex = 4;
          });
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
        color: colorPrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            MaterialButton(
              color: _currentIndex == 0 ? colorSecondary : colorPrimary,
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageIcon(
                      AssetImage(
                          _currentIndex == 0 ? homeIcon : homeUnselectImage),
                      color: _currentIndex == 0 ? bottomnavBack : greyTextColor,
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
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: MaterialButton(
                color: _currentIndex == 1 ? colorSecondary : colorPrimary,
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 5),
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
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: MaterialButton(
                color: _currentIndex == 2 ? colorSecondary : colorPrimary,
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 5),
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
            MaterialButton(
              color: _currentIndex == 3 ? colorSecondary : colorPrimary,
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageIcon(
                      AssetImage(_currentIndex == 3
                          ? accountSelectImage
                          : accountIcon),
                      color: _currentIndex == 3 ? bottomnavBack : greyTextColor,
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
          ],
        ),
      ),
      body: screen[_currentIndex],
    );
  }
}
