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

  ///true if you want to cache route with the same ID, does not work between two different map view
  final bool cached;

  ///static zIndex (for case where selected route doesn't have to be on top of unselected ones)
  final int? zIndex;

  ///zoom on tap. This does not affect onRouteTapListener
  final bool selectOnTap;

  RouteConfig(
    this.id,
    this.waypoints, {
    this.routeType = RouteType.auto,
    this.color,
    this.width,
    this.travelMode,
    this.cached = false,
    this.zIndex,
    this.selectOnTap = true,
  });

  RouteConfig copyWith({
    String? id,
    List<LatLng>? waypoints,
    RouteType? routeType,
    Color? color,
    int? width,
    RouteTravelMode? travelMode,
    bool? cached,
    int? zIndex,
    bool? selectOnTap,
  }) {
    return RouteConfig(
      id ?? this.id,
      waypoints ?? this.waypoints,
      routeType: routeType ?? this.routeType,
      color: color ?? this.color,
      width: width ?? this.width,
      travelMode: travelMode ?? this.travelMode,
      cached: cached ?? this.cached,
      zIndex: zIndex ?? this.zIndex,
      selectOnTap: selectOnTap ?? this.selectOnTap,
    );
  }
}

enum RouteType {
  auto,
  autoSort,
  line,
}

enum RouteTravelMode { driving, bycycling, walking }

class RouteInfo {
  final String id;
  final List<LatLng>? waypoints;

  ///total distance (Kilometers)
  final double? totalDistance;
  final double? totalDuration;

  RouteInfo(
    this.id,
    this.waypoints,
    this.totalDistance,
    this.totalDuration,
  );
}
