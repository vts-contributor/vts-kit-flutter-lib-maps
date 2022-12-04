import 'package:maps_core/maps/models/models.dart';

class ViewPort {
  final LatLng? northeast;
  final LatLng? southwest;

  ViewPort({this.northeast, this.southwest});

  factory ViewPort.fromJson(Map<String, dynamic>? json) {
    final LatLng? northeast =
        LatLng.fromMapsAPIJson(json?['northeast']);
    final LatLng? southwest =
        LatLng.fromMapsAPIJson(json?['southwest']);
    return ViewPort(northeast: northeast, southwest: southwest);
  }
}
