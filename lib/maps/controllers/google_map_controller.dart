import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/polygon.dart';

import '../models/core_map_data.dart';
import 'core_map_controller.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

class GoogleMapController extends CoreMapController {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController controller;

  GoogleMapController(this.controller, {
    required CoreMapData data,
  }): super(data);

  @override
  Future<void> addPolygon(Polygon polygon) async {
    data.polygons.add(polygon);
    notifyListeners();
  }

  @override
  Future<bool> removePolygon(String polygonId) {
    // TODO: implement removePolygon
    throw UnimplementedError();
  }

  @override
  Future<void> reloadWithData(CoreMapData newData) {
    // TODO: implement reloadWithData
    throw UnimplementedError();
  }

}