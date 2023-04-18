
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/maps/extensions/utils.dart';
import 'package:maps_core/maps/models/map_objects/bitmap_cache_factory.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon_data_processor.dart';

///A cache factory for marker icon bitmaps
class MarkerIconDataFactory implements MarkerIconDataProcessor, BitmapCacheFactory {

  final Map<String, Uint8List> _cache = {};

  @override
  Future<Uint8List> processAssetMarkerIcon(MarkerIconData<String> markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      final assetBitmap = await rootBundle.loadImageAsUint8List(markerIconData.value);
      _cache.putIfAbsent(markerIconData.name, () => assetBitmap);
      return assetBitmap;
    });
  }

  @override
  Future<Uint8List> processBitmapMarkerIcon(MarkerIconData<Uint8List> markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      _cache.putIfAbsent(markerIconData.name, () => markerIconData.value);
      return markerIconData.value;
    });
  }

  @override
  Future<Uint8List> processNetworkMarkerIcon(MarkerIconData<String> markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      final networkBitmap = await Dio().downloadImageToBitmap(markerIconData.value);
      _cache.putIfAbsent(markerIconData.name, () => networkBitmap);
      return networkBitmap;
    });
  }

  Future<Uint8List> _getBitmapOrElse(String name, {
    required Future<Uint8List> Function() orElse,
  }) async {
    Uint8List? bitmap = getCachedBitmap(name);

    if (bitmap != null) {
      return bitmap;
    } else {
      return orElse();
    }
  }

  @override
  Uint8List? getCachedBitmap(String name) {
    return _cache[name];
  }
}