import 'package:flutter/material.dart';
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
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: DummyContainer(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                  )),
              Positioned(
                bottom: 30,
                right: 16,
                child: DummyContainer(
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: DummyContainer(
            width: 50,
            height: 10,
          ),
        ),
        const Padding(
            padding:
                EdgeInsets.only(top: 12.0, bottom: 5.0, left: 12, right: 12),
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
                  padding: EdgeInsets.only(left: 10),
                  child: DummyContainer(
                    width: 50,
                    height: 10,
                  ),
                )
              ],
            )),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: DummyContainer(
            width: 50,
            height: 10,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const DummyContainer(
                width: 50,
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                child: const Padding(
                  padding:
                      EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 8),
                  child: DummyContainer(
                    width: 50,
                    height: 10,
                  ),
                ),
              )
            ],
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(
                    top: 30.0, bottom: 0.0, left: 12, right: 12),
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
