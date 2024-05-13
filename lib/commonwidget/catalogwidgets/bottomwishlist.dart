// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../common_widgets.dart';

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
      height: 410,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                          height: 12, width: 12, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: widget.wishlistList.isNotEmpty
                      ? ListView.builder(
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
                                          color: text ==
                                                  widget.wishlistList[index]
                                                      ["name"]
                                              ? blackColor
                                              : whiteColor,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            child: Text(
                                              widget.wishlistList[index]
                                                  ["name"],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: text ==
                                                        widget.wishlistList[
                                                            index]["name"]
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
                      : const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: Text("No Wishlist Found",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: "Franklin Gothic Regular")),
                          ),
                        )),
            ),
            widget.wishlistList.isNotEmpty
                ? Obx(() => Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
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
