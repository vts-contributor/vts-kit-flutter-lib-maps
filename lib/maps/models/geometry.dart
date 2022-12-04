import 'package:maps_core/maps/models/models.dart';

class Geometry {
  final LatLng? location;
  final String? locationType;
  final ViewPort? viewPort;

  Geometry({
    this.location,
    this.locationType,
    this.viewPort,
  });

  factory Geometry.fromJson(Map<String, dynamic>? json) {
    final LatLng? location = LatLng.fromMapsAPIJson(json?['location']);
    final String? locationType = json?['location_type'];
    final ViewPort viewPort = ViewPort.fromJson(json?['viewport']);
    return Geometry(
      location: location,
      locationType: locationType,
      viewPort: viewPort,
    );
  }
}
