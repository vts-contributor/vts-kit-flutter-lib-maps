import 'dart:math';

import 'package:collection/collection.dart';
import 'package:maps_core/maps.dart';

extension ZoomHelperExtension on CoreMapController {
  ///animate camera to center of these points with zoom level to see all of these points
  Future<void> animateCameraToCenterOfPoints(List<LatLng> points, double padding) async {
    if (points.isEmpty) return;

    List<double> latitudes = points.map((e) => e.latitude).toList();
    List<double> longitudes = points.map((e) => e.longitude).toList();

    double maxLat = latitudes.max;
    double minLat = latitudes.min;

    double maxLng = longitudes.max;
    double minLng = longitudes.min;

    animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
      northeast: LatLng(maxLat, maxLng),
      southwest: LatLng(minLat, minLng),
    ), padding));
  }
}