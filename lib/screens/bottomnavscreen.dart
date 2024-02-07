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
      /* appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: btnTextColor,
            child: IconButton(
              onPressed: () {},
              icon: Image.asset(boltIcon),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text("Social Teams"),
        automaticallyImplyLeading: false,
        backgroundColor: whiteTextColor,
      ), */
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ImageIcon(
                      AssetImage(homeIcon),
                      size: 22,
                    ),
                    Text(
                      "Home",
                      style: TextStyle(
                          color: bottomnavBack,
                          fontSize: 10.sp,
                          fontFamily: "Franklin Gothic"),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
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
                    const ImageIcon(
                      AssetImage(brandsIcon),
                      size: 22,
                    ),
                    Text(
                      "Brands",
                      style: TextStyle(color: bottomnavBack, fontSize: 10.sp),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
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
                    const ImageIcon(
                      AssetImage(wishlistIcon),
                      size: 22,
                    ),
                    Text(
                      "Wishlist",
                      style: TextStyle(color: bottomnavBack, fontSize: 10.sp),
                    )
                  ],
                ),
              ),
            ),
            MaterialButton(
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
                    const ImageIcon(
                      AssetImage(accountIcon),
                      size: 22,
                    ),
                    Text(
                      "Account",
                      style: TextStyle(color: bottomnavBack, fontSize: 10.sp),
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
