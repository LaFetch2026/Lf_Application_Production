import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'dummy_container.dart';


class DummyWishlistList extends StatelessWidget {
  const DummyWishlistList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
      child: AnimationLimiter(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
          childAspectRatio: 0.7,
          physics: const ScrollPhysics(),
          crossAxisSpacing: 5,
          mainAxisSpacing: 0,
          children: List.generate(
            6,
                (index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0.sp),
                            child: Container(
                              height: (MediaQuery.of(context).size.width / 2) -
                                  24.sp,
                              width: (MediaQuery.of(context).size.width / 2) -
                                  24.sp,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.sp, vertical: 5.sp),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
