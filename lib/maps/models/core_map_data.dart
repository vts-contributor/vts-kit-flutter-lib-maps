import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/models/camera_position.dart';
import 'package:maps_core/maps/models/map_objects/polygon.dart';

///State of the map
class CoreMapData {

  CoreMapData({
    this.accessToken,
    required this.initialCameraPosition,
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    Set<Circle>? circles,
  }): polygons = polygons ?? {},
        polylines = polylines ?? {},
        circles = circles ?? {},
        markers = markers ?? {};

  ///should be removed, use file instead
  final String? accessToken;

  final CameraPosition initialCameraPosition;

  final Set<Polygon> polygons;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final Set<Marker> markers;

  CoreMapData copyWith({
    String? accessToken,
    CameraPosition? initialCameraPosition,
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    Set<Circle>? circles,
  }) {
    return CoreMapData(
      accessToken: accessToken ?? this.accessToken,
      initialCameraPosition: initialCameraPosition ?? this.initialCameraPosition,
      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
    );
  }
}