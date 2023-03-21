import 'dart:ui';

import 'package:maps_core/maps/models/camera_position.dart';
import 'package:maps_core/maps/models/lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/models/polygon.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;
import 'package:maps_core/maps/models/viettel/viettel_polygon.dart';

extension ColorConverter on Color {
  String toHex() {
    String hexString = value.toRadixString(16);

    return '#${hexString.substring(2, hexString.length)}';
  }
}


extension LatLngConvert on LatLng {
  ggmap.LatLng toGoogle() {
    return ggmap.LatLng(lat, lng);
  }

  vtmap.LatLng toViettel() {
    return vtmap.LatLng(lat, lng);
  }
}

extension PolygonConvert on Polygon {
  ggmap.Polygon toGoogle() {
    return ggmap.Polygon(
      polygonId: ggmap.PolygonId(polygonId),
      consumeTapEvents: consumeTapEvents,
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
      fillOpacity: fillColor.alpha / 255,
      fillOutlineColor: strokeColor.toHex(),
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
    //to connect first point and last point
    if (points.length > 2) {
      points.add(points.first);
    }
    return vtmap.LineOptions(
      geometry: points.map((e) => e.toViettel()).toList(),
      lineWidth: strokeWidth.toDouble(),
      lineColor: strokeColor.toHex(),
    );
  }
}

extension ConvertCameraPosition on CameraPosition {
  vtmap.CameraPosition toViettel() {
    return vtmap.CameraPosition(
      target: target.toViettel(),
      bearing: bearing,
      tilt: tilt,
      zoom: zoom
    );
  }

  ggmap.CameraPosition toGoogle() {
    return ggmap.CameraPosition(
        target: target.toGoogle(),
        bearing: bearing,
        tilt: tilt,
        zoom: zoom
    );
  }
}