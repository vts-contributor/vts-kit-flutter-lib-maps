import 'package:maps_core/maps/controllers/core_map_controller.dart';
import 'package:maps_core/maps/models/core_map_data.dart';
import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/extensions/convert_extensions.dart';
import 'package:maps_core/maps/models/polygon.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

class VTMapController extends CoreMapController {

  final vt.MapboxMapController _controller;

  VTMapController(this._controller, {
    required CoreMapData data,
  }): super(data) {
    init(data);
  }

  Future<void> init(CoreMapData data) async {
    //should not move camera position here
    //because it may be the first init and the VTMap widget has already handled that

  }

  @override
  Future<void> addPolygon(Polygon polygon) async {
    final fill = await _controller.addFill(polygon.toFillOptions());
    data.polygons.add(polygon);
  }

  @override
  CoreMapType get coreMapType => CoreMapType.viettel;

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