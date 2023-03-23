import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/map_objects/map_object.dart';

import '../../../maps.dart';
import '../../models/core_map_data.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

class GoogleMapController extends BaseCoreMapController with ChangeNotifier {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController controller;

  CoreMapData _data;

  @override
  CoreMapData get data => _data;

  GoogleMapController(this.controller, {
    required CoreMapData data,
    CoreMapCallbacks? callback,
  }): _data = data, super(callback);


  @override
  Future<void> addPolygon(Polygon polygon) async {
   _addMapObject(polygon, data.polygons);
  }

  @override
  Future<void> removePolygon(String polygonId) async {
    _removeMapObject(polygonId, data.polygons);
  }

  @override
  Future<void> addPolyline(Polyline polyline) async {
    _addMapObject(polyline, data.polylines);
  }

  @override
  Future<void> removePolyline(String polylineId) async {
    _removeMapObject(polylineId, data.polylines);
  }

  @override
  Future<void> addCircle(Circle circle) async {
    _addMapObject(circle, data.circles);
  }

  @override
  Future<void> removeCircle(String circleId) async {
    _removeMapObject(circleId, data.circles);
  }

  @override
  Future<void> addMarker(Marker marker) async {
    _addMapObject(marker, data.markers);
  }

  @override
  Future<void> removeMarker(String markerId) async {
    _removeMapObject(markerId, data.markers);
  }

  void _addMapObject(MapObject object, Set<MapObject> objects) {
    if (!objects.any((element) => element.id == object.id)) {
      objects.add(object);
      notifyListeners();
    }
  }

  void _removeMapObject(String objectId, Set<MapObject> objects) {
    objects.removeWhere((element) => element.id == objectId);
    notifyListeners();
  }

  @override
  Future<void> reloadWithData(CoreMapData data) async {
    _data = data;
    controller.moveCamera(gg.CameraUpdate.newCameraPosition(
        data.initialCameraPosition.toGoogle()));
    notifyListeners();
  }

  @override
  void onDispose() {
    dispose();
    controller.dispose();
  }

}