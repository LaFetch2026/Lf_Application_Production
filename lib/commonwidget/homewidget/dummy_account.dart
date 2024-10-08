import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyAccount extends StatelessWidget {
  const DummyAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 40.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DummyContainer(height: 20, width: 100),
                  Padding(
                    padding: EdgeInsets.only(top: 5.sp),
                    child: Row(
                      children: [
                        DummyContainer(height: 15, width: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.sp),
                          child: DummyContainer(height: 14, width: 100),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16.sp),
                child: DummyContainer(height: 14, width: 50),
              ),
            ],
          ),
          /*  const SizedBox(
            height: 12,
          ),
          DummyContainer(height: 50, width: double.infinity),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 20),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    width: 0,
                  ),
                ),
                Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                  ),
                ),
              ],
            ),
          ),
          */
          Padding(
            padding: EdgeInsets.only(top: 30.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 20,
              width: 100,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 20,
              width: 100,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
        ],
      ),
    );
  }
}
