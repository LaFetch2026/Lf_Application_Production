import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'dummy_container.dart';
//import 'package:lafetch/utils/constants.dart';

class DummyProductDetails extends StatelessWidget {
  const DummyProductDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.0.sp, top: 12.sp),
          child: DummyContainer(
            width: 50,
            height: 20,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(
                top: 12.0.sp, bottom: 5.0.sp, left: 12.sp, right: 12.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: DummyContainer(
                    width: 50,
                    height: 20,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.sp),
                  child: DummyContainer(
                    width: 50,
                    height: 20,
                  ),
                )
              ],
            )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 2.sp),
          child: DummyContainer(
            width: 50,
            height: 20,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0.sp, left: 12.sp, right: 12.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const DummyContainer(
                width: 50,
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0.sp),
                child: DummyContainer(
                  width: 50,
                  height: 20,
                ),
              ),
              /*  Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 6.sp, bottom: 6.sp, left: 8.sp, right: 8.sp),
                  child: DummyContainer(
                    width: 50,
                    height: 20,
                  ),
                ),
              ) */
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(
                    top: 30.0.sp, bottom: 5.0.sp, left: 12.sp, right: 12.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DummyContainer(
                      width: 50,
                      height: 20,
                    ),
                    DummyContainer(
                      width: 50,
                      height: 20,
                    ),
                  ],
                )),
            Padding(
              padding: EdgeInsets.only(top: 12.0.sp, left: 12.sp, right: 12.sp),
              child: DummyContainer(height: 40.sp, width: 40.sp),
            ),
            /*   Padding(
              padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 12.sp),
              child: DummyContainer(
                height: 2.sp,
                width: MediaQuery.of(context).size.width,
              ),
            ),
               Padding(
              padding: EdgeInsets.only(top: 12.0.sp, left: 12.sp, right: 12.sp),
              child: DummyContainer(height: 40.sp, width: 50.sp),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 20.sp),
              child: DummyContainer(
                width: 200.sp,
                height: 20.sp,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 20.sp),
              child: DummyContainer(
                width: 50,
                height: 50.sp,
              ),
            ), */
          ],
        ),
      ],
    );
  }
}
