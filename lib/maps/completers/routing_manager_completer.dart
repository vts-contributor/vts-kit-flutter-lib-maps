import 'dart:async';

import '../views/managers/routing_manager.dart';

///used to wrap the controller instance in case of map type switching
class RoutingManagerCompleter {
  late Completer<RoutingManager> _completer = Completer();

  Future<RoutingManager> get controller => _completer.future;

  ///complete with a controller
  void complete(RoutingManager controller) {
    if (_completer.isCompleted) {
      _completer = Completer();
    }

    _completer.complete(controller);
  }

}