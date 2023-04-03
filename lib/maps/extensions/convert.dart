import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/constants.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

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

extension VTLatLngConvert on vtmap.LatLng {
  LatLng toCore() {
    return LatLng(latitude, longitude);
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
    points = List.from(points);
    if (points.length > 2) {
      points.add(points.first);
    }
    return vtmap.LineOptions(
      geometry: points.map((e) => e.toViettel()).toList(),
      lineWidth: strokeWidth * Constant.vtStrokeWidthMultiplier,
      lineColor: strokeColor.toHex(),
      lineOpacity: strokeColor.opacity,
      lineJoin: "round"
    );
  }
}

extension CameraPositionConvert on CameraPosition {
  vtmap.CameraPosition toViettel() {
    return vtmap.CameraPosition(
      target: target.toViettel(),
      bearing: bearing,
      tilt: tilt,
      zoom: zoom.toZoomViettel()
    );
  }

  ggmap.CameraPosition toGoogle() {
    return ggmap.CameraPosition(
        target: target.toGoogle(),
        bearing: bearing,
        tilt: tilt,
        //persist with vtmap_gl zoom
        zoom: zoom.toZoomGoogle()
    );
  }
}

extension VTCameraPositionConvert on vtmap.CameraPosition {
  CameraPosition toCore() {
    return CameraPosition(
      target: target.toCore(),
      bearing: bearing,
      tilt: tilt,
      zoom: zoom.toZoomCore(CoreMapType.viettel)
    );
  }
}

extension GGCameraPositionConvert on ggmap.CameraPosition {
  CameraPosition toCore() {
    return CameraPosition(
        target: target.toCore(),
        bearing: bearing,
        tilt: tilt,
        zoom: zoom.toZoomCore(CoreMapType.google)
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
      consumeTapEvents: onTap != null,
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
      circleStrokeColor: strokeColor.toHex(),
      circleStrokeWidth: strokeWidth.toDouble(),
      circleOpacity: fillColor.opacity,
      circleStrokeOpacity: strokeColor.opacity
    );
  }

  vtmap.FillOptions toFillOptions([List<LatLng>? points]) {
    points ??= toCirclePoints();
    return vtmap.FillOptions(
      geometry: [points.toViettel()],
      fillColor: fillColor.toHex(),
      fillOpacity: fillColor.opacity,
    );
  }

  vtmap.LineOptions toLineOptions([List<LatLng>? points]) {
    points ??= toCirclePoints();
    if (points.length > 2) {
      points.add(points.first);
    }
    return vtmap.LineOptions(
      geometry: points.toViettel(),
      lineWidth: (strokeWidth * Constant.vtStrokeWidthMultiplier).toDouble(),
      lineColor: strokeColor.toHex(),
      lineOpacity: strokeColor.opacity,
      lineJoin: "round",
    );
  }

  ///see https://github.com/flutter-mapbox-gl/maps/issues/355#issuecomment-777289787
  ///add 320 points
  List<LatLng> toCirclePoints() {
    final point = center;
    int dir = 1;

    var d2r = pi / 180; // degrees to radians
    var r2d = 180 / pi; // radians to degrees
    var earthsradius = 6371000; // radius of the earth in meters

    var points = 160;

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

extension InfoWindowConvert on InfoWindow {
  ggmap.InfoWindow toGoogle() {
    return ggmap.InfoWindow(
      title: title,
      snippet: snippet,
      anchor: anchor.offset,
      onTap: onTap
    );
  }
}

extension MarkerConvert on Marker {
  ggmap.Marker toGoogle(Uint8List markerBitmap) {
    ggmap.BitmapDescriptor markerDescriptor;

    markerDescriptor = ggmap.BitmapDescriptor.fromBytes(markerBitmap);

    return ggmap.Marker(
      markerId: ggmap.MarkerId(id),
      alpha: alpha,
      anchor: anchor.offset,
      consumeTapEvents: onTap != null,
      draggable: draggable,
      flat: flat,
      icon: markerDescriptor,
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
      iconImage: icon.data.name,
      iconColor: Colors.blue.toHex(),
      iconAnchor: anchor.string,
      draggable: draggable,
      zIndex: zIndex.toInt()
      // textField: infoWindow.title,
      // textAnchor: infoWindow.anchor.toString()
    );
  }
}

extension AnchorConvert on Anchor {
  Offset get offset {
    switch(this) {
      case Anchor.center:
        return const Offset(0.5, 0.5);
      case Anchor.top:
        return const Offset(0.5, 0);
      case Anchor.bottom:
        return const Offset(0.5, 1);
      case Anchor.left:
        return const Offset(0, 0.5);
      case Anchor.right:
        return const Offset(1, 0.5);
      case Anchor.topLeft:
        return const Offset(0, 0);
      case Anchor.topRight:
        return const Offset(1, 0);
      case Anchor.bottomLeft:
        return const Offset(0, 1);
      case Anchor.bottomRight:
        return const Offset(1, 1);
    }
  }

  String get string {
    switch(this) {
      case Anchor.center:
        return "center";
      case Anchor.top:
        return "top";
      case Anchor.bottom:
        return "bottom";
      case Anchor.left:
        return "left";
      case Anchor.right:
        return "right";
      case Anchor.topLeft:
        return "top-left";
      case Anchor.topRight:
        return "top-right";
      case Anchor.bottomLeft:
        return "bottom-left";
      case Anchor.bottomRight:
        return "bottom-right";
    }
  }
}

extension ScreenCoordinateConvert on ScreenCoordinate {
  ggmap.ScreenCoordinate toGoogle() {
    return ggmap.ScreenCoordinate(
      x: x,
      y: y,
    );
  }

  Point<double> toPoint() {
    return Point(x.toDouble(), y.toDouble());
  }
}

extension GoogleScreenCoordinateConvert on ggmap.ScreenCoordinate {
  ScreenCoordinate toCore() {
    return ScreenCoordinate(x: x, y: y);
  }
}

extension ViettelScreenCoordinateConvert on Point<num> {
  ScreenCoordinate toScreenCoordinate() {
    return ScreenCoordinate(x: x.toInt(), y: y.toInt());
  }
}

extension LatLngBoundsConvert on LatLngBounds {
  ggmap.LatLngBounds toGoogle() {
    return ggmap.LatLngBounds(
      northeast: northeast.toGoogle(),
      southwest: southwest.toGoogle(),
    );
  }
  vtmap.LatLngBounds toViettel() {
    return vtmap.LatLngBounds(
      northeast: northeast.toViettel(),
      southwest: southwest.toViettel(),
    );
  }
}

extension ZoomLevelConvert on double {
  double toZoomGoogle() {
    double zoom = validCoreZoomLevel;
    return zoom > 1? zoom + 1: zoom;
  }

  double toZoomCore(CoreMapType type) {
    double zoom = validCoreZoomLevel;
    switch (type) {
      case CoreMapType.google:
        return zoom > 1? zoom - 1: zoom;
      case CoreMapType.viettel:
        return zoom;
    }
  }

  double toZoomViettel() {
    return validCoreZoomLevel;
  }
}

extension MinMaxZoomPreferenceConvert on MinMaxZoomPreference {
  ggmap.MinMaxZoomPreference toGoogle() {
    return ggmap.MinMaxZoomPreference(minZoom, maxZoom);
  }

  vtmap.MinMaxZoomPreference toViettel() {
    return vtmap.MinMaxZoomPreference(minZoom, maxZoom);
  }
}

extension CameraTargetBoundsConvert on CameraTargetBounds {
  ggmap.CameraTargetBounds toGoogle() {
    return ggmap.CameraTargetBounds(bounds?.toGoogle());
  }

  vtmap.CameraTargetBounds toViettel() {
    return vtmap.CameraTargetBounds(bounds?.toViettel());
  }
}