import '../models/models.dart';

//This interface should only be used by client
//If you're a maintainer, please make your new controller extends BaseCoreMapController
abstract class CoreMapController {

  ///current type of the map
  CoreMapType get coreMapType;

  ///current data of the map
  CoreMapData get data;

  Future<void> addPolygon(Polygon polygon);
  Future<void> removePolygon(String polygonId);

  Future<void> addPolyline(Polyline polyline);
  Future<void> removePolyline(String polylineId);

  Future<void> addCircle(Circle circle);
  Future<void> removeCircle(String circleId);

  Future<void> addMarker(Marker marker);
  Future<void> removeMarker(String markerId);

  Future<void> reloadWithData(CoreMapData data);

  ///change current CoreMap type, all data will be reserved
  void changeMapType(CoreMapType type);

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


