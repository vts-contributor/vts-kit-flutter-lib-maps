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
        const CameraPosition(target: LatLng(11.3726, 108.9519),zoom: 7),

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
        myLocationEnabled: true,
        myLocationRenderMode: MyLocationRenderMode.COMPASS,
        myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
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
    final _stop1 = WayPoint(
        name: "Way Point 2",
        latitude: 16.065423,
        longitude: 108.188714);
    final _origin = WayPoint(
        name: "Way Point 1",
        latitude: 16.059761,
        longitude: 108.211771);

    wayPoints.add(_origin);
    wayPoints.add(_stop1);

    controller?.startNavigation(
        wayPoints: wayPoints,
        options: VTMapOptions(
            access_token: '49013166841fe36d7fa7f395fce4a663',
            mode:
            VTMapNavigationMode.driving,
            simulateRoute: true,
            language: "vi"));
  }
}
