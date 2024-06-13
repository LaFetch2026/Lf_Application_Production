import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';
import 'package:lafetch/utils/constants.dart';

class DummySaveAddress extends StatelessWidget {
  const DummySaveAddress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: 5,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Container(
              color: whiteColor,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            child: DummyContainer(height: 10, width: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 5),
                            width: 80,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: DummyContainer(height: 10, width: 50),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
