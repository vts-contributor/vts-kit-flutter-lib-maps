import 'dart:math';

import 'package:collection/collection.dart';
import 'package:maps_core/maps.dart';

extension ZoomHelperExtension on CoreMapController {
  ///animate camera to center of these points with zoom level to see all of these points
  Future<void> animateCameraToCenterOfPoints(List<LatLng> points, double padding, {int? duration}) async {
    if (points.isEmpty) return;
    ViewPort viewPort = points.getBounds();
    LatLng? southwest = viewPort.southwest;
    LatLng? northeast = viewPort.northeast;
    if (southwest != null && northeast != null) {
      animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        northeast: northeast,
        southwest: southwest,
      ), padding), duration: duration);
    }
  }
}