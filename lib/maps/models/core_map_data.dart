import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps/models/camera_position.dart';
import 'package:maps_core/maps/models/polygon.dart';

///State of the map
class CoreMapData {

  CoreMapData({
    this.accessToken,
    required this.initialCameraPosition,
    List<Polygon>? polygons,
  }): polygons = polygons ?? [];

  ///should be removed, use file instead
  final String? accessToken;

  final CameraPosition initialCameraPosition;

  final List<Polygon> polygons;

  CoreMapData copyWith() {
    return CoreMapData(
      accessToken: accessToken,
      initialCameraPosition: initialCameraPosition,
    );
  }
}