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


class _RADII {
  int km;
  int mile;
  int meter;
  int nmi;

  _RADII(this.km, this.mile, this.meter, this.nmi);
}

enum _Unit { KM, MILE, METER, NMI }

class _HaversineDistance {
  final _RADII radii = new _RADII(6371, 3960, 6371000, 3440);

  double toRad(double num) {
    return num * pi / 180;
  }

  int getUnit(_Unit unit) {
    switch (unit) {
      case (_Unit.KM):
        return radii.km;
      case (_Unit.MILE):
        return radii.mile;
      case (_Unit.METER):
        return radii.meter;
      case (_Unit.NMI):
        return radii.nmi;
      default:
        return radii.km;
    }
  }

  double haversine(
      LatLng startCoordinates, LatLng endCoordinates, _Unit unit) {
    final R = getUnit(unit);
    final dLat = toRad(endCoordinates.latitude - startCoordinates.latitude);
    final dLon = toRad(endCoordinates.longitude - startCoordinates.longitude);
    final lat1 = toRad(startCoordinates.latitude);
    final lat2 = toRad(endCoordinates.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}

extension LatLngDistanceHelper on LatLng {
  double getDistanceFrom(LatLng other) {
    return _HaversineDistance().haversine(this, other, _Unit.METER);
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