// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart'
    show immutable, listEquals, VoidCallback;
import 'package:flutter/material.dart' show Color, Colors;

import 'joint_type.dart';
import 'lat_lng.dart';


/// Draws a line through geographical locations on the map.
@immutable
class Polyline{
  /// Creates an immutable object representing a line drawn through geographical locations on the map.
  const Polyline({
    required this.id,
    this.consumeTapEvents = false,
    this.color = Colors.black,
    this.geodesic = false,
    this.jointType = JointType.mitered,
    this.points = const <LatLng>[],
    this.visible = true,
    this.width = 10,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Polyline].
  final String id;

  /// True if the [Polyline] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color color;

  /// Indicates whether the segments of the polyline should be drawn as geodesics, as opposed to straight lines
  /// on the Mercator projection.
  ///
  /// A geodesic is the shortest path between two points on the Earth's surface.
  /// The geodesic curve is constructed assuming the Earth is a sphere
  final bool geodesic;

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
  final int zIndex;

  /// Callbacks to receive tap events for polyline placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Polyline] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polyline copyWith({
    Color? colorParam,
    bool? consumeTapEventsParam,

    bool? geodesicParam,
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
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      geodesic: geodesicParam ?? geodesic,
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
  @override
  Polyline clone() {
    return copyWith(
      pointsParam: List<LatLng>.of(points),
    );
  }

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polylineId', id);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('color', color.value);
    addIfPresent('geodesic', geodesic);
    addIfPresent('jointType', jointType.value);
    addIfPresent('visible', visible);
    addIfPresent('width', width);
    addIfPresent('zIndex', zIndex);

    if (points != null) {
      json['points'] = _pointsToJson();
    }


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
        consumeTapEvents == other.consumeTapEvents &&
        color == other.color &&
        geodesic == other.geodesic &&
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
}
