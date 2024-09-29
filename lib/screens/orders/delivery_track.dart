// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
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
    super.initState();
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
                      padding: const EdgeInsets.only(top: 40.0, left: 10),
                      child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Image.asset(
                            backWhiteArrow,
                            height: 16,
                            width: 16,
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
