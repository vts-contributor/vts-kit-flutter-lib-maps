// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

import '../../constants.dart';

/// Uniquely identifies a [Circle] among [CoreMap] markers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class CircleId extends MapObjectId<Circle> {
  /// Creates an immutable identifier for a [Circle].
  const CircleId(String value) : super(value);
}

/// Draws a circle on the map.
@immutable
class Circle implements MapObject<Circle> {
  /// Creates an immutable representation of a [Circle] to draw on [GoogleMap].
  const Circle({
    required this.id,
    this.fillColor = Colors.transparent,
    required this.center,
    this.radius = 0,
    this.strokeColor = Colors.black,
    this.strokeWidth = 10,
    this.visible = true,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Circle].
  @override
  final CircleId id;

  /// Fill color in ARGB format, the same format used by Color. The default value is transparent (0x00000000).
  final Color fillColor;

  /// Geographical location of the circle center.
  final LatLng center;

  /// Radius of the circle in meters; must be positive. The default value is 0.
  final double radius;

  /// Fill color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color strokeColor;

  /// The width of the circle's outline in screen points.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  /// Setting strokeWidth to 0 results in no stroke.
  final int strokeWidth;

  /// True if the circle is visible.
  final bool visible;

  /// The z-index of the circle, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  @override
  final int zIndex;

  /// Callbacks to receive tap events for circle placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Circle] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Circle copyWith({
    Color? fillColorParam,
    LatLng? centerParam,
    double? radiusParam,
    Color? strokeColorParam,
    int? strokeWidthParam,
    bool? visibleParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Circle(
      id: id,
      fillColor: fillColorParam ?? fillColor,
      center: centerParam ?? center,
      radius: radiusParam ?? radius,
      strokeColor: strokeColorParam ?? strokeColor,
      strokeWidth: strokeWidthParam ?? strokeWidth,
      visible: visibleParam ?? visible,
      zIndex: zIndexParam ?? zIndex,
      onTap: onTapParam ?? onTap,
    );
  }

  /// Creates a new [Circle] object whose values are the same as this instance.
  @override
  Circle clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('circleId', id);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('center', center.toJson());
    addIfPresent('radius', radius);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

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
    return other is Circle &&
        id == other.id &&
        fillColor == other.fillColor &&
        center == other.center &&
        radius == other.radius &&
        strokeColor == other.strokeColor &&
        strokeWidth == other.strokeWidth &&
        visible == other.visible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => id.hashCode;

  ggmap.Circle toGoogle() {
    return ggmap.Circle(
        circleId: ggmap.CircleId(id.value),
        consumeTapEvents: onTap != null,
        fillColor: fillColor,
        center: center.toGoogle(),
        radius: radius,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        visible: visible,
        zIndex: zIndex,
        onTap: onTap
    );
  }

  vtmap.CircleOptions toCircleOptions() {
    return vtmap.CircleOptions(
        geometry: center.toViettel(),
        circleColor: fillColor.toHex(),
        circleRadius: radius / 1000, //kilometer -> meter
        circleStrokeColor: strokeColor.toRGBA(),
        circleStrokeWidth: strokeWidth.toDouble(),
        circleOpacity: fillColor.opacity,
        circleStrokeOpacity: strokeColor.opacity
    );
  }

  vtmap.FillOptions toFillOptions([List<LatLng>? points]) {
    points ??= toCirclePoints(160);
    return vtmap.FillOptions(
      geometry: [points.toViettel()],
      fillColor: fillColor.toHex(),
      fillOpacity: fillColor.opacity,
    );
  }

  vtmap.LineOptions toLineOptions([List<LatLng>? points]) {
    points ??= toCirclePoints(160);
    points = List.from(points);
    if (points.length > 2) {
      //to remove outline little gap
      points.addAll(points.getRange(0, points.length ~/ 10));
    }
    return vtmap.LineOptions(
      geometry: points.toViettel(),
      lineWidth: (strokeWidth * Constant.vtStrokeWidthMultiplier).toDouble(),
      lineColor: strokeColor.toRGBA(),
      lineOpacity: strokeColor.opacity,
      lineJoin: "round",
    );
  }

  ///see https://github.com/flutter-mapbox-gl/maps/issues/355#issuecomment-777289787
  ///add 320 points
  List<LatLng> toCirclePoints([int numberOfPoints = 160]) {
    final point = center;
    int dir = 1;

    var d2r = pi / 180; // degrees to radians
    var r2d = 180 / pi; // radians to degrees
    var earthsradius = 6371000; // radius of the earth in meters

    var points = numberOfPoints;

    // find the radius in lat/lon
    var rlat = (radius / earthsradius) * r2d;
    var rlng = rlat / cos(point.lat * d2r);

    List<LatLng> extp = [];
    int start = 0;
    int end = points + 1;
    if (dir == -1) {
      start = points + 1;
      end = 0;
    }
    for (var i = start; (dir == 1 ? i < end : i > end); i = i + dir) {
      var theta = pi * (i / (points / 2));
      double ey = point.lng +
          (rlng * cos(theta)); // center a + radius x * cos(theta)
      double ex = point.lat +
          (rlat * sin(theta)); // center b + radius y * sin(theta)
      extp.add(LatLng(ex, ey));
    }
    return extp..remove(extp.last);
  }
}
