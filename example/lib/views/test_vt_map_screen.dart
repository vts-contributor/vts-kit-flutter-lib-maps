import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:maps_core/maps/models/geometry.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

class TestVTMapScreen extends StatefulWidget {

  static String routeName = "/test-vt-map";

  const TestVTMapScreen({Key? key}) : super(key: key);

  @override
  State<TestVTMapScreen> createState() => _TestVTMapScreenState();
}

class _TestVTMapScreenState extends State<TestVTMapScreen> {
  MapboxMapController? controller;
  LatLng firstPoint = LatLng(10.83581439676659, 106.67246659058827);
  LatLng secondPoint = LatLng(10.844372, 106.673161);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                navigate();
              }
          )
        ],
      ),
      body: VTMap(
        accessToken: "49013166841fe36d7fa7f395fce4a663",
        initialCameraPosition:
        CameraPosition(
            target: firstPoint, zoom: 15),

        onMapCreated: (controller) {
          this.controller = controller;
        },
        onCameraTrackingChanged: (mode) {
          Log.d("VTMAP", "onCameraTrackingChanged: ${mode.toString()}");
        },
        onCameraMovingStarted: () {
          Log.d("VTMAP", "onCameraMovingStarted: ${controller?.cameraPosition?.target.toString()}");
        },
        onCameraIdle: () {
          Log.d("VTMAP", "onCameraIdle: ${controller?.cameraPosition?.target.toString()}");
        },
        onCameraTrackingDismissed: () {
          Log.d("VTMAP", "onCameraTrackingDismissed: ${controller?.cameraPosition?.target.toString()}");
        },
        myLocationEnabled: false,
        myLocationRenderMode: MyLocationRenderMode.NORMAL,
        myLocationTrackingMode: MyLocationTrackingMode.None,
        gpsControlEnable: false,
        trackCameraPosition: true,
        compassEnabled: true,
        compassViewMargins: Point(100, 100),
        compassViewPosition: CompassViewPosition.TopLeft,
        logoEnabled: false,
      ),
    );
  }

  void navigate() {
    List<WayPoint> wayPoints = [];
    LatLng firstPoint = LatLng(10.836879731223707, 106.68931830464587);
    LatLng secondPoint = LatLng(10.875063025053082, 106.62863270883156);

    final _stop1 = WayPoint(
        name: "Way Point 2",
        latitude: secondPoint.latitude,
        longitude: secondPoint.longitude);
    final _origin = WayPoint(
        name: "Way Point 1",
        latitude: firstPoint.latitude,
        longitude: firstPoint.longitude);

    wayPoints.add(_origin);
    wayPoints.add(_stop1);

    controller?.buildRoute(
        wayPoints: wayPoints,
        options: VTMapOptions(
            access_token: '49013166841fe36d7fa7f395fce4a663',
            alternatives: true,
            mode:
            VTMapNavigationMode.cycling,
            simulateRoute: true,
            language: "vi"));
  }
}
