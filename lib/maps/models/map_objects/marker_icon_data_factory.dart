
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:maps_core/maps/extensions/utils.dart';
import 'package:maps_core/maps/models/map_objects/bitmap_cache_factory.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon_data_processor.dart';

///A cache factory for marker icon bitmaps
class MarkerIconDataFactory implements MarkerIconDataProcessor, BitmapCacheFactory {

  final Map<String, Uint8List> _cache = {};

  @override
  Future<Uint8List> processAssetMarkerIcon(AssetMarkerIconData markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      final  assetBitmap = await rootBundle.loadImageAsUint8List(markerIconData.value);
      final resizedBitmap = _resizeBitmap(
          assetBitmap, markerIconData.height, markerIconData.width);
      _cache.putIfAbsent(markerIconData.name, () => resizedBitmap);
      return resizedBitmap;
    });
  }

  Uint8List _resizeBitmap(Uint8List bitmap, int? height, int? width) {
    if (height == null && width == null) {
      return bitmap;
    }

    Image? img = decodeImage(bitmap);
    if (img == null) return bitmap;

    Image resized = copyResize(img, height: height ?? img.height, width: width ?? img.width);
    return encodePng(resized);
  }

  @override
  Future<Uint8List> processBitmapMarkerIcon(BitmapMarkerIconData markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      _cache.putIfAbsent(markerIconData.name, () => markerIconData.value);
      return markerIconData.value;
    });
  }

  @override
  Future<Uint8List> processNetworkMarkerIcon(NetworkMarkerIconData markerIconData) async {
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