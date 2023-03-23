import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/models/viettel/viettel_polygon.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

import '../../../maps.dart';


class ViettelMapController extends BaseCoreMapController {

  final vt.MapboxMapController _controller;

  CoreMapData _data;

  //Store vtmap shapes so that we can remove them
  final Map<String, ViettelPolygon> _viettelPolygonMap = {};
  final Map<String, vt.Line> _viettelPolylineMap = {};
  final Map<String, vt.Circle> _viettelCircleMap = {};
  final Map<String, vt.Symbol> _viettelMarkerMap = {};

  ViettelMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callback,
  }): _data = data, super(callback) {
    initAssets(data);
  }

  @override
  CoreMapType get coreMapType => CoreMapType.viettel;

  void initAssets(CoreMapData data) async {
    _controller.addImageFromAsset(Constant.markerAssetName, Constant.markerAssetPath);
  }

  @override
  Future<void> addPolygon(Polygon polygon) async {
    if (_viettelPolygonMap.containsKey(polygon.id)) {
      return;
    }

    //add a dummy object to map
    _viettelPolygonMap.putIfAbsent(polygon.id, () =>
        ViettelPolygon(polygon.id, vt.Fill("dummy", const vt.FillOptions()), []));

    final fill = await _controller.addFill(polygon.toFillOptions());

    final outlineOptions = polygon.getOutlineLineOptions();
    List<Future<vt.Line>> outlineFutures = [];
    for (final outlineOption in outlineOptions) {
      outlineFutures.add(_controller.addLine(outlineOption));
    }

    final outlines = await Future.wait(outlineFutures);
    _viettelPolygonMap.update(polygon.id, (_) => ViettelPolygon(polygon.id, fill, outlines));
    data.polygons.add(polygon);
  }


  @override
  Future<void> removePolygon(String polygonId) async {
    if (_viettelPolygonMap.containsKey(polygonId)) {
      final polygon = _viettelPolygonMap[polygonId];

      if (polygon != null) {
        _controller.removeFill(polygon.fill);

        for (final outline in polygon.outlines) {
          _controller.removeLine(outline);
        }

        data.polygons.removeWhere((polygon) => polygon.id == polygonId);
        _viettelPolygonMap.removeWhere((key, value) => key == polygonId);
      }
    }
  }

  @override
  Future<void> addPolyline(Polyline polyline) async {
    if (_viettelPolylineMap.containsKey(polyline.id)) {
      return;
    }

    //add a dummy object to map
    _viettelPolylineMap.putIfAbsent(polyline.id, () => vt.Line("dummy", const vt.LineOptions()));
    final line = await _controller.addLine(polyline.toLineOptions());

    _viettelPolylineMap.update(polyline.id, (_) => line);
    data.polylines.add(polyline);
  }

  @override
  Future<void> removePolyline(String polylineId) async {
    if (_viettelPolylineMap.containsKey(polylineId)) {
      final line = _viettelPolylineMap[polylineId];

      if (line != null) {
        _controller.removeLine(line);

        data.polylines.removeWhere((e) => e.id == polylineId);
        _viettelPolylineMap.removeWhere((key, value) => key == polylineId);
      }
    }
  }

  @override
  Future<void> addCircle(Circle circle) async {
    if (_viettelCircleMap.containsKey(circle.id)) {
      return;
    }

    //add a dummy object to map
    _viettelCircleMap.putIfAbsent(circle.id, () => vt.Circle("dummy", const vt.CircleOptions()));
    final vtCircle = await _controller.addCircle(circle.toCircleOptions());

    _viettelCircleMap.update(circle.id, (_) => vtCircle);
    data.circles.add(circle);
  }

  @override
  Future<void> removeCircle(String circleId) async {
    if (_viettelCircleMap.containsKey(circleId)) {
      final circle = _viettelCircleMap[circleId];

      if (circle != null) {
        _controller.removeCircle(circle);

        data.circles.removeWhere((e) => e.id == circleId);
        _viettelCircleMap.removeWhere((key, value) => key == circleId);
      }
    }
  }

  @override
  Future<void> addMarker(Marker marker) async {
    if (_viettelMarkerMap.containsKey(marker.id)) {
      return;
    }

    //add a dummy object to map
    _viettelMarkerMap.putIfAbsent(marker.id, () => vt.Symbol("dummy", const vt.SymbolOptions()));
    final symbol = await _controller.addSymbol(marker.toSymbolOptions());

    _viettelMarkerMap.update(marker.id, (_) => symbol);
    data.markers.add(marker);
  }

  @override
  Future<void> removeMarker(String markerId) {
    // TODO: implement removeMarker
    throw UnimplementedError();
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
    _addPolygons(data.polygons);
    _addPolylines(data.polylines);
    _addCircles(data.circles);
  }
  void _addPolygons(Set<Polygon> polygons) {
    for (var polygon in polygons) {
      addPolygon(polygon);
    }
  }

  void _addPolylines(Set<Polyline> polylines) {
    for (var polyline in polylines) {
      addPolyline(polyline);
    }
  }

  void _addCircles(Set<Circle> circles) {
    for (var circle in circles) {
      addCircle(circle);
    }
  }

  Future<void> _clearShapes() async {
    _controller.clearCircles();
    _controller.clearLines();
    _controller.clearSymbols();
    _controller.clearRoute();

    _viettelPolygonMap.clear();
    _viettelPolylineMap.clear();
    _viettelCircleMap.clear();
    _viettelMarkerMap.clear();
  }

  void onMapLoaded() {
    _addShapes(_data);
  }
}