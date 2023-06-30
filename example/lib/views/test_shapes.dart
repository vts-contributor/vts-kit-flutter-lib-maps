import 'package:flutter/material.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/models/models.dart';

Polygon polygon1() {
  List<LatLng> polygonCoords = [];
  polygonCoords.addAll([
    const LatLng(9.85419858085518, 105.49970250115466),
    const LatLng(10.111173278744552, 105.79221346758048),
    const LatLng(9.739171049977948, 106.4115676734868),
    const LatLng(9.408755662724216, 106.01194001513039),
    const LatLng(9.148388064993938, 105.04703715806114),
    // LatLng(10.716637841384983, 105.63506199738214),
  ]);

  return Polygon(
      id: const PolygonId('test1'),
      points: polygonCoords,
      strokeWidth: 20,
      zIndex: 0,
      holes: [
        [
          const LatLng(9.749998867791605, 105.59033970201901),
          const LatLng(9.605997144751647, 105.67252492760872),
          const LatLng(9.575401419508188, 105.58270292414889)
        ],
        [
          const LatLng(9.861925859419564, 105.93872468331696),
          const LatLng(9.776638107960828, 106.03507919611933),
          const LatLng(9.683279273763315, 105.85380206186403)
        ],
      ],
      fillColor: Colors.black,
      strokeColor: Colors.yellow,
      onTap: () {
        Log.d("Polygon", "onTap");
      }
  );
}

Polygon polygon2() {
  List<LatLng> polygonCoords = [];
  polygonCoords.addAll([
    const LatLng(9.85419858085518, 105.49970250115466),
    const LatLng(10.111173278744552, 105.79221346758048),
    const LatLng(9.739171049977948, 106.4115676734868),
    const LatLng(9.408755662724216, 106.01194001513039),
    const LatLng(9.148388064993938, 105.04703715806114),
  ]);

  return Polygon(
      id: const PolygonId('test2'),
      points: polygonCoords,
      holes: [
        [
          const LatLng(9.749998867791605, 105.59033970201901),
          const LatLng(9.605997144751647, 105.67252492760872),
          const LatLng(9.575401419508188, 105.58270292414889)
        ],
        [
          const LatLng(9.861925859419564, 105.93872468331696),
          const LatLng(9.776638107960828, 106.03507919611933),
          const LatLng(9.683279273763315, 105.85380206186403)
        ],
      ],
      fillColor: Colors.black,
      strokeColor: Colors.yellow,
      onTap: () {
        Log.d("Polygon", "onTap");
      }
  );
}

Polyline polyline() => Polyline(
    id: const PolylineId("test1"),
    points: const [
      LatLng(10.015567019306467, 105.74686134987519),
      LatLng(10.19612670788822, 105.97871325750828),
      LatLng(10.651704727581484, 106.2319038895347),
      LatLng(10.781534156930388, 107.0149202769658),
      LatLng(11.447301198223213, 107.27501155457392),
    ],
    zIndex: 1,
    jointType: JointType.round,
    color: Colors.blue,
    onTap: () {
      Log.d("Polyline", "onTap");
    }
);

Polyline polyline2() => Polyline(
    id: const PolylineId("test2"),
    points: const [
      LatLng(10.015567019306467, 105.74686134987519),
      LatLng(10.19612670788822, 105.97871325750828),
      LatLng(10.651704727581484, 106.2319038895347),
      LatLng(11.447301198223213, 107.27501155457392),
    ],
    zIndex: 0,
    jointType: JointType.round,
    color: Colors.red,
    onTap: () {
      Log.d("Polyline", "onTap");
    }
);


Circle circle() => Circle(
  id: const CircleId("123"),
  center: const LatLng(8.848028919141523, 104.96513564005897),
  radius: 10000,
  strokeColor: Colors.blue,
  strokeWidth: 10,
  zIndex: 0,
  fillColor: Colors.red,
  onTap: () {
    Log.d("Circle", "onTap");
  },
);

Marker marker() => Marker(
  id: const MarkerId("test1"),
  // position: LatLng(10.625380787927542, 105.051574201898),
  position: const LatLng(8.848028919141523, 104.96513564005897),
  alpha: 1,
  zIndex: 0,
  draggable: true,
  infoWindow: InfoWindow(
    widget: Container(
      child: Text("123"),
      height: 100,
      width: 100,
      color: Colors.red,
    )
  ),
  icon: MarkerIcon.fromWidget("widget1", Container(
    color: Colors.blue,
    child: Image.asset("assets/custom_marker.png"),
    height: 100,
    width: 100,
  )),
  // icon: MarkerIcon.fromAsset("marker icon", "assets/custom_marker.png"),
  // icon: MarkerIcon.fromNetwork("marker network image", "https://cdn-icons-png.flaticon.com/512/25/25613.png")
);
