import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/controllers/marker_icon_data_processor.dart';

import '../../../maps.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

class GoogleMapController extends BaseCoreMapController
    with ChangeNotifier
    implements MarkerIconDataProcessor {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController _controller;

  final Map<String, Uint8List> _bitmapMap = {};

  gg.CameraPosition _currentCameraPosition;

  GoogleMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callbacks,
  }):_currentCameraPosition = data.initialCameraPosition.toGoogle(), super(callbacks);

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

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _controller.animateCamera(cameraUpdate.toGoogle());
  }
}