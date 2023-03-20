import 'package:maps_core/maps/models/extensions/convert_extensions.dart';
import 'package:maps_core/maps/models/lat_lng.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:maps_core/maps/models/polygon.dart';
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