import 'dart:ui';

import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;
import 'package:maps_core/maps/models/viettel/viettel_polygon.dart';

extension ConvertColor on Color {
  String toHex() {
    String hexString = value.toRadixString(16);

    return '#${hexString.substring(2, hexString.length)}';
  }
}


extension Convert on LatLng {
  ggmap.LatLng toGoogle() {
    return ggmap.LatLng(lat, lng);
  }

  vtmap.LatLng toViettel() {
    return vtmap.LatLng(lat, lng);
  }
}

extension ConvertPolygon on Polygon {
  ggmap.Polygon toGoogle() {
    return ggmap.Polygon(
      polygonId: ggmap.PolygonId(id),
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

extension ConvertJointType on JointType {
  ggmap.JointType toGoogle() {
    switch (this) {
      case JointType.bevel:
        return ggmap.JointType.bevel;
      case JointType.mitered:
        return ggmap.JointType.mitered;
      case JointType.round:
        return ggmap.JointType.round;
      default:
        return ggmap.JointType.bevel;
    }
  }

  String toViettel() {
    switch (this) {
      case JointType.bevel:
        return "bevel";
      case JointType.mitered:
        return "mitered";
      case JointType.round:
        return "round";
      default:
        return "bevel";
    }
  }
}

extension ConvertPolyline on Polyline {
  ggmap.Polyline toGoogle() {
    return ggmap.Polyline(
      polylineId: ggmap.PolylineId(id),
      consumeTapEvents: consumeTapEvents,
      color: color,
      geodesic: geodesic,
      jointType: jointType.toGoogle(),
      visible: visible,
      onTap: onTap,
      width: width,
      zIndex: zIndex,
    );
  }

  vtmap.LineOptions toLineOptions() {
    return vtmap.LineOptions(
      geometry: points.toViettel(),
      lineWidth: width.toDouble(),
      lineColor: color.toHex(),
      lineJoin: jointType.toViettel()
    );
  }
}