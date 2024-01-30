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

extension LatLngDistanceHelper on LatLng {
  double getDistanceFrom(LatLng other) {
    return _calculateDistance(latitude, longitude, other.latitude, other.longitude);
  }

  double _calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}

extension ListLatLngDistanceHeler on List<LatLng> {
  double getTotalDistance() {
    double distance = 0;
    for (int i = 0; i < length - 1; i++) {
      distance += this[i].getDistanceFrom(this[i + 1]);
    }
    return distance;
  }
}