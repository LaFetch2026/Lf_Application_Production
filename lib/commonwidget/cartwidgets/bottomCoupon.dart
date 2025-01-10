// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/appbarwidgets/saveaddress_appbar.dart';
import 'package:lafetch/controller/cart_controller.dart';
import 'package:lafetch/screens/bottomnavscreen.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

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
  final controller = Get.put(CartController());
  Timer? debounce;

  onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SaveAddressAppbar(
            text: "Apply Coupon",
            onPressedWishlist: () {
              Get.off(BottomNavScreen(
                index: 2,
              ));
            },
          ),
          Divider(
            color: dividerColor,
            height: 1.sp,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*   MediaQuery.of(context).size.width < 600
                      ? SizedBox(
                          height: 40.sp,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (value) {
                                print(value);
                                if (value is RawKeyDownEvent) {}
                              },
                              child: TextField(
                                textCapitalization: TextCapitalization.words,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: textColor,
                                  fontFamily: "Franklin Gothic Regular",
                                ),
                                controller: controller.couponController,
                                onChanged: onSearchChanged,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  fillColor: whiteColor,
                                  suffixIcon: InkWell(
                                    onTap: () {},
                                    child: ImageIcon(
                                      AssetImage(greyCrossImage),
                                      size: 14.sp,
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.search,
                                      size: 20.sp, color: Colors.grey),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: borderColor)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                    borderSide:
                                        const BorderSide(color: borderColor),
                                  ),
                                  counterText: "",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.sp),
                                  hintText: "Apply Coupon",
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: titleColor,
                                    fontFamily: "Franklin Gothic Regular",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 40.sp,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (value) {
                                print(value);
                                if (value is RawKeyDownEvent) {}
                              },
                              child: TextField(
                                textCapitalization: TextCapitalization.words,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: textColor,
                                  fontFamily: "Franklin Gothic Regular",
                                ),
                                controller: controller.couponController,
                                onChanged: onSearchChanged,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  fillColor: whiteColor,
                                  suffixIcon: InkWell(
                                    onTap: () {},
                                    child: ImageIcon(
                                      AssetImage(greyCrossImage),
                                      size: 14.sp,
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.search,
                                      size: 20.sp, color: Colors.grey),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: borderColor)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                    borderSide:
                                        const BorderSide(color: borderColor),
                                  ),
                                  counterText: "",
                                  /*   contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.sp), */
                                  hintText: "Apply Coupon",
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: titleColor,
                                    fontFamily: "Franklin Gothic Regular",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  */
                  Padding(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
