import 'package:maps_core/maps/models/models.dart';

class ViewPort {
  final LatLng? northeast;
  final LatLng? southwest;

  ViewPort({this.northeast, this.southwest});

  factory ViewPort.fromJson(Map<String, dynamic>? json) {
    final LatLng? northeast = json?['northeast'] != null
        ? LatLng.fromJson(json?['northeast'])
        : (json?['high'] != null ? LatLng.fromJson(json?['high']) : null);
    final LatLng? southwest = json?['southwest'] != null
        ? LatLng.fromJson(json?['southwest'])
        : (json?['low'] != null ? LatLng.fromJson(json?['low']) : null);
    return ViewPort(northeast: northeast, southwest: southwest);
  }

  Map<String, dynamic> toJson() {
    return {
      'northeast': northeast?.toJson(),
      'southwest': southwest?.toJson(),
    };
  }
}
