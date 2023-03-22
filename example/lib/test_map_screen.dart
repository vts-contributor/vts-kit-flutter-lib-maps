import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:map_core_example/test_shapes.dart';
import 'package:maps_core/maps/controllers/core_map_controller.dart';
import 'package:maps_core/maps/controllers/core_map_controller_completer.dart';
import 'package:maps_core/maps/models/camera_position.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/core_map_data.dart';
import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/lat_lng.dart';
import 'package:maps_core/maps/models/polygon.dart';
import 'package:maps_core/maps/views/core_map.dart';

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
            }
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
        )
      ],
    );
  }
  
}
