import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummyProductDetails extends StatelessWidget {
  const DummyProductDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.sp),
                  child: DummyContainer(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                  )),
              Positioned(
                bottom: 30.sp,
                right: 16.sp,
                child: DummyContainer(
                  width: MediaQuery.of(context).size.width,
                  height: 30.sp,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 24.sp,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
          child: DummyContainer(
            width: 50,
            height: 10,
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
                    height: 10,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.sp),
                  child: DummyContainer(
                    width: 50,
                    height: 10,
                  ),
                )
              ],
            )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          child: DummyContainer(
            width: 50,
            height: 10,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.0.sp, left: 12.sp, right: 12.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const DummyContainer(
                width: 50,
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0.sp),
                child: DummyContainer(
                  width: 50,
                  height: 10,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 6.sp, bottom: 6.sp, left: 8.sp, right: 8.sp),
                  child: DummyContainer(
                    width: 50,
                    height: 10,
                  ),
                ),
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(
                    top: 30.0.sp, bottom: 0.0.sp, left: 12.sp, right: 12.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DummyContainer(
                      width: 50,
                      height: 10,
                    ),
                    DummyContainer(
                      width: 50,
                      height: 10,
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }
}
