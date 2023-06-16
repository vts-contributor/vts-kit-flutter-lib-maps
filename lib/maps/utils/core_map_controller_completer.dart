import 'dart:async';

import 'package:maps_core/maps/controllers/core_map_controller.dart';

///used to wrap the controller instance in case of map type switching
class ReusableCompleter<T> {
  late Completer<T> _completer = Completer();

  Future<T> get value => _completer.future;

  ///complete with a controller
  void complete(T value) {
    if (_completer.isCompleted) {
      _completer = Completer();
    }

    _completer.complete(value);
  }

}