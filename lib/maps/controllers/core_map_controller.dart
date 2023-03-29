import '../models/models.dart';

//This interface should only be used by client
//If you're a maintainer, please make your new controller extends BaseCoreMapController
abstract class CoreMapController {

  CoreMapType get coreMapType;
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
  void changeMapType(CoreMapType type);

  CameraPosition getCurrentPosition();

  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng);
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate);

  Future<void> moveCamera(CameraUpdate cameraUpdate);

  Future<void> animateCamera(CameraUpdate cameraUpdate);
}


