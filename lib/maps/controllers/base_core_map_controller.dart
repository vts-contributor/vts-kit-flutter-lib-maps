import 'dart:typed_data';

import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';

abstract class BaseCoreMapController implements CoreMapController {
  final CoreMapCallbacks? callbacks;

  final String logTag = "CORE MAP CONTROLLER";

  BaseCoreMapController(this.callbacks);

  @override
  void changeMapType(CoreMapType type) {
    if (coreMapType == type) {
      Log.e(logTag, "new map type is the same as current type: $type");
      return;
    }

    callbacks?.onChangeMapType?.call(getCurrentData(), coreMapType, type);

    //After map has been changed, the controller is re-created so should free resources here
    onDispose();
  }

  void onDispose();

  ///Need to persist camera position
  CoreMapData getCurrentData() {
    return data.copyWith(
      initialCameraPosition: getCurrentPosition()
    );
  }
}