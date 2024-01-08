import 'package:maps_core/maps.dart';

class AutoRoute {
  final String id;
  final List<LatLng> waypoints;
  late final RouteType routeType;

  AutoRoute(this.id, this.waypoints, [this.routeType = RouteType.line]);
}

enum RouteType {
  auto,
  line,
}