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
          padding: const EdgeInsets.only(top: 30, left: 16),
          child: AppText(
            text: "Most Searched",
            fontFamily: "Franklin Gothic Regular",
            fontWeight: FontWeight.w400,
            color: bottomnavBack,
            fontSize: 16.sp,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            childAspectRatio: 0.7,
            physics: const ScrollPhysics(),
            crossAxisSpacing: 5,
            mainAxisSpacing: 1,
            children: List.generate(
              8,
              (index) {
                return const Column(
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
