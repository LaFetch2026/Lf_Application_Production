// // ignore_for_file: avoid_print, deprecated_member_use

// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:lafetch/screens/orderdetailsscreen.dart';

// import '../common/widget/appbar/backbutton_appbar.dart';
// import '../common/widget/button/singlebtn.dart';
// import '../common/widget/lists/dummy_order_list.dart';
// import '../common/widget/other/common_widget.dart';
// import '../common/widget/text/app_text.dart';
// import '../controllers/order_controller.dart';
// import '../core/constant/constants.dart';

// class OrderExchangeScreen extends StatefulWidget {
//   const OrderExchangeScreen({super.key});

//   @override
//   State<OrderExchangeScreen> createState() => OrderExchangeScreenState();
// }

// class OrderExchangeScreenState extends State<OrderExchangeScreen> {
//   final orderController = Get.put(OrderController());
//   final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   String? filter;
//   Timer? debounce;

//   @override
//   void initState() {
//     filter = "All";
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       orderController.hasnextpage.value = true;
//       orderController.loadMore.value = false;
//       orderController.isOrder.value = false;
//       orderController.page.value = 1;
//       orderController.lat.value = 0.0;
//       orderController.lng.value = 0.0;
//       orderController.queryText.value = "";
//     });
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => orderController.getOrderData());
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       orderController.orderListController.addListener(() {
//         orderController.fetchMoreData();
//         orderController.update();
//       });
//     });
//     super.initState();
//   }

//   onSearchChanged(String query) {
//     if (debounce?.isActive ?? false) debounce?.cancel();
//     debounce = Timer(const Duration(milliseconds: 500), () async {
//       orderController.queryText.value = query;
//       orderController.getOrderData();
//       orderController.update();
//       await analytics.logEvent(
//         name: 'search_orderclick',
//         parameters: <String, Object>{
//           'page_name': 'search_orderclick',
//         },
//       );
//     });
//   }

//   @override
//   void dispose() {
//     debounce?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//       },
//       child: Scaffold(
//         backgroundColor: whiteTextColor,
//         body: Column(
//           children: [
//             const BackButtonAppbar(
//               text: "Orders & Exchanges",
//               threeDot: false,
//               backgroundColor: whiteColor,
//               icon: threeDotImage,
//             ),
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: () {
//                   return Future.delayed(Duration(milliseconds: 1), () {
//                     orderController.getOrderData();
//                   });
//                 },
//                 child: SingleChildScrollView(
//                   physics: AlwaysScrollableScrollPhysics(),
//                   controller: orderController.orderListController,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Obx(
//                         () => Container(
//                           color: whiteColor,
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 12.sp, vertical: 20.sp),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//                                 /* Container(
//                                 height: 40,
//                                 width: 180,
//                                 decoration: BoxDecoration(
//                                     color: whiteBorderColor,
//                                     borderRadius: BorderRadius.circular(1),
//                                     border: Border.all(color: borderColor, width: 1)),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(left: 16, right: 10),
//                                   child: Row(
//                                     children: [
//                                       const ImageIcon(
//                                         AssetImage(searchImage),
//                                         color: textHintColor,
//                                         size: 14,
//                                       ),
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.symmetric(horizontal: 5),
//                                         child: AppText(
//                                           text: "Search",
//                                           color: textHintColor,
//                                           fontSize: 14.sp,
//                                           fontFamily: "Clash Display Regular",
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ), */
//                                 MediaQuery.of(context).size.width < 600
//                                     ? Expanded(
//                                         flex: 1,
//                                         child: SizedBox(
//                                           height: 40.sp,
//                                           child: Padding(
//                                             padding:
//                                                 EdgeInsets.only(right: 10.sp),
//                                             child: RawKeyboardListener(
//                                               focusNode: FocusNode(),
//                                               onKey: (value) {
//                                                 print(value);
//                                                 if (value is RawKeyDownEvent) {
//                                                   orderController
//                                                       .queryText.value = "";
//                                                   orderController
//                                                       .getOrderData();
//                                                 }
//                                               },
//                                               child: TextField(
//                                                 textCapitalization:
//                                                     TextCapitalization.words,
//                                                 style: TextStyle(
//                                                   color: textColor,
//                                                   fontSize: 15.sp,
//                                                   fontFamily:
//                                                       "Clash Display Regular",
//                                                 ),
//                                                 onChanged: onSearchChanged,
//                                                 controller: orderController
//                                                     .searchController,
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 decoration: InputDecoration(
//                                                   filled: true,
//                                                   // isDense: true,
//                                                   fillColor: whiteColor,
//                                                   prefixIcon: Icon(Icons.search,
//                                                       size: 20.sp,
//                                                       color: Colors.grey),
//                                                   focusedBorder:
//                                                       const OutlineInputBorder(
//                                                           borderSide: BorderSide(
//                                                               color:
//                                                                   borderColor)),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             1.sp),
//                                                   ),
//                                                   enabledBorder:
//                                                       OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             1.sp),
//                                                     borderSide:
//                                                         const BorderSide(
//                                                             color: borderColor),
//                                                   ),
//                                                   contentPadding:
//                                                       EdgeInsets.zero,
//                                                   counterText: "",
//                                                   hintText: "Search",
//                                                   hintStyle: TextStyle(
//                                                       fontSize: 14.sp),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : Expanded(
//                                         flex: 1,
//                                         child: SizedBox(
//                                           height: 40.sp,
//                                           child: Padding(
//                                             padding:
//                                                 EdgeInsets.only(right: 10.sp),
//                                             child: RawKeyboardListener(
//                                               focusNode: FocusNode(),
//                                               onKey: (value) {
//                                                 print(value);
//                                                 if (value is RawKeyDownEvent) {
//                                                   orderController
//                                                       .queryText.value = "";
//                                                   orderController
//                                                       .getOrderData();
//                                                 }
//                                               },
//                                               child: TextField(
//                                                 textCapitalization:
//                                                     TextCapitalization.words,
//                                                 style: TextStyle(
//                                                   color: textColor,
//                                                   fontSize: 15.sp,
//                                                   fontFamily:
//                                                       "Clash Display Regular",
//                                                 ),
//                                                 onChanged: onSearchChanged,
//                                                 controller: orderController
//                                                     .searchController,
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 decoration: InputDecoration(
//                                                   filled: true,
//                                                   isDense: true,
//                                                   fillColor: whiteColor,
//                                                   prefixIcon: Icon(Icons.search,
//                                                       size: 20.sp,
//                                                       color: Colors.grey),
//                                                   focusedBorder:
//                                                       const OutlineInputBorder(
//                                                           borderSide: BorderSide(
//                                                               color:
//                                                                   borderColor)),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             1.sp),
//                                                   ),
//                                                   enabledBorder:
//                                                       OutlineInputBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             1.sp),
//                                                     borderSide:
//                                                         const BorderSide(
//                                                             color: borderColor),
//                                                   ),
//                                                   counterText: "",
//                                                   hintText: "Search",
//                                                   hintStyle: TextStyle(
//                                                       fontSize: 14.sp),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                 SizedBox(
//                                   height: 40.sp,
//                                   width: 130.sp,
//                                   child: DropdownButtonFormField2(
//                                     value: filter,
//                                     decoration: InputDecoration(
//                                       filled: true,
//                                       fillColor: whiteColor,
//                                       focusedBorder: const OutlineInputBorder(
//                                           borderSide:
//                                               BorderSide(color: borderColor)),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(1.sp),
//                                         borderSide: const BorderSide(
//                                             color: borderColor),
//                                       ),
//                                       isDense: true,
//                                       contentPadding: EdgeInsets.only(
//                                           left: 10.sp, right: 0),
//                                       hintText: 'Filter',
//                                       hintStyle: TextStyle(
//                                           fontSize: 12.sp,
//                                           fontFamily:
//                                               "Clash Display Regular"),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(1),
//                                       ),
//                                     ),
//                                     isExpanded: true,
//                                     items: orderController.filterList
//                                         .map((item) => DropdownMenuItem<String>(
//                                               value: item,
//                                               child: Text(
//                                                 item,
//                                                 style: TextStyle(
//                                                   fontSize: 12.sp,
//                                                   color: textColor,
//                                                   fontFamily:
//                                                       "Clash Display Regular",
//                                                 ),
//                                               ),
//                                             ))
//                                         .toList(),
//                                     validator: (value) {
//                                       if (value == null) {
//                                         return 'Please select Types.';
//                                       }
//                                       return null;
//                                     },
//                                     onChanged: (value) async {
//                                       filter = value;
//                                       print(orderController.filterId[
//                                           orderController.filterList
//                                               .indexOf(filter.toString())]);
//                                       orderController.status.value =
//                                           orderController.filterId[
//                                               orderController.filterList
//                                                   .indexOf(filter.toString())];
//                                       orderController.getOrderData();
//                                       await analytics.logEvent(
//                                         name: 'order_filterClick',
//                                         parameters: <String, Object>{
//                                           'page_name': 'order_filterClick',
//                                         },
//                                       );
//                                     },
//                                     onSaved: (value) {},
//                                     buttonStyleData: ButtonStyleData(
//                                       height: 60.sp,
//                                       padding: EdgeInsets.only(right: 10.sp),
//                                     ),
//                                     iconStyleData: IconStyleData(
//                                       icon:
//                                           ImageIcon(AssetImage(dropdownImage)),
//                                       iconSize: 10.sp,
//                                     ),
//                                     dropdownStyleData: DropdownStyleData(
//                                       maxHeight: 200.sp,
//                                       decoration: BoxDecoration(
//                                         color: whiteTextColor,
//                                         borderRadius:
//                                             BorderRadius.circular(4.sp),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Obx(() => orderController.isOrder.value
//                           ? const DummyOrderList()
//                           : orderController.orderList.isNotEmpty
//                               ? Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                         padding: EdgeInsets.only(bottom: 10.sp),
//                                         child: GetBuilder<OrderController>(
//                                           builder: (value) => ListView.builder(
//                                               primary: false,
//                                               shrinkWrap: true,
//                                               controller:
//                                                   value.orderListController,
//                                               physics: const ScrollPhysics(),
//                                               itemCount: value.orderList.length,
//                                               padding: EdgeInsets.zero,
//                                               scrollDirection: Axis.vertical,
//                                               itemBuilder: (ctx, index) {
//                                                 return Padding(
//                                                   padding: EdgeInsets.only(
//                                                       bottom: 10.sp),
//                                                   child: Column(
//                                                     children: [
//                                                       Container(
//                                                         color: whiteColor,
//                                                         child: Padding(
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   top: 10.sp),
//                                                           child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Padding(
//                                                                   padding: EdgeInsets
//                                                                       .symmetric(
//                                                                           horizontal:
//                                                                               16.sp),
//                                                                   child:
//                                                                       GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       orderController
//                                                                           .isDownloadInvoice
//                                                                           .value = false;
//                                                                       orderController
//                                                                           .downloadSuccess
//                                                                           .value = "";
//                                                                       Get.to(
//                                                                           OrderDetailsScreen(
//                                                                         orderId:
//                                                                             value.orderList[index]["id"],
//                                                                       ))?.then((value) =>
//                                                                           setState(
//                                                                             () {
//                                                                               orderController.getOrderData();
//                                                                             },
//                                                                           ));
//                                                                       await analytics
//                                                                           .logEvent(
//                                                                         name:
//                                                                             'order_details',
//                                                                         parameters: <String,
//                                                                             Object>{
//                                                                           'page_name':
//                                                                               'order_details',
//                                                                         },
//                                                                       );
//                                                                     },
//                                                                     child: Row(
//                                                                       children: [
//                                                                         Expanded(
//                                                                             flex:
//                                                                                 1,
//                                                                             child: value.orderList[index]["order_lines"][0]["product"] != null
//                                                                                 ? value.orderList[index]["order_lines"][0]["product"]["images"].isNotEmpty && value.orderList[index]["order_lines"][0]["product"]["images"] != null
//                                                                                     ? SizedBox(
//                                                                                         height: 85.sp,
//                                                                                         width: 70.sp,
//                                                                                         child: CachedNetworkImage(
//                                                                                           cacheManager: CacheManager(Config("customCacheKey", stalePeriod: const Duration(days: 15), maxNrOfCacheObjects: 100)),
//                                                                                           fit: BoxFit.cover,
//                                                                                           imageUrl: isImage(value.orderList[index]["order_lines"][0]["product"]["images"][0]["name"]) ? value.orderList[index]["order_lines"][0]["product"]["images"][0]["name"] : value.orderList[index]["order_lines"][0]["product"]["images"][1]["name"],
//                                                                                           errorWidget: (context, url, error) => Image.asset(
//                                                                                             downloadImage,
//                                                                                             fit: BoxFit.cover,
//                                                                                             height: 85.sp,
//                                                                                             width: 70.sp,
//                                                                                           ),
//                                                                                         ),
//                                                                                       )
//                                                                                     : Image.asset(dummyWishlistImage, height: 85.sp, width: 70.sp, fit: BoxFit.cover)
//                                                                                 : Image.asset(dummyWishlistImage, height: 85.sp, width: 70.sp, fit: BoxFit.cover)),
//                                                                         Expanded(
//                                                                           flex:
//                                                                               3,
//                                                                           child:
//                                                                               Column(
//                                                                             crossAxisAlignment:
//                                                                                 CrossAxisAlignment.start,
//                                                                             mainAxisAlignment:
//                                                                                 MainAxisAlignment.start,
//                                                                             children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(right: 5.sp, left: 12.sp),
//                                                                                 child: AppText(
//                                                                                   text: value.orderList[index]["order_lines"][0]["product"] != null ? value.orderList[index]["order_lines"][0]["product"]["name"] : "",
//                                                                                   maxLines: 1,
//                                                                                   fontFamily: "Clash Display Regular",
//                                                                                   fontWeight: FontWeight.w400,
//                                                                                   fontSize: 14,
//                                                                                   color: nameText,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(right: 5.sp, left: 12.sp, top: 5.sp, bottom: 5.sp),
//                                                                                 child: AppText(
//                                                                                   text: value.orderList[index]["order_lines"][0]["product"] != null ? value.orderList[index]["order_lines"][0]["product"]["brand_name"] ?? "" : "",
//                                                                                   color: greyTextColor,
//                                                                                   maxLines: 2,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display Regular",
//                                                                                   fontWeight: FontWeight.w400,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(right: 5.sp, left: 12.sp, top: 0.sp, bottom: 5.sp),
//                                                                                 child: Row(
//                                                                                   children: [
//                                                                                     /*  value.orderList[index]["order_lines"][0]["inventory"] != null
//                                                                                       ? Padding(
//                                                                                           padding: EdgeInsets.only(right: 10.sp),
//                                                                                           child: AppText(
//                                                                                             text: "Size :${value.orderList[index]["order_lines"][0]["inventory"]["product_matrix_name_size"] ?? ""}",
//                                                                                             color: greyTextColor,
//                                                                                             maxLines: 2,
//                                                                                             fontSize: 12,
//                                                                                             fontFamily: "Clash Display Regular",
//                                                                                             fontWeight: FontWeight.w400,
//                                                                                           ),
//                                                                                         )
//                                                                                       : const SizedBox(
//                                                                                           height: 0,
//                                                                                         ),
//                                                                                   Expanded(
//                                                                                     flex: 1,
//                                                                                     child: Padding(
//                                                                                       padding: EdgeInsets.only(right: 10.sp),
//                                                                                       child: AppText(
//                                                                                         text: "Qty :${value.orderList[index]["order_lines"][0]["quantity"] ?? "0"}",
//                                                                                         color: greyTextColor,
//                                                                                         maxLines: 2,
//                                                                                         fontSize: 12,
//                                                                                         fontFamily: "Clash Display Regular",
//                                                                                         fontWeight: FontWeight.w400,
//                                                                                       ),
//                                                                                     ),
//                                                                                   ), */
//                                                                                     Padding(
//                                                                                       padding: EdgeInsets.only(right: 10.sp),
//                                                                                       child: AppText(
//                                                                                         text: value.orderList[index]["order_lines"].length > 1 ? "Items : ${value.orderList[index]["order_lines"].length}" : "Item : ${value.orderList[index]["order_lines"].length}",
//                                                                                         color: greyTextColor,
//                                                                                         maxLines: 2,
//                                                                                         fontSize: 12,
//                                                                                         fontFamily: "Clash Display Regular",
//                                                                                         fontWeight: FontWeight.w400,
//                                                                                       ),
//                                                                                     ),
//                                                                                     Expanded(
//                                                                                       flex: 1,
//                                                                                       child: const SizedBox(
//                                                                                         height: 0,
//                                                                                       ),
//                                                                                     ),
//                                                                                     AppText(
//                                                                                       text: "\u{20B9} ${value.orderList[index]["total"] ?? "0"}",
//                                                                                       color: greyTextColor,
//                                                                                       fontSize: 12,
//                                                                                       textAlign: TextAlign.right,
//                                                                                       fontFamily: "Clash Display Regular",
//                                                                                       fontWeight: FontWeight.w400,
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                                 Padding(
//                                                                   padding: EdgeInsets.symmetric(
//                                                                       vertical:
//                                                                           10.sp,
//                                                                       horizontal:
//                                                                           16.sp),
//                                                                   child: Row(
//                                                                     children: [
//                                                                       if (value.orderList[index]["status"] ==
//                                                                           6) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightGreen,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: SvgPicture.asset(
//                                                                                   deliverSvgImage,
//                                                                                   height: 8.sp,
//                                                                                   width: 11.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Delivered
//                                                                                   color: deepGreen,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]["status"] ==
//                                                                           5) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightYellow,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: SvgPicture.asset(
//                                                                                   shipSvgImage,
//                                                                                   height: 16.sp,
//                                                                                   width: 16.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Shipped
//                                                                                   color: deeptYellow,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]["status"] ==
//                                                                           1) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightYellow,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 2.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Cart
//                                                                                   color: deeptYellow,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]["status"] ==
//                                                                           3) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightPurple,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: SvgPicture.asset(
//                                                                                   confirmSvgImage,
//                                                                                   color: deepPurple,
//                                                                                   height: 16.sp,
//                                                                                   width: 16.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Order Confirmed
//                                                                                   color: deepPurple,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]["status"] ==
//                                                                           2) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightPurple,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: ImageIcon(
//                                                                                   AssetImage(confirmOrderImage),
//                                                                                   color: deepPurple,
//                                                                                   size: 14.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Pending
//                                                                                   color: deepPurple,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]["status"] ==
//                                                                           4) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightPurple,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: SvgPicture.asset(
//                                                                                   confirmSvgImage,
//                                                                                   color: deepPurple,
//                                                                                   height: 16.sp,
//                                                                                   width: 16.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Processing
//                                                                                   color: deepPurple,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]["status"] ==
//                                                                           7) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightback,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: ImageIcon(
//                                                                                   AssetImage(cancelImage),
//                                                                                   color: deepRed,
//                                                                                   size: 14.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Cancelled
//                                                                                   color: deepRed,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]
//                                                                               [
//                                                                               "status"] ==
//                                                                           8) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightPurple,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: SvgPicture.asset(
//                                                                                   confirmSvgImage,
//                                                                                   color: deepPurple,
//                                                                                   height: 16.sp,
//                                                                                   width: 16.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Completed
//                                                                                   color: deepPurple,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]
//                                                                               [
//                                                                               "status"] ==
//                                                                           9) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightPurple,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: ImageIcon(
//                                                                                   AssetImage(confirmOrderImage),
//                                                                                   color: deepPurple,
//                                                                                   size: 14,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Exchange
//                                                                                   color: deepPurple,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]
//                                                                               [
//                                                                               "status"] ==
//                                                                           11) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightback,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: ImageIcon(
//                                                                                   AssetImage(cancelImage),
//                                                                                   color: deepRed,
//                                                                                   size: 14.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Rejected
//                                                                                   color: deepRed,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ] else if (value.orderList[index]
//                                                                               [
//                                                                               "status"] ==
//                                                                           10) ...[
//                                                                         AnimatedContainer(
//                                                                           duration:
//                                                                               const Duration(milliseconds: 300),
//                                                                           margin:
//                                                                               EdgeInsets.only(right: 5.sp),
//                                                                           height:
//                                                                               30.sp,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             color:
//                                                                                 lightGreen,
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20.sp),
//                                                                             border:
//                                                                                 Border.all(color: textHintColor, width: 1.sp),
//                                                                           ),
//                                                                           child:
//                                                                               Padding(
//                                                                             padding:
//                                                                                 EdgeInsets.symmetric(horizontal: 5.sp),
//                                                                             child:
//                                                                                 Row(children: [
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.symmetric(horizontal: 2.sp),
//                                                                                 child: ImageIcon(
//                                                                                   AssetImage(checkImage),
//                                                                                   color: deepGreen,
//                                                                                   size: 14.sp,
//                                                                                 ),
//                                                                               ),
//                                                                               Padding(
//                                                                                 padding: EdgeInsets.only(left: 5.sp, right: 2.sp),
//                                                                                 child: AppText(
//                                                                                   text: "${value.orderList[index]["status_details"]}".capitalize!,
//                                                                                   //Approved
//                                                                                   color: deepGreen,
//                                                                                   fontSize: 12,
//                                                                                   fontFamily: "Clash Display",
//                                                                                   fontWeight: FontWeight.w500,
//                                                                                 ),
//                                                                               ),
//                                                                             ]),
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                       /* const Expanded(
//                                                                         child:
//                                                                             SizedBox(
//                                                                           width:
//                                                                               0,
//                                                                         ),
//                                                                       ), */
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 Padding(
//                                                                   padding: EdgeInsets
//                                                                       .only(
//                                                                           right:
//                                                                               16.sp),
//                                                                   child: Row(
//                                                                     children: [
//                                                                       const Expanded(
//                                                                         child:
//                                                                             SizedBox(
//                                                                           width:
//                                                                               0,
//                                                                         ),
//                                                                       ),
//                                                                       Column(
//                                                                         crossAxisAlignment:
//                                                                             CrossAxisAlignment.end,
//                                                                         children: [
//                                                                           if (value.orderList[index]["delivered_at"] !=
//                                                                               null) ...[
//                                                                             Padding(
//                                                                               padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
//                                                                               child: AppText(
//                                                                                 text: "Delivered on",
//                                                                                 color: greyTextColor,
//                                                                                 fontSize: 11,
//                                                                                 fontFamily: "Clash Display Regular",
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               ),
//                                                                             ),
//                                                                           ] else if (value.orderList[index]["estimated_delivery_at"] !=
//                                                                               null) ...[
//                                                                             Padding(
//                                                                               padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
//                                                                               child: AppText(
//                                                                                 text: "Estimated Delivery",
//                                                                                 color: greyTextColor,
//                                                                                 fontSize: 11,
//                                                                                 fontFamily: "Clash Display Regular",
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               ),
//                                                                             ),
//                                                                           ] else if (value.orderList[index]["cancelled_at"] !=
//                                                                               null) ...[
//                                                                             Padding(
//                                                                               padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
//                                                                               child: AppText(
//                                                                                 text: "Cancelled on",
//                                                                                 color: greyTextColor,
//                                                                                 fontSize: 11,
//                                                                                 fontFamily: "Clash Display Regular",
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                           if (value.orderList[index]["delivered_at"] !=
//                                                                               null) ...[
//                                                                             Padding(
//                                                                               padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
//                                                                               child: AppText(
//                                                                                 text: value.orderList[index]["delivered_at"],
//                                                                                 // text: "${DateFormat.MMMM().format(DateTime.parse(value.orderList[index]["delivered_at"])).substring(0, 3)} ${DateTime.parse(value.orderList[index]["delivered_at"]).day}, at ${DateFormat('hh:mm a').format(DateTime.parse(value.orderList[index]["delivered_at"]))}",
//                                                                                 color: greyTextColor,
//                                                                                 fontSize: 11,
//                                                                                 fontFamily: "Clash Display Regular",
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               ),
//                                                                             )
//                                                                           ] else if (value.orderList[index]["estimated_delivery_at"] !=
//                                                                               null) ...[
//                                                                             Padding(
//                                                                               padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
//                                                                               child: AppText(
//                                                                                 text: value.orderList[index]["estimated_delivery_at"],
//                                                                                 // text: "${DateFormat.MMMM().format(DateTime.parse(value.orderList[index]["estimated_delivery_at"])).substring(0, 3)} ${DateTime.parse(value.orderList[index]["estimated_delivery_at"]).day}, ${DateTime.parse(value.orderList[index]["estimated_delivery_at"]).year}",
//                                                                                 color: greyTextColor,
//                                                                                 fontSize: 11,
//                                                                                 fontFamily: "Clash Display Regular",
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               ),
//                                                                             )
//                                                                           ] else if (value.orderList[index]["cancelled_at"] !=
//                                                                               null) ...[
//                                                                             Padding(
//                                                                               padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
//                                                                               child: AppText(
//                                                                                 text: value.orderList[index]["cancelled_at"],
//                                                                                 //  text: "${DateFormat.MMMM().format(DateTime.parse(value.orderList[index]["cancelled_at"])).substring(0, 3)} ${DateTime.parse(value.orderList[index]["cancelled_at"]).day}, ${DateTime.parse(value.orderList[index]["cancelled_at"]).year}",
//                                                                                 color: greyTextColor,
//                                                                                 fontSize: 11,
//                                                                                 fontFamily: "Clash Display Regular",
//                                                                                 fontWeight: FontWeight.w400,
//                                                                               ),
//                                                                             )
//                                                                           ],
//                                                                         ],
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 Padding(
//                                                                   padding: EdgeInsets.only(
//                                                                       top:
//                                                                           10.sp,
//                                                                       bottom: 30
//                                                                           .sp),
//                                                                   child: SingleButton(
//                                                                       label: "View details",
//                                                                       height: 40,
//                                                                       textColor: btnTextColor,
//                                                                       backgroundColor: whiteColor,
//                                                                       onPressed: () async {
//                                                                         orderController
//                                                                             .isDownloadInvoice
//                                                                             .value = false;
//                                                                         orderController
//                                                                             .downloadSuccess
//                                                                             .value = "";
//                                                                         Get.to(
//                                                                             OrderDetailsScreen(
//                                                                           orderId:
//                                                                               value.orderList[index]["id"],
//                                                                         ))?.then((value) =>
//                                                                             setState(
//                                                                               () {
//                                                                                 orderController.getOrderData();
//                                                                               },
//                                                                             ));
//                                                                         await analytics
//                                                                             .logEvent(
//                                                                           name:
//                                                                               'order_details',
//                                                                           parameters: <String,
//                                                                               Object>{
//                                                                             'page_name':
//                                                                                 'order_details',
//                                                                           },
//                                                                         );
//                                                                       },
//                                                                       borderColor: btnTextColor),
//                                                                 ),
//                                                               ]),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 );
//                                               }),
//                                         )),
//                                     /*  orderController.loadMore.value
//                                         ? DummyOrderList()
//                                         : GestureDetector(
//                                             onTap: () {
//                                               orderController.orderListController
//                                                   .addListener(() {
//                                                 orderController.fetchMoreData();
//                                                 orderController.update();
//                                               });
//                                             },
//                                             child: Padding(
//                                               padding: EdgeInsets.only(
//                                                   top: 10.sp, bottom: 10.sp),
//                                               child: Center(
//                                                 child: AppText(
//                                                   text: "load more",
//                                                   textAlign: TextAlign.center,
//                                                   fontFamily:
//                                                       "Clash Display Regular",
//                                                   color: blue,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                           ), */
//                                     orderController.loadMore.value
//                                         ? Padding(
//                                             padding: const EdgeInsets.all(10.0),
//                                             child: Center(
//                                                 child:
//                                                     CircularProgressIndicator()),
//                                           )
//                                         : const SizedBox(
//                                             height: 0,
//                                           ),
//                                   ],
//                                 )
//                               : Padding(
//                                   padding: EdgeInsets.all(40.0.sp),
//                                   child: Center(
//                                     child: Text("No Order Found",
//                                         style: TextStyle(
//                                             fontSize: 14.sp,
//                                             color: Colors.black,
//                                             fontFamily:
//                                                 "Clash Display Regular")),
//                                   ),
//                                 )),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
