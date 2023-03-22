import '../models/models.dart';
import '../models/polyline.dart';

abstract class CoreMapController {

  CoreMapType get coreMapType;
  CoreMapData get data;

  Future<void> addPolygon(Polygon polygon);
  Future<void> removePolygon(String polygonId);
  Future<void> reloadWithData(CoreMapData data);
  void changeMapType(CoreMapType type);
  Future<void> addPolyline(Polyline polyline);
  Future<void> removePolyline(String polylineId);
}

