import 'dart:ui';

import 'package:flutter/material.dart';

///constants used by the lib
class Constant {
  Constant._();

  ///default asset path for Marker's icon
  static const String markerDefaultAssetPath = "packages/maps_core/assets/default_marker.png";

  ///default asset name for Marker's icon
  static const String markerDefaultName = "default_08506dfjlsdp42odfo_marker_2432023";

  ///asset path for start marker
  static const String markerStartAssetPath = "packages/maps_core/assets/start_marker.png";

  ///asset name for start marker
  static const String markerStartName = "start_129nasdfkb44bhzdf_marker_11012024";

    ///asset path for end marker
  static const String markerEndAssetPath = "packages/maps_core/assets/end_marker.png";

  ///asset name for end marker
  static const String markerEndName = "end_35asdff123fa2356sfs_marker_11012024";

  ///the lowest zoom level that maps should support
  static const double zoomLevelLowerBound = 1.0;

  ///sometime we draw outlines of vtmap shapes with Line
  ///and Google map stroke is 2 times thicker than viettel map line
  static const double vtStrokeWidthMultiplier = 2.0;

  ///my location button size
  static const double myLocationButtonSize = 36;

  ///zoom button size
  static const double zoomButtonSize = 32;

  ///distance between buttons
  static const double buttonDistance = 6;

  ///default padding of buttons
  static const double defaultButtonPadding = 10;

  ///default button color
  static final Color defaultButtonColor = Colors.white.withOpacity(0.5);

  ///default button icon color
  static final Color defaultButtonIconColor = Colors.black.withOpacity(0.6);

  ///full screen button size
  static const double fullScreenButtonSize = 36;
}