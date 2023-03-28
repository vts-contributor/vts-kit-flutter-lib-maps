import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_core_example/test_shapes.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/controllers/core_map_controller_completer.dart';

class TestMapScreen extends StatefulWidget {
  
  static String routeName = "/test-map";
  
  const TestMapScreen({Key? key}) : super(key: key);

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {

  CoreMapControllerCompleter _controllerCompleter = CoreMapControllerCompleter();

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () async {
              final controller = await _controllerCompleter.controller;
              controller.changeMapType(controller.coreMapType == CoreMapType.viettel?CoreMapType.google: CoreMapType.viettel);
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final controller = await _controllerCompleter.controller;
              showDialog(
                context: context,
                builder: (context) {
                  return TestDialog(
                    controller: controller,
                  );
                }
              );
            },
          ),
        ],
      ),
      body: CoreMap(
        initialType: CoreMapType.viettel,
        initialData: CoreMapData(
          accessToken: "49013166841fe36d7fa7f395fce4a663",
          initialCameraPosition: CameraPosition(target: LatLng(9.85419858085518, 105.49970250115466), zoom: 7),
        ),
        callbacks: CoreMapCallbacks(
          onMapCreated: (controller) {
            _controllerCompleter.complete(controller);
          },
          onCameraMove: (position) {
            Log.d("onCameraMove", position.toString());
          },
          onCameraIdle: () => Log.d("onCameraMove", ""),
          onCameraMoveStarted: () => Log.d("onCameraMovingStarted", ""),
        ),
      ),
    );
  }
}

class TestDialog extends StatelessWidget {
  final CoreMapController controller;

  const TestDialog({super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Test features"),
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            ElevatedButton(onPressed: () {
              controller.addPolygon(polygon1());
            }, child: Text("add a polygon")),
            SizedBox(width: 10,),
            IconButton(onPressed: () {
              controller.removePolygon(polygon1().id);
            }, icon: Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () {
              controller.addPolyline(polyline());
            }, child: Text("add a polyline")),
            SizedBox(width: 10,),
            IconButton(onPressed: () {
              controller.removePolyline(polyline().id);
            }, icon: Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () {
              controller.addCircle(circle());
            }, child: Text("add a circle")),
            SizedBox(width: 10,),
            IconButton(onPressed: () {
              controller.removeCircle(circle().id);
            }, icon: Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () {
              controller.addMarker(marker());
            }, child: Text("add a marker")),
            SizedBox(width: 10,),
            IconButton(onPressed: () {
              controller.removeMarker(marker().id);
            }, icon: Icon(Icons.delete),)
          ],
        ),
        Row(
          children: [
            ElevatedButton(onPressed: () async {
              Log.d("getScreenCoordinate",
                  (await controller.getScreenCoordinate(
                      LatLng(9.75419858085518, 105.59970250115466))
                  ).toString());
            }, child: Text("Log screen coordinate")),
            SizedBox(width: 10,),
          ],
        )
      ],
    );
  }


}
