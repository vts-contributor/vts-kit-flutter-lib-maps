import 'package:maps_core/maps.dart';

import 'map_objects/map_objects.dart';

///Data object for map shapes. Just for convenient
class CoreMapShapes {

  ///CoreMap Polygon
  final Set<Polygon> polygons;

  ///CoreMap Polyline
  final Set<Polyline> polylines;

  ///CoreMap Circle
  final Set<Circle> circles;

  ///CoreMap Markers
  final Set<Marker> markers;

  CoreMapShapes({
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    Set<Marker>? markers,
  }): polygons = polygons ?? {},
        polylines = polylines ?? {},
        circles = circles ?? {},
        markers = markers ?? {};

  CoreMapShapes clone() {
    return CoreMapShapes(
      polygons: Set.from(polygons),
      polylines: Set.from(polylines),
      circles: Set.from(circles),
      markers: Set.from(markers),
    );
  }

  CoreMapShapes copyWith({
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    Set<Marker>? markers,
  }) {
    return CoreMapShapes(
      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,
      circles: circles ?? this.circles,
      markers: markers ?? this.markers,
    );
  }

  Set<MapObject> toSet() {
    return {...polygons, ...polylines, ...circles, ...markers};
  }
}