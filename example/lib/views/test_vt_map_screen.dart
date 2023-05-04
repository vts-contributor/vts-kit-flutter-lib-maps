import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

class TestVTMapScreen extends StatefulWidget {

  static String routeName = "/test-vt-map";

  const TestVTMapScreen({Key? key}) : super(key: key);

  @override
  State<TestVTMapScreen> createState() => _TestVTMapScreenState();
}

class _TestVTMapScreenState extends State<TestVTMapScreen> {
  MapboxMapController? controller;
  LatLng firstPoint = const LatLng(8.848028919141523, 104.96513564005897);
  LatLng secondPoint = const LatLng(10.844372, 106.673161);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await controller?.addImage("123", await rootBundle.loadImageAsUint8List("assets/custom_marker.png"));

                await controller?.addSymbol(SymbolOptions(
                  iconImage: "123",
                  geometry: const LatLng(8.848028919141523, 104.96513564005897)
                ));
              }
          )
        ],
      ),
      body: VTMap(
        accessToken: "49013166841fe36d7fa7f395fce4a663",
        initialCameraPosition:
        CameraPosition(
            target: firstPoint, zoom: 7),

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
        compassViewMargins: const Point(100, 100),
        compassViewPosition: CompassViewPosition.TopLeft,
        logoEnabled: false,
      ),
    );
  }

  void navigate() {
    List<WayPoint> wayPoints = [];
    LatLng firstPoint = const LatLng(10.836879731223707, 106.68931830464587);
    LatLng secondPoint = const LatLng(10.875063025053082, 106.62863270883156);

    final stop1 = WayPoint(
        name: "Way Point 2",
        latitude: secondPoint.latitude,
        longitude: secondPoint.longitude);
    final origin = WayPoint(
        name: "Way Point 1",
        latitude: firstPoint.latitude,
        longitude: firstPoint.longitude);

    wayPoints.add(origin);
    wayPoints.add(stop1);

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
