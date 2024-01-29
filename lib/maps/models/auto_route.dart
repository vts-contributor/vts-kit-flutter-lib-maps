import 'dart:ui';

import 'package:maps_core/maps.dart';

class RouteConfig {

  ///Passing the same id will connect first point of this config with last point of the route with same id
  ///Read other fields documment
  final String id;

  ///waypoints or points base on [routeType]
  final List<LatLng> waypoints;

  ///type of route
  ///
  ///same [id] can use different routeType
  final RouteType routeType;

  ///route's color, override [CoreMapData.selectedRouteColor] and [CoreMapData.unselectedRouteColor]
  ///
  /// with the same [id], the first config will be the route's color
  final Color? color;

  ///route's width, override [CoreMapData.selectedRouteWidth] and [CoreMapData.unselectedRouteWidth]
  ///
  /// with the same [id], the first config will be the route's width
  final int? width;

  ///type of travel mode
  ///
  ///same [id] can use different [travelMode]
  final RouteTravelMode? travelMode;

  ///true if you want to cache route with the same ID
  final bool cached;

  RouteConfig(this.id, this.waypoints, {
    this.routeType = RouteType.auto,
    this.color,
    this.width,
    this.travelMode,
    this.cached = false,
  });
}

enum RouteType {
  auto,
  autoSort,
  line,
}

enum RouteTravelMode {
  driving,
  bycycling,
  walking
}