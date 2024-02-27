import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../singlebtn.dart';

class ProfilePicWidgets extends StatelessWidget {
  final Function? onPressedNotification;

  const ProfilePicWidgets({
    Key? key,
    this.onPressedNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: Image.asset(profileImage,
                  height: 100, width: 100, fit: BoxFit.cover)),
        ),
        /* Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                "https://i.imgur.com/BoN9kdC.png")))),
              ),
            ), */
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleButton(
              label: "Login / Sign up",
              textColor: btnTextColor,
              onPressed: () {},
              backgroundColor: whiteTextColor,
              borderColor: btnTextColor),
        ),
      ],
    );
  }
}
