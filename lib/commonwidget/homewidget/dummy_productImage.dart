// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyProductImage extends StatelessWidget {
  const DummyProductImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 2.sp),
          child: Align(
              alignment: Alignment.center, child: CircularProgressIndicator()),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          left: 16.sp, right: 16.sp, top: 10.sp),
                      child: DummyContainer(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.7,
                      )),
                  Positioned(
                    bottom: 20.sp,
                    right: 30.sp,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.sp))),
                      width: 50.sp,
                      height: 30.sp,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 12.sp,
            ),
          ],
        ),
      ],
    );
  }
}
