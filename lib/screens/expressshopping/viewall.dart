// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../commonwidget/app_text.dart';
import '../../commonwidget/doublebtn.dart';
import '../../utils/constants.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "400",
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    child: AppText(
                      text: "Express Delivery",
                      fontFamily: "Franklin Gothic Regular",
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                      fontSize: 16.sp,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 10),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      childAspectRatio: 0.5,
                      physics: const ScrollPhysics(),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 0,
                      children: List.generate(
                        items.length,
                        (index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Center(
                                          child: Image.asset(backImage,
                                              height: 190,
                                              width: 152,
                                              fit: BoxFit.cover),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircleAvatar(
                                                  backgroundColor: whiteColor,
                                                  child: Image.asset(
                                                    heartImage,
                                                    height: 16,
                                                    color: bottomnavBack,
                                                    width: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: AppText(
                                        text: "Jack & Jones Core ",
                                        color: nameText,
                                        maxLines: 2,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: AppText(
                                        text:
                                            "Topman super skinny suit jacket and trousers in light blue",
                                        color: nameText,
                                        maxLines: 2,
                                        fontSize: 11.sp,
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: Row(
                                        children: [
                                          AppText(
                                            text: "\u{20B9} ${items[index]}",
                                            color: deepGreytextColor,
                                            maxLines: 2,
                                            fontSize: 11.sp,
                                            fontFamily: "Franklin Gothic",
                                            fontWeight: FontWeight.w400,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              "\u{20B9} ${items[index]}",
                                              style: TextStyle(
                                                color: textHintColor,
                                                fontSize: 11.sp,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: Row(
                                        children: [
                                          const ImageIcon(
                                            AssetImage(truckImage),
                                            color: expressText,
                                            size: 14,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: AppText(
                                              text: "Express",
                                              color: expressText,
                                              maxLines: 2,
                                              fontSize: 11.sp,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DoubleButton(
            firstText: "Sort By",
            secondText: "Filters",
            firstTextColor: deepGreytextColor,
            secondTextColor: deepGreytextColor,
            firstBackgroundColor: whiteBorderColor,
            secondBackgroundColor: whiteBorderColor,
            firstBorderColor: deepGreytextColor,
            secondBorderColor: deepGreytextColor,
            onPressedFirst: () {},
            onPressedSecond: () {
              /*  Get.to(
                      () => const LoginScreen(),
                    ); */
            },
          ),
        ],
      ),
    );
  }
}
