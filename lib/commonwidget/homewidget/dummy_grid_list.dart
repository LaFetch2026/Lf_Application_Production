import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyGridList extends StatelessWidget {
  final int size;
  const DummyGridList({
    Key? key,
    this.size = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16.sp, right: 16.sp, top: 10.sp, bottom: 90.sp),
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
              return Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: DummyContainer(
                              height: 190,
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 24,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 22.sp, vertical: 10.sp),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                child: DummyContainer(
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 22.sp, vertical: 10.sp),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: DummyContainer(
                                height: 26,
                                width: 80,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 5.sp),
                        child: DummyContainer(
                          height: 10,
                          width: 50,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
                        child: DummyContainer(
                          height: 10,
                          width: 50,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.sp, left: 10.sp, right: 1.sp),
                        child: Row(
                          children: [
                            DummyContainer(
                              height: 10,
                              width: 50,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5.sp),
                              child: DummyContainer(
                                height: 10,
                                width: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.sp, left: 10.sp, right: 10.sp),
                        child: Row(
                          children: [
                            DummyContainer(
                              height: 14,
                              width: 14,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: DummyContainer(
                                height: 10,
                                width: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
