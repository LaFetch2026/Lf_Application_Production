// // ignore_for_file: avoid_print

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../common/widget/appbar/backbutton_appbar.dart';
// import '../../common/widget/other/common_widget.dart';
// import '../../common/widget/text/app_text.dart';
// import '../../controllers/order_controller.dart';
// import '../../core/constant/constants.dart';

// class ExchangeConfirmScreen extends StatefulWidget {
//   final int productId;
//   final String productName;
//   final String productDescription;
//   final String productimage;
//   final int sizeId;
//   final int orderId;
//   final int newInventoryId;

//   const ExchangeConfirmScreen(
//       {super.key,
//       required this.productId,
//       required this.productName,
//       required this.productimage,
//       required this.sizeId,
//       required this.orderId,
//       required this.newInventoryId,
//       required this.productDescription});

//   @override
//   State<ExchangeConfirmScreen> createState() => ExchangeConfirmScreenState();
// }

// class ExchangeConfirmScreenState extends State<ExchangeConfirmScreen> {
//   final controller = Get.put(OrderController());
//   final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   String? text1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: whiteColor,
//       body: Column(
//         children: [
//           const BackButtonAppbar(
//             text: "Exchange Product",
//             threeDot: false,
//             backgroundColor: whiteColor,
//             icon: threeDotImage,
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     color: whiteColor,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.sp, vertical: 20.sp),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: SizedBox(
//                                   height: 85.sp,
//                                   width: 70.sp,
//                                   child: CachedNetworkImage(
//                                     cacheManager: CacheManager(Config(
//                                         "customCacheKey",
//                                         stalePeriod: const Duration(days: 15),
//                                         maxNrOfCacheObjects: 100)),
//                                     fit: BoxFit.fill,
//                                     imageUrl: widget.productimage,
//                                     errorWidget: (context, url, error) =>
//                                         Image.asset(
//                                       downloadImage,
//                                       fit: BoxFit.fill,
//                                       height: 85.sp,
//                                       width: 70.sp,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 flex: 3,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: 10.sp,
//                                       ),
//                                       child: AppText(
//                                         text: widget.productName,
//                                         maxLines: 2,
//                                         fontFamily: "Clash Display Regular",
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 14,
//                                         color: nameText,
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           vertical: 10.sp, horizontal: 10.sp),
//                                       child: AppText(
//                                         text: Bidi.stripHtmlIfNeeded(
//                                             widget.productDescription),
//                                         maxLines: 2,
//                                         fontFamily: "Clash Display Regular",
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                         color: nameText,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.sp, vertical: 10.sp),
//                           child: AppText(
//                             text: "Why you exchanging this?",
//                             maxLines: 2,
//                             fontFamily: "Clash Display",
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                             color: loginText,
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.sp, vertical: 10.sp),
//                           child: TextField(
//                             textCapitalization: TextCapitalization.sentences,
//                             style: TextStyle(
//                               color: textColor,
//                               fontSize: 14.sp,
//                               fontFamily: "Clash Display Regular",
//                             ),
//                             controller: controller.exchangeComment,
//                             maxLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: whiteTextColor,
//                               focusedBorder: const OutlineInputBorder(
//                                   borderSide: BorderSide(color: borderColor)),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(1),
//                                 borderSide:
//                                     const BorderSide(color: borderColor),
//                               ),
//                               counterText: "",
//                               contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 10.sp, vertical: 10.sp),
//                               hintText: "How is the product? What do you hate?",
//                               hintStyle: TextStyle(fontSize: 14.sp),
//                             ),
//                           ),
//                         ),
//                         Obx(() => Padding(
//                               padding:
//                                   EdgeInsets.only(top: 30.sp, bottom: 10.sp),
//                               child: getSingleButton(
//                                   label: "Exchange Item",
//                                   textColor: btnTextColor,
//                                   controller: controller,
//                                   backgroundColor: whiteColor,
//                                   onPressed: () async {
//                                     if (controller.checkExchangeValidation()) {
//                                       controller.callExchangeProduct(
//                                           widget.orderId,
//                                           widget.sizeId,
//                                           widget.newInventoryId);
//                                     }
//                                     await analytics.logEvent(
//                                       name: 'submit_productExchangeItemClick',
//                                       parameters: <String, Object>{
//                                         'page_name':
//                                             'submit_productExchangeItemClick',
//                                       },
//                                     );
//                                   },
//                                   borderColor: btnTextColor),
//                             ))
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
