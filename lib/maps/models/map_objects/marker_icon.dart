import 'dart:typed_data';

import 'package:maps_core/maps/constants.dart';

import 'marker_icon_data_processor.dart';

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
  final T _value;

  String get name => _name;

  T get value => _value;

  const MarkerIconData(this._name, this._value);

  Future<Uint8List> initResource(MarkerIconDataProcessor processor);
}

class AssetMarkerIconData extends MarkerIconData<String> {
  const AssetMarkerIconData(super.name, super.data);

  @override
  Future<Uint8List> initResource(MarkerIconDataProcessor processor) async {
    return await processor.processAssetMarkerIcon(this);
  }
}

class NetworkMarkerIconData extends MarkerIconData<String> {
  const NetworkMarkerIconData(super.name, super.data);

  @override
  Future<Uint8List> initResource(MarkerIconDataProcessor processor) async {
    return await processor.processNetworkMarkerIcon(this);
  }

}

class BitmapMarkerIconData extends MarkerIconData<Uint8List> {
  BitmapMarkerIconData(super.name, super.data);

  @override
  Future<Uint8List> initResource(MarkerIconDataProcessor processor) async {
    return await processor.processBitmapMarkerIcon(this);
  }

}
