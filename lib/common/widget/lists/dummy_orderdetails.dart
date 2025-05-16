import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../core/constant/constants.dart';
import 'dummy_container.dart';

class DummyOrderDetails extends StatelessWidget {
  const DummyOrderDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
            child: DummyContainer(
              height: 10,
              width: 50,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.sp),
            child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: 1,
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
                                ]),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp),
            child: Container(
              color: whiteColor,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 16.sp, right: 16.sp, top: 20.sp, bottom: 20.sp),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 10, width: 60),
                    ),
                    DummyContainer(height: 10, width: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
