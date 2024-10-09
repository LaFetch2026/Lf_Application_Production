// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../screens/bottomnavscreen.dart';
import '../../utils/constants.dart';
import '../common_widgets.dart';
import '../smallbtn.dart';

class BottomWishlist extends StatefulWidget {
  final Function(int)? onPressed;
  final GetxController controller;
  final List wishlistList;

  const BottomWishlist({
    Key? key,
    this.onPressed,
    required this.controller,
    required this.wishlistList,
  }) : super(key: key);

  @override
  State<BottomWishlist> createState() => _BottomWishlistState();
}

class _BottomWishlistState extends State<BottomWishlist> {
  String text = "0";
  int id = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 410.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0.sp),
            topRight: Radius.circular(16.0.sp)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 5.sp),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Select Wishlist",
                      style: TextStyle(
                        color: loginText,
                        fontSize: 14.sp,
                        fontFamily: "Franklin Gothic",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Image.asset(blackCrossImage,
                          height: 20.sp, width: 20.sp, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 10.sp),
              child: widget.wishlistList.isNotEmpty
                  ? SizedBox(
                      width: double.infinity,
                      height: 250.sp,
                      child: ListView.builder(
                          physics: const ScrollPhysics(),
                          itemCount: widget.wishlistList.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (ctx, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    text = widget.wishlistList[index]["name"];
                                    id = widget.wishlistList[index]["id"];
                                    print(text);
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: whiteColor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        index == 0
                                            ? const Divider(
                                                color: colorSecondary,
                                              )
                                            : const SizedBox(
                                                height: 0,
                                              ),
                                        Container(
                                          width: double.infinity,
                                          color: id ==
                                                  widget.wishlistList[index]
                                                      ["id"]
                                              ? blackColor
                                              : whiteColor,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.sp,
                                                horizontal: 10.sp),
                                            child: Text(
                                              widget.wishlistList[index]
                                                  ["name"],
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: id ==
                                                        widget.wishlistList[
                                                            index]["id"]
                                                    ? whiteColor
                                                    : nameText,
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Divider(
                                          color: colorSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                      /* const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: Text("No Wishlist Found",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: "Franklin Gothic Regular")),
                          ),
                        ) */
                      )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 150.sp),
                        child: SmallButton(
                            width: 160.sp,
                            label: "Create Wishlist",
                            textColor: whiteBorderColor,
                            backgroundColor: colorPrimary,
                            onPressed: () {
                              Get.offAll(
                                () => const BottomNavScreen(
                                  index: 2,
                                ),
                              );
                            },
                            borderColor: colorPrimary),
                      ),
                    ),
            ),
            widget.wishlistList.isNotEmpty
                ? Obx(() => Padding(
                      padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
                      child: getSingleButton(
                          label: "Done",
                          textColor: whiteBorderColor,
                          backgroundColor: colorPrimary,
                          controller: widget.controller,
                          onPressed: () {
                            if (id != 0) {
                              widget.onPressed?.call(id);
                            } else {
                              getSnackBar("Select Wishlist");
                            }
                          },
                          borderColor: colorPrimary),
                    ))
                : const SizedBox(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
