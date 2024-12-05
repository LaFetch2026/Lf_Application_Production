import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummyOrderList extends StatelessWidget {
  final int size;
  const DummyOrderList({Key? key, this.size = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.sp),
            child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: size,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.sp),
                    child: Column(
                      children: [
                        Container(
                          color: whiteColor,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.sp),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: DummyContainer(
                                              height: 85,
                                              width: 70,
                                            )),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5.sp, left: 12.sp),
                                                child: DummyContainer(
                                                  height: 10,
                                                  width: 70,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5.sp,
                                                    left: 12.sp,
                                                    top: 5.sp,
                                                    bottom: 5.sp),
                                                child: DummyContainer(
                                                  height: 10,
                                                  width: 70,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5.sp,
                                                    left: 12.sp,
                                                    top: 5.sp,
                                                    bottom: 5.sp),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 10.sp),
                                                      child: DummyContainer(
                                                        height: 10,
                                                        width: 50,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10.sp),
                                                        child: DummyContainer(
                                                          height: 10,
                                                          width: 50,
                                                        ),
                                                      ),
                                                    ),
                                                    DummyContainer(
                                                      height: 10,
                                                      width: 50,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.sp, horizontal: 16.sp),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: EdgeInsets.only(right: 5.sp),
                                      height: 30.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                        borderRadius:
                                            BorderRadius.circular(20.sp),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.sp, vertical: 5.sp),
                                    child: DummyContainer(
                                      height: 10,
                                      width: 50,
                                    ),
                                  ),
                                ]),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
