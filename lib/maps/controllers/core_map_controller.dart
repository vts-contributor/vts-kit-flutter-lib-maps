import 'package:maps_core/maps.dart';

import '../models/models.dart';

//This interface should only be used by client
//If you're a maintainer, please make your new controller extends BaseCoreMapController
abstract class CoreMapController implements InfoWindowManager {
  ///get current [CameraPosition]
  CameraPosition getCurrentPosition();

  ///get coordinate on screen by pixels
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng);

  ///get location on map from screen coordinate
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate);

  /// Starts an animated change of the map camera position.
  /// The animate process may be interrupted by map state rebuild with [CoreMapType.viettel]
  /// => camera will stop before reaching its final destination
  ///
  /// Duration won't take effect in [CoreMapType.google]
  ///
  /// see https://github.com/flutter/flutter/issues/39810
  Future<void> animateCamera(CameraUpdate cameraUpdate, {int? duration});

  ///This may lead to unexpected behaviors of [getCurrentPosition] like:
  ///- [getCurrentPosition] won't be updated
  ///- [CoreMapCallbacks.onCameraMove] may return wrong CameraPosition (old lat lng, wrong zoom)
  ///
  ///If you can, please use [animateCamera] with duration = 1 instead.
  Future<void> moveCamera(CameraUpdate cameraUpdate);
}


