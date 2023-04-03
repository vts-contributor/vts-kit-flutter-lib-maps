import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon_data_processor.dart';

import '../../../maps.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;

class GoogleMapController extends BaseCoreMapController
    with ChangeNotifier {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController _controller;

  gg.CameraPosition _currentCameraPosition;

  final MarkerIconDataProcessor markerIconDataProcessor;

  GoogleMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callbacks,
    required this.markerIconDataProcessor,
  }):_currentCameraPosition = data.initialCameraPosition.toGoogle(), super(callbacks);
  @override
  void onDispose() {
    dispose();
    _controller.dispose();
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

  Future<void> updateMarkers(Set<Marker> newMarkers) async {
    List<Future> markerFutures = [];
    for (final marker in newMarkers) {
      //process all marker data to check if there are new maker icons
      markerFutures.add(marker.icon.data.initResource(markerIconDataProcessor));
    }
    await Future.wait(markerFutures);

    notifyListeners();
  }
}