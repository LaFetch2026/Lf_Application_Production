// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    getDirections();
    super.initState();
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
