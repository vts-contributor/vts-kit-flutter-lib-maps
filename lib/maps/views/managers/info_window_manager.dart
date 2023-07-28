import '../../models/map_objects/marker.dart';

abstract class InfoWindowManager {
  static const String logTag = "InfoWindowManager";
  Future<void> showInfoWindow(MarkerId markerId);
  Future<void> hideInfoWindow(MarkerId markerId);
}