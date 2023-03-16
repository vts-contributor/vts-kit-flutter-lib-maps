import 'dart:math';

export 'map_controller.dart';

abstract class MapController {
  Future<Point> addMarker();
}