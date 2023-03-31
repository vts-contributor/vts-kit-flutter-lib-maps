import 'dart:typed_data';

import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';

abstract class BaseCoreMapController implements CoreMapController {
  final CoreMapCallbacks? callbacks;

  final String logTag = "CORE MAP CONTROLLER";

  BaseCoreMapController(this.callbacks);

  void onDispose();
}