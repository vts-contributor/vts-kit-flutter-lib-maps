import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:map_core_example/views/test_shapes.dart';
import 'package:maps_core/maps.dart';

class TestSharedMarkerScreen extends StatefulWidget {
  const TestSharedMarkerScreen({super.key});

  static String routeName = "/test_shared_marker";

  @override
  State<TestSharedMarkerScreen> createState() => _TestSharedMarkerScreenState();
}

class _TestSharedMarkerScreenState extends State<TestSharedMarkerScreen> {
  final CoreMapType _type = CoreMapType.viettel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () async {
              setState(() {
                // showMarker = !showMarker;
              });
            },
          ),
        ],
      ),
      body: SizedBox(
        child: CoreMap(
          type: _type,
          data: CoreMapData(
            accessToken: "49013166841fe36d7fa7f395fce4a663",
            // markerAllowOverlap: true,
            initialCameraPosition: CameraPosition(
                target: const LatLng(10.885305387234123, 106.63943723003548),
                zoom: 10),
            compassEnabled: true,
            myLocationEnabled: true,
            zoomInButtonData: CoreMapButtonCustomizeData(
              icon: const Icon(
                Icons.reddit,
              ),
              color: Colors.yellow.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(4),
              ),
            ),
            zoomOutButtonData: CoreMapButtonCustomizeData(
              icon: const Icon(Icons.bluetooth),
              color: Colors.yellow.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            zoomButtonAlignment: Alignment.bottomRight,
            zoomButtonDividerColor: Colors.grey,
            zoomButtonDividerThickness: 1,
            markerAllowOverlap: true,
            isUseCluster: true,
          ),
          callbacks: CoreMapCallbacks(
            onMapCreated: (controller) {},
            onCameraMove: (position) {
              // Log.d("onCameraMove", position.toString() + (_controller?.getCurrentPosition().toString() ?? ""));
            },
            // onCameraIdle: () => Log.d("onCameraIdle", ""),
            onCameraMoveStarted: () => log("onCameraMovingStarted"),
            onTap: (latLng) {
              // log("onTap", latLng.toString());
            },
            onLongPress: (latLng) {
              // log("onLongPress", latLng.toString());
            },
            onCameraIdle: () {
              log("CameraIdle");
            },
          ),
          shapes: CoreMapShapes(
            markers: {marker(), marker2(), marker3()},
          ),
          custom: CoreMapCustoms(),
        ),
      ),
    );
  }
}
