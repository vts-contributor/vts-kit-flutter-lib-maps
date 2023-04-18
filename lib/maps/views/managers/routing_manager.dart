import 'dart:ui';

import 'package:maps_core/maps.dart';

abstract class RoutingManager {

  static const double moveCameraPadding = 10;

  static const String logTag = "ROUTING MANAGER";

  ///build routes base on [directions]
  Future<void> buildRoutes(List<MapRoute>? routes) ;

  ///start navigation with the selected route
  ///
  /// if no route is selected, this will has no effect
  Future<void> startNavigation();

  ///listener will be notified when a route was tapped
  void addRouteTapListener(void Function(String id) listener);

  ///remove listener
  void removeRouteTapListener(void Function(String id) listener);

  ///select a route with id,
  ///have to buildDirections first or else this always return false
  bool selectRoute(String id);

  ///get current selected route if possible
  MapRoute? get selectedRoute;
}