import 'dart:ui';

import 'package:maps_core/maps.dart';

import '../controllers/core_map_controller.dart';

class CoreMapCallbacks {
  CoreMapCallbacks({
    this.onMapCreated,
    this.onChangeMapType,
    this.onCameraMove,
    this.onCameraMoveStarted,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  });

  ///Map is ready to be used
  final void Function(CoreMapController controller)? onMapCreated;

  ///called before switching type
  final void Function(CoreMapData data, CoreMapType oldType, CoreMapType newType)? onChangeMapType;

  final void Function(CameraPosition position)? onCameraMove;

  final VoidCallback? onCameraMoveStarted;

  final VoidCallback? onCameraIdle;

  final void Function(LatLng latLng)? onTap;

  final void Function(LatLng latLng)? onLongPress;

  CoreMapCallbacks copyWith({
    final void Function(CoreMapController controller)? onMapCreated,
    final void Function(CoreMapData data, CoreMapType oldType, CoreMapType newType)? onChangeMapType,
    final void Function(CameraPosition position)? onCameraMove,
    final VoidCallback? onCameraMoveStarted,
    final VoidCallback? onCameraIdle,
    final void Function(LatLng latLng)? onTap,
    final void Function(LatLng latLng)? onLongPress,
  }) {
    return CoreMapCallbacks(
      onMapCreated: onMapCreated ?? this.onMapCreated,
      onChangeMapType: onChangeMapType ?? this.onChangeMapType,
      onCameraMove: onCameraMove ?? this.onCameraMove,
      onCameraMoveStarted: onCameraMoveStarted ?? this.onCameraMoveStarted,
      onCameraIdle: onCameraIdle ?? this.onCameraIdle,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
    );
  }
}