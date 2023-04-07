import 'dart:ui';

import 'package:location/location.dart';
import 'package:maps_core/maps.dart';

import '../controllers/core_map_controller.dart';

class CoreMapCallbacks {
  CoreMapCallbacks({
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraMoveStarted,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.onUserPositionChanged,
  });

  ///Map is ready to be used
  final void Function(CoreMapController controller)? onMapCreated;

  final void Function(CameraPosition position)? onCameraMove;

  final VoidCallback? onCameraMoveStarted;

  final VoidCallback? onCameraIdle;

  final void Function(LatLng latLng)? onTap;

  final void Function(LatLng latLng)? onLongPress;

  final void Function(LocationData position)? onUserPositionChanged;

  CoreMapCallbacks copyWith({
    final void Function(CoreMapController controller)? onMapCreated,
    final void Function(CameraPosition position)? onCameraMove,
    final VoidCallback? onCameraMoveStarted,
    final VoidCallback? onCameraIdle,
    final void Function(LatLng latLng)? onTap,
    final void Function(LatLng latLng)? onLongPress,
    final void Function(LocationData position)? onUserPositionChanged,
  }) {
    return CoreMapCallbacks(
      onMapCreated: onMapCreated ?? this.onMapCreated,
      onCameraMove: onCameraMove ?? this.onCameraMove,
      onCameraMoveStarted: onCameraMoveStarted ?? this.onCameraMoveStarted,
      onCameraIdle: onCameraIdle ?? this.onCameraIdle,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onUserPositionChanged: onUserPositionChanged ?? this.onUserPositionChanged,
    );
  }
}