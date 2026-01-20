// // ignore_for_file: avoid_print, deprecated_member_use
// import 'dart:async';

// //import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// //import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../../controllers/order_controller.dart';
// import '../../core/constant/constants.dart';

// class DeliverTrackScreen extends StatefulWidget {
//   final int orderId;
//   final double dropLat;
//   final double dropLng;

//   const DeliverTrackScreen({
//     super.key,
//     required this.orderId,
//     required this.dropLat,
//     required this.dropLng,
//   });

//   @override
//   State<DeliverTrackScreen> createState() => DeliverTrackScreenState();
// }

// class DeliverTrackScreenState extends State<DeliverTrackScreen>
//     with WidgetsBindingObserver {
//   late GoogleMapController mapController;
//   final orderController = Get.put(OrderController());
//   final Set<Marker> markers = new Set();
//   LatLng dropLatLng = const LatLng(0, 0);
//   BitmapDescriptor myIcon = BitmapDescriptor.defaultMarker;
//   Map<PolylineId, Polyline> polylines = {};
//   String googleAPiKey = "AIzaSyCBFuMTFiBOwMOAbiCNJFInpiknSupbfEc";
//   PolylinePoints polylinePoints = PolylinePoints();

//   @override
//   void initState() {
//     /*  WidgetsBinding.instance.addPostFrameCallback((_) {
//       orderController.getLatLng();
//        initializeService();
//     }); */
//     /* WidgetsFlutterBinding.ensureInitialized();
//     DartPluginRegistrant.ensureInitialized(); */
  
//     WidgetsBinding.instance.addObserver(this);
  
//     dropLatLng = LatLng(widget.dropLat, widget.dropLng);
//     BitmapDescriptor.fromAssetImage(
//             ImageConfiguration(size: Size(20, 20)), deliveryImage)
//         .then((onValue) {
//       myIcon = onValue;
//     });
//     getDirections();
//     super.initState();
//   }

//   /*  Future<void> initializeService() async {
//     final service = FlutterBackgroundService();

//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         autoStart: true,
//         isForegroundMode: false,
//       ),
//       iosConfiguration: IosConfiguration(),
//     );
//     service.startService();
//   }
//  */
//   /*  @pragma('vm:entry-point')
//   static void onStart(ServiceInstance service) async {
//     service.on('stopService').listen((event) async {
//       await FlutterLocalNotificationsPlugin().cancelAll();
//       service.stopSelf();
//     });

//     service.on('initiateLocation').listen((event) {
//       print('initiateLocation--------${event?['ongoingDeliveries']}');
//     });

//     Timer.periodic(const Duration(seconds: 5), (timer) async {
//       DeliverTrackScreenState().orderController.getLatLng();
//     });
//   } */

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         orderController.getLatLng();
//         break;
//       case AppLifecycleState.inactive:
//         break;
//       case AppLifecycleState.paused:
//         break;
//       case AppLifecycleState.detached:
//         FlutterBackgroundService().invoke("stopService");
//         break;
//       case AppLifecycleState.hidden:
//         throw UnimplementedError();
//     }
//   }

//   @override
//   void dispose() {
//     Future.delayed(const Duration(seconds: 0), () async {
//       final service = FlutterBackgroundService();
//       var isRunning = await service.isRunning();
//       if (isRunning) {
//         service.invoke("stopService");
//       }
//     });
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   getDirections() async {
//     print("pointer abcd ${orderController.lat.value}");
//     List<LatLng> polylineCoordinates = [];
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleAPiKey,
//       PointLatLng(widget.dropLat, widget.dropLng),
//       PointLatLng(orderController.lat.value, orderController.lng.value),
//       travelMode: TravelMode.driving,
//     );
//     print("pointer ${result.points}");
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     } else {
//       print(result.errorMessage);
//     }
//     addPolyLine(polylineCoordinates);
//   }

//   addPolyLine(List<LatLng> polylineCoordinates) {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.deepPurpleAccent,
//       points: polylineCoordinates,
//       width: 5,
//     );
//     polylines[id] = polyline;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: whiteColor,
//         body: Column(
//           children: [
//             Expanded(
//                 flex: 1,
//                 child: Stack(
//                   children: [
//                     _getMap(),
//                     Padding(
//                       padding: EdgeInsets.only(top: 40.0.sp, left: 10.sp),
//                       child: InkWell(
//                           onTap: () {
//                             Get.back();
//                           },
//                           child: SvgPicture.asset(arrowBack,
//                               height: 15.sp, width: 15.sp, fit: BoxFit.fill)),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(
//                           top: MediaQuery.of(context).size.height - 100.sp,
//                           left: 20.sp),
//                       child: InkWell(
//                           onTap: () {
//                             orderController.getLatLng();
//                             markers.clear();
//                             getDirections();
//                           },
//                           child: CircleAvatar(
//                             backgroundColor: blackColor,
//                             child: Image.asset(
//                               refreshImage,
//                               height: 20.sp,
//                               width: 20.sp,
//                               color: whiteColor,
//                             ),
//                           )),
//                     ),
//                   ],
//                 )),
//           ],
//         ));
//   }

//   Widget _getMap() {
//     return Obx(() => orderController.isUpdateLocation.value
//         ? Center(
//             child: SizedBox(
//               height: 16.sp,
//               width: 16.sp,
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           )
//         : GoogleMap(
//             zoomGesturesEnabled: true,
//             scrollGesturesEnabled: true,
//             tiltGesturesEnabled: false,
//             rotateGesturesEnabled: false,
//             zoomControlsEnabled: false,
//             polylines: Set<Polyline>.of(polylines.values),
//             initialCameraPosition: CameraPosition(
//               target: orderController.deliveryPatnerLatLng.value,
//               zoom: 15.0,
//             ),
//             markers: getmarkers(),
//             mapType: MapType.normal,
//             onMapCreated: (controller) {
//               setState(() {
//                 mapController = controller;
//               });
//             },
//           ));
//   }

//   Set<Marker> getmarkers() {
//     markers.add(Marker(
//       markerId: MarkerId(dropLatLng.toString()),
//       position: dropLatLng,
//       infoWindow: InfoWindow(
//         title: 'Drop Location',
//         // snippet: 'Drop Location',
//       ),
//       icon: BitmapDescriptor.defaultMarker,
//     ));

//     markers.add(Marker(
//       markerId: MarkerId(orderController.deliveryPatnerLatLng.value.toString()),
//       position: orderController.deliveryPatnerLatLng.value, //position of marker
//       infoWindow: InfoWindow(
//         title: 'Delivery Partner Location',
//         //  snippet: 'Partner Location',
//       ),
//       icon: myIcon,
//     ));
//     ;

//     return markers;
//   }
// }
