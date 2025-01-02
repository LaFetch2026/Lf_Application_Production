// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummyHomeBrand extends StatelessWidget {
  const DummyHomeBrand({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.sp, left: 16.sp),
            child: DummyContainer(
              width: 150,
              height: 20,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.sp, left: 16.sp, right: 16.sp),
            child: SizedBox(
              height: 100.sp,
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.sp),
                      child: Container(
                        height: 80.sp,
                        width: 80.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.04),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
