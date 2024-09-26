import 'package:flutter/material.dart';
import 'package:lafetch/commonwidget/dummy_container.dart';

class DummyAccount extends StatelessWidget {
  const DummyAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DummyContainer(height: 20, width: 100),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        DummyContainer(height: 15, width: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: DummyContainer(height: 14, width: 100),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Expanded(
                child: SizedBox(
                  height: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DummyContainer(height: 14, width: 50),
              ),
            ],
          ),
          /*  const SizedBox(
            height: 12,
          ),
          DummyContainer(height: 50, width: double.infinity),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 20),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    width: 0,
                  ),
                ),
                Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                  ),
                ),
              ],
            ),
          ),
          */
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: DummyContainer(
              height: 20,
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: DummyContainer(
              height: 20,
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: DummyContainer(
              height: 14,
              width: 100,
            ),
          ),
        ],
      ),
    );
  }
}
