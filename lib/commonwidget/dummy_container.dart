import 'package:flutter/material.dart';

class DummyContainer extends StatelessWidget {
  final double width;
  final double height;
  const DummyContainer({
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
      ),
    );
  }
}
