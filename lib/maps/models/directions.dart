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

  factory Directions.fromJsonGoogle(Map<String, dynamic> json, {int? routePointsSkipStep}) {
    final List<GeocodingPlaceGoogle>? geocodedWaypoints =
    (json['geocoded_waypoints'] as List<dynamic>?)
        ?.map((e) => GeocodingPlaceGoogle.fromJson(e))
        .toList();
    final List<MapRoute>? routes = (json['routes'] as List<dynamic>?)
        ?.map((e) => MapRoute.fromJson(e, pointsSkipStep: routePointsSkipStep))
        .toList();
    return Directions(
      geocodedWaypoints: geocodedWaypoints,
      routes: routes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geocoded_waypoints': geocodedWaypoints?.map((e) => e.toJson()).toList(),
      'routes': routes?.map((e) => e.toJson()).toList(),
    };
  }

}
