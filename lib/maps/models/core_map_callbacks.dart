import 'dart:ui';

import 'package:location/location.dart';
import 'package:maps_core/maps.dart';

class CoreMapCallbacks {
  CoreMapCallbacks({
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraMoveStarted,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.onUserLocationUpdated,
    this.onServiceDisabled,
    this.onPermissionDenied,
    this.onPermissionDeniedForever,
  });

  ///Map is ready to be used
  final void Function(CoreMapController controller)? onMapCreated;

  final void Function(CameraPosition position)? onCameraMove;

  final VoidCallback? onCameraMoveStarted;

  final VoidCallback? onCameraIdle;

  final void Function(LatLng latLng)? onTap;

  final void Function(LatLng latLng)? onLongPress;

  ///This will be called periodically even if [userLocation] doesn't change.
  final void Function(LocationData userLocation)? onUserLocationUpdated;

  final Future<bool> Function()? onServiceDisabled;

  final Future<bool> Function()? onPermissionDenied;

  final Future<bool> Function()? onPermissionDeniedForever;

  CoreMapCallbacks copyWith({
    final void Function(CoreMapController controller)? onMapCreated,
    final void Function(CameraPosition position)? onCameraMove,
    final VoidCallback? onCameraMoveStarted,
    final VoidCallback? onCameraIdle,
    final void Function(LatLng latLng)? onTap,
    final void Function(LatLng latLng)? onLongPress,
    final void Function(LocationData userLocation)? onUserLocationUpdated,
    final Future<bool> Function()? onServiceDisabled,
    final Future<bool> Function()? onPermissionDenied,
    final Future<bool> Function()? onPermissionDeniedForever,
  }) {
    return CoreMapCallbacks(
      onMapCreated: onMapCreated ?? this.onMapCreated,
      onCameraMove: onCameraMove ?? this.onCameraMove,
      onCameraMoveStarted: onCameraMoveStarted ?? this.onCameraMoveStarted,
      onCameraIdle: onCameraIdle ?? this.onCameraIdle,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onUserLocationUpdated: onUserLocationUpdated ?? this.onUserLocationUpdated,
      onServiceDisabled: onServiceDisabled ?? this.onServiceDisabled,
      onPermissionDenied: onPermissionDenied ?? this.onPermissionDenied,
      onPermissionDeniedForever: onPermissionDeniedForever ?? this.onPermissionDeniedForever,
    );
  }
}