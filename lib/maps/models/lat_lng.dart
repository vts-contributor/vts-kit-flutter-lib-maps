import 'package:flutter_core/log/log.dart';

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
}
