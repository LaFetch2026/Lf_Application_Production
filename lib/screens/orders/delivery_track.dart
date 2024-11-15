// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/order_controller.dart';
import '../../utils/constants.dart';

class DeliverTrackScreen extends StatefulWidget {
  final double dropLat;
  final double dropLng;
  final double deliverPartnerLat;
  final double deliverPartnerLng;
  const DeliverTrackScreen({
    super.key,
    required this.dropLat,
    required this.dropLng,
    required this.deliverPartnerLat,
    required this.deliverPartnerLng,
  });

  @override
  State<DeliverTrackScreen> createState() => DeliverTrackScreenState();
}

class DeliverTrackScreenState extends State<DeliverTrackScreen> {
  late GoogleMapController mapController;
  final orderController = Get.put(OrderController());
  final Set<Marker> markers = new Set();
  LatLng dropLatLng = const LatLng(0, 0);
  LatLng deliveryPatnerLatLng = const LatLng(0, 0);
  BitmapDescriptor myIcon = BitmapDescriptor.defaultMarker;
  Map<PolylineId, Polyline> polylines = {};
  String googleAPiKey = "AIzaSyCei4lyJgwzgsBLWRYjMALVbAe85K7k3sk";
  PolylinePoints polylinePoints = PolylinePoints();
  @override
  void initState() {
    dropLatLng = LatLng(widget.dropLat, widget.dropLng);
    deliveryPatnerLatLng =
        LatLng(widget.deliverPartnerLat, widget.deliverPartnerLng);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(20, 20)), deliveryImage)
        .then((onValue) {
      myIcon = onValue;
    });
    initializeService();
    getDirections();
    super.initState();
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    service.on('stopService').listen((event) async {
      await FlutterLocalNotificationsPlugin().cancelAll();
      service.stopSelf();
    });

    service.on('initiateLocation').listen((event) {
      print('initiateLocation--------${event?['ongoingDeliveries']}');
    });

    // bring to foreground
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      DeliverTrackScreenState().orderController.getLatLng();
      /*  final deliveryList =
          _DeliveriesTabState().deliveryController.deliveryList;
      if (deliveryList.isEmpty) {
        _DeliveriesTabState().deliveryController.getOngoingDeliveryList();
      }

      deliveryList.forEach((item) async {
        if (item['status_details'] == 'SHIPPED') {
          print('${item['status_details']}----------${item['id']}');
          _DeliveriesTabState()._getCurrentPosition(item);
        }
      }); */
    });
  }

  getDirections() async {
    print("pointer abcd");
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(widget.dropLat, widget.dropLng),
      PointLatLng(widget.deliverPartnerLat, widget.deliverPartnerLng),
      travelMode: TravelMode.driving,
    );
    print("pointer ${result.points}");
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    _getMap(),
                    Padding(
                      padding: EdgeInsets.only(top: 40.0.sp, left: 10.sp),
                      child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Image.asset(
                            backWhiteArrow,
                            height: 16.sp,
                            width: 16.sp,
                            color: colorPrimary,
                          )),
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget _getMap() {
    return GoogleMap(
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
      polylines: Set<Polyline>.of(polylines.values),
      initialCameraPosition: CameraPosition(
        target: dropLatLng,
        zoom: 15.0,
      ),
      markers: getmarkers(),
      mapType: MapType.normal,
      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
    );
  }

  Set<Marker> getmarkers() {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(dropLatLng.toString()),
        position: dropLatLng,
        infoWindow: InfoWindow(
          title: 'Drop Location',
          // snippet: 'Drop Location',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));

      markers.add(Marker(
        markerId: MarkerId(deliveryPatnerLatLng.toString()),
        position: deliveryPatnerLatLng, //position of marker
        infoWindow: InfoWindow(
          title: 'Delivery Partner Location',
          //  snippet: 'Partner Location',
        ),
        icon: myIcon,
      ));
    });

    return markers;
  }
}
