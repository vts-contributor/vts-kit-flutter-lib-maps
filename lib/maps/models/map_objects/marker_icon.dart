import 'dart:typed_data';

import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/constants.dart';

import 'marker_icon_data_processor.dart';

//used to hide accept() from client
class MarkerIcon {
  final MarkerIconData _data;

  const MarkerIcon._(this._data);

  MarkerIconData get data => _data;

  static const MarkerIcon defaultIcon = MarkerIcon._(AssetMarkerIconData(
      Constant.markerDefaultName, Constant.markerDefaultAssetPath));

  static MarkerIcon fromAsset(
    final String name,
    final String assetPath, {
    int? height,
    int? width,
  }) =>
      MarkerIcon._(
          AssetMarkerIconData(name, assetPath, height: height, width: width));

  static MarkerIcon fromNetwork(final String name, final String url) =>
      MarkerIcon._(NetworkMarkerIconData(name, url));

  static MarkerIcon fromBitmap(final String name, final Uint8List bitmap) =>
      MarkerIcon._(BitmapMarkerIconData(name, bitmap));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MarkerIcon && data == other.data;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => data.hashCode;
}

abstract class MarkerIconData<T> {
  final String _name;
  final T _value;

  String get name => _name;

  T get value => _value;

  const MarkerIconData(this._name, this._value);

  Future<Uint8List> initResource(MarkerIconDataProcessor processor);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MarkerIconData<T> &&
        name == other.name &&
        value == other.value;
  }

  @override
  int get hashCode => name.hashCode;
}

class AssetMarkerIconData extends MarkerIconData<String> {
  final int? height;
  final int? width;
  const AssetMarkerIconData(
    super.name,
    super.data, {
    this.height,
    this.width,
  });

  @override
  Future<Uint8List> initResource(MarkerIconDataProcessor processor) async {
    return await processor.processAssetMarkerIcon(this);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AssetMarkerIconData &&
        height == other.height &&
        width == other.width &&
        name == other.name &&
        value == other.value;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String get name => "${super.name}-${width}x$height";
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
