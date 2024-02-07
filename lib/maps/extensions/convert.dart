import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
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
  
  String toRGBA() {
    return "rgba($red, $green, $blue, $opacity)";
  }

  String? toViettel() {
    return Platform.isAndroid? toRGBA(): toHex();
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

double mWorldWidth = 1;

extension LatLngConvert on LatLng {
  PointMarker toPoint() {
    final double x = longitude / 360 + .5;
    final double siny = sin(latitude * pi / 180);
    final double y = 0.5 * log((1 + siny) / (1 - siny)) / -(2 * pi) + .5;

    return PointMarker(x * mWorldWidth, y * mWorldWidth);
  }
}

extension PointConvert on PointMarker {
  LatLng toLatLng() {
    final double a = x / mWorldWidth - 0.5;
    final double lng = a * 360;

    double b = .5 - (y / mWorldWidth);
    final double lat = 90 - (atan(exp(-b * 2 * pi)) * 2 * 180 / pi);

    return LatLng(lat, lng);
  }

  BoundMarker toBoundFromSpan(double span) {
    double halfSpan = span / 2;

    return BoundMarker(x - halfSpan, x + halfSpan, y - halfSpan, y + halfSpan);
  }
}

extension MarkerConvert on Marker {
  MarkerCover toMarkerCover() {
    MarkerCover markerCover = MarkerCover(
      id: id,
      position: position,
      alpha: alpha,
      anchor: anchor,
      draggable: draggable,
      flat: flat,
      icon: icon,
      infoWindow: infoWindow,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
      onDragStart: onDragStart,
      onTap: onTap,
      rotation: rotation,
      visible: visible,
      zIndex: zIndex,
      positionMarkerCover: position,
      isCanCluster: isCanCluster,
    );

    return markerCover;
  }
}
