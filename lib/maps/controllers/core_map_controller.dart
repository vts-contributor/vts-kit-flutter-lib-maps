import '../models/models.dart';
import '../models/polyline.dart';

abstract class CoreMapController {

  CoreMapType get coreMapType;
  CoreMapData get data;

  Future<void> addPolygon(Polygon polygon);
  Future<void> removePolygon(String polygonId);

  Future<void> addPolyline(Polyline polyline);
  Future<void> removePolyline(String polylineId);

  Future<void> addCircle(Circle circle);
  Future<void> removeCircle(Circle circle);

  Future<void> addMarker(Marker marker);
  Future<void> removeMarker(Marker marker);

  Future<void> reloadWithData(CoreMapData data);
  void changeMapType(CoreMapType type);
}

