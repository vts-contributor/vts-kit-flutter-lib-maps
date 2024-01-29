import 'package:maps_core/maps.dart';

class CoreMapControllerWrapper implements CoreMapController {
  late CoreMapController _innerController;


  set innerController(CoreMapController value) {
    _innerController = value;
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate, {int? duration}) {
    return _innerController.animateCamera(cameraUpdate, duration: duration);
  }

  @override
  CameraPosition getCurrentPosition() {
    return _innerController.getCurrentPosition();

  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return _innerController.getLatLng(screenCoordinate);
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return _innerController.getScreenCoordinate(latLng);
  }

  @override
  Future<void> hideInfoWindow(MarkerId markerId) {
    return _innerController.hideInfoWindow(markerId);
  }

  @override
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return _innerController.moveCamera(cameraUpdate);
  }

  @override
  void onMarkerTapSetInfoWindow(MarkerId markerId) {
    return _innerController.onMarkerTapSetInfoWindow(markerId);
  }

  @override
  Future<void> showInfoWindow(MarkerId markerId) {
    return _innerController.showInfoWindow(markerId);
  }
  
}