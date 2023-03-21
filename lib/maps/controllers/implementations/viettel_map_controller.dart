import 'package:maps_core/extensions/convert.dart';
import 'package:maps_core/extensions/extensions.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/controllers/core_map_controller.dart';
import 'package:maps_core/maps/models/core_map_data.dart';
import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/polygon.dart';
import 'package:maps_core/maps/models/viettel/viettel_polygon.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

import '../../models/core_map_callbacks.dart';
import '../../models/lat_lng.dart';

class ViettelMapController extends BaseCoreMapController {

  final vt.MapboxMapController _controller;

  CoreMapData _data;

  final Map<String, ViettelPolygon> _viettelPolygonMap = {};

  ViettelMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callback,
  }): _data = data, super(callback);

  @override
  CoreMapType get coreMapType => CoreMapType.viettel;

  @override
  Future<void> addPolygon(Polygon polygon) async {
    if (_viettelPolygonMap.containsKey(polygon.polygonId)) {
      return;
    }

    final fill = await _controller.addFill(polygon.toFillOptions());

    final outlineOptions = polygon.getOutlineLineOptions();
    List<Future<vt.Line>> outlineFutures = [];
    for (final outlineOption in outlineOptions) {
      outlineFutures.add(_controller.addLine(outlineOption));
    }
    final outlines = await Future.wait(outlineFutures);

    _viettelPolygonMap.putIfAbsent(polygon.polygonId, () => ViettelPolygon(polygon.polygonId, fill, outlines));
    data.polygons.add(polygon);
  }


  @override
  Future<bool> removePolygon(String polygonId) async {
    if (_viettelPolygonMap.containsKey(polygonId)) {
      final polygon = _viettelPolygonMap[polygonId];

      if (polygon != null) {
        _controller.removeFill(polygon.fill);

        for (final outline in polygon.outlines) {
          _controller.removeLine(outline);
        }

        data.polygons.removeWhere((polygon) => polygon.polygonId == polygonId);
        _viettelPolygonMap.removeWhere((key, value) => key == polygonId);

        return true;
      }
    }

    return false;
  }

  @override
  Future<void> reloadWithData(CoreMapData data) async {
    _data = data;
    _controller.moveCamera(vt.CameraUpdate.newCameraPosition(
        data.initialCameraPosition.toViettel()));

    _clearShapes();
    _addShapes(data);
  }

  @override
  CoreMapData get data => _data;

  @override
  void onDispose() {
    _controller.dispose();
  }

  Future<void> _addShapes(CoreMapData data) async {
    for (var polygon in data.polygons) {
      addPolygon(polygon);
    }
  }

  Future<void> _clearShapes() async {
    _controller.clearCircles();
    _controller.clearLines();
    _controller.clearSymbols();
    _controller.clearRoute();

    _viettelPolygonMap.clear();
  }

  void onMapLoaded() {
    _addShapes(_data);
  }
}