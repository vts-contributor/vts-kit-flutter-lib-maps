import 'dart:async';

import 'package:maps_core/maps/controllers/core_map_controller.dart';

///used to wrap the controller instance in case of map type switching
class CoreMapControllerCompleter {
  late Completer<CoreMapController> _completer = Completer();

  Future<CoreMapController> get controller async => _completer.future;

  void complete(CoreMapController controller) {
    if (_completer.isCompleted) {
      _completer.completeError(NullThrownError());
    } else {

    }

    _completer = Completer();
    _completer.complete();
  }

}