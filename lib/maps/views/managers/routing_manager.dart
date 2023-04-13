import 'package:maps_core/maps.dart';

abstract class RoutingManager {
  Future<void> buildRoute(MapRoute route);
  Future<void> startNavigation(MapRoute route);
}