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