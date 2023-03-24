import 'dart:typed_data';

import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/controllers/base_core_map_controller.dart';

import '../../controllers/marker_icon_data_processor.dart';

//used to hide accept() from client
class MarkerIcon {
  final MarkerIconData _data;

  const MarkerIcon._(this._data);

  MarkerIconData get data => _data;

  static const MarkerIcon defaultIcon = MarkerIcon._(AssetMarkerIconData(
    Constant.markerDefaultName, Constant.markerDefaultAssetPath
  ));

  static MarkerIcon fromAsset(final String name,final String assetPath) =>
       MarkerIcon._(AssetMarkerIconData(name, assetPath));

  static MarkerIcon fromNetwork(final String name, final String url) =>
      MarkerIcon._(NetworkMarkerIconData(name, url));
}

abstract class MarkerIconData<T> {
  final String _name;
  final T _data;

  String get name => _name;

  T get data => _data;

  const MarkerIconData(this._name, this._data);

  Future<void> initResource(MarkerIconDataProcessor controller);
}

class AssetMarkerIconData extends MarkerIconData<String> {
  const AssetMarkerIconData(super.name, super.data);

  @override
  Future<void> initResource(MarkerIconDataProcessor controller) async {
    await controller.processAssetMarkerIcon(this);
  }
}

class NetworkMarkerIconData extends MarkerIconData<String> {
  const NetworkMarkerIconData(super.name, super.data);

  @override
  Future<void> initResource(MarkerIconDataProcessor controller) async {
    await controller.processNetworkMarkerIcon(this);
  }

}

class BitmapMarkerIconData extends MarkerIconData<Uint8List> {
  BitmapMarkerIconData(super.name, super.data);

  @override
  Future<void> initResource(MarkerIconDataProcessor controller) async {
    await controller.processBitmapMarkerIcon(this);
  }

}
