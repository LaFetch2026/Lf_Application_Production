// ignore_for_file: avoid_print, deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/constants.dart';
import '../../../screens/wishlistscreen.dart';
import '../button/doublebutton_new.dart';
import '../button/smallbtn.dart';
import '../text/app_text.dart';

class BottomWishlist extends StatefulWidget {
  final Function(int)? onPressed;
  final Function? onPressedBoard;
  final GetxController controller;
  final List wishlistList;
  final String productImage;

  const BottomWishlist({
    Key? key,
    this.onPressed,
    required this.controller,
    this.onPressedBoard,
    required this.wishlistList,
    this.productImage = "",
  }) : super(key: key);

  @override
  State<BottomWishlist> createState() => _BottomWishlistState();
}

class _BottomWishlistState extends State<BottomWishlist> {
  String text = "0";
  String error = "";
  int id = 0;
  List<bool> wishlistSelected = List.generate(50, (i) => false);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: whiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 16.sp, top: 16.sp, right: 16.sp),
                  child: Row(
                    children: [
                      widget.productImage.isNotEmpty
                          ? SizedBox(
                              height: 85.sp,
                              width: 68.sp,
                              child: CachedNetworkImage(
                                cacheManager: CacheManager(Config(
                                    "customCacheKey",
                                    stalePeriod: const Duration(days: 15),
                                    maxNrOfCacheObjects: 100)),
                                fit: BoxFit.cover,
                                imageUrl: widget.productImage,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  downloadImage,
                                  height: 85.sp,
                                  width: 68.sp,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Image.asset(dummyWishlistImage,
                              height: 85.sp, width: 68.sp, fit: BoxFit.cover),
                      Padding(
                        padding: EdgeInsets.only(left: 12.sp),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 24.sp),
                              child: Text(
                                "SAVED",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: blackColor,
                                  fontFamily: "Franklin Gothic Semibold",
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 4.sp, bottom: 24.sp),
                              child: Text(
                                "All ITEMS".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: subtitleColor,
                                  fontFamily: "Franklin Gothic Regular",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 0,
                        ),
                      ),
                      SvgPicture.asset(redHeartSvgImage,
                          color: redColor,
                          height: 18.sp,
                          width: 18.sp,
                          fit: BoxFit.cover)
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 16.sp, top: 30.sp, right: 16.sp),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "SELECT BOARDS",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 12.sp,
                            fontFamily: "Franklin Gothic Semibold",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onPressedBoard?.call();
                        },
                        child: Container(
                          color: Color(0xffDFC5FE),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.sp, vertical: 10.sp),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: blackColor,
                                  size: 10.sp,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5.sp),
                                  child: AppText(
                                    text: "New Board".toUpperCase(),
                                    color: homeAppBarColor,
                                    fontSize: 10,
                                    fontFamily: "Franklin Gothic",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                  child: widget.wishlistList.isNotEmpty
                      ? Container(
                          //  color: blue,
                          width: double.infinity,
                          height: 240.sp,
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
                                        wishlistSelected.clear();
                                        wishlistSelected =
                                            List.generate(50, (i) => false);
                                        wishlistSelected[index] =
                                            !wishlistSelected[index];
                                        text =
                                            widget.wishlistList[index]["name"];
                                        id = widget.wishlistList[index]["id"];

                                        setState(() {});
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        color: whiteColor,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              color: whiteColor,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 10.sp,
                                                ),
                                                child: Row(
                                                  children: [
                                                    widget
                                                            .wishlistList[index]
                                                                ["images"]
                                                            .isNotEmpty
                                                        ? SizedBox(
                                                            height: 64.sp,
                                                            width: 64.sp,
                                                            child:
                                                                CachedNetworkImage(
                                                              cacheManager: CacheManager(Config(
                                                                  "customCacheKey",
                                                                  stalePeriod:
                                                                      const Duration(
                                                                          days:
                                                                              15),
                                                                  maxNrOfCacheObjects:
                                                                      100)),
                                                              fit: BoxFit.cover,
                                                              imageUrl: widget
                                                                          .wishlistList[
                                                                      index]
                                                                  ["images"][0],
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                downloadImage,
                                                                height: 64.sp,
                                                                width: 64.sp,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          )
                                                        : Image.asset(
                                                            dummyWishlistImage,
                                                            height: 64.sp,
                                                            width: 64.sp,
                                                            fit: BoxFit.cover),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12.sp),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 15.sp),
                                                            child: Text(
                                                              widget
                                                                  .wishlistList[
                                                                      index]
                                                                      ["name"]
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                color:
                                                                    blackColor,
                                                                fontFamily:
                                                                    "Franklin Gothic Semibold",
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 2.sp,
                                                                    bottom:
                                                                        15.sp),
                                                            child: Text(
                                                              "${widget.wishlistList[index]["products_count"].toString()} ITEMS"
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                fontSize: 10.sp,
                                                                color:
                                                                    subtitleColor,
                                                                fontFamily:
                                                                    "Franklin Gothic Regular",
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 0,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15.sp),
                                                      child: Material(
                                                        color: whiteColor,
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: whiteColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0),
                                                              border: Border(
                                                                top: BorderSide(
                                                                    width:
                                                                        2.0.sp,
                                                                    color: wishlistSelected[
                                                                            index]
                                                                        ? titleColor
                                                                        : searchTextColor),
                                                                left: BorderSide(
                                                                    width:
                                                                        2.0.sp,
                                                                    color: wishlistSelected[
                                                                            index]
                                                                        ? titleColor
                                                                        : searchTextColor),
                                                                right: BorderSide(
                                                                    width:
                                                                        2.0.sp,
                                                                    color: wishlistSelected[
                                                                            index]
                                                                        ? titleColor
                                                                        : searchTextColor),
                                                                bottom: BorderSide(
                                                                    width:
                                                                        2.0.sp,
                                                                    color: wishlistSelected[
                                                                            index]
                                                                        ? titleColor
                                                                        : searchTextColor),
                                                              ),
                                                            ),
                                                            width: 20,
                                                            height: 20,
                                                            child: Checkbox(
                                                              value:
                                                                  wishlistSelected[
                                                                      index],
                                                              checkColor:
                                                                  wishlistSelected[
                                                                          index]
                                                                      ? whiteColor
                                                                      : titleColor,
                                                              activeColor:
                                                                  wishlistSelected[
                                                                          index]
                                                                      ? titleColor
                                                                      : whiteColor,
                                                              side: BorderSide(
                                                                  color: wishlistSelected[
                                                                          index]
                                                                      ? whiteColor
                                                                      : titleColor,
                                                                  width: 0),
                                                              onChanged:
                                                                  (value) {
                                                                wishlistSelected
                                                                    .clear();
                                                                wishlistSelected =
                                                                    List.generate(
                                                                        50,
                                                                        (i) =>
                                                                            false);
                                                                wishlistSelected[
                                                                        index] =
                                                                    !wishlistSelected[
                                                                        index];
                                                                text = widget
                                                                        .wishlistList[
                                                                    index]["name"];
                                                                id = widget
                                                                        .wishlistList[
                                                                    index]["id"];
                                                                error = "";
                                                                setState(() {});
                                                              },
                                                            )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                  Get.to(
                                    () => const WishlistScreen(),
                                  );
                                },
                                borderColor: colorPrimary),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: error != "" ? true : false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.sp,
                right: 20.sp,
                top: 2.sp,
              ),
              child: AppText(
                text: error,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: redColor,
                fontSize: 12,
              ),
            ),
          ),
          widget.wishlistList.isNotEmpty
              ? DoubleButtonNew(
                  firstText: "CLOSE",
                  secondText: "SAVE",
                  lineColor: dividerColor,
                  controller: widget.controller,
                  onPressedFirst: () {
                    Get.back();
                  },
                  onPressedSecond: () {
                    if (id != 0) {
                      widget.onPressed?.call(id);
                    } else {
                      // getSnackBar("Select Wishlist");
                      error = "Select Wishlist";
                      setState(() {});
                    }
                  },
                )
              : const SizedBox(
                  height: 0,
                ),
        ],
      ),
    );
  }
}
