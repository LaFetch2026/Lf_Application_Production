import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants.dart';

class BottomFilters extends StatefulWidget {
  final Function? onPressedEdit;

  const BottomFilters({
    Key? key,
    this.onPressedEdit,
  }) : super(key: key);

  @override
  State<BottomFilters> createState() => BottomFiltersState();
}

class BottomFiltersState extends State<BottomFilters> {
  String? text1;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: whiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                Text(
                  "Filters",
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 14.sp,
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    width: 0,
                  ),
                ),
                Text(
                  "Clear All",
                  style: TextStyle(
                    color: greyTextColor,
                    fontSize: 12.sp,
                    fontFamily: "Franklin Gothic",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                color: backWhite,
                width: 150,
                height: MediaQuery.of(context).size.height - 160,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Price Range",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Brand",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Size",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Color",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Material",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Style",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Occasion",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          "Feature",
                          style: TextStyle(
                            color: bottomnavBack,
                            fontSize: 14.sp,
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ]),
              ),
              Container(
                color: whiteBorderColor,
                width: MediaQuery.of(context).size.width - 150,
                height: MediaQuery.of(context).size.height - 160,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select All",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                            fontFamily: "Franklin Gothic",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
