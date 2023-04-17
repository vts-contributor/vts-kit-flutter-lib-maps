import 'dart:ui';

import 'package:maps_core/maps.dart';

abstract class RoutingManager {
  ///build routes base on [directions]
  Future<void> buildDirections(Directions directions) ;

  ///start navigation with the selected route
  ///
  /// if no route is selected, this will has no effect
  Future<void> startNavigation();

  ///set line color for the selected route
  set selectedRouteColor(Color color);

  ///set line color for unselected routes
  set unselectedRouteColor(Color color);
}