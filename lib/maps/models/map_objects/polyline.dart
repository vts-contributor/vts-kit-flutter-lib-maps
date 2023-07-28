// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart'
    show immutable, listEquals, VoidCallback;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:maps_core/maps.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

/// Uniquely identifies a [Polyline] among [CoreMap] markers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class PolylineId extends MapObjectId<Polyline> {
  /// Creates an immutable identifier for a [Polyline].
  const PolylineId(String value) : super(value);
}

/// Draws a line through geographical locations on the map.
@immutable
class Polyline implements MapObject<Polyline> {
  /// Creates an immutable object representing a line drawn through geographical locations on the map.
  const Polyline({
    required this.id,
    this.color = Colors.black,
    this.jointType = JointType.mitered,
    this.points = const <LatLng>[],
    this.visible = true,
    this.width = 10,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Polyline].
  @override
  final PolylineId id;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color color;

  /// Joint type of the polyline line segments.
  ///
  /// The joint type defines the shape to be used when joining adjacent line segments at all vertices of the
  /// polyline except the start and end vertices. See [JointType] for supported joint types. The default value is
  /// mitered.
  ///
  /// Supported on Android only.
  final JointType jointType;

  /// The vertices of the polyline to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polyline is not closed by
  /// default; to form a closed polyline, the start and end points must be the same.
  final List<LatLng> points;

  /// True if the marker is visible.
  final bool visible;

  /// Width of the polyline, used to define the width of the line segment to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int width;

  /// The z-index of the polyline, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  @override
  final int zIndex;

  /// Callbacks to receive tap events for polyline placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Polyline] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polyline copyWith({
    Color? colorParam,
    bool? consumeTapEventsParam,
    JointType? jointTypeParam,
    List<LatLng>? pointsParam,
    bool? visibleParam,
    int? widthParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Polyline(
      id: id,
      color: colorParam ?? color,
      jointType: jointTypeParam ?? jointType,
      points: pointsParam ?? points,
      visible: visibleParam ?? visible,
      width: widthParam ?? width,
      onTap: onTapParam ?? onTap,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  /// Creates a new [Polyline] object whose values are the same as this
  /// instance.
  Polyline clone() {
    return copyWith(
      pointsParam: List<LatLng>.of(points),
    );
  }

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polylineId', id);
    addIfPresent('color', color.value);
    addIfPresent('jointType', jointType.value);
    addIfPresent('visible', visible);
    addIfPresent('width', width);
    addIfPresent('zIndex', zIndex);

    json['points'] = _pointsToJson();


    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Polyline &&
        id == other.id &&
        color == other.color &&
        jointType == other.jointType &&
        listEquals(points, other.points) &&
        visible == other.visible &&
        width == other.width &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => id.hashCode;

  Object _pointsToJson() {
    final List<Object> result = <Object>[];
    for (final LatLng point in points) {
      result.add(point.toJson());
    }
    return result;
  }

  ggmap.Polyline toGoogle() {
    return ggmap.Polyline(
      polylineId: ggmap.PolylineId(id.value),
      consumeTapEvents: onTap != null,
      color: color,
      jointType: jointType.toGoogle(),
      points: points.toGoogle(),
      visible: visible,
      onTap: onTap,
      width: width,
      zIndex: zIndex,
      startCap: ggmap.Cap.roundCap
    );
  }

  vtmap.LineOptions toLineOptions() {
    return vtmap.LineOptions(
      geometry: points.toViettel(),
      lineWidth: width.toDouble(),
      lineColor: color.toRGBA(),
      lineJoin: jointType.toViettel(),
      lineOpacity: color.opacity,
    );
  }
}
