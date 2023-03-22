import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/polygon.dart';
import 'package:maps_core/maps/models/polyline.dart';

import '../../models/core_map_data.dart';
import '../core_map_controller.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

class GoogleMapController extends BaseCoreMapController with ChangeNotifier {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController controller;

  CoreMapData _data;

  GoogleMapController(this.controller, {
    required CoreMapData data,
    CoreMapCallbacks? callback,
  }): _data = data, super(callback);


  @override
  Future<void> addPolygon(Polygon polygon) async {
    _data.polygons.add(polygon);
    notifyListeners();
  }

  @override
  Future<bool> removePolygon(String polygonId) async {
    _data.polygons.removeWhere((polygon) => polygon.id == polygonId);
    notifyListeners();
    return true;
  }

  @override
  CoreMapData get data => _data;

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

  @override
  Future<void> addPolyline(Polyline polyline) async {
    _data.polylines.add(polyline);
    notifyListeners();
  }

  @override
  Future<void> removePolyline(String polylineId) async {
    _data.polylines.removeWhere((polyline) => polyline.id == polylineId);
    notifyListeners();
  }
  
  
}