// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/extensions/utils.dart';

import 'map_objects/lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

/// Type of map tiles to display.
// Enum constants must be indexed to match the corresponding int constants of
// the Android platform API, see
// <https://developers.google.com/android/reference/com/google/android/gms/maps/GoogleMap.html#MAP_TYPE_NORMAL>
enum MapType {
  /// Do not display map tiles.
  none,

  /// Normal tiles (traffic and labels, subtle terrain information).
  normal,

  /// Satellite imaging tiles (aerial photos)
  satellite,

  /// Terrain tiles (indicates type and height of terrain)
  terrain,

  /// Hybrid tiles (satellite images with some labels/overlays)
  hybrid,
}

/// Bounds for the map camera target.
// Used with [GoogleMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
@immutable
class CameraTargetBounds {
  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds? bounds;

  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  /// Converts this object to something serializable in JSON.
  Object toJson() => <Object?>[bounds?.toJson()];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is CameraTargetBounds && bounds == other.bounds;
  }

  @override
  int get hashCode => bounds.hashCode;

  @override
  String toString() {
    return 'CameraTargetBounds(bounds: $bounds)';
  }

  ggmap.CameraTargetBounds toGoogle() {
    return ggmap.CameraTargetBounds(bounds?.toGoogle());
  }

  vtmap.CameraTargetBounds toViettel() {
    return vtmap.CameraTargetBounds(bounds?.toViettel());
  }
}

/// Preferred bounds for map camera zoom level.
// Used with [GoogleMapOptions] to wrap min and max zoom. This allows
// distinguishing between specifying unbounded zooming (null `minZoom` and
// `maxZoom`) from not specifying anything (null `MinMaxZoomPreference`).
@immutable
class MinMaxZoomPreference {
  /// Creates a immutable representation of the preferred minimum and maximum zoom values for the map camera.
  ///
  /// [AssertionError] will be thrown if [minZoom] > [maxZoom].
  ///
  /// [minZoom] >= 1
  MinMaxZoomPreference({double minZoom = 1, this.maxZoom})
      : assert(maxZoom == null || minZoom <= maxZoom), minZoom = minZoom.validCoreZoomLevel ;

  const MinMaxZoomPreference._(this.minZoom, this.maxZoom);

  /// The preferred minimum zoom level or 1, if unbounded from below.
  final double minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double? maxZoom;

  /// Unbounded zooming. (but to unify maps, lower bound must >= 1)
  static const MinMaxZoomPreference unbounded =
  MinMaxZoomPreference._(1, null);

  /// Converts this object to something serializable in JSON.
  Object toJson() => <Object?>[minZoom, maxZoom];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is MinMaxZoomPreference &&
        minZoom == other.minZoom &&
        maxZoom == other.maxZoom;
  }

  @override
  int get hashCode => Object.hash(minZoom, maxZoom);

  @override
  String toString() {
    return 'MinMaxZoomPreference(minZoom: $minZoom, maxZoom: $maxZoom)';
  }

  ggmap.MinMaxZoomPreference toGoogle() {
    return ggmap.MinMaxZoomPreference(minZoom, maxZoom);
  }

  vtmap.MinMaxZoomPreference toViettel() {
    return vtmap.MinMaxZoomPreference(minZoom, maxZoom);
  }
}

/// Exception when a map style is invalid or was unable to be set.
///
/// See also: `setStyle` on [GoogleMapController] for why this exception
/// might be thrown.
class MapStyleException implements Exception {
  /// Default constructor for [MapStyleException].
  const MapStyleException(this.cause);

  /// The reason `GoogleMapController.setStyle` would throw this exception.
  final String cause;
}
