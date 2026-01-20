// // ignore_for_file: avoid_print, deprecated_member_use

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// //import 'package:lafetch/controller/review_controller.dart';
// import 'package:lafetch/screens/orders/exchangeconfirm.dart';

// import '../../common/widget/appbar/backbutton_appbar.dart';
// import '../../common/widget/bottom_sheets/bottomsize.dart';
// import '../../common/widget/lists/dummy_container.dart';
// import '../../common/widget/text/app_text.dart';
// import '../../controllers/exchange_controller.dart';
// import '../../core/constant/constants.dart';

// class ExchangeProductScreen extends StatefulWidget {
//   final int productId;
//   final String productName;
//   final String productDescription;
//   final String productimage;
//   final int sizeId;
//   final int orderId;

//   const ExchangeProductScreen(
//       {super.key,
//       required this.productId,
//       required this.productName,
//       required this.productimage,
//       required this.sizeId,
//       required this.orderId,
//       required this.productDescription});

//   @override
//   State<ExchangeProductScreen> createState() => ExchangeProductScreenState();
// }

// class ExchangeProductScreenState extends State<ExchangeProductScreen> {
//   final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   String? text1;
//   final exchangeController = Get.put(ExchangeController());
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     exchangeController.getProductDetails(widget.productId);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         text1 = "";
//         setState(() {});
//         return true;
//       },
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: whiteColor,
//         body: Column(
//           // children: [
//             const BackButtonAppbar(
//               text: "Exchange Product",
//               threeDot: false,
//               backgroundColor: whiteColor,
//               icon: threeDotImage,
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       color: whiteColor,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 16.sp, vertical: 20.sp),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 1,
//                                   child: SizedBox(
//                                     height: 85.sp,
//                                     width: 70.sp,
//                                     child: CachedNetworkImage(
//                                       cacheManager: CacheManager(Config(
//                                           "customCacheKey",
//                                           stalePeriod: const Duration(days: 15),
//                                           maxNrOfCacheObjects: 100)),
//                                       fit: BoxFit.fill,
//                                       imageUrl: widget.productimage,
//                                       errorWidget: (context, url, error) =>
//                                           Image.asset(
//                                         downloadImage,
//                                         fit: BoxFit.fill,
//                                         height: 85.sp,
//                                         width: 70.sp,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 10.sp,
//                                         ),
//                                         child: AppText(
//                                           text: widget.productName,
//                                           maxLines: 2,
//                                           fontFamily: "Clash Display Regular",
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 14,
//                                           color: nameText,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 10.sp, horizontal: 10.sp),
//                                         child: AppText(
//                                           text: Bidi.stripHtmlIfNeeded(
//                                               widget.productDescription),
//                                           maxLines: 2,
//                                           fontFamily: "Clash Display Regular",
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 12,
//                                           color: nameText,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 16.sp, vertical: 10.sp),
//                             child: AppText(
//                               text: "Choose why you exchanging this?",
//                               maxLines: 2,
//                               fontFamily: "Clash Display",
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14,
//                               color: loginText,
//                             ),
//                           ),
//                           Obx(
//                             () => exchangeController.isDetails.value
//                                 ? Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 16.sp, vertical: 10.sp),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             DummyContainer(
//                                                 height: 16.sp, width: 16.sp),
//                                             Padding(
//                                               padding:
//                                                   EdgeInsets.only(left: 8.sp),
//                                               child: DummyContainer(
//                                                   height: 16.sp, width: 80.sp),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 30.sp,
//                                         ),
//                                         Row(
//                                           children: [
//                                             DummyContainer(
//                                                 height: 16.sp, width: 16.sp),
//                                             Padding(
//                                               padding:
//                                                   EdgeInsets.only(left: 8.sp),
//                                               child: DummyContainer(
//                                                   height: 16.sp, width: 80.sp),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 : Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 16.sp, vertical: 10.sp),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Radio(
//                                                 value: "Ordered wrong size",
//                                                 activeColor: colorPrimary,
//                                                 groupValue: text1,
//                                                 onChanged: (value) async {
//                                                   text1 = value.toString();
//                                                   showModalBottomSheet(
//                                                     context: context,
//                                                     isScrollControlled: true,
//                                                     constraints: BoxConstraints(
//                                                       maxWidth: double.infinity,
//                                                       maxHeight: 300.sp,
//                                                     ),
//                                                     builder: (ctx) {
//                                                       return BottomSize(
//                                                         sizeList: exchangeController
//                                                                 .productDetails[
//                                                             "new_inventories"],
//                                                         controller:
//                                                             exchangeController,
//                                                         onPressedCross: () {
//                                                           Get.back();
//                                                           text1 = "";
//                                                           setState(() {});
//                                                         },
//                                                         onPressed: (p0) {
//                                                           text1 = "";
//                                                           setState(() {});
//                                                           Get.back();
//                                                           Get.to(ExchangeConfirmScreen(
//                                                               sizeId:
//                                                                   widget.sizeId,
//                                                               orderId: widget
//                                                                   .orderId,
//                                                               newInventoryId:
//                                                                   p0,
//                                                               productId: widget
//                                                                   .productId,
//                                                               productName: widget
//                                                                   .productName,
//                                                               productimage: widget
//                                                                   .productimage,
//                                                               productDescription:
//                                                                   widget
//                                                                       .productDescription));
//                                                         },
//                                                         selectedSizeId:
//                                                             widget.sizeId,
//                                                       );
//                                                     },
//                                                   );

//                                                   await analytics.logEvent(
//                                                     name:
//                                                         'exchange_product_updatesizeClick',
//                                                     parameters: <String,
//                                                         Object>{
//                                                       'page_name':
//                                                           'exchange_product_updatesizeClick',
//                                                     },
//                                                   );
//                                                   setState(() {});
//                                                 }),
//                                             GestureDetector(
//                                               onTap: () async {
//                                                 text1 = "Ordered wrong size";
//                                                 showModalBottomSheet(
//                                                   context: context,
//                                                   isScrollControlled: true,
//                                                   constraints: BoxConstraints(
//                                                     maxWidth: double.infinity,
//                                                     maxHeight: 230.sp,
//                                                   ),
//                                                   builder: (ctx) {
//                                                     return BottomSize(
//                                                       sizeList: exchangeController
//                                                               .productDetails[
//                                                           "new_inventories"],
//                                                       controller:
//                                                           exchangeController,
//                                                       onPressedCross: () {
//                                                         Get.back();
//                                                         text1 = "";
//                                                         setState(() {});
//                                                       },
//                                                       onPressed: (p0) {
//                                                         text1 = "";
//                                                         setState(() {});
//                                                         Get.back();
//                                                         Get.to(ExchangeConfirmScreen(
//                                                             sizeId:
//                                                                 widget.sizeId,
//                                                             orderId:
//                                                                 widget.orderId,
//                                                             newInventoryId: p0,
//                                                             productId: widget
//                                                                 .productId,
//                                                             productName: widget
//                                                                 .productName,
//                                                             productimage: widget
//                                                                 .productimage,
//                                                             productDescription:
//                                                                 widget
//                                                                     .productDescription));
//                                                       },
//                                                       selectedSizeId:
//                                                           widget.sizeId,
//                                                     );
//                                                   },
//                                                 );

//                                                 await analytics.logEvent(
//                                                   name:
//                                                       'exchange_product_updatesizeClick',
//                                                   parameters: <String, Object>{
//                                                     'page_name':
//                                                         'exchange_product_updatesizeClick',
//                                                   },
//                                                 );
//                                                 setState(() {});
//                                               },
//                                               child: Text(
//                                                 "Ordered wrong size",
//                                                 style: TextStyle(
//                                                   color: colorPrimary,
//                                                   fontSize: 14.sp,
//                                                   fontFamily:
//                                                       "Clash Display Regular",
//                                                   fontWeight: FontWeight.w400,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           children: [
//                                             Radio(
//                                                 value: "Others",
//                                                 activeColor: colorPrimary,
//                                                 groupValue: text1,
//                                                 onChanged: (value) async {
//                                                   text1 = value.toString();
//                                                   setState(() {});
//                                                   Navigator.of(context)
//                                                       .push(MaterialPageRoute(
//                                                           builder: (BuildContext
//                                                                   context) =>
//                                                               ExchangeConfirmScreen(
//                                                                   sizeId: widget
//                                                                       .sizeId,
//                                                                   orderId: widget
//                                                                       .orderId,
//                                                                   newInventoryId:
//                                                                       widget
//                                                                           .sizeId,
//                                                                   productId: widget
//                                                                       .productId,
//                                                                   productName:
//                                                                       widget
//                                                                           .productName,
//                                                                   productimage:
//                                                                       widget
//                                                                           .productimage,
//                                                                   productDescription:
//                                                                       widget
//                                                                           .productDescription)))
//                                                       .then((value) => setState(
//                                                             () {
//                                                               text1 = "";
//                                                             },
//                                                           ));
//                                                   await analytics.logEvent(
//                                                     name:
//                                                         'submit_productExchangeOtherClick',
//                                                     parameters: <String,
//                                                         Object>{
//                                                       'page_name':
//                                                           'submit_productExchangeOtherClick',
//                                                     },
//                                                   );
//                                                 }),
//                                             GestureDetector(
//                                               onTap: () async {
//                                                 text1 = "Others";
//                                                 setState(() {});
//                                                 Navigator.of(context)
//                                                     .push(MaterialPageRoute(
//                                                         builder: (BuildContext
//                                                                 context) =>
//                                                             ExchangeConfirmScreen(
//                                                                 sizeId: widget
//                                                                     .sizeId,
//                                                                 orderId:
//                                                                     widget
//                                                                         .orderId,
//                                                                 newInventoryId:
//                                                                     widget
//                                                                         .sizeId,
//                                                                 productId:
//                                                                     widget
//                                                                         .productId,
//                                                                 productName: widget
//                                                                     .productName,
//                                                                 productimage: widget
//                                                                     .productimage,
//                                                                 productDescription:
//                                                                     widget
//                                                                         .productDescription)))
//                                                     .then((value) => setState(
//                                                           () {
//                                                             text1 = "";
//                                                           },
//                                                         ));
//                                                 await analytics.logEvent(
//                                                   name:
//                                                       'submit_productExchangeOtherClick',
//                                                   parameters: <String, Object>{
//                                                     'page_name':
//                                                         'submit_productExchangeOtherClick',
//                                                   },
//                                                 );
//                                               },
//                                               child: Text(
//                                                 "Others",
//                                                 style: TextStyle(
//                                                   color: colorPrimary,
//                                                   fontSize: 14.sp,
//                                                   fontFamily:
//                                                       "Clash Display Regular",
//                                                   fontWeight: FontWeight.w400,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
