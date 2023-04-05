import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'
    show immutable, listEquals, VoidCallback;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/models/map_objects/map_object.dart';

import 'lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

/// Draws a polygon through geographical locations on the map.
class Polygon implements MapObject {
  /// Creates an immutable representation of a polygon through geographical locations on the map.
  const Polygon({
    required this.id,
    this.fillColor = Colors.black,
    this.geodesic = false,
    this.points = const <LatLng>[],
    this.holes = const <List<LatLng>>[],
    this.strokeColor = Colors.black,
    this.strokeWidth = 1,
    this.visible = true,
    this.zIndex = 0,
    this.onTap,
  });

  /// Uniquely identifies a [Polygon].
  @override
  final String id;

  /// Fill color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color fillColor;

  /// Indicates whether the segments of the polygon should be drawn as geodesics, as opposed to straight lines
  /// on the Mercator projection.
  ///
  /// A geodesic is the shortest path between two points on the Earth's surface.
  /// The geodesic curve is constructed assuming the Earth is a sphere
  final bool geodesic;

  /// The vertices of the polygon to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polygon is not closed by
  /// default; to form a closed polygon, the start and end points must be the same.
  final List<LatLng> points;

  /// To create an empty area within a polygon, you need to use holes.
  /// To create the hole, the coordinates defining the hole path must be inside the polygon.
  ///
  /// The vertices of the holes to be cut out of polygon.
  ///
  /// Line segments of each points of hole are drawn inside polygon between consecutive hole points.
  final List<List<LatLng>> holes;

  /// True if the marker is visible.
  final bool visible;

  /// Line color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color strokeColor;

  /// Width of the polygon, used to define the width of the line to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int strokeWidth;

  /// The z-index of the polygon, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for polygon placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Polygon] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polygon copyWith({
    Color? fillColorParam,
    bool? geodesicParam,
    List<LatLng>? pointsParam,
    List<List<LatLng>>? holesParam,
    Color? strokeColorParam,
    int? strokeWidthParam,
    bool? visibleParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
  }) {
    return Polygon(
      id: id,
      fillColor: fillColorParam ?? fillColor,
      geodesic: geodesicParam ?? geodesic,
      points: pointsParam ?? points,
      holes: holesParam ?? holes,
      strokeColor: strokeColorParam ?? strokeColor,
      strokeWidth: strokeWidthParam ?? strokeWidth,
      visible: visibleParam ?? visible,
      onTap: onTapParam ?? onTap,
      zIndex: zIndexParam ?? zIndex,
    );
  }

  /// Creates a new [Polygon] object whose values are the same as this instance.
  @override
  Polygon clone() {
    return copyWith(pointsParam: List<LatLng>.of(points));
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

    addIfPresent('polygonId', id);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('geodesic', geodesic);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('strokeWidth', strokeWidth);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);

    if (points != null) {
      json['points'] = _pointsToJson();
    }

    if (holes != null) {
      json['holes'] = _holesToJson();
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
    bool comp = other is Polygon &&
        id == other.id &&
        fillColor == other.fillColor &&
        geodesic == other.geodesic &&
        listEquals(points, other.points) &&
        const DeepCollectionEquality().equals(holes, other.holes) &&
        visible == other.visible &&
        strokeColor == other.strokeColor &&
        strokeWidth == other.strokeWidth &&
        zIndex == other.zIndex;
    return other is Polygon && 
        id == other.id &&
        fillColor == other.fillColor &&
        geodesic == other.geodesic &&
        listEquals(points, other.points) &&
        const DeepCollectionEquality().equals(holes, other.holes) &&
        visible == other.visible &&
        strokeColor == other.strokeColor &&
        strokeWidth == other.strokeWidth &&
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

  List<List<Object>> _holesToJson() {
    final List<List<Object>> result = <List<Object>>[];
    for (final List<LatLng> hole in holes) {
      final List<Object> jsonHole = <Object>[];
      for (final LatLng point in hole) {
        jsonHole.add(point.toJson());
      }
      result.add(jsonHole);
    }
    return result;
  }

  ggmap.Polygon toGoogle() {
    return ggmap.Polygon(
        polygonId: ggmap.PolygonId(id),
        consumeTapEvents: onTap != null,
        fillColor: fillColor,
        geodesic: geodesic,
        points: points.map((e) => e.toGoogle()).toList(),
        holes: holes.map((list) => list.map((e) => e.toGoogle()).toList()).toList(),
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        visible: visible,
        zIndex: zIndex,
        onTap: onTap
    );
  }

  vtmap.FillOptions toFillOptions() {
    return vtmap.FillOptions(
      geometry: [
        points.map((e) => e.toViettel()).toList(),
        ...holes.map((list) => list.map((e) => e.toViettel()).toList()).toList()
      ],
      fillColor: fillColor.toHex(),
      fillOpacity: fillColor.opacity,
      // fillOutlineColor: strokeColor.toRGBA(),
    );
  }

  List<vtmap.LineOptions> getOutlineLineOptions() {
    List<vtmap.LineOptions> result = [];

    result.add(_toFillOutline(points));

    for (final hole in holes) {
      result.add(_toFillOutline(hole));
    }

    return result;
  }

  vtmap.LineOptions _toFillOutline(List<LatLng> points) {
    points = List.from(points);
    if (points.length > 2) {
      //to connect first point and last point
      points.add(points[0]);
      //connect second point too to remove the little gap of first and last point
      points.add(points[1]);
    }
    return vtmap.LineOptions(
      geometry: points.map((e) => e.toViettel()).toList(),
      lineWidth: strokeWidth * Constant.vtStrokeWidthMultiplier,
      lineColor: strokeColor.toRGBA(),
      lineOpacity: strokeColor.opacity,
      lineJoin: "round",
    );
  }
}
