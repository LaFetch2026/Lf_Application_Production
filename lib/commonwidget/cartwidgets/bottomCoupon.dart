import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants.dart';
import '../app_text.dart';
import '../appbarwidgets/backbutton_appbar.dart';

class BottomCoupon extends StatefulWidget {
  final List list;
  final Function(String) onPressed;

  const BottomCoupon({
    Key? key,
    required this.list,
    required this.onPressed,
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
                /*  Padding(
                  padding: EdgeInsets.only(
                      left: 16.sp, right: 16.sp, top: 50.sp, bottom: 20.sp),
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
                */
                const BackButtonAppbar(
                  text: "Coupons",
                  threeDot: false,
                  backgroundColor: whiteColor,
                  icon: threeDotImage,
                ),
                Container(
                  color: backWhite,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 90.sp,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
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
                                    EdgeInsets.only(bottom: 10.sp, top: 10.sp),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 10.sp,
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.sp,
                                                  vertical: 5.sp),
                                              child: AppText(
                                                text: widget.list[index]
                                                    ["code"],
                                                color: loginText,
                                                fontSize: 16,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          selected[index]
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 30.sp,
                                                      right: 40.sp),
                                                  child: Center(
                                                    child: SizedBox(
                                                      height: 16.sp,
                                                      width: 16.sp,
                                                      child: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    selected[index] =
                                                        !selected[index];
                                                    setState(() {});
                                                    widget.onPressed.call(widget
                                                        .list[index]["code"]);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 14.sp,
                                                    ),
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      margin: EdgeInsets.only(
                                                          right: 5.sp),
                                                      width: 80.sp,
                                                      height: 30.sp,
                                                      decoration: BoxDecoration(
                                                        color: btnTextColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20.sp),
                                                        border: Border.all(
                                                            color: btnTextColor,
                                                            width: 1.sp),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.sp),
                                                        child: Center(
                                                          child: AppText(
                                                            text: "Apply",
                                                            color: whiteBack,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Franklin Gothic",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.sp, vertical: 20.sp),
                                        child: AppText(
                                          text: widget.list[index]
                                                  ["description"] ??
                                              "",
                                          color: greyTextColor,
                                          fontSize: 12,
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
                            height: MediaQuery.of(context).size.height - 60.sp,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text("No Coupon Found",
                                  style: TextStyle(
                                      fontSize: 14.sp,
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
