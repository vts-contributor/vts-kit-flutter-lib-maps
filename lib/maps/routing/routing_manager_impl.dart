import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/routing/routing_manager.dart';

class RoutingManagerImpl extends RoutingManager {

  late CoreMapController controller;

  Set<Polyline> _lines = {};
  Set<Marker> _markers = {};

  CoreMapShapes copyWithInternal(CoreMapShapes? shapes) {
    shapes ??= CoreMapShapes();
    return shapes.copyWith(
      polylines: shapes.polylines..addAll(_lines),
      markers: shapes.markers..addAll(_markers),
    );
  }

  @override
  void buildDirections(Directions directions) {
    // TODO: implement buildDirections
  }

  @override
  void buildRoute(Route route) {
    // TODO: implement buildRoute
  }

  @override
  void startNavigation(Route route) {
    // TODO: implement startNavigation
  }

}