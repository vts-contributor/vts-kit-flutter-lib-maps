
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:maps_core/maps/extensions/utils.dart';
import 'package:maps_core/maps/models/map_objects/bitmap_cache_factory.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon_data_processor.dart';

import '../../utils/widget_converter.dart';

///A cache factory for marker icon bitmaps
class MarkerIconDataFactory implements MarkerIconDataProcessor, BitmapCacheFactory {

  final Map<String, Uint8List> _cache = {};

  @override
  Future<Uint8List> processAssetMarkerIcon(AssetMarkerIconData markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      final  assetBitmap = await rootBundle.loadImageAsUint8List(markerIconData.value);
      final resizedBitmap = _resizeBitmap(
          assetBitmap, markerIconData.height, markerIconData.width);
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
      return markerIconData.value;
    });
  }

  @override
  Future<Uint8List> processNetworkMarkerIcon(NetworkMarkerIconData markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      return await Dio().downloadImageToBitmap(markerIconData.value);
    });
  }

  Future<Uint8List> _getBitmapOrElse(String name, {
    required Future<Uint8List> Function() orElse,
  }) async {
    Uint8List? bitmap = getCachedBitmap(name);

    if (bitmap != null) {
      return bitmap;
    } else {
      Uint8List bitmap = await orElse();
      _cache.putIfAbsent(name, () => bitmap);
      return bitmap;
    }
  }

  @override
  Uint8List? getCachedBitmap(String name) {
    return _cache[name];
  }

  @override
  Future<void> validateCache(List<String> validNames) async {
    _cache.removeWhere((key, value) => !validNames.contains(key));
  }

  @override
  Future<Uint8List> processWidgetMarkerIcon(WidgetMarkerIconData markerIconData) async {
    return _getBitmapOrElse(markerIconData.name, orElse: () async {
      return await WidgetConverter().widgetToBitmap(markerIconData.value);
    });
  }

  @override
  ui.Size? sizeOf(String name) {
    Uint8List? bitmap = getCachedBitmap(name);
    if (bitmap != null) {
      Image? image = decodeImage(bitmap);
      if (image != null) {
        return Size(image.width.toDouble(), image.height.toDouble());
      }
    }
    return null;
  }
}