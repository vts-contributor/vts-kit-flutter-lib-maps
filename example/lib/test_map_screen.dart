import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
              (await _controllerCompleter.controller).addPolygon(polygon1());
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

  Polygon polygon1() {
    List<LatLng> polygonCoords = [];
    polygonCoords.addAll([
      LatLng(9.85419858085518, 105.49970250115466),
      LatLng(10.111173278744552, 105.79221346758048),
      LatLng(9.739171049977948, 106.4115676734868),
      LatLng(9.408755662724216, 106.01194001513039),
      LatLng(9.148388064993938, 105.04703715806114),
    ]);

    return Polygon(
        polygonId: 'test1',
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
        strokeColor: Colors.red);
  }

  Polygon polygon2() {
    List<LatLng> polygonCoords = [];
    polygonCoords.addAll([
      LatLng(9.85419858085518, 105.49970250115466),
      LatLng(10.111173278744552, 105.79221346758048),
      LatLng(9.739171049977948, 106.4115676734868),
      LatLng(9.408755662724216, 106.01194001513039),
      LatLng(9.148388064993938, 105.04703715806114),
    ]);

    return Polygon(
        polygonId: 'test2',
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
        strokeColor: Colors.red);
  }
}
