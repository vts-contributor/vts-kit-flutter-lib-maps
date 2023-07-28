import 'dart:typed_data';

import 'package:maps_core/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/models/map_objects/bitmap_cache_factory.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

extension ListLatLnConvert on List<LatLng> {
  List<ggmap.LatLng> toGoogle() {
    return map((e) => e.toGoogle()).toList();
  }

  List<vtmap.LatLng> toViettel() {
    return map((e) => e.toViettel()).toList();
  }
}

extension ListPolygonConvert on List<Polygon> {
  List<ggmap.Polygon> toGoogle() {
    return map((e) => e.toGoogle()).toList();
  }

  List<vtmap.FillOptions> toFillOptions() {
    return map((e) => e.toFillOptions()).toList();
  }
}

extension SetPolygonConvert on Set<Polygon> {
  Set<ggmap.Polygon> toGoogle() {
    return map((e) => e.toGoogle()).toSet();
  }

  Set<vtmap.FillOptions> toFillOptions() {
    return map((e) => e.toFillOptions()).toSet();
  }
}

extension SetPolylineConvert on Set<Polyline> {
  Set<ggmap.Polyline> toGoogle() {
    return map((e) => e.toGoogle()).toSet();
  }

  Set<vtmap.LineOptions> toLineOptions() {
    return map((e) => e.toLineOptions()).toSet();
  }
}

extension SetCircleConvert on Set<Circle> {
  Set<ggmap.Circle> toGoogle() {
    return map((e) => e.toGoogle()).toSet();
  }

  Set<vtmap.CircleOptions> toCircleOptions() {
    return map((e) => e.toCircleOptions()).toSet();
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

  Set<vtmap.SymbolOptions> toSymbolOptions() {
    return map((e) => e.toSymbolOptions()).toSet();
  }
}

