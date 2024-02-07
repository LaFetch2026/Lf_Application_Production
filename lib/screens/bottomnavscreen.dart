import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/screens/accountscreen.dart';
import 'package:lafetch/screens/boltscreen.dart';
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
    const AccountScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const BoltScreen()));
        },
        backgroundColor: btnTextColor,
        foregroundColor: whiteBorderColor,
        child: Image.asset(boltIcon),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 1,
        shape: const CircularNotchedRectangle(),
        color: btnTextColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            MaterialButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              child: Container(
                color: _currentIndex == 0 ? colorSecondary : bottomnavBack,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, top: 5, left: 5, right: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        const AssetImage(homeIcon),
                        color:
                            _currentIndex == 0 ? bottomnavBack : colorSecondary,
                        size: 22,
                      ),
                      Text(
                        "Home",
                        style: TextStyle(
                            color: _currentIndex == 0
                                ? bottomnavBack
                                : colorSecondary,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              child: Container(
                color: _currentIndex == 1 ? colorSecondary : bottomnavBack,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, top: 5, left: 5, right: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        const AssetImage(brandsIcon),
                        color:
                            _currentIndex == 1 ? bottomnavBack : colorSecondary,
                        size: 22,
                      ),
                      Text(
                        "Brands",
                        style: TextStyle(
                            color: _currentIndex == 1
                                ? bottomnavBack
                                : colorSecondary,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: Container(
                color: _currentIndex == 2 ? colorSecondary : bottomnavBack,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, top: 5, left: 5, right: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        const AssetImage(wishlistIcon),
                        color:
                            _currentIndex == 2 ? bottomnavBack : colorSecondary,
                        size: 22,
                      ),
                      Text(
                        "Wishlist",
                        style: TextStyle(
                            color: _currentIndex == 2
                                ? bottomnavBack
                                : colorSecondary,
                            fontSize: 10.sp,
                            fontFamily: "Franklin Gothic"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
              child: Container(
                color: _currentIndex == 3 ? colorSecondary : bottomnavBack,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, top: 5, left: 5, right: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        const AssetImage(accountIcon),
                        color:
                            _currentIndex == 3 ? bottomnavBack : colorSecondary,
                        size: 22,
                      ),
                      Text(
                        "Account",
                        style: TextStyle(
                            color: _currentIndex == 3
                                ? bottomnavBack
                                : colorSecondary,
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
