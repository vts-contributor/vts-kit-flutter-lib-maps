import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_core_example/views/test_shapes.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart' as mt;
import 'package:maps_core/maps/models/map_objects/marker_icon_data_factory.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

class TestVTMapScreen extends StatefulWidget {
  static String routeName = "/test-vt-map";

  const TestVTMapScreen({Key? key}) : super(key: key);

  @override
  State<TestVTMapScreen> createState() => _TestVTMapScreenState();
}

class _TestVTMapScreenState extends State<TestVTMapScreen> {
  MapboxMapController? controller;
  LatLng firstPoint = const LatLng(10.844372, 106.673161);
  LatLng secondPoint = const LatLng(10.844372, 106.673161);
  double height = 400;

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                controller?.addSymbol(marker().toSymbolOptions());
                controller?.onSymbolTapped.add((argument) {
                  log("on symbol tapped");
                });
              })
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 500,
            child: VTMap(
              accessToken: "ad903093bbefba04624d5e742e155e30",
              initialCameraPosition: CameraPosition(target: firstPoint, zoom: 7),
              onMapCreated: (controller) {
                this.controller = controller;
              },
              onStyleLoadedCallback: () async {
                mt.Marker marker1 = marker();
                Uint8List bitmap = await marker1.icon.data.initResource(MarkerIconDataFactory());
                controller?.addImage(marker1.icon.data.name, bitmap);
                controller?.addSymbol(marker1.toSymbolOptions());
                controller?.onSymbolTapped.add((argument) {
                  Log.d("VTMAP", "onSymbol");

                  setState(() {
                    count++;
                  });
                });
              },
              onCameraTrackingChanged: (mode) {
                Log.d("VTMAP", "onCameraTrackingChanged: ${mode.toString()}");
              },
              onCameraMovingStarted: () {
                Log.d("VTMAP",
                    "onCameraMovingStarted: ${controller?.cameraPosition?.target.toString()}");
              },
              onCameraIdle: () {
                Log.d("VTMAP", "onCameraIdle: ${controller?.cameraPosition?.target.toString()}");
              },
              onCameraTrackingDismissed: () {
                Log.d("VTMAP",
                    "onCameraTrackingDismissed: ${controller?.cameraPosition?.target.toString()}");
              },
              myLocationEnabled: false,
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
              myLocationTrackingMode: MyLocationTrackingMode.None,
              gpsControlEnable: false,
              trackCameraPosition: false,
              compassEnabled: false,
              logoEnabled: false,
            ),
          ),
          const SizedBox(height: 50),
          Text("On tap marker: $count"),
        ],
      ),
    );
  }

  void navigate() {
    List<WayPoint> wayPoints = [];
    LatLng firstPoint = const LatLng(10.836879731223707, 106.68931830464587);
    LatLng secondPoint = const LatLng(10.875063025053082, 106.62863270883156);

    final stop1 = WayPoint(
        name: "Way Point 2", latitude: secondPoint.latitude, longitude: secondPoint.longitude);
    final origin = WayPoint(
        name: "Way Point 1", latitude: firstPoint.latitude, longitude: firstPoint.longitude);

    wayPoints.add(origin);
    wayPoints.add(stop1);

    controller?.buildRoute(
        wayPoints: wayPoints,
        options: VTMapOptions(
            access_token: '',
            alternatives: true,
            mode: VTMapNavigationMode.cycling,
            simulateRoute: true,
            language: "vi"));
  }
}
