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
          padding: const EdgeInsets.only(top: 10, left: 16),
          child: AppText(
            text: text,
            fontFamily: "Franklin Gothic",
            color: textColor,
            fontSize: 16.sp,
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: SizedBox(
              height: 250,
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
                          width: 122,
                          height: 250,
                          margin: const EdgeInsets.only(right: 5),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150,
                                width: 122,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Container(
                                  height: 10,
                                  width: 102,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.04),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 1),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Container(
                                        height: 10,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 14,
                                      width: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Container(
                                        height: 10,
                                        width: 50,
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
