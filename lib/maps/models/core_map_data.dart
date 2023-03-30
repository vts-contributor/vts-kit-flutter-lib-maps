import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/models/camera_position.dart';
import 'package:maps_core/maps/models/map_objects/polygon.dart';

///State of the map
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
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    Set<Circle>? circles,
  }): polygons = polygons ?? {},
        polylines = polylines ?? {},
        circles = circles ?? {},
        markers = markers ?? {};

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

  final Set<Polygon> polygons;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final Set<Marker> markers;

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
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    Set<Circle>? circles,
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
      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
    );
  }
}