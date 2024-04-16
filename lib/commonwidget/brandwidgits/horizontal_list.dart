import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/product_controller.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class HorizontalBrandList extends StatelessWidget {
  final String text;
  final Function(int)? onPressed;
  final ProductController productController;
  final Function? onPressedExpress;
  final Function? onPressedHeart;

  const HorizontalBrandList({
    Key? key,
    required this.text,
    this.onPressed,
    this.onPressedHeart,
    this.onPressedExpress,
    required this.productController,
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
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: productController.productList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onPressed?.call(
                              productController.productList[index]["id"]);
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
                                    Image.asset(backImage,
                                        height: 150,
                                        width: 122,
                                        fit: BoxFit.cover),
                                    GestureDetector(
                                      onTap: () {
                                        onPressedHeart!.call();
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
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: AppText(
                                    text:
                                        "${productController.productList[index]["name"]}\n",
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
                                        text:
                                            "\u{20B9} ${productController.productList[index]["price"] ?? ""}",
                                        color: deepGreytextColor,
                                        maxLines: 2,
                                        fontSize: 11.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "\u{20B9} ${productController.productList[index]["mrp"]}",
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
                                      top: 10, left: 10, right: 10, bottom: 5),
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
      ],
    );
  }
}
