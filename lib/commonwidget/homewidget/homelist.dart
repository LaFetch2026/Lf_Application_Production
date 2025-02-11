import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/homewidget/home_product_list.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class HomeList extends StatelessWidget {
  final List list;
  final Function(int)? onPressed;

  const HomeList({
    Key? key,
    this.onPressed,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350 * list.length.sp,
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Visibility(
              visible: list[index]["products"].isNotEmpty ? true : false,
              child: Container(
                color: index % 2 == 0 ? homeAppBarColor : Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 24.sp, left: 16.sp, right: 16.sp),
                      child: AppText(
                        text: list[index]["title"].toUpperCase() ?? "",
                        fontFamily: "Franklin Gothic Semibold",
                        color: index % 2 == 0 ? whiteColor : blackColor,
                        fontSize: 20,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 4.sp, left: 16.sp, right: 16.sp),
                      child: AppText(
                        text: list[index]["sub_title"] ?? "",
                        fontFamily: "Franklin Gothic Regular",
                        color: index % 2 == 0
                            ? productSubtitleColor
                            : subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                    HomeProductList(
                      list: list[index]["products"],
                      onPressed: (p0) {
                        onPressed?.call(p0);
                      },
                      parentIndex: index,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
