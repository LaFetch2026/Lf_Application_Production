import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/screens/home/women/discountscreen.dart';

import '../../commonwidget/app_text.dart';
import '../../utils/constants.dart';

class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
  List<String> items = [
    "Discounts",
    "New Arrivals",
    "Clothing",
    "Footwear",
  ];
  final screen = [
    const DiscountScreen(),
    const DiscountScreen(),
    const DiscountScreen(),
    const DiscountScreen(),
  ];

  int current = 0;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: whiteTextColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              current = index;
                            });
                            pageController.animateToPage(
                              current,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 5),
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: current == index
                                  ? btnTextColor
                                  : whiteTextColor,
                              borderRadius: current == index
                                  ? BorderRadius.circular(20)
                                  : BorderRadius.circular(20),
                              border: current == index
                                  ? Border.all(color: btnTextColor, width: 1)
                                  : Border.all(color: textHintColor, width: 1),
                            ),
                            child: Center(
                              child: AppText(
                                text: items[index],
                                color: current == index
                                    ? whiteBorderColor
                                    : textHintColor,
                                fontSize: 12.sp,
                                fontFamily: "Franklin Gothic",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: screen.length,
              controller: pageController,
              physics: const ScrollPhysics(),
              itemBuilder: (context, index) {
                return screen[current];
              },
            ),
          ),
        ],
      ),
    );
  }
}
