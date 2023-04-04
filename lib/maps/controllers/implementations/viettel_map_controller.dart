import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:collection/collection.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

import '../../../maps.dart';
import '../../models/map_objects/marker_icon_data_processor.dart';


class ViettelMapController extends BaseCoreMapController {

  final vt.MapboxMapController _controller;

  final CoreMapShapes _shapes;

  final CameraPosition _initialCameraPosition;

  //Store core map shape id to vtmap shape mapping so that we can remove them later
  final Map<String, ViettelPolygon> _viettelPolygonMap = {};
  final Map<String, vt.Line> _viettelPolylineMap = {};
  final Map<String, ViettelCircle> _viettelCircleMap = {};
  final Map<String, vt.Symbol> _viettelMarkerMap = {};

  //used to check if marker icon has been added
  final Set<String> _markerIconNames = {};

  final MarkerIconDataProcessor markerIconDataProcessor;

  ViettelMapController(this._controller, {
    required CoreMapData data,
    CoreMapShapes? shapes,
    CoreMapCallbacks? callbacks,
    required this.markerIconDataProcessor,
  }): _shapes = shapes?.clone() ?? CoreMapShapes(),
        _initialCameraPosition = data.initialCameraPosition,
        super(callbacks) {
    _initHandlers();
  }

  @override
  CoreMapType get coreMapType => CoreMapType.viettel;

  Future<void> updatePolygons(Set<Polygon> polygons) async {
    await _updateMapObjects(_shapes.polygons, polygons,
      addFunc: (polygons) => _addMapObjects(polygons, _addPolygon),
      removeFunc: (ids) => _removeMapObject(ids, _removePolygon),
    );
  }

  Future<void> updatePolylines(Set<Polyline> polylines) async {
    await _updateMapObjects(_shapes.polylines, polylines,
      addFunc: (polylines) => _addMapObjects(polylines, _addPolyline),
      removeFunc: (ids) => _removeMapObject(ids, _removePolyline),
    );
  }

  Future<void> updateCircles(Set<Circle> circles) async {
    await _updateMapObjects(_shapes.circles, circles,
      addFunc: (circles) => _addMapObjects(circles, _addCircle),
      removeFunc: (ids) => _removeMapObject(ids, _removeCircle),
    );
  }

  Future<void> updateMarkers(Set<Marker> markers) async {
    await _updateMapObjects(_shapes.markers, markers,
      addFunc: (markers) => _addMapObjects(markers, _addMarker),
      removeFunc: (ids) => _removeMapObject(ids, _removeMarker),
    );
  }

  Future<void> _updateMapObjects<T extends MapObject>(Set<T> oldObjects, Set<T> newObjects, {
    required Future<void> Function(Set<T>) addFunc,
    required Future<void> Function(Set<String>) removeFunc,
  }) async {
    final mapObjectUpdates = MapObjectUpdates.from(oldObjects, newObjects);

    Set<String> allRemoveIds = {
      ...mapObjectUpdates.removeIds,
      ...mapObjectUpdates.updateIds
    };

    Set<String> allAddIds = {
      ...mapObjectUpdates.updateIds,
      ...mapObjectUpdates.addIds
    };

    await removeFunc(allRemoveIds);
    await addFunc(newObjects.where((element) => allAddIds.contains(element.id)).toSet());
  }

  Future<void> _addMapObjects<T extends MapObject>(Set<T> mapObjects,
      Future<void> Function(T) addFunc) async {
    for (var mapObject in mapObjects) {
      await addFunc(mapObject);
    }
  }

  Future<void> _removeMapObject(Set<String> ids, Future<void> Function(String) removeFunc) async {
    List<Future> futures = [];
    for (var id in ids) {
      futures.add(removeFunc(id));
    }

    await Future.wait(futures);
  }

  Future<void> _addPolygon(Polygon polygon) async {
    if (_viettelPolygonMap.containsKey(polygon.id)) {
      return;
    }

    //add a dummy object to map
    _viettelPolygonMap.putIfAbsent(polygon.id, () =>
        ViettelPolygon(polygon.id, vt.Fill("dummy", const vt.FillOptions()), []));

    final fill = await _controller.addFill(polygon.toFillOptions());

    List<vt.Line> outlines = await Future
        .wait(polygon.getOutlineLineOptions().map((e) => _controller.addLine(e)));

    _viettelPolygonMap.update(polygon.id, (_) => ViettelPolygon(polygon.id, fill, outlines));
    _shapes.polygons.add(polygon);
  }

  Future<void> _removePolygon(String polygonId) async {
    if (_viettelPolygonMap.containsKey(polygonId)) {
      final polygon = _viettelPolygonMap[polygonId];

      if (polygon != null) {
        _controller.removeFill(polygon.fill);

        for (final outline in polygon.outlines) {
          _controller.removeLine(outline);
        }

        _shapes.polygons.removeWhere((polygon) => polygon.id == polygonId);
        _viettelPolygonMap.removeWhere((key, value) => key == polygonId);
      }
    }
  }

  Future<void> _updatePolygon(Polygon polygon) async {
    ViettelPolygon? updatingPolygon = _viettelPolygonMap[polygon.id];
    if (updatingPolygon == null) {
      return;
    }

    _controller.updateFill(updatingPolygon.fill, polygon.toFillOptions());

    List<vt.Line> lines = updatingPolygon.outlines;
    await Future.wait(lines.map((e) => _controller.removeLine(e)));
    List<vt.Line> newLines = await Future
        .wait(polygon.getOutlineLineOptions().map((e) => _controller.addLine(e)));

    _viettelPolygonMap.update(polygon.id, (_) =>
        ViettelPolygon(polygon.id, updatingPolygon.fill, newLines));
  }

  Future<void> _addPolyline(Polyline polyline) async {
    if (_viettelPolylineMap.containsKey(polyline.id)) {
      return;
    }

    //add a dummy object to map
    _viettelPolylineMap.putIfAbsent(polyline.id, () => vt.Line("dummy", const vt.LineOptions()));
    final line = await _controller.addLine(polyline.toLineOptions());

    _viettelPolylineMap.update(polyline.id, (_) => line);
    _shapes.polylines.add(polyline);
  }

  Future<void> _removePolyline(String polylineId) async {
    if (_viettelPolylineMap.containsKey(polylineId)) {
      final line = _viettelPolylineMap[polylineId];

      if (line != null) {
        _controller.removeLine(line);

        _shapes.polylines.removeWhere((e) => e.id == polylineId);
        _viettelPolylineMap.removeWhere((key, value) => key == polylineId);
      }
    }
  }

  Future<void> _addCircle(Circle circle) async {
    if (_viettelCircleMap.containsKey(circle.id)) {
      return;
    }

    //add a dummy object to map
    _viettelCircleMap.putIfAbsent(circle.id, () => ViettelCircle(circle.id,
        vt.Fill("dummy", const vt.FillOptions()), vt.Line("dummy", const vt.LineOptions())));

    List<LatLng> points = circle.toCirclePoints();

    final fill = await _controller.addFill(circle.toFillOptions(points));
    final outline = await _controller.addLine(circle.toLineOptions(points));

    _viettelCircleMap.update(circle.id, (_) => ViettelCircle(circle.id, fill, outline));
    _shapes.circles.add(circle);
  }

  Future<void> _removeCircle(String circleId) async {
    if (_viettelCircleMap.containsKey(circleId)) {
      final circle = _viettelCircleMap[circleId];

      if (circle != null) {
        _controller.removeFill(circle.fill);
        _controller.removeLine(circle.outline);

        _shapes.circles.removeWhere((e) => e.id == circleId);
        _viettelCircleMap.removeWhere((key, value) => key == circleId);
      }
    }
  }

  Future<void> _addMarker(Marker marker) async {
    if (_viettelMarkerMap.containsKey(marker.id)) {
      return;
    }

    //add a dummy object to map
    _viettelMarkerMap.putIfAbsent(marker.id, () => vt.Symbol("dummy", const vt.SymbolOptions()));

    //marker resource must has been initialized before being added to the map
    if (!_markerIconNames.contains(marker.icon.data.name)) {
      _markerIconNames.add(marker.icon.data.name);
      Uint8List bitmap = await marker.icon.data.initResource(markerIconDataProcessor);
      _controller.addImage(marker.icon.data.name, bitmap);
    }

    final symbol = await _controller.addSymbol(marker.toSymbolOptions());

    _viettelMarkerMap.update(marker.id, (_) => symbol);
    _shapes.markers.add(marker);
  }

  Future<void> _removeMarker(String markerId) async {
    if (_viettelMarkerMap.containsKey(markerId)) {
      final marker = _viettelMarkerMap[markerId];

      if (marker != null) {
        _controller.removeSymbol(marker);

        _shapes.markers.removeWhere((e) => e.id == markerId);
        _viettelMarkerMap.removeWhere((key, value) => key == markerId);
      }
    }
  }

  @override
  void onDispose() {
    _controller.dispose();
  }

  Future<void> _addShapes(CoreMapShapes shapes) async {
    _addMapObjects(shapes.polygons, _addPolygon);
    _addMapObjects(shapes.polylines, _addPolyline);
    _addMapObjects(shapes.circles, _addCircle);
    _addMapObjects(shapes.markers, _addMarker);
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

  Future<void> onStyleLoaded() async {
    _addShapes(_shapes);

    callbacks?.onMapCreated?.call(this);
  }

  @override
  CameraPosition getCurrentPosition() {
    return _controller.cameraPosition?.toCore() ?? _initialCameraPosition;
  }

  void _initHandlers() {
    _initCameraMoveHandler();
    _initMarkerTapHandler();
    _initPolygonTapHandler();
    _initCircleTapHandler();
    _initPolylineTapHandler();
  }

  void _initCameraMoveHandler() {
    if (callbacks?.onCameraMove != null) {
      _controller.addListener(() {
        if (_controller.isCameraMoving) {
          _onCameraMove(_controller.cameraPosition);
        }
      });
    }
  }

  void _initMarkerTapHandler() {
    _controller.onSymbolTapped.add((vtSymbol) {
      String? markerId = _viettelMarkerMap.keyWhere((value) => value.id == vtSymbol.id);
      final marker = _shapes.markers.firstWhereOrNull((element) => element.id == markerId);
      if (marker != null) {
        if (marker.onTap != null) {
          marker.onTap?.call();
        } else {
          _defaultMarkerOnTap(marker);
        }
      }
    });
  }

  void _initCircleTapHandler() {
    _controller.onCircleTapped.add((vtCircle) {
      String? circleId = _viettelCircleMap.keyWhere((value) => value.id == vtCircle.id);
      final circle = _shapes.circles.firstWhereOrNull((element) => element.id == circleId);
      circle?.onTap?.call();
    });
  }

  void _initPolylineTapHandler() {
    _controller.onLineTapped.add((vtLine) {
      String? polylineId = _viettelPolylineMap.keyWhere((value) => value.id == vtLine.id);
      final polyline = _shapes.polylines.firstWhereOrNull((element) => element.id == polylineId);
      polyline?.onTap?.call();
    });
  }

  void _initPolygonTapHandler() {

    void callPolygonOnTapById(String? id) {
      final polygon = _shapes.polygons.firstWhereOrNull((element) => element.id == id);
      polygon?.onTap?.call();
    }

    //check if polygon's outlines are tapped?
    _controller.onLineTapped.add((vtLine) {
      String? polygonId = _viettelPolygonMap.keyWhere(
              (vtPolygon) => vtPolygon.outlines.firstWhereOrNull(
                      (outline) => outline.id == vtLine.id)
                  != null
      );

      callPolygonOnTapById(polygonId);
    });

    //check if the fill is tapped?
    _controller.onFillTapped.add((fill) {
      String? polygonId = _viettelPolygonMap.keyWhere((value) => value.fill.id == fill.id);

      callPolygonOnTapById(polygonId);
    });
  }

  void _onCameraMove(vt.CameraPosition? position) {
    if (position != null) {
      callbacks?.onCameraMove?.call(position.toCore());
    }
  }

  void onCameraMovingStarted() {
    callbacks?.onCameraMoveStarted?.call();
  }

  void onCameraIdle() {
    callbacks?.onCameraMoveStarted?.call();
  }

  void onMapClick(vt.LatLng latLng) {
    callbacks?.onTap?.call(latLng.toCore());
  }

  void onMapLongClick(vt.LatLng latLng) {
    callbacks?.onLongPress?.call(latLng.toCore());
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    return (await _controller.toScreenLocation(latLng.toViettel())).toScreenCoordinate();
  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    return (await _controller.toLatLng(screenCoordinate.toPoint())).toCore();
  }

  void _defaultMarkerOnTap(Marker marker) {
    animateCamera(CameraUpdate.newLatLng(marker.position));
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _controller.animateCamera(cameraUpdate: cameraUpdate.toViettel());
  }
}