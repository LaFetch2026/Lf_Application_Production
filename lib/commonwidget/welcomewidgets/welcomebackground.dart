import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          height: MediaQuery.of(context).size.height - 250,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(backImage), fit: BoxFit.cover),
          ),
        ),
        Center(
            child: Padding(
          padding: EdgeInsets.only(top: 40.sp),
          child: Image.asset(appNameImage, height: 46.sp, fit: BoxFit.cover),
        )),
      ],
    );
  }
}
