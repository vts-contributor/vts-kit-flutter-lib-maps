import 'dart:ui';

import 'package:maps_core/maps.dart';

abstract class RoutingManager {

  static const double moveCameraPadding = 10;

  ///build routes base on [directions]
  Future<void> buildDirections(Directions directions) ;

  ///start navigation with the selected route
  ///
  /// if no route is selected, this will has no effect
  Future<void> startNavigation();
}