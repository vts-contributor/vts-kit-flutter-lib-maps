import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/constants.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;
import 'package:maps_core/maps/models/viettel/viettel_polygon.dart';

extension ColorConvert on Color {
  String? toHex() {
    if (this == Colors.transparent) {
      return null;
    } else {
      String hexString = value.toRadixString(16);

      return '#${hexString.substring(2, hexString.length)}';
    }
  }

  double? get opacity => this == Colors.transparent? null: alpha / 255;
}


extension LatLngConvert on LatLng {
  ggmap.LatLng toGoogle() {
    return ggmap.LatLng(lat, lng);
  }

  vtmap.LatLng toViettel() {
    return vtmap.LatLng(lat, lng);
  }
}

extension GoogleLatLngConvert on ggmap.LatLng {
  LatLng toCore() {
    return LatLng(latitude, longitude);
  }
}

extension PolygonConvert on Polygon {
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
      fillOpacity: fillColor.opacity,
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
      lineOpacity: strokeColor.opacity,
    );
  }
}

extension CameraPositionConvert on CameraPosition {
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

extension JointTypeConvert on JointType {
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

extension PolylineConvert on Polyline {
  ggmap.Polyline toGoogle() {
    return ggmap.Polyline(
      polylineId: ggmap.PolylineId(id),
      consumeTapEvents: consumeTapEvents,
      color: color,
      geodesic: geodesic,
      jointType: jointType.toGoogle(),
      points: points.toGoogle(),
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
      lineJoin: jointType.toViettel(),
      lineOpacity: color.opacity
    );
  }
}

extension CircleConvert on Circle {
  ggmap.Circle toGoogle() {
    return ggmap.Circle(
      circleId: ggmap.CircleId(id),
      consumeTapEvents: consumeTapEvents,
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
      circleStrokeColor: strokeColor.toHex(),
      circleStrokeWidth: strokeWidth.toDouble(),
      circleOpacity: fillColor.opacity,
      circleStrokeOpacity: strokeColor.opacity
    );
  }
}

extension InfoWindowConvert on InfoWindow {
  ggmap.InfoWindow toGoogle() {
    return ggmap.InfoWindow(
      title: title,
      snippet: snippet,
      anchor: anchor,
      onTap: onTap
    );
  }
}

extension MarkerConvert on Marker {
  ggmap.Marker toGoogle() {
    return ggmap.Marker(
      markerId: ggmap.MarkerId(id),
      alpha: alpha,
      anchor: anchor,
      consumeTapEvents: consumeTapEvents,
      draggable: draggable,
      flat: flat,
      icon: ggmap.BitmapDescriptor.defaultMarker,
      infoWindow: infoWindow.toGoogle(),
      position: position.toGoogle(),
      rotation: rotation,
      visible: visible,
      zIndex: zIndex,
      onTap: onTap,
      onDrag: (ggmap.LatLng value) => onDrag?.call(value.toCore()),
      onDragStart: (ggmap.LatLng value) => onDragStart?.call(value.toCore()),
      onDragEnd: (ggmap.LatLng value) => onDragEnd?.call(value.toCore()),
    );
  }

  vtmap.SymbolOptions toSymbolOptions() {
    return vtmap.SymbolOptions(
      geometry: position.toViettel(),
      iconImage: Constant.markerAssetName,
      textField: infoWindow.title,
    );
  }
}