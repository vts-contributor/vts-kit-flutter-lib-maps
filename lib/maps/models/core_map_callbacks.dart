import 'package:maps_core/maps.dart';

import '../controllers/core_map_controller.dart';

class CoreMapCallbacks {
  CoreMapCallbacks({
    this.onMapCreated,
    this.onChangeMapType,
    this.onCameraMove,
  });

  ///Map is ready to be used
  final void Function(CoreMapController controller)? onMapCreated;

  ///called before switching type
  final void Function(CoreMapData data, CoreMapType oldType, CoreMapType newType)? onChangeMapType;

  final void Function(CameraPosition position)? onCameraMove;

  CoreMapCallbacks copyWith({
    void Function(CoreMapController controller)? onMapCreated,
    void Function(CoreMapData data, CoreMapType oldType, CoreMapType newType)? onChangeMapType,
    final void Function(CameraPosition position)? onCameraMove,
  }) {
    return CoreMapCallbacks(
      onMapCreated: onMapCreated ?? this.onMapCreated,
      onChangeMapType: onChangeMapType ?? this.onChangeMapType,
      onCameraMove: onCameraMove ?? this.onCameraMove
    );
  }
}