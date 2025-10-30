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
  /// Called with the selected boardId when user taps SAVE
  final Function(int)? onPressed;
  /// “New Board” action
  final Function? onPressedBoard;
  /// Controller only for button loading state
  final GetxController controller;
  /// Boards from new API: [{id, name, productCount}]
  final List wishlistList;
  /// Optional PDP image preview
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
  String error = "";
  int selectedBoardId = 0;
  late List<bool> wishlistSelected;

  @override
  void initState() {
    super.initState();
    wishlistSelected = List<bool>.filled(widget.wishlistList.length, false);
  }

  @override
  void didUpdateWidget(covariant BottomWishlist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wishlistList.length != widget.wishlistList.length) {
      wishlistSelected = List<bool>.filled(widget.wishlistList.length, false);
      selectedBoardId = 0;
      error = "";
    }
  }

  // ---------- helpers ----------

  bool _looksLikeImageUrl(String url) {
    final p = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif');
  }

  /// Try to find a usable board thumbnail if the API ever provides one.
  /// (Current API doesn't, so we fall back to placeholder.)
  String _firstBoardImage(dynamic item) {
    try {
      if (item is! Map) return '';
      // Common guesses:
      final candidates = <String?>[
        item['thumbnail']?.toString(),
        item['coverImage']?.toString(),
        item['image']?.toString(),
      ];

      // If board contains an images list (string or {name: url})
      if (item['images'] is List) {
        for (final it in (item['images'] as List)) {
          if (it is String && it.trim().isNotEmpty) candidates.add(it);
          if (it is Map && it['name'] != null) candidates.add(it['name']?.toString());
        }
      }

      // Return first valid-looking image url
      for (final c in candidates) {
        if (c != null && c.trim().isNotEmpty && _looksLikeImageUrl(c)) {
          return c;
        }
      }
    } catch (_) {}
    return '';
  }

  int _productCount(dynamic item) {
    try {
      if (item is Map && item['productCount'] != null) {
        return int.tryParse(item['productCount'].toString()) ?? 0;
      }
      if (item is Map && item['products_count'] != null) {
        return int.tryParse(item['products_count'].toString()) ?? 0;
      }
      if (item is Map && item['count'] != null) {
        return int.tryParse(item['count'].toString()) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  void _selectIndex(int index) {
    for (int i = 0; i < wishlistSelected.length; i++) {
      wishlistSelected[i] = (i == index) ? !wishlistSelected[i] : false;
    }

    if (wishlistSelected[index]) {
      final item = widget.wishlistList[index] as Map;
      selectedBoardId = (item['id'] is int)
          ? item['id'] as int
          : int.tryParse(item['id']?.toString() ?? '0') ?? 0;
      error = "";
    } else {
      selectedBoardId = 0;
    }
    setState(() {});
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.sp,
      width: double.infinity,
      color: whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with product preview
          Padding(
            padding: EdgeInsets.only(left: 16.sp, top: 16.sp, right: 16.sp),
            child: Row(
              children: [
                // PDP image preview or placeholder
                widget.productImage.isNotEmpty
                    ? SizedBox(
                        height: 85.sp,
                        width: 68.sp,
                        child: CachedNetworkImage(
                          cacheManager: CacheManager(
                            Config(
                              "customCacheKey",
                              stalePeriod: const Duration(days: 15),
                              maxNrOfCacheObjects: 100,
                            ),
                          ),
                          fit: BoxFit.cover,
                          imageUrl: widget.productImage,
                          errorWidget: (_, __, ___) => Image.asset(
                            downloadImage,
                            height: 85.sp,
                            width: 68.sp,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Image.asset(
                        dummyWishlistImage,
                        height: 85.sp,
                        width: 68.sp,
                        fit: BoxFit.cover,
                      ),
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
                        padding: EdgeInsets.only(top: 4.sp, bottom: 24.sp),
                        child: Text(
                          "ALL ITEMS",
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
                const Expanded(child: SizedBox(height: 0)),
                SvgPicture.asset(
                  redHeartSvgImage,
                  color: redColor,
                  height: 18.sp,
                  width: 18.sp,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),

          // Row: SELECT BOARDS + New Board
          Padding(
            padding: EdgeInsets.only(left: 16.sp, top: 30.sp, right: 16.sp),
            child: Row(
              children: [
                Expanded(
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
                  onTap: () => widget.onPressedBoard?.call(),
                  child: Container(
                    color: const Color(0xffDFC5FE),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 10.sp,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: blackColor, size: 10.sp),
                          Padding(
                            padding: EdgeInsets.only(left: 5.sp),
                            child: AppText(
                              text: "NEW BOARD",
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

          // Boards list
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: widget.wishlistList.isNotEmpty
                  ? ListView.builder(
                      physics: const ScrollPhysics(),
                      itemCount: widget.wishlistList.length,
                      itemBuilder: (ctx, index) {
                        final item = widget.wishlistList[index] as Map;
                        final boardName = (item['name'] ?? '').toString();
                        final count = _productCount(item);
                        final firstImageUrl = _firstBoardImage(item);
                        final isSelected = wishlistSelected[index];

                        return GestureDetector(
                          onTap: () => _selectIndex(index),
                          child: Container(
                            color: whiteColor,
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Board thumbnail (fallback to placeholder)
                                  firstImageUrl.isNotEmpty
                                      ? SizedBox(
                                          height: 64.sp,
                                          width: 64.sp,
                                          child: CachedNetworkImage(
                                            cacheManager: CacheManager(
                                              Config(
                                                "customCacheKey",
                                                stalePeriod:
                                                    const Duration(days: 15),
                                                maxNrOfCacheObjects: 100,
                                              ),
                                            ),
                                            fit: BoxFit.cover,
                                            imageUrl: firstImageUrl,
                                            errorWidget: (_, __, ___) =>
                                                Image.asset(
                                              downloadImage,
                                              height: 64.sp,
                                              width: 64.sp,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          dummyWishlistImage,
                                          height: 64.sp,
                                          width: 64.sp,
                                          fit: BoxFit.cover,
                                        ),

                                  // Board name + count
                                  Padding(
                                    padding: EdgeInsets.only(left: 12.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: 15.sp),
                                          child: Text(
                                            boardName.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: blackColor,
                                              fontFamily:
                                                  "Franklin Gothic Semibold",
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 2.sp, bottom: 15.sp),
                                          child: Text(
                                            "$count ${count == 1 ? 'ITEM' : 'ITEMS'}",
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: subtitleColor,
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Spacer(),

                                  // Checkbox (styled)
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.sp),
                                    child: Material(
                                      color: whiteColor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          border: Border(
                                            top: BorderSide(
                                              width: 2.0.sp,
                                              color: isSelected
                                                  ? titleColor
                                                  : searchTextColor,
                                            ),
                                            left: BorderSide(
                                              width: 2.0.sp,
                                              color: isSelected
                                                  ? titleColor
                                                  : searchTextColor,
                                            ),
                                            right: BorderSide(
                                              width: 2.0.sp,
                                              color: isSelected
                                                  ? titleColor
                                                  : searchTextColor,
                                            ),
                                            bottom: BorderSide(
                                              width: 2.0.sp,
                                              color: isSelected
                                                  ? titleColor
                                                  : searchTextColor,
                                            ),
                                          ),
                                        ),
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: isSelected,
                                          checkColor: isSelected
                                              ? whiteColor
                                              : titleColor,
                                          activeColor: isSelected
                                              ? titleColor
                                              : whiteColor,
                                          side: BorderSide(
                                            color: isSelected
                                                ? whiteColor
                                                : titleColor,
                                            width: 0,
                                          ),
                                          onChanged: (_) => _selectIndex(index),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 150.sp),
                        child: SmallButton(
                          width: 160.sp,
                          label: "Create Board",
                          textColor: whiteBorderColor,
                          backgroundColor: colorPrimary,
                          onPressed: () {
                            Get.to(() => const WishlistScreen());
                          },
                          borderColor: colorPrimary,
                        ),
                      ),
                    ),
            ),
          ),

          // Error (no board selected)
          if (error.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 20.sp, right: 20.sp, top: 2.sp),
              child: AppText(
                text: error,
                fontFamily: "Franklin Gothic Regular",
                fontWeight: FontWeight.w400,
                color: redColor,
                fontSize: 12,
              ),
            ),

          // Bottom buttons
          widget.wishlistList.isNotEmpty
              ? DoubleButtonNew(
                  firstText: "CLOSE",
                  secondText: "SAVE",
                  lineColor: dividerColor,
                  controller: widget.controller,
                  onPressedFirst: () => Get.back(),
                  onPressedSecond: () {
                    if (selectedBoardId == 0) {
                      setState(() => error = "Select Board");
                      return;
                    }
                    // return just the boardId; caller will do addProductToBoard(boardId, productId)
                    widget.onPressed?.call(selectedBoardId);
                    Get.back();
                  },
                )
              : const SizedBox(height: 0),
        ],
      ),
    );
  }
}
