import 'package:maps_core/maps/models/models.dart';

class Directions {
  final List<Place>? geocodedWaypoints;
  final List<MapRoute>? routes;

  Directions({
    this.geocodedWaypoints,
    this.routes,
  });

  factory Directions.fromJson(Map<String, dynamic> json, {int? routePointsSkipStep}) {
    final List<GeocodingPlace>? geocodedWaypoints =
        (json['geocoded_waypoints'] as List<dynamic>?)
            ?.map((e) => GeocodingPlace.fromJson(e))
            .toList();
    final List<MapRoute>? routes = (json['routes'] as List<dynamic>?)
        ?.map((e) => MapRoute.fromJson(e, pointsSkipStep: routePointsSkipStep))
        .toList();
    return Directions(
      geocodedWaypoints: geocodedWaypoints,
      routes: routes,
    );
  }
}
