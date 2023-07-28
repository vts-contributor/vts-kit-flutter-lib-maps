import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

///Data (usually flags) of specific map type
class MapViewSpecificData {
  GoogleMapSpecificData? google;
  ViettelMapSpecificData? viettel;
}

class GoogleMapSpecificData {

  /// The layout direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead. If there is
  /// no ambient [Directionality], [TextDirection.ltr] is used.
  final TextDirection? layoutDirection;

  // /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  // EdgeInsets? padding;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool? liteModeEnabled;

  /// The type of the map.
  final MapType? mapType;

  final bool? mapToolbarEnabled;

  const GoogleMapSpecificData({
    Key? key,
    this.mapType = MapType.normal,
    this.liteModeEnabled = false,
    this.myLocationButtonEnabled = true,
    this.layoutDirection,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.mapToolbarEnabled = false,
    this.tileOverlays = const <TileOverlay>{},
  });
}

class ViettelMapSpecificData {

  ///show or hide Mapbox logo
  final bool? logoEnabled;

  /// Set the layout margins for the Mapbox Logo
  final Point? logoViewMargin;

  /// Position of the compass when rotate the map
  final CompassViewPosition? compassViewPosition;

  /// margins of the compass
  final Point? compassViewMargins;

  /// margins of the attribution button
  final Point? attributionButtonMargins;

  ViettelMapSpecificData({
    this.logoEnabled = true,
    this.logoViewMargin,
    this.compassViewPosition,
    this.compassViewMargins,
    this.attributionButtonMargins,
  });
}