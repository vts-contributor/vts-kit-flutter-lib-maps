import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';

///Data the map. Used as object for better transferring between maps and controllers
class CoreMapData {
  CoreMapData({
    this.accessToken,
    required this.initialCameraPosition,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.compassEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.myLocationButtonAlignment = Alignment.topRight,
    this.selectedRouteColor = Colors.blueAccent,
    this.unselectedRouteColor = Colors.grey,
    this.selectedRouteWidth,
    this.unselectedRouteWidth,
    this.myLocationButtonPadding,
    this.myLocationButtonData,
    this.zoomButtonEnabled = true,
    this.zoomButtonAlignment = Alignment.bottomRight,
    this.zoomButtonPadding,
    this.zoomInButtonData,
    this.zoomOutButtonData,
    this.zoomButtonDividerColor = Colors.grey,
    this.zoomButtonDividerThickness = 1,
    this.markerAllowOverlap = false,
    this.defaultTravelMode = RouteTravelMode.bycycling,
  });

  ///should be removed, use file instead
  final String? accessToken;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

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

  ///alignment of the location button
  ///
  /// Please note that if you set [compassEnabled] to true,
  /// these two will be overlapped
  final Alignment myLocationButtonAlignment;

  ///padding for my location button
  final EdgeInsets? myLocationButtonPadding;

  ///custom my location button.
  final CoreMapButtonCustomizeData? myLocationButtonData;

  ///Color for the selected route
  final Color selectedRouteColor;

  ///Color for unselected routes
  final Color unselectedRouteColor;

  ///Selected route polyline width
  final int? selectedRouteWidth;

  ///Unselected route polyline width
  final int? unselectedRouteWidth;

  ///add zoom button to bottom right corner
  final bool zoomButtonEnabled;

  ///alignment for zoom button
  ///
  /// Please note that if you set [compassEnabled] to true,
  /// these two will be overlapped
  final Alignment zoomButtonAlignment;

  ///padding for zoom button
  final EdgeInsets? zoomButtonPadding;

  ///custom zoom in button
  ///
  ///If you want a ripple press effect, use [Ink] to wrap your custom button
  final CoreMapButtonCustomizeData? zoomInButtonData;

  ///custom zoom out button
  ///
  /// If you want a ripple press effect, use [Ink] to wrap your custom button
  final CoreMapButtonCustomizeData? zoomOutButtonData;

  ///color of the divider between zoom buttons
  ///
  /// set this = [Colors.transparent] to disable the divider
  final Color zoomButtonDividerColor;

  ///width of the divider between zoom buttons
  ///
  /// set this = 0 to disable the divider
  final double zoomButtonDividerThickness;

  ///true means markers won't be grouped when zooming out
  final bool markerAllowOverlap;

  ///default travel mode for routing
  final RouteTravelMode defaultTravelMode;

  ///copy data with new parameters
  CoreMapData copyWith({
    String? accessToken,
    CameraPosition? initialCameraPosition,
    MinMaxZoomPreference? minMaxZoomPreference,
    CameraTargetBounds? cameraTargetBounds,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    bool? compassEnabled,
    bool? rotateGesturesEnabled,
    bool? scrollGesturesEnabled,
    bool? zoomGesturesEnabled,
    bool? tiltGesturesEnabled,
    bool? myLocationEnabled,
    bool? myLocationButtonEnabled,
    Alignment? myLocationButtonAlignment,
    Color? selectedRouteColor,
    Color? unselectedRouteColor,
    int? selectedRouteWidth,
    int? unselectedRouteWidth,
    EdgeInsets? myLocationButtonPadding,
    CoreMapButtonCustomizeData? myLocationButtonData,
    bool? zoomButtonEnabled,
    Alignment? zoomButtonAlignment,
    EdgeInsets? zoomButtonPadding,
    CoreMapButtonCustomizeData? zoomInButtonData,
    CoreMapButtonCustomizeData? zoomOutButtonData,
    Color? zoomButtonDividerColor,
    double? zoomButtonDividerThickness,
    bool? markerAllowOverlap,
    RouteTravelMode? defaultTravelMode,
  }) {
    return CoreMapData(
      accessToken: accessToken ?? this.accessToken,
      initialCameraPosition: initialCameraPosition ?? this.initialCameraPosition,
      minMaxZoomPreference: minMaxZoomPreference ?? this.minMaxZoomPreference,
      cameraTargetBounds: cameraTargetBounds ?? this.cameraTargetBounds,
      gestureRecognizers: gestureRecognizers ?? this.gestureRecognizers,
      compassEnabled: compassEnabled ?? this.compassEnabled,
      rotateGesturesEnabled: rotateGesturesEnabled ?? this.rotateGesturesEnabled,
      scrollGesturesEnabled: scrollGesturesEnabled ?? this.scrollGesturesEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled ?? this.zoomGesturesEnabled,
      tiltGesturesEnabled: tiltGesturesEnabled ?? this.tiltGesturesEnabled,
      myLocationEnabled: myLocationEnabled ?? this.myLocationEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled ?? this.myLocationButtonEnabled,
      myLocationButtonAlignment: myLocationButtonAlignment ?? this.myLocationButtonAlignment,
      selectedRouteColor: selectedRouteColor ?? this.selectedRouteColor,
      unselectedRouteColor: unselectedRouteColor ?? this.unselectedRouteColor,
      selectedRouteWidth: selectedRouteWidth,
      unselectedRouteWidth: unselectedRouteWidth,
      myLocationButtonPadding: myLocationButtonPadding ?? this.myLocationButtonPadding,
      myLocationButtonData: myLocationButtonData ?? this.myLocationButtonData,
      zoomButtonEnabled: zoomButtonEnabled ?? this.zoomButtonEnabled,
      zoomButtonAlignment: zoomButtonAlignment ?? this.zoomButtonAlignment,
      zoomButtonPadding: zoomButtonPadding ?? this.zoomButtonPadding,
      zoomInButtonData: zoomInButtonData ?? this.zoomInButtonData,
      zoomOutButtonData: zoomOutButtonData ?? this.zoomOutButtonData,
      zoomButtonDividerColor: zoomButtonDividerColor ?? this.zoomButtonDividerColor,
      zoomButtonDividerThickness: zoomButtonDividerThickness ?? this.zoomButtonDividerThickness,
      markerAllowOverlap: markerAllowOverlap ?? this.markerAllowOverlap,
      defaultTravelMode: defaultTravelMode ?? this.defaultTravelMode,
    );
  }
}

class CoreMapButtonCustomizeData {
  const CoreMapButtonCustomizeData({
    this.width,
    this.height,
    this.color,
    this.borderSide,
    this.icon,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final Color? color;
  final BorderSide? borderSide;
  final Widget? icon;
  final BorderRadius? borderRadius;
}
