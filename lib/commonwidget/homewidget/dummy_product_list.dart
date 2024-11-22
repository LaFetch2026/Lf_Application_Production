import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/constants.dart';
import '../app_text.dart';

class DummyProductList extends StatelessWidget {
  final String text;

  const DummyProductList({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.sp, left: 16.sp),
          child: AppText(
            text: text,
            fontFamily: "Franklin Gothic",
            color: textColor,
            fontSize: 16,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 10.sp, left: 16.sp, right: 16.sp),
            child: SizedBox(
              height: 250.sp,
              width: double.infinity,
              child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: [
                        Container(
                          width: 122.sp,
                          height: 250.sp,
                          margin: EdgeInsets.only(right: 5.sp),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150.sp,
                                width: 122.sp,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.sp, vertical: 5.sp),
                                child: Container(
                                  height: 10.sp,
                                  width: 102.sp,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.04),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.sp, left: 10.sp, right: 1.sp),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 10.sp,
                                      width: 50.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.sp),
                                      child: Container(
                                        height: 10.sp,
                                        width: 50.sp,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                        ),
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
                                    Container(
                                      height: 14.sp,
                                      width: 14.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.sp),
                                      child: Container(
                                        height: 10.sp,
                                        width: 50.sp,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
            )),
      ],
    );
  }
}
