import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/constants.dart';
import '../text/app_text.dart';

class DummyProductBrand extends StatelessWidget {
  final String text;

  const DummyProductBrand({
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
            fontFamily: "Clash Display",
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
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Container(
                                  height: 10,
                                  width: 102,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
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
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Container(
                                        height: 10,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
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
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Container(
                                        height: 10,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
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
