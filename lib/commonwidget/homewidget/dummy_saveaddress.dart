import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummySaveAddress extends StatelessWidget {
  final int size;
  const DummySaveAddress({Key? key, this.size = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.sp, bottom: 5.sp),
      child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: size,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Container(
              color: whiteColor,
              margin: EdgeInsets.only(bottom: 10.sp),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10.sp,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.sp, vertical: 5.sp),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.sp,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: 5.sp),
                            width: 80.sp,
                            height: 20.sp,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.sp, vertical: 2.sp),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.sp, vertical: 2.sp),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.sp, vertical: 2.sp),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.sp, vertical: 2.sp),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
