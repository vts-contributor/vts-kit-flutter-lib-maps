import '../models/models.dart';

//This interface should only be used by client
//If you're a maintainer, please make your new controller extends BaseCoreMapController
abstract class CoreMapController {
  ///get current [CameraPosition]
  CameraPosition getCurrentPosition();

  ///get coordinate on screen by pixels
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng);

  ///get location on map from screen coordinate
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate);

  /// Starts an animated change of the map camera position.
  ///
  /// We've decided that moveCamera method is not suitable and highly possible to lead to
  /// unexpected behavior so it won't be provided
  Future<void> animateCamera(CameraUpdate cameraUpdate);
}


