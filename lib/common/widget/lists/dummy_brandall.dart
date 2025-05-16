import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DummybrandAll extends StatelessWidget {
  const DummybrandAll({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: MasonryGridView.count(
        primary: false,
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 2.sp,
        mainAxisSpacing: 7.sp,
        itemCount: 2,
        itemBuilder: (context, index) {
          double ht = 100;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: ht.sp,
                    width: (MediaQuery.of(context).size.width / 2) - 16.sp,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.sp, vertical: 10.sp),
                        child: Container(
                          height: 10.sp,
                          width: 50.sp,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
