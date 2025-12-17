import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';
import 'dummy_container.dart';

class DummyGridMostSearch extends StatelessWidget {
  final String text;
  const DummyGridMostSearch({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.sp, left: 16.sp),
          child: AppText(
            text: text.toUpperCase(),
            fontFamily: "Clash Display Semibold",
            fontWeight: FontWeight.w400,
            color: blackColor,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 16.sp, right: 16.sp, top: 12.sp, bottom: 10.sp),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            childAspectRatio: 0.6,
            physics: const ScrollPhysics(),
            crossAxisSpacing: 7.sp,
            mainAxisSpacing: 0.sp,
            children: List.generate(
              8,
              (index) {
                return Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: DummyContainer(
                            width: 104,
                            height: 130,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.sp, vertical: 6.sp),
                          child: InkWell(
                            child: DummyContainer(
                              height: 16,
                              width: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
