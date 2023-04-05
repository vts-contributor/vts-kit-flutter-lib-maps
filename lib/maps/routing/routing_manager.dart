import 'package:maps_core/maps.dart';

abstract class RoutingManager {
  void buildRoute(Route route);
  void buildDirections(Directions directions);
  void startNavigation(Route route);
}