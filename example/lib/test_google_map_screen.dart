import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_core_example/test_shapes.dart';
import 'package:maps_core/log/log.dart';

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

  Polyline polyline() => Polyline(
    polylineId: PolylineId("test2"),
    points: [
      LatLng(10.015567019306467, 105.74686134987519),
      LatLng(10.19612670788822, 105.97871325750828),
      LatLng(10.651704727581484, 106.2319038895347),
      LatLng(10.781534156930388, 107.0149202769658),
      LatLng(11.447301198223213, 107.27501155457392),
    ],
    endCap: Cap.roundCap,
    startCap: Cap.roundCap,
    jointType: JointType.bevel,
    patterns: [
      PatternItem.gap(1000),
      PatternItem.dash(1000)
    ],
    width: 10
  );

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
        mapType: MapType.normal,
        // polygons: myPolygon(),
        initialCameraPosition: const CameraPosition(target: LatLng(10, 100),zoom: 8),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        polylines: {polyline()},
        circles: {Circle(circleId: CircleId("test2123"),
            center: LatLng(8.848028919141523, 104.96513564005897),
            radius: 10000,
            strokeColor: Colors.red,
            strokeWidth: 5,
            fillColor: Colors.black
        )},
        onTap: (pos) {
          Log.d("GOOGLEMAP", pos.toString());
        },
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: true,
      ),
    );
  }
}
