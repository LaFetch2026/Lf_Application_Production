import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

import '../../utils/constants.dart';

class DummyOrderAddress extends StatelessWidget {
  const DummyOrderAddress({
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
              DummyContainer(height: 20, width: 100),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: DummyContainer(height: 16, width: 100),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DummyContainer(height: 16, width: 100),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: DummyContainer(height: 16, width: 100),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: DummyContainer(height: 16, width: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
