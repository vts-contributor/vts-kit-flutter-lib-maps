import 'dart:ui';

import 'package:maps_core/maps/extensions/convert.dart';

import 'models.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
///
// Because this is a unify interface for different maps and at this time,
// zoom level and related CameraUpdate functions don't behave in the same way
// between GoogleMap and ViettelMap, so we need to check zoom level everytime we need to change it
abstract class CameraUpdate {

  /// Returns a camera update that moves the camera to the specified position.
  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return _NewPositionCameraUpdate(cameraPosition);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location.
  static CameraUpdate newLatLng(LatLng latLng) {
    return _NewLatLngCameraUpdate(latLng);
  }

  /// Returns a camera update that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [padding] insets the bounding box from the
  /// map view's edges. The camera's new tilt and bearing will both be 0.0.
  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) {
    return _NewLatLngBoundsCameraUpdate(bounds, padding);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location and zoom level.
  static CameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    return _NewLatLngZoomCameraUpdate(latLng, zoom);
  }

  /// Returns a camera update that moves the camera target the specified screen
  /// distance.
  ///
  /// For a camera with bearing 0.0 (pointing north), scrolling by 50,75 moves
  /// the camera's target to a geographical location that is 50 to the east and
  /// 75 to the south of the current location, measured in screen coordinates.
  static CameraUpdate scrollBy(double dx, double dy) {
    return _ScrollByCameraUpdate(dx, dy);
  }

  /// Returns a camera update that modifies the camera zoom level by the
  /// specified amount. The optional [focus] is a screen point whose underlying
  /// geographical location should be invariant, if possible, by the movement.
  static CameraUpdate zoomBy(double amount, [Offset? focus]) {
    return _ZoomByCameraUpdate(amount, focus);
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static CameraUpdate zoomIn() {
    return _ZoomInCameraUpdate();
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static CameraUpdate zoomOut() {
    return _ZoomOutCameraUpdate();
  }

  /// Returns a camera update that sets the camera zoom level.
  static CameraUpdate zoomTo(double zoom) {
    return _ZoomToCameraUpdate(zoom);
  }

  //These 2 method sometimes will need currentPosition for zoom level check
  vt.CameraUpdate toViettel();
  gg.CameraUpdate toGoogle();
}

class _NewPositionCameraUpdate implements CameraUpdate {
  CameraPosition cameraPosition;

  _NewPositionCameraUpdate(this.cameraPosition);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.newCameraPosition(cameraPosition.toGoogle());
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.newCameraPosition(cameraPosition.toViettel());
  }
}

class _NewLatLngCameraUpdate implements CameraUpdate {

  LatLng latLng;

  _NewLatLngCameraUpdate(this.latLng);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.newLatLng(latLng.toGoogle());
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.newLatLng(latLng.toViettel());
  }
}

class _NewLatLngBoundsCameraUpdate implements CameraUpdate {

  LatLngBounds bounds;
  double padding;

  _NewLatLngBoundsCameraUpdate(this.bounds, this.padding);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.newLatLngBounds(bounds.toGoogle(), padding);
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.newLatLngBounds(bounds.toViettel(),
        top: padding, bottom: padding, right: padding, left: padding);
  }
}

class _NewLatLngZoomCameraUpdate implements CameraUpdate {

  LatLng latLng;
  double zoom;

  _NewLatLngZoomCameraUpdate(this.latLng, this.zoom);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.newLatLngZoom(latLng.toGoogle(), zoom.toZoomGoogle());
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.newLatLngZoom(latLng.toViettel(), zoom.toZoomViettel());
  }
}

class _ScrollByCameraUpdate implements CameraUpdate {

  double dx;
  double dy;

  _ScrollByCameraUpdate(this.dx, this.dy);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.scrollBy(dx, dy);
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.scrollBy(dx, dy);
  }
}

class _ZoomByCameraUpdate implements CameraUpdate {

  double amount;
  Offset? focus;

  _ZoomByCameraUpdate(this.amount, this.focus);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.zoomBy(amount, focus);
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.zoomBy(amount, focus);
  }
}

class _ZoomInCameraUpdate implements CameraUpdate {
  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.zoomIn();
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.zoomIn();
  }
}

class _ZoomOutCameraUpdate implements CameraUpdate {
  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.zoomOut();
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.zoomOut();
  }
}

class _ZoomToCameraUpdate implements CameraUpdate {

  double zoom;

  _ZoomToCameraUpdate(this.zoom);

  @override
  gg.CameraUpdate toGoogle() {
    return gg.CameraUpdate.zoomTo(zoom.toZoomGoogle());
  }

  @override
  vt.CameraUpdate toViettel() {
    return vt.CameraUpdate.zoomTo(zoom.toZoomViettel());
  }
}
