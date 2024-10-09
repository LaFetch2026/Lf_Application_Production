import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyVerticalList extends StatelessWidget {
  const DummyVerticalList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.sp,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 60.sp),
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ScrollPhysics(),
              itemCount: 5,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        DummyContainer(
                            height: MediaQuery.of(context).size.width + 40,
                            width: double.infinity),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.sp, vertical: 10.sp),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: DummyContainer(height: 30, width: 30),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20.sp,
                          bottom: 20.sp,
                          child: DummyContainer(height: 26, width: 80),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 5.sp),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
                        child: DummyContainer(height: 10, width: 50)),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.sp, left: 10.sp, right: 1.sp),
                      child: Row(
                        children: [
                          DummyContainer(height: 10, width: 50),
                          Padding(
                            padding: EdgeInsets.only(left: 5.sp),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5.sp, left: 10.sp, right: 10.sp, bottom: 30.sp),
                      child: Row(
                        children: [
                          DummyContainer(height: 14, width: 14),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.sp),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
            //  ),
          ),
        ],
      ),
    );
  }
}
