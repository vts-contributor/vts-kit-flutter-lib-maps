import 'dart:typed_data';

import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/models/map_objects/bitmap_cache_factory.dart';
import 'package:image/image.dart' as img;

extension ListLatLnConvert on List<LatLng> {
  List<ggmap.LatLng> toGoogle() {
    return map((e) => e.toGoogle()).toList();
  }
}

extension ListPolygonConvert on List<Polygon> {
  List<ggmap.Polygon> toGoogle() {
    return map((e) => e.toGoogle()).toList();
  }
}

extension SetPolygonConvert on Set<Polygon> {
  Set<ggmap.Polygon> toGoogle() {
    return map((e) => e.toGoogle()).toSet();
  }
}

extension SetPolylineConvert on Set<Polyline> {
  Set<ggmap.Polyline> toGoogle() {
    return map((e) => e.toGoogle()).toSet();
  }
}

extension SetCircleConvert on Set<Circle> {
  Set<ggmap.Circle> toGoogle() {
    return map((e) => e.toGoogle()).toSet();
  }
}

extension ScaleImage on Uint8List {
  Uint8List? resizeImage(double scale) {
    Uint8List? resizedData;
    img.Image? image = img.decodeImage(this);
    if (image != null) {
      img.Image resized = img.copyResize(image,
          width: (image.width * scale).toInt(),
          height: (image.height * scale).toInt());
      resizedData = img.encodePng(resized);
    }
    return resizedData;
  }
}

extension SetMarkerConvert on Set<Marker> {
  ///only return markers whose icon data were initialized
  Set<ggmap.Marker> toGoogle(BitmapCacheFactory cacheFactory) {
    Set<ggmap.Marker> ggMarkers = {};

    for (final marker in this) {
      Uint8List? bitmap = cacheFactory.getCachedBitmap(marker.icon.data.name);
      if (bitmap != null) {
        ggMarkers.add(marker.toGoogle(bitmap));
      }
    }

    return ggMarkers;
  }
}
