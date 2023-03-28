
import 'package:flutter/foundation.dart';

import '../../../log/log.dart';

class LatLng {
  late final double lat;
  late final double lng;
  late final bool isValid;
  int? _receiveTimestamp;
  final bool isDefault;

  int? get receiveTimestamp => _receiveTimestamp;

  /// The [lat] from -90.0 to +90.0.
  ///
  /// The [lng] from -180.0 to +180.0.
  LatLng(double lat, double lng,
      {bool receiveNow = false, this.isDefault = false}) {
    if (-90 > lat || lat > 90 || -180 > lng || lng > 180) {
      isValid = false;
      this.lat = 0.0;
      this.lng = 0.0;
    } else {
      isValid = true;
      this.lat = lat;
      this.lng = lng;
    }
    if (receiveNow) {
      _receiveTimestamp = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// The [latLngMap] structured {lat: ..., lng: ...}
  ///
  /// The [lat] from -90.0 to +90.0.
  ///
  /// The [lng] from -180.0 to +180.0.
  factory LatLng.fromMap(Map latLngMap, {bool receiveNow = false}) {
    try {
      return LatLng(latLngMap['lat'], latLngMap['lng'], receiveNow: receiveNow);
    } catch (err) {
      Log.e('LatLng.fromMap',
          'Parse LatLng from Map $latLngMap failed because $err');
      return LatLng.defaultInvalid();
    }
  }

  factory LatLng.defaultInvalid() {
    //constructor will set lat=0.0, lng=0.0
    return LatLng(-91, -181);
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
  static LatLng? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is List && json.length == 2);
    final List<Object?> list = json as List<Object?>;
    return LatLng(list[0]! as double, list[1]! as double);
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
      : assert(southwest != null),
        assert(northeast != null),
        assert(southwest.lat <= northeast.lat);

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

  /// Converts a list to [LatLngBounds].
  @visibleForTesting
  static LatLngBounds? fromList(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is List && json.length == 2);
    final List<Object?> list = json as List<Object?>;
    return LatLngBounds(
      southwest: LatLng.fromJson(list[0])!,
      northeast: LatLng.fromJson(list[1])!,
    );
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
}

