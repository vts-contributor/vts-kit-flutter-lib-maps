import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

///Data (usually flags) of specific map type
class MapViewSpecificData {
  GoogleMapSpecificData? google;
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