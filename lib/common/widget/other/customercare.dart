// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
// import 'package:flutter_tawk/flutter_tawk.dart';

import '../../../core/constant/constants.dart';

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({
    super.key,
  });

  @override
  State<CustomerCareScreen> createState() => CustomerCareScreenState();
}

class CustomerCareScreenState extends State<CustomerCareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          // Expanded(
          //   child: Tawk(
          //     directChatLink:
          //     'https://tawk.to/chat/66f8fcc1e5982d6c7bb6389e/1i8u9ml4f',
          //     visitor: TawkVisitor(
          //       name: 'Lafetch',
          //       email: 'ashish@thecodework.com',
          //     ),
          //     onLoad: () {
          //       print('Hello!');
          //     },
          //     onLinkTap: (String url) {
          //       print(url);
          //     },
          //     placeholder: Container(
          //       color: whiteColor,
          //       child: Center(
          //         child: Text(
          //           'Loading...',
          //           style: TextStyle(color: colorPrimary),
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
