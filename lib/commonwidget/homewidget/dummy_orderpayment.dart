import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

import '../../utils/constants.dart';

class DummyOrderPayment extends StatelessWidget {
  const DummyOrderPayment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: DummyContainer(height: 16, width: 100),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    DummyContainer(height: 16, width: 100),
                    DummyContainer(height: 16, width: 100),
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    DummyContainer(height: 16, width: 100),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: DummyContainer(height: 16, width: 100),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: DummyContainer(height: 16, width: 100),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
