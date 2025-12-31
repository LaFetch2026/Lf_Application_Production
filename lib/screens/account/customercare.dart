// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constant/constants.dart';

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({
    super.key,
  });

  @override
  State<CustomerCareScreen> createState() => CustomerCareScreenState();
}

class CustomerCareScreenState extends State<CustomerCareScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tawk.to/chat/66f8fcc1e5982d6c7bb6389e/1i8u9ml4f'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: controller),
          )
        ],
      ),
    );
  }
}
