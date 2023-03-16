import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestGoogleMapScreen extends StatefulWidget {

  static String routeName = "/test-google-map";

  const TestGoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<TestGoogleMapScreen> createState() => _TestGoogleMapScreenState();
}

class _TestGoogleMapScreenState extends State<TestGoogleMapScreen> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  Set<Polygon> myPolygon() {
    List<LatLng> polygonCoords = [];
    polygonCoords.addAll([
      LatLng(9.85419858085518, 105.49970250115466),
      LatLng(10.111173278744552, 105.79221346758048),
      LatLng(9.739171049977948, 106.4115676734868),
      LatLng(9.408755662724216, 106.01194001513039),
      LatLng(9.148388064993938, 105.04703715806114),
    ]);


    Set<Polygon> polygonSet = Set();
    polygonSet.add(Polygon(
        polygonId: PolygonId('test'),
        points: polygonCoords,
        holes: [
          [
            LatLng(9.749998867791605, 105.59033970201901),
            LatLng(9.605997144751647, 105.67252492760872),
            LatLng(9.575401419508188, 105.58270292414889)
          ],
          [
            LatLng(9.861925859419564, 105.93872468331696),
            LatLng(9.776638107960828, 106.03507919611933),
            LatLng(9.683279273763315, 105.85380206186403)
          ],
        ],
        strokeColor: Colors.red));

    return polygonSet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final GoogleMapController controller = await _controller.future;
              }
          )
        ],
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        polygons: myPolygon(),
        initialCameraPosition: const CameraPosition(target: LatLng(9.823077422713277, 105.81830599510204),zoom: 8),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
