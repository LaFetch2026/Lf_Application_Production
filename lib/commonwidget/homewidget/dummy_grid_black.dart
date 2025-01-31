import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lafetch/utils/constants.dart';

class DummyGridBlack extends StatelessWidget {
  final int size;
  const DummyGridBlack({
    Key? key,
    this.size = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp, right: 16.sp, top: 10.sp, bottom: 50.sp),
        child: AnimationLimiter(
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            childAspectRatio: 0.5,
            physics: const ScrollPhysics(),
            crossAxisSpacing: 5.sp,
            mainAxisSpacing: 0.sp,
            children: List.generate(
              size,
              (index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  height:
                                      (MediaQuery.of(context).size.width / 2) +
                                          10.sp,
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          24.sp,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.sp, vertical: 5.sp),
                            child: Container(
                              height: 10.sp,
                              width: 50.sp,
                              decoration: BoxDecoration(
                                color: cardBg,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Container(
                              height: 10.sp,
                              width: 50.sp,
                              decoration: BoxDecoration(
                                color: cardBg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
