///constants used by the lib
class Constant {
  ///default asset path for Marker's icon
  static const String markerDefaultAssetPath = "packages/maps_core/assets/default_marker.png";

  ///default asset name for Marker's icon
  static const String markerDefaultName = "default_08506dfjlsdp42odfo_marker_2432023";

  ///the lowest zoom level that maps should support
  static const double zoomLevelLowerBound = 1.0;

  ///sometime we draw outlines of vtmap shapes with Line
  ///and Google map stroke is 2 times thicker than viettel map line
  static const double vtStrokeWidthMultiplier = 2.0;
}