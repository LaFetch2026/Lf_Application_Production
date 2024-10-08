import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

import '../../utils/constants.dart';
import '../app_text.dart';

class DummyGridMostSearch extends StatelessWidget {
  const DummyGridMostSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 30.sp, left: 16.sp),
          child: AppText(
            text: "Most Searched",
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: bottomnavBack,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 16.sp, right: 16.sp, top: 20.sp, bottom: 10.sp),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            childAspectRatio: 0.7,
            physics: const ScrollPhysics(),
            crossAxisSpacing: 5.sp,
            mainAxisSpacing: 1.sp,
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
                            height: 72,
                            width: 80,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sp, vertical: 5.sp),
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
