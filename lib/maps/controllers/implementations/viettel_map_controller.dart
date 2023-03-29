import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/models/viettel/viettel_polygon.dart';
import 'package:collection/collection.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

import '../../../maps.dart';
import '../marker_icon_data_processor.dart';


class ViettelMapController extends BaseCoreMapController implements MarkerIconDataProcessor {

  final vt.MapboxMapController _controller;

  CoreMapData _data;

  //Store core map shape id to vtmap shape mapping so that we can remove them later
  final Map<String, ViettelPolygon> _viettelPolygonMap = {};
  final Map<String, vt.Line> _viettelPolylineMap = {};
  final Map<String, vt.Circle> _viettelCircleMap = {};
  final Map<String, vt.Symbol> _viettelMarkerMap = {};

  //used to check if marker icon has been added
  final Set<String> _markerIconNames = {};

  ViettelMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callback,
  }): _data = data, super(callback) {
    _initHandlers();
  }
  @override
  CoreMapType get coreMapType => CoreMapType.viettel;

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

    //marker resource must has been initialized before being added to the map
    await marker.icon.data.initResource(this);
    final symbol = await _controller.addSymbol(marker.toSymbolOptions());

    _viettelMarkerMap.update(marker.id, (_) => symbol);
    data.markers.add(marker);
  }

  @override
  Future<void> removeMarker(String markerId) async {
    if (_viettelMarkerMap.containsKey(markerId)) {
      final marker = _viettelMarkerMap[markerId];

      if (marker != null) {
        _controller.removeSymbol(marker);

        data.markers.removeWhere((e) => e.id == markerId);
        _viettelMarkerMap.removeWhere((key, value) => key == markerId);
      }
    }
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
    _addMarkers(data.markers);
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
    _addShapes(_data);

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
    return _controller.cameraPosition?.toCore() ?? data.initialCameraPosition;
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
      final marker = data.markers.firstWhereOrNull((element) => element.id == markerId);
      marker?.onTap?.call();
    });
  }

  void _initCircleTapHandler() {
    _controller.onCircleTapped.add((vtCircle) {
      String? circleId = _viettelCircleMap.keyWhere((value) => value.id == vtCircle.id);
      final circle = data.circles.firstWhereOrNull((element) => element.id == circleId);
      circle?.onTap?.call();
    });
  }

  void _initPolylineTapHandler() {
    _controller.onLineTapped.add((vtLine) {
      String? polylineId = _viettelPolylineMap.keyWhere((value) => value.id == vtLine.id);
      final polyline = data.polylines.firstWhereOrNull((element) => element.id == polylineId);
      polyline?.onTap?.call();
    });
  }

  void _initPolygonTapHandler() {

    void callPolygonOnTapById(String? id) {
      final polygon = data.polygons.firstWhereOrNull((element) => element.id == id);
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
    _controller.moveCamera(vt.CameraUpdate.newLatLng(
      marker.position.toViettel()
    ));
    CameraPosition cameraPosition = CameraPosition(target: LatLng(0,0));

  }

  @override
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await _controller.moveCamera(cameraUpdate.toViettel());
  }
}