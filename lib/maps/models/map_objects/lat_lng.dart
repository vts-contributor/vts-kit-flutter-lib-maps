
import 'package:flutter/foundation.dart';

import '../../../log/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

class LatLng {
  final double latitude;
  final double longitude;

  /// The [lat] from -90.0 to +90.0.
  ///
  /// The [lng] from -180.0 to +180.0.
  const LatLng(double lat, double lng):
        latitude = (lat < -90.0 ? -90.0 : (90.0 < lat ? 90.0 : lat)),
        longitude = (lng + 180.0) % 360.0 - 180.0;

  /// The [latLngMap] structured {lat: ..., lng: ...}
  ///
  /// The [latitude] from -90.0 to +90.0.
  ///
  /// The [longitude] from -180.0 to +180.0.
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
  String toString() => '{lat:$latitude, lng:$longitude}';

  Map<String, dynamic> toJson() {
    return {
      "lat": latitude,
      "lng": longitude
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
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  ggmap.LatLng toGoogle() {
    return ggmap.LatLng(latitude, longitude);
  }

  vtmap.LatLng toViettel() {
    return vtmap.LatLng(latitude, longitude);
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
      : assert(southwest.latitude <= northeast.latitude);

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
    return _containslat(point.latitude) &&
        _containslng(point.longitude);
  }

  bool _containslat(double lat) {
    return (southwest.latitude <= lat) && (lat <= northeast.latitude);
  }

  bool _containslng(double lng) {
    if (southwest.longitude <= northeast.longitude) {
      return southwest.longitude <= lng && lng <= northeast.longitude;
    } else {
      return southwest.longitude <= lng || lng <= northeast.longitude;
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

