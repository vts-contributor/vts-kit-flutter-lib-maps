import 'package:flutter/material.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/models/models.dart';

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
      id: 'test1',
      points: polygonCoords,
      strokeWidth: 10,
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
      strokeColor: Colors.red,
      onTap: () {
        Log.d("Polygon", "onTap");
      }
  );
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
      id: 'test2',
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
      strokeColor: Colors.red,
      onTap: () {
        Log.d("Polygon", "onTap");
      }
  );
}

Polyline polyline() => Polyline(
    id: "test1",
    points: [
      LatLng(10.015567019306467, 105.74686134987519),
      LatLng(10.19612670788822, 105.97871325750828),
      LatLng(10.651704727581484, 106.2319038895347),
      LatLng(10.781534156930388, 107.0149202769658),
      LatLng(11.447301198223213, 107.27501155457392),
    ],
    jointType: JointType.bevel,
    color: Colors.blue,
    onTap: () {
      Log.d("Polyline", "onTap");
    }
);

Circle circle() => Circle(
  id: "test1",
  center: LatLng(8.848028919141523, 104.96513564005897),
  radius: 100000,
  strokeColor: Colors.red,
  strokeWidth: 5,
  fillColor: Colors.black,
  onTap: () {
    Log.d("Circle", "onTap");
  }
);

Marker marker() => Marker(
  id: "test1",
  position: LatLng(8.848028919141523, 104.96513564005897),
  infoWindow: InfoWindow(
    title: "Test"
  ),
  // icon: MarkerIcon.fromAsset("marker icon", "assets/custom_marker.png"),
  // icon: MarkerIcon.fromNetwork("marker network image", "https://cdn-icons-png.flaticon.com/512/25/25613.png")
);
