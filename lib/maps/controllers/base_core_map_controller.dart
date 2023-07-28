part of core_map;

abstract class BaseCoreMapController implements CoreMapController {
  CoreMapCallbacks? callbacks;

  final String logTag = "CORE MAP CONTROLLER";

  BaseCoreMapController(this.callbacks);

  void onDispose();
}