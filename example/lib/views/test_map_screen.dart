import 'package:flutter/material.dart';
import 'package:map_core_example/views/test_shapes.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';

class TestMapScreen extends StatefulWidget {
  static String routeName = "/test-map";

  const TestMapScreen({Key? key}) : super(key: key);

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  CoreMapController? _controller;

  CoreMapType _type = CoreMapType.google;

  bool showMarker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () async {
              setState(() {
                showMarker = !showMarker;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.slideshow),
            onPressed: () async {
              _controller?.showInfoWindow(const MarkerId("test1"));
            },
          ),
          IconButton(
            icon: const Icon(Icons.abc),
            onPressed: () async {
              _controller?.animateCameraToCenterOfPoints([
                const LatLng(9.50184, 105.26001),
                const LatLng(9.14554, 105.15764),
                const LatLng(9.22674, 105.45377),
              ], 0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
                  _controller?.animateCamera(CameraUpdate.newLatLngZoom(const LatLng(10.867235213747376, 106.63784199919601), 20), duration: 1);
            },
          ),
        ],
      ),
      body: SizedBox(
        child: CoreMap(
          type: _type,
          data: CoreMapData(
            ggMapAccessToken: "",
            provider: MapProviderConst.GOOGLE,
            markerAllowOverlap: true,
            initialCameraPosition: CameraPosition(
                target: const LatLng(9.85419858085518, 105.49970250115466),
                zoom: 7),
            compassEnabled: true,
            myLocationEnabled: true,
            zoomInButtonData: CoreMapButtonCustomizeData(
                icon: const Icon(Icons.reddit, ),
                color: Colors.yellow.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(4),
                ),
            ),
            zoomOutButtonData: CoreMapButtonCustomizeData(
              icon: const Icon(Icons.bluetooth),
              color: Colors.yellow.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            zoomButtonDividerColor: Colors.grey,
            zoomButtonDividerThickness: 1,
            zoomButtonEnabled: true,
          ),
          callbacks: CoreMapCallbacks(
            onMapCreated: (controller) {
              _controller = controller;
            },
            onCameraMove: (position) {
              // Log.d("onCameraMove", position.toString() + (_controller?.getCurrentPosition().toString() ?? ""));
            },
            // onCameraIdle: () => Log.d("onCameraIdle", ""),
            // onCameraMoveStarted: () => Log.d("onCameraMovingStarted", ""),
            onTap: (latLng) {
              Log.d("onTap", latLng.toString());
            },
            onLongPress: (latLng) {
              Log.d("onLongPress", latLng.toString());
            }, onCameraIdle: () {
            // Log.d("CameraIdle", "camera idle");
          },
          ),
          shapes: CoreMapShapes(
            polygons: {polygon1()},
            circles: {circle()},
            markers: showMarker? {marker(), marker2(), marker3()}: {},
            polylines: {polyline(), polyline2()},
          ),
        ),
      ),
    );
  }

  void findRoute() {}
}
