import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class HorizontalBrandList extends StatelessWidget {
  final String text;
  final Function(int)? onPressed;
  final List list;
  final ScrollController controller;
  final Function? onPressedExpress;
  final Function(int, int)? onPressedHeart;

  const HorizontalBrandList({
    Key? key,
    required this.text,
    this.onPressed,
    this.onPressedHeart,
    this.onPressedExpress,
    required this.controller,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 16),
          child: AppText(
            text: text,
            fontFamily: "Franklin Gothic",
            fontWeight: FontWeight.w500,
            color: whiteBorderColor,
            fontSize: 16.sp,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            height: 250,
            child: PrimaryScrollController(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            onPressed?.call(list[index]["id"]);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 5),
                            width: 122,
                            height: 250,
                            child: Container(
                              color: whiteBorderColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      list[index]["images"].isNotEmpty &&
                                              list[index]["images"] != null
                                          ? SizedBox(
                                              height: 150,
                                              width: 122,
                                              child: CachedNetworkImage(
                                                cacheManager: CacheManager(
                                                    Config("customCacheKey",
                                                        stalePeriod:
                                                            const Duration(
                                                                days: 15),
                                                        maxNrOfCacheObjects:
                                                            100)),
                                                fit: BoxFit.cover,
                                                imageUrl: list[index]["images"]
                                                    [0]["name"],
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  dummyWishlistImage,
                                                  fit: BoxFit.cover,
                                                  height: 150,
                                                  width: 122,
                                                ),
                                              ),
                                            )
                                          : Image.asset(dummyWishlistImage,
                                              height: 150,
                                              width: 122,
                                              fit: BoxFit.cover),
                                      GestureDetector(
                                        onTap: () {
                                          onPressedHeart?.call(
                                              list[index]["id"], index);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 10),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircleAvatar(
                                                  backgroundColor: whiteColor,
                                                  child: list[index]
                                                          ["wishlisted"]
                                                      ? Image.asset(
                                                          wishlistSelectImage,
                                                          height: 16,
                                                          width: 16,
                                                        )
                                                      : Image.asset(
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
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: AppText(
                                      text: "${list[index]["name"]}\n",
                                      color: nameText,
                                      maxLines: 2,
                                      fontSize: 11.sp,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 1),
                                    child: Row(
                                      children: [
                                        AppText(
                                          text:
                                              "\u{20B9} ${list[index]["price"] ?? ""}",
                                          color: deepGreytextColor,
                                          maxLines: 2,
                                          fontSize: 11.sp,
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                            "\u{20B9} ${list[index]["mrp"]}",
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
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                        bottom: 5),
                                    child: Row(
                                      children: [
                                        const ImageIcon(
                                          AssetImage(truckImage),
                                          color: expressText,
                                          size: 14,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            onPressedExpress!.call();
                                          },
                                          child: Padding(
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
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
