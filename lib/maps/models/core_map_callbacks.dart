import 'dart:ui';

import 'package:geolocator/geolocator.dart';
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
    this.onLocationServiceDisabled,
    this.onLocationPermissionDenied,
    this.onLocationPermissionDeniedForever,
    this.onRoutingManagerReady,
  });

  ///Map is ready to be used
  final void Function(CoreMapController controller)? onMapCreated;

  ///listener for camera position changes.
  final void Function(CameraPosition position)? onCameraMove;

  ///camera starts moving
  final VoidCallback? onCameraMoveStarted;

  ///camera idling
  final VoidCallback? onCameraIdle;

  ///listen to user's tap on the map
  final void Function(LatLng latLng)? onTap;

  ///listen to user's long press on the map
  final void Function(LatLng latLng)? onLongPress;

  ///This will be called periodically even if [userLocation] doesn't change.
  final void Function(Position userLocation)? onUserLocationUpdated;

  ///override default handler when location service is disabled.
  final Future<bool> Function()? onLocationServiceDisabled;

  ///override default handler when location permission is denied.
  final Future<bool> Function()? onLocationPermissionDenied;

  ///override default handler when location permission is denied forever.
  final Future<bool> Function()? onLocationPermissionDeniedForever;

  ///routing manager is ready to be used.
  final void Function(RoutingManager)? onRoutingManagerReady;

  CoreMapCallbacks copyWith({
    final void Function(CoreMapController controller)? onMapCreated,
    final void Function(CameraPosition position)? onCameraMove,
    final VoidCallback? onCameraMoveStarted,
    final VoidCallback? onCameraIdle,
    final void Function(LatLng latLng)? onTap,
    final void Function(LatLng latLng)? onLongPress,
    final void Function(Position userLocation)? onUserLocationUpdated,
    final Future<bool> Function()? onLocationServiceDisabled,
    final Future<bool> Function()? onLocationPermissionDenied,
    final Future<bool> Function()? onLocationPermissionDeniedForever,
    final void Function(RoutingManager)? onRoutingManagerReady,
  }) {
    return CoreMapCallbacks(
      onMapCreated: onMapCreated ?? this.onMapCreated,
      onCameraMove: onCameraMove ?? this.onCameraMove,
      onCameraMoveStarted: onCameraMoveStarted ?? this.onCameraMoveStarted,
      onCameraIdle: onCameraIdle ?? this.onCameraIdle,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onUserLocationUpdated: onUserLocationUpdated ?? this.onUserLocationUpdated,
      onLocationServiceDisabled: onLocationServiceDisabled ?? this.onLocationServiceDisabled,
      onLocationPermissionDenied: onLocationPermissionDenied ?? this.onLocationPermissionDenied,
      onLocationPermissionDeniedForever: onLocationPermissionDeniedForever ?? this.onLocationPermissionDeniedForever,
      onRoutingManagerReady: onRoutingManagerReady ?? this.onRoutingManagerReady,
    );
  }
}