part of core_map;

abstract class InfoWindowManager {
  static const String logTag = "InfoWindowManager";

  ///show info window of marker with markerId
  Future<void> showInfoWindow(MarkerId markerId);

  ///hide info window of marker with markerId
  Future<void> hideInfoWindow(MarkerId markerId);

  /// show/hide info window of the marker on tap
  void onMarkerTapSetInfoWindow(MarkerId markerId);
}