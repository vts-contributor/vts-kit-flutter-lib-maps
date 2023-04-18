
import 'package:flutter/foundation.dart';

import '../../../log/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

class LatLng {
  final double lat;
  final double lng;

  /// The [lat] from -90.0 to +90.0.
  ///
  /// The [lng] from -180.0 to +180.0.
  const LatLng(double lat, double lng):
        lat = (lat < -90.0 ? -90.0 : (90.0 < lat ? 90.0 : lat)),
        lng = (lng + 180.0) % 360.0 - 180.0;

  /// The [latLngMap] structured {lat: ..., lng: ...}
  ///
  /// The [lat] from -90.0 to +90.0.
  ///
  /// The [lng] from -180.0 to +180.0.
  factory LatLng.fromMap(Map latLngMap, {bool receiveNow = false}) {
    try {
      return LatLng(latLngMap['lat'], latLngMap['lng']);
    } catch (err) {
      Log.e('LatLng.fromMap',
          'Parse LatLng from Map $latLngMap failed because $err');
      return LatLng.defaultInvalid();
    }
  }

  factory LatLng.defaultInvalid() {
    //constructor will set lat=0.0, lng=0.0
    return const LatLng(-91, -181);
  }

  static LatLng? fromMapsAPIJson(Map<String, dynamic>? json) {
    final double? lat = json?['lat'];
    final double? lng = json?['lng'];
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  @override
  String toString() => '{lat:$lat, lng:$lng}';

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lng": lng
    };
  }
  
  /// Initialize a LatLng from an \[lat, lng\] array.
  static LatLng? fromJson(Map<String, dynamic>? json) {
    if (json != null && json.containsKey("lat") == true && json.containsKey("lng") == true) {
      return LatLng(json["lat"], json["lng"]);
    } else {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is LatLng &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode => Object.hash(lat, lng);

  ggmap.LatLng toGoogle() {
    return ggmap.LatLng(lat, lng);
  }

  vtmap.LatLng toViettel() {
    return vtmap.LatLng(lat, lng);
  }
}


/// A lat/lng aligned rectangle.
///
/// The rectangle conceptually includes all points (lat, lng) where
/// * lat ∈ [`southwest.lat`, `northeast.lat`]
/// * lng ∈ [`southwest.lng`, `northeast.lng`],
///   if `southwest.lng` ≤ `northeast.lng`,
/// * lng ∈ [-180, `northeast.lng`] ∪ [`southwest.lng`, 180],
///   if `northeast.lng` < `southwest.lng`
@immutable
class LatLngBounds {
  /// Creates geographical bounding box with the specified corners.
  ///
  /// The lat of the southwest corner cannot be larger than the
  /// lat of the northeast corner.
  LatLngBounds({required this.southwest, required this.northeast})
      : assert(southwest.lat <= northeast.lat);

  /// The southwest corner of the rectangle.
  final LatLng southwest;

  /// The northeast corner of the rectangle.
  final LatLng northeast;

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    return <Object>[southwest.toJson(), northeast.toJson()];
  }

  /// Returns whether this rectangle contains the given [LatLng].
  bool contains(LatLng point) {
    return _containslat(point.lat) &&
        _containslng(point.lng);
  }

  bool _containslat(double lat) {
    return (southwest.lat <= lat) && (lat <= northeast.lat);
  }

  bool _containslng(double lng) {
    if (southwest.lng <= northeast.lng) {
      return southwest.lng <= lng && lng <= northeast.lng;
    } else {
      return southwest.lng <= lng || lng <= northeast.lng;
    }
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'LatLngBounds')}($southwest, $northeast)';
  }

  @override
  bool operator ==(Object other) {
    return other is LatLngBounds &&
        other.southwest == southwest &&
        other.northeast == northeast;
  }

  @override
  int get hashCode => Object.hash(southwest, northeast);

  ggmap.LatLngBounds toGoogle() {
    return ggmap.LatLngBounds(
      northeast: northeast.toGoogle(),
      southwest: southwest.toGoogle(),
    );
  }

  vtmap.LatLngBounds toViettel() {
    return vtmap.LatLngBounds(
      northeast: northeast.toViettel(),
      southwest: southwest.toViettel(),
    );
  }
}

