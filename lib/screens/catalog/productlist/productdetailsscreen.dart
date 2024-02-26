// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/commonwidget/text_field.dart';
import '../../../commonwidget/app_text.dart';
import '../../../utils/constants.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController controller = PageController();
  final pincodeController = TextEditingController();
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
                    Container(
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
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Image.asset(arrowBack),
                                    onPressed: () {},
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
                                      padding: const EdgeInsets.all(6.0),
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
                            Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: borderColor, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: TextField(
                                      controller: pincodeController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        // filled: true,
                                        // fillColor: whiteTextColor,
                                        // focusedBorder: const OutlineInputBorder(
                                        //     borderSide: BorderSide(color: borderColor)),
                                        // border: OutlineInputBorder(
                                        //   borderRadius: BorderRadius.circular(1),
                                        // ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          borderSide: const BorderSide(
                                              color: Color(0x00000000)),
                                        ),
                                        counterText: "",
                                        hintText: 'Enter pincode',
                                        hintStyle: const TextStyle(
                                            fontSize: 14, color: textHintColor),
                                      ),
                                      style: TextStyle(
                                        fontFamily: "Franklin Gothic Regular",
                                        fontWeight: FontWeight.w500,
                                        color: colorPrimary,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: AppText(
                                      text: 'Check',
                                      fontFamily: "Franklin Gothic Regular",
                                      fontWeight: FontWeight.w600,
                                      color: blackColor,
                                      fontSize: 14.sp,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 18.0, bottom: 54.0),
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
                          ]),
                    ),
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