import 'dart:ui';

import 'package:maps_core/maps/models/lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/models/polygon.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

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

  vtmap.Fill toViettel() {
    return vtmap.Fill(polygonId, vtmap.FillOptions(
      fillColor: fillColor.toHex(),
      fillOpacity: fillColor.alpha / 255,
      fillOutlineColor: strokeColor.toHex(),
    ));
  }
}