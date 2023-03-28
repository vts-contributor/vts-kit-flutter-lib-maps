import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/controllers/marker_icon_data_processor.dart';
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/core_map_type.dart';
import 'package:maps_core/maps/models/map_objects/map_object.dart';

import '../../../log/log.dart';
import '../../../maps.dart';
import '../../models/core_map_data.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

class GoogleMapController extends BaseCoreMapController
    with ChangeNotifier
    implements MarkerIconDataProcessor {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController _controller;

  CoreMapData _data;

  final Map<String, Uint8List> _bitmapMap = {};

  gg.CameraPosition _currentCameraPosition;

  @override
  CoreMapData get data => _data;

  GoogleMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callback,
  }): _data = data,
        _currentCameraPosition = data.initialCameraPosition.toGoogle(),
        super(callback)
  {
    _initAssets(data);
  }

  Future<void> _initAssets(CoreMapData data) async {
    for (final marker in data.markers) {
      await marker.icon.data.initResource(this);
    }
  }

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
    await marker.icon.data.initResource(this);
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
    _controller.moveCamera(gg.CameraUpdate.newCameraPosition(
        data.initialCameraPosition.toGoogle()));
    notifyListeners();
  }

  @override
  void onDispose() {
    dispose();
    _controller.dispose();
  }

  @override
  Future<void> processAssetMarkerIcon(MarkerIconData<String> markerIconData) async {
    if (_checkMarkerIconWasAdded(markerIconData)) return;

    final Uint8List bitmap = await rootBundle.loadImageAsUint8List(markerIconData.data);

    _bitmapMap.putIfAbsent(markerIconData.name, () => bitmap);
    notifyListeners();
  }

  @override
  Future<void> processBitmapMarkerIcon(MarkerIconData<Uint8List> markerIconData) async {
    if (_checkMarkerIconWasAdded(markerIconData)) return;

    _bitmapMap.putIfAbsent(markerIconData.name, () => markerIconData.data);
    notifyListeners();
  }

  @override
  Future<void> processNetworkMarkerIcon(MarkerIconData<String> markerIconData) async {
    if (_checkMarkerIconWasAdded(markerIconData)) return;

    Uint8List bitmap = await Dio().downloadImageToBitmap(markerIconData.data);

    _bitmapMap.putIfAbsent(markerIconData.name, () => bitmap);
    notifyListeners();
  }

  bool _checkMarkerIconWasAdded(MarkerIconData data) {
    return _bitmapMap.containsKey(data.name);
  }

  Uint8List? getBitmapOf(String name) {
    return _bitmapMap[name];
  }

  @override
  CameraPosition getCurrentPosition() {
    return _currentCameraPosition.toCore();
  }

  void onCameraMove(gg.CameraPosition position) {
    _currentCameraPosition = position;

    callbacks?.onCameraMove?.call(position.toCore());
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    return (await _controller.getScreenCoordinate(latLng.toGoogle())).toCore();
  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    return (await _controller.getLatLng(screenCoordinate.toGoogle())).toCore();
  }
}