import 'package:flutter/material.dart';
import 'package:map_core_example/views/test_shapes.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';

class TestMapScreen extends StatefulWidget {
  static String routeName = "/test-map";

  const TestMapScreen({Key? key}) : super(key: key);

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  CoreMapController? _controller;

  CoreMapType _type = CoreMapType.viettel;

  bool showMarker = false;

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context);
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
              _controller?.showInfoWindow(MarkerId("test1"));
            },
          ),
          IconButton(
            icon: const Icon(Icons.abc),
            onPressed: () async {
              _controller?.animateCameraToCenterOfPoints([
                LatLng(9.50184, 105.26001),
                LatLng(9.14554, 105.15764),
                LatLng(9.22674, 105.45377),
              ], 0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () async {
              setState(() {
                _type = _type == CoreMapType.viettel
                    ? CoreMapType.google
                    : CoreMapType.viettel;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
                  _controller?.animateCamera(CameraUpdate.newLatLng(LatLng(13.199416385789831, 108.46161682049204)), duration: 1);
            },
          ),
        ],
      ),
      body: SizedBox(
        child: CoreMap(
          type: _type,
          data: CoreMapData(
            accessToken: "49013166841fe36d7fa7f395fce4a663",
            initialCameraPosition: CameraPosition(
                target: const LatLng(9.85419858085518, 105.49970250115466),
                zoom: 7),
            compassEnabled: true,
            myLocationEnabled: true,
            zoomInButtonData: CoreMapButtonCustomizeData(
                icon: Icon(Icons.reddit, ),
                color: Colors.yellow.withOpacity(0.4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(4),
                ),
            ),
            zoomOutButtonData: CoreMapButtonCustomizeData(
              icon: Icon(Icons.bluetooth),
              color: Colors.yellow.withOpacity(0.4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            zoomButtonAlignment: Alignment.bottomRight,
            zoomButtonDividerColor: Colors.grey,
            zoomButtonDividerThickness: 1,
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
            markers: showMarker? {marker()}: {},
            polylines: {polyline(), polyline2()},
          ),
        ),
      ),
    );
  }

  void findRoute() {}
}
