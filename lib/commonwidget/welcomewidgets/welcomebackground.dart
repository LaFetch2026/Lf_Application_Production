import 'package:flutter/material.dart';
import 'package:lafetch/utils/constants.dart';

class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 520,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(backImage), fit: BoxFit.cover),
          ),
        ),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Image.asset(appNameImage, height: 46, fit: BoxFit.cover),
        )),
      ],
    );
  }
}
