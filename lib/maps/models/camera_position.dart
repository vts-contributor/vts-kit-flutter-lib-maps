// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/extensions/utils.dart';

import 'map_objects/lat_lng.dart';

/// The position of the map "camera", the view point from which the world is shown in the map view.
///
/// Aggregates the camera's [target] geographical location, its [zoom] level,
/// [tilt] angle, and [bearing].
@immutable
class CameraPosition {
  /// Creates a immutable representation of the [GoogleMap] camera.
  ///
  /// [zoom] will be fixed to >= 1 if it's < 1
  CameraPosition({
    this.bearing = 0.0,
    required this.target,
    this.tilt = 0.0,
    double zoom = Constant.zoomLevelLowerBound,
  }): zoom = zoom.validCoreZoomLevel;

  /// The camera's bearing in degrees, measured clockwise from north.
  ///
  /// A bearing of 0.0, the default, means the camera points north.
  /// A bearing of 90.0 means the camera points east.
  final double bearing;

  /// The geographical location that the camera is pointing at.
  final LatLng target;

  /// The angle, in degrees, of the camera angle from the nadir.
  ///
  /// A tilt of 0.0, the default and minimum supported value, means the camera
  /// is directly facing the Earth.
  ///
  /// The maximum tilt value depends on the current zoom level. Values beyond
  /// the supported range are allowed, but on applying them to a map they will
  /// be silently clamped to the supported range.
  final double tilt;

  /// The zoom level of the camera.
  ///
  /// A zoom of 0.0, the default, means the screen width of the world is 256.
  /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
  /// zoom level 3.0, the screen width of the world is 2³x256=2048.
  ///
  /// Larger zoom levels thus means the camera is placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  /// Serializes [CameraPosition].
  ///
  /// Mainly for internal use when calling [CameraUpdate.newCameraPosition].
  Object toMap() => <String, Object>{
    'bearing': bearing,
    'target': target.toJson(),
    'tilt': tilt,
    'zoom': zoom,
  };

  /// Deserializes [CameraPosition] from a map.
  ///
  /// Mainly for internal use.
  static CameraPosition? fromMap(Object? json) {
    if (json == null || json is! Map<dynamic, dynamic>) {
      return null;
    }

    final LatLng? target = LatLng.fromJson(json['target']);
    if (target == null) {
      return null;
    }
    return CameraPosition(
      bearing: json['bearing'] as double,
      target: target,
      tilt: json['tilt'] as double,
      zoom: json['zoom'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is CameraPosition &&
        bearing == other.bearing &&
        target == other.target &&
        tilt == other.tilt &&
        zoom == other.zoom;
  }

  @override
  int get hashCode => Object.hash(bearing, target, tilt, zoom);

  @override
  String toString() =>
      'CameraPosition(bearing: $bearing, target: $target, tilt: $tilt, zoom: $zoom)';

  CameraPosition copyWith({
    double? bearing,
    LatLng? target,
    double? zoom,
    double? tilt,
  }) {
    return CameraPosition(
      target: target ?? this.target,
      bearing: bearing ?? this.bearing,
      zoom: zoom ?? this.zoom,
      tilt: tilt ?? this.tilt
    );
  }
}
