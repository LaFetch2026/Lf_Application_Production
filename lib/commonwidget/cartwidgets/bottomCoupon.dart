import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class BottomCoupon extends StatefulWidget {
  final List list;
  final Function(String) onressed;

  const BottomCoupon({
    Key? key,
    required this.list,
    required this.onressed,
  }) : super(key: key);

  @override
  State<BottomCoupon> createState() => BottomCouponState();
}

class BottomCouponState extends State<BottomCoupon> {
  List<bool> selected = List.generate(50, (i) => false);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 30, bottom: 20),
                  child: Row(
                    children: [
                      Text(
                        "Coupons",
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 14.sp,
                          decoration: TextDecoration.none,
                          fontFamily: "Franklin Gothic",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Expanded(
                        child: SizedBox(
                          width: 0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          "BACK",
                          style: TextStyle(
                            color: greyTextColor,
                            decoration: TextDecoration.none,
                            fontSize: 12.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: backWhite,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 70,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: widget.list.isNotEmpty
                        ? ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: widget.list.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (ctx, index) {
                              return Container(
                                color: whiteColor,
                                margin:
                                    const EdgeInsets.only(bottom: 10, top: 10),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 5),
                                              child: AppText(
                                                text: widget.list[index]
                                                    ["coupan"],
                                                color: loginText,
                                                fontSize: 16.sp,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              width: 80,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: btnTextColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: btnTextColor,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Center(
                                                  child: AppText(
                                                    text: "Apply",
                                                    color: whiteBack,
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        "Franklin Gothic",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 20),
                                        child: AppText(
                                          text:
                                              "Get upto Rs 150 cashback using Amazon Pay Balance",
                                          color: greyTextColor,
                                          fontSize: 12.sp,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                        : SizedBox(
                            height: MediaQuery.of(context).size.height - 60,
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: Text("No Coupan Found",
                                  style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                      color: Colors.black,
                                      fontFamily: "Franklin Gothic Regular")),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
