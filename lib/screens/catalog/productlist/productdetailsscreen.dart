// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/controller/product_controller.dart';
import '../../../commonwidget/app_text.dart';
import '../../../utils/constants.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController controller = PageController();
  final productController = Get.put(ProductController());
  int _curr = 0;
  final List<String> images = [
    'https://s3-alpha-sig.figma.com/img/2f0d/21cc/22d5c0b59802d64433ee57355546f23b?Expires=1710115200&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=irBTQhEp97J~f93ETyTr6PkEV6zJvSvvObu9q0GfUCD1P503BBR-KR0wStaqg7ZsrEhYI0BUprdto~1LDD4JdkXjnvLc-CeoECBUYTcESzoC~I-dfqASDSETa2twg6nYR2D8DCPajI709rF0zgJrmly-ZmlQTOtSz4u05CtjVB4eeky-G6OrJP5~Ku2Qq8zSqC7uD397pK3eSPgGUgC0g2PL4G3cp0gsZapnLHeNCxCVmDYCaQhZB09cxz8z8ukyqLhlwHyBHxHHg5uYyc0X3yQphDGQt2xsynBTY33SpcAtQ5k-Q6f1r2AfFTDjB-1Ju1yqTmvlEPLh0StG7PezIw__',
    'https://s3-alpha-sig.figma.com/img/40fa/03ef/017df2ddaadae8ddc39cc06fb579a5b9?Expires=1710115200&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=dTZI800itjgyI~~ybXeDYqA9K4g4-n-LTAcVrqe8uKgBEAdfbIxq2Sb7eRAIiBAx5tbt9m7WXOWdSK9Wb2EeG3T3qH39m-bFQPlr03-7OynKxDHUMEd8EYCAWOR9Aq-7cszgSBKrp6LPjzOLyasGWdzTDvNgJ9w71C3nlB~GYCE4Z3iHpkUKu-KHRg16-a7bw~fSQmf2IU9vFRcirhfuVtdUdFbKYO1Ve6GMUIwVJcbJUIgJ73Oh2Rlx4f~dvkOmgx~Y4zB1BkTU6C6C0sU~pE7-lSXolMBZSm3S51sa9coUAQ7uiZ88cxTQwheDvGxndv~a6GYnr7HitM6EtmDGXQ__'
  ];

  final List<Map<String, String>> sizes = [
    {'id': '1', 'title': 'XS', 'left': '3'},
    {'id': '2', 'title': 'S', 'left': '6'},
    {'id': '3', 'title': 'M', 'left': '100'},
    {'id': '4', 'title': 'L', 'left': '50'},
    {'id': '5', 'title': 'XL', 'left': '1'},
  ];

  final List<Map<String, String>> reviewsCount = [
    {'id': '1', 'title': '5', 'count': '1121', 'total': '2015'},
    {'id': '2', 'title': '4', 'count': '406', 'total': '2015'},
    {'id': '3', 'title': '3', 'count': '250', 'total': '2015'},
    {'id': '4', 'title': '2', 'count': '87', 'total': '2015'},
    {'id': '5', 'title': '1', 'count': '151', 'total': '2015'},
  ];

  final List<Map<String, String>> customerReviews = [
    {
      'id': '1',
      'rating': '5',
      'name': 'Samantha Payne',
      'comment':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
      'date': '2 years ago',
      'helpfulCount': '21'
    },
    {
      'id': '1',
      'rating': '4',
      'name': 'Payne Samantha',
      'comment':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
      'date': '6 years ago',
      'helpfulCount': '2'
    },
    {
      'id': '1',
      'rating': '1',
      'name': 'Samantha',
      'comment':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
      'date': '1 years ago',
      'helpfulCount': '31'
    },
  ];

  Color getColorForReview(reviewTitle) {
    switch (reviewTitle) {
      case '5':
        return color5StartReview;
      case '4':
        return color4StartReview;
      case '3':
        return color3StartReview;
      case '2':
        return color2StartReview;
      case '1':
        return color1StartReview;
      default:
        return colorPrimary;
    }
  }

  List<String> items = [
    "100",
    "200",
    "300",
    "400",
    "500",
  ];

  List<Widget> getListForPageView() {
    List<Widget> list = [];
    for (var i in images) {
      list.add(Container(
          color: colorSecondary,
          child: Image.network(
              // 'https://s3-alpha-sig.figma.com/img/2f0d/21cc/22d5c0b59802d64433ee57355546f23b?Expires=1710115200&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=irBTQhEp97J~f93ETyTr6PkEV6zJvSvvObu9q0GfUCD1P503BBR-KR0wStaqg7ZsrEhYI0BUprdto~1LDD4JdkXjnvLc-CeoECBUYTcESzoC~I-dfqASDSETa2twg6nYR2D8DCPajI709rF0zgJrmly-ZmlQTOtSz4u05CtjVB4eeky-G6OrJP5~Ku2Qq8zSqC7uD397pK3eSPgGUgC0g2PL4G3cp0gsZapnLHeNCxCVmDYCaQhZB09cxz8z8ukyqLhlwHyBHxHHg5uYyc0X3yQphDGQt2xsynBTY33SpcAtQ5k-Q6f1r2AfFTDjB-1Ju1yqTmvlEPLh0StG7PezIw__',
              i,
              fit: BoxFit.fitHeight)));
    }
    return list;
  }

  SizedBox getListForProductSize() {
    return SizedBox(
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Wrap(
              direction: Axis.horizontal,
              spacing: 12.0,
              runSpacing: 8.0,
              runAlignment: WrapAlignment.spaceEvenly,
              children: [
                for (var i in sizes)
                  Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: colorPrimary, width: 1),
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Align(
                              alignment: Alignment.center,
                              child: AppText(
                                text: i['title'].toString(),
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: colorPrimary,
                                fontSize: 14.sp,
                              ),
                            ),
                          )),
                      int.parse(i['left'].toString()) > 3
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: AppText(
                                text: '${i['left'].toString()} left',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: redColor,
                                fontSize: 11.sp,
                              ),
                            )
                    ],
                  ),
              ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: PageView(
                                    allowImplicitScrolling: true,
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (num) {
                                      setState(() {
                                        _curr = num;
                                      });
                                    },
                                    children: getListForPageView()),
                              )),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.15,
                            // height: 80,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Image.asset(arrowBack),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: CircleAvatar(
                                            backgroundColor: colorPrimary,
                                            child: Image.asset(cartIconWhite)),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: CircleAvatar(
                                            backgroundColor: colorSecondary,
                                            child: Image.asset(shareImage)),
                                        onPressed: () {},
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 30,
                              right: 16,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                height: 30,
                                color: whiteBack,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      starImage,
                                      height: 24,
                                      color: bottomnavBack,
                                      width: 24,
                                    ),
                                    AppText(
                                      text: '4.4',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: colorPrimary,
                                      fontSize: 12.sp,
                                    ),
                                    const VerticalDivider(
                                        color: colorSecondary),
                                    AppText(
                                      text: '8',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                      color: colorPrimary,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22.0, vertical: 18.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                            images.length,
                            (index) => Container(
                                  height: 6,
                                  width: 40,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: (index == _curr)
                                          ? colorPrimary
                                          : colorSecondary),
                                )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 12.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            AppText(
                              text: "New Season",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: greyTextColor,
                              fontSize: 12.sp,
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AppText(
                                      text: 'Kassually',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w600,
                                      color: colorPrimary,
                                      fontSize: 16.sp,
                                    ),
                                    AppText(
                                      text: 'Explore Brand',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w600,
                                      color: colorPrimary,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                )),
                            AppText(
                              text: "Solid shirt style crop top",
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w400,
                              color: greyTextColor,
                              fontSize: 14.sp,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    "\u{20B9} 1800",
                                    style: TextStyle(
                                      color: textHintColor,
                                      fontSize: 16.sp,
                                      decoration: TextDecoration.lineThrough,
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: AppText(
                                      text: "\u{20B9} 699",
                                      color: colorPrimary,
                                      fontSize: 16.sp,
                                      fontFamily: "Franklin Gothic",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: greyBack,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6, bottom: 6, left: 8, right: 8),
                                      child: AppText(
                                        text: "61% OFF",
                                        color: expressText,
                                        fontSize: 12.sp,
                                        fontFamily: "Franklin Gothic",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 30.0, bottom: 0.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AppText(
                                      text: 'Select size',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w500,
                                      color: colorPrimary,
                                      fontSize: 16.sp,
                                    ),
                                    AppText(
                                      text: 'View Size chart',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w600,
                                      color: colorPrimary,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                )),
                            getListForProductSize(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Divider(
                                color: colorSecondary,
                              ),
                            ),
                            AppText(
                              text: 'Delivery options',
                              fontFamily: "Franklin Gothic Regular",
                              fontWeight: FontWeight.w500,
                              color: colorPrimary,
                              fontSize: 16.sp,
                            ),
                            Obx(
                              () => Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: TextField(
                                    controller:
                                        productController.pincodeController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteTextColor,
                                      suffixIcon: TextButton(
                                        onPressed: () {
                                          if (productController
                                              .checkPinvalidation(
                                                  productController
                                                      .pincodeController.text
                                                      .toString()
                                                      .trim())) {
                                            productController.getCheckPincode(
                                                productController
                                                    .pincodeController.text
                                                    .toString()
                                                    .trim());
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 6, bottom: 3),
                                          child: productController
                                                  .isPincode.value
                                              ? const SizedBox(
                                                  height: 10,
                                                  width: 10,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                )
                                              : const AppText(
                                                  text: 'Check',
                                                  fontFamily: "Franklin Gothic",
                                                  fontWeight: FontWeight.w500,
                                                  color: blackColor,
                                                  fontSize: 14,
                                                ),
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: borderColor)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(1),
                                        borderSide: const BorderSide(
                                            color: borderColor),
                                      ),
                                      hintText: 'Enter pincode',
                                      hintStyle: const TextStyle(
                                          fontSize: 14,
                                          color: textHintColor,
                                          fontFamily:
                                              "Franklin Gothic Regular"),
                                    ),
                                    style: const TextStyle(
                                        color: colorPrimary, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 18.0, bottom: 40.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: Image.asset(getItByIcon),
                                      ),
                                      AppText(
                                        text: 'Get it by Fri, 21 Jul',
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
                                        fontSize: 14.sp,
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Image.asset(walletBlack),
                                        ),
                                        AppText(
                                          text: 'Pay on delivery available',
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w500,
                                          color: blackColor,
                                          fontSize: 14.sp,
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Image.asset(exchangeItemImage),
                                        ),
                                        AppText(
                                          text:
                                              'Easy 10 day return & exchange available',
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w500,
                                          color: blackColor,
                                          fontSize: 14.sp,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: colorSecondary,
                            ),
                            ExpansionTile(
                              title: AppText(
                                text: 'Product Description',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w500,
                                color: colorPrimary,
                                fontSize: 16.sp,
                              ),
                              tilePadding: const EdgeInsets.all(0),
                              childrenPadding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              children: [
                                AppText(
                                  text:
                                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
                                  fontFamily: "Franklin Gothic Regular",
                                  maxLines: 7,
                                  fontWeight: FontWeight.w500,
                                  color: colorPrimary,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                            const Divider(
                              color: colorSecondary,
                            ),
                            ExpansionTile(
                              title: AppText(
                                text: 'Composition & Care',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w500,
                                color: colorPrimary,
                                fontSize: 16.sp,
                              ),
                              tilePadding: const EdgeInsets.all(0),
                              childrenPadding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              children: [
                                AppText(
                                  text:
                                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
                                  fontFamily: "Franklin Gothic Regular",
                                  maxLines: 7,
                                  fontWeight: FontWeight.w500,
                                  color: colorPrimary,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                            const Divider(
                              color: colorSecondary,
                            ),
                            ExpansionTile(
                              title: AppText(
                                text: 'Delivery & Returns',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w500,
                                color: colorPrimary,
                                fontSize: 16.sp,
                              ),
                              tilePadding: const EdgeInsets.all(0),
                              childrenPadding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              children: [
                                AppText(
                                  text:
                                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
                                  fontFamily: "Franklin Gothic Regular",
                                  maxLines: 7,
                                  fontWeight: FontWeight.w500,
                                  color: colorPrimary,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                            const Divider(
                              color: colorSecondary,
                            ),
                            ExpansionTile(
                              title: AppText(
                                text: 'About the Brand',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w500,
                                color: colorPrimary,
                                fontSize: 16.sp,
                              ),
                              tilePadding: const EdgeInsets.all(0),
                              childrenPadding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              children: [
                                AppText(
                                  text:
                                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis accumsan nunc nec placerat. Cras vel ante lorem. Sed mattis, arcu non auctor rhoncus, nulla nisi eleifend mauris, sed venenatis quam eros id lacus. Aliquam ac orci id elit viverra ornare placerat at mauris. Etiam eget lectus vitae tellus bibendum accumsan. Maecenas vitae aliquet diam, a vehicula urna. Praesent at mauris eget nunc viverra tempus et porttitor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas quis efficitur lorem. ',
                                  fontFamily: "Franklin Gothic Regular",
                                  maxLines: 7,
                                  fontWeight: FontWeight.w500,
                                  color: colorPrimary,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                            const Divider(
                              color: colorSecondary,
                            ),
                            Align(
                              alignment: Alignment.center,
                              heightFactor: 2.0,
                              child: AppText(
                                text: 'LaFetch ID: 27384720',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w500,
                                color: textHintColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: backWhite,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: AppText(
                        text: 'You will earn 10 LaFetch coins on this purchase',
                        fontFamily: "Franklin Gothic Regular",
                        fontWeight: FontWeight.w500,
                        color: expressText,
                        fontSize: 12.sp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          AppText(
                            text: 'Customer Reviews',
                            fontFamily: "Franklin Gothic Regular",
                            fontWeight: FontWeight.w500,
                            color: colorPrimary,
                            fontSize: 16.sp,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: '${4.5} \u{2605}',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w500,
                                      color: blackColor,
                                      fontSize: 24.sp,
                                    ),
                                    AppText(
                                      text: '2015 verified buyers',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w500,
                                      color: textHintColor,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    ...reviewsCount.map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              AppText(
                                                text:
                                                    '${e['title']} \u{2605}  ',
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: blackColor,
                                                fontSize: 10.sp,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.33,
                                                child: LinearProgressIndicator(
                                                  value: (int.parse(e['count']
                                                          .toString()) /
                                                      int.parse(e['total']
                                                          .toString())),
                                                  backgroundColor:
                                                      colorSecondary,
                                                  color: getColorForReview(
                                                      e['title']),
                                                ),
                                              ),
                                              AppText(
                                                text: '  ${e['count']}',
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: blackColor,
                                                fontSize: 10.sp,
                                              ),
                                            ],
                                          ),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                physics: const BouncingScrollPhysics(),
                                itemCount: customerReviews.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (ctx, index) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: color5StartReview,
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              ' ${customerReviews[index]['rating']} \u{2605} ',
                                              style: TextStyle(
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w500,
                                                color: whiteColor,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                          AppText(
                                            text:
                                                '${customerReviews[index]['date']}',
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w400,
                                            color: textHintColor,
                                            fontSize: 12.sp,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: AppText(
                                          text:
                                              '${customerReviews[index]['comment']}',
                                          maxLines: 4,
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: greyTextColor,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            text: 'Read more  ',
                                            fontFamily:
                                                "Franklin Gothic Regular",
                                            fontWeight: FontWeight.w600,
                                            color: bottomnavBack,
                                            fontSize: 12.sp,
                                          ),
                                          const ImageIcon(
                                            AssetImage(dropdownImage),
                                            color: nameText,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppText(
                                              text:
                                                  '${customerReviews[index]['name']}',
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              color: bottomnavBack,
                                              fontSize: 11.sp,
                                            ),
                                            AppText(
                                              text:
                                                  '${customerReviews[index]['helpfulCount']} found this helpful',
                                              fontFamily:
                                                  "Franklin Gothic Regular",
                                              fontWeight: FontWeight.w400,
                                              color: bottomnavBack,
                                              fontSize: 11.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        color: colorSecondary,
                                      )
                                    ],
                                  );
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: AppText(
                              text: "Recommended for you",
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                              color: blackColor,
                              fontSize: 16.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: items.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            width: 122,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(children: [
                                                  Image.asset(backImage,
                                                      height: 150,
                                                      width: 122,
                                                      fit: BoxFit.cover),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton(
                                                      icon: CircleAvatar(
                                                          radius: 12.0,
                                                          backgroundColor:
                                                              whiteColor,
                                                          child: Image.asset(
                                                              heartImage)),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ]),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: AppText(
                                                    text:
                                                        "Topman super skinny suit jacket and trousers in light blue",
                                                    color: nameText,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      AppText(
                                                        text:
                                                            "\u{20B9} ${items[index]}",
                                                        color:
                                                            deepGreytextColor,
                                                        maxLines: 2,
                                                        fontSize: 11.sp,
                                                        fontFamily:
                                                            "Franklin Gothic",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          "\u{20B9} ${items[index]}",
                                                          style: TextStyle(
                                                            color:
                                                                textHintColor,
                                                            fontSize: 11.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      const ImageIcon(
                                                        AssetImage(truckImage),
                                                        color: expressText,
                                                        size: 14,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5),
                                                        child: AppText(
                                                          text: "Express",
                                                          color: expressText,
                                                          maxLines: 2,
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                          const Divider(
                            color: colorSecondary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: AppText(
                              text: "Frequently bought with",
                              fontFamily: "Franklin Gothic",
                              fontWeight: FontWeight.w500,
                              color: blackColor,
                              fontSize: 16.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: items.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (ctx, index) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            width: 122,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(children: [
                                                  Image.asset(backImage,
                                                      height: 150,
                                                      width: 122,
                                                      fit: BoxFit.cover),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton(
                                                      icon: CircleAvatar(
                                                          radius: 12.0,
                                                          backgroundColor:
                                                              whiteColor,
                                                          child: Image.asset(
                                                              heartImage)),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ]),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: AppText(
                                                    text:
                                                        "Topman super skinny suit jacket and trousers in light blue",
                                                    color: nameText,
                                                    maxLines: 2,
                                                    fontSize: 11.sp,
                                                    fontFamily:
                                                        "Franklin Gothic Regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      AppText(
                                                        text:
                                                            "\u{20B9} ${items[index]}",
                                                        color:
                                                            deepGreytextColor,
                                                        maxLines: 2,
                                                        fontSize: 11.sp,
                                                        fontFamily:
                                                            "Franklin Gothic",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          "\u{20B9} ${items[index]}",
                                                          style: TextStyle(
                                                            color:
                                                                textHintColor,
                                                            fontSize: 11.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontFamily:
                                                                "Franklin Gothic Regular",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 10,
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      const ImageIcon(
                                                        AssetImage(truckImage),
                                                        color: expressText,
                                                        size: 14,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5),
                                                        child: AppText(
                                                          text: "Express",
                                                          color: expressText,
                                                          maxLines: 2,
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                              "Franklin Gothic Regular",
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                          const Divider(
                            color: colorSecondary,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              height: 90,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: btnTextColor, width: 1),
                      ),
                      child: IconButton(
                          onPressed: () {}, icon: Image.asset(heartIcon24))),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            border: Border.all(color: btnTextColor, width: 1),
                          ),
                          child: TextButton(
                              onPressed: () {},
                              child: AppText(
                                text: 'Add to bag',
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w600,
                                color: whiteBorderColor,
                                fontSize: 14.sp,
                              ))),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
