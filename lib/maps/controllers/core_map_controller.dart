import '../models/models.dart';
import '../models/map_objects/polyline.dart';

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
}

