import '../controllers/core_map_controller.dart';

class CoreMapCallbacks {
  CoreMapCallbacks({
    this.onMapCreated,
  });


  final void Function(CoreMapController controller)? onMapCreated;


  CoreMapCallbacks copyWith() {
    return CoreMapCallbacks(
      onMapCreated: onMapCreated,
    );
  }
}