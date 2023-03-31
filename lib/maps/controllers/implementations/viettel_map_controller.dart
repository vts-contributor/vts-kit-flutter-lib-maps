import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:collection/collection.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

import '../../../maps.dart';
import '../marker_icon_data_processor.dart';


class ViettelMapController extends BaseCoreMapController implements MarkerIconDataProcessor {

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

  ViettelMapController(this._controller, {
    required CoreMapData data,
    CoreMapShapes? shapes,
    CoreMapCallbacks? callback,
  }): _shapes = shapes ?? CoreMapShapes(),
        _initialCameraPosition = data.initialCameraPosition,
        super(callback) {
    _initHandlers();
  }
  @override
  CoreMapType get coreMapType => CoreMapType.viettel;

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
    _shapes.polygons.add(polygon);
  }

  Future<void> removePolygon(String polygonId) async {
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

  Future<void> addPolyline(Polyline polyline) async {
    if (_viettelPolylineMap.containsKey(polyline.id)) {
      return;
    }

    //add a dummy object to map
    _viettelPolylineMap.putIfAbsent(polyline.id, () => vt.Line("dummy", const vt.LineOptions()));
    final line = await _controller.addLine(polyline.toLineOptions());

    _viettelPolylineMap.update(polyline.id, (_) => line);
    _shapes.polylines.add(polyline);
  }

  Future<void> removePolyline(String polylineId) async {
    if (_viettelPolylineMap.containsKey(polylineId)) {
      final line = _viettelPolylineMap[polylineId];

      if (line != null) {
        _controller.removeLine(line);

        _shapes.polylines.removeWhere((e) => e.id == polylineId);
        _viettelPolylineMap.removeWhere((key, value) => key == polylineId);
      }
    }
  }

  Future<void> addCircle(Circle circle) async {
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

  @override
  Future<void> removeCircle(String circleId) async {
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

  @override
  Future<void> addMarker(Marker marker) async {
    if (_viettelMarkerMap.containsKey(marker.id)) {
      return;
    }

    //add a dummy object to map
    _viettelMarkerMap.putIfAbsent(marker.id, () => vt.Symbol("dummy", const vt.SymbolOptions()));

    //marker resource must has been initialized before being added to the map
    await marker.icon.data.initResource(this);
    final symbol = await _controller.addSymbol(marker.toSymbolOptions());

    _viettelMarkerMap.update(marker.id, (_) => symbol);
    _shapes.markers.add(marker);
  }

  @override
  Future<void> removeMarker(String markerId) async {
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
    _addPolygons(shapes.polygons);
    _addPolylines(shapes.polylines);
    _addCircles(shapes.circles);
    _addMarkers(shapes.markers);
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

  void _addMarkers(Set<Marker> markers) {
    for (var marker in markers) {
      addMarker(marker);
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

  Future<void> onStyleLoaded() async {
    _addShapes(_shapes);

    callbacks?.onMapCreated?.call(this);
  }

  @override
  Future<void> processAssetMarkerIcon(MarkerIconData<String> markerIconData) async {
    if (_checkMarkerIconDataWasAdded(markerIconData)) return;

    _markerIconNames.add(markerIconData.name);

    if (! await _controller.addImageFromAsset(markerIconData.name, markerIconData.data)) {
      _markerIconNames.remove(markerIconData.name);
    }
  }

  @override
  Future<void> processBitmapMarkerIcon(MarkerIconData<Uint8List> markerIconData) async {
    if (_checkMarkerIconDataWasAdded(markerIconData)) return;

    _markerIconNames.add(markerIconData.name);

    await _controller.addImage(markerIconData.name, markerIconData.data);
  }

  @override
  Future<void> processNetworkMarkerIcon(MarkerIconData<String> markerIconData) async {
    if (_checkMarkerIconDataWasAdded(markerIconData)) return;

    _markerIconNames.add(markerIconData.name);

    Uint8List bitmap = await Dio().downloadImageToBitmap(markerIconData.data);

    await _controller.addImage(markerIconData.name,bitmap);
  }
  bool _checkMarkerIconDataWasAdded(MarkerIconData data) {
    return _markerIconNames.contains(data.name);
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