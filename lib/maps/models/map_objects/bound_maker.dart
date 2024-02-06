import 'package:maps_core/maps/models/map_objects/point.dart';

class BoundMarker {
  final double minX;
  final double minY;

  final double maxX;
  final double maxY;

  late final double midX;
  late final double midY;

  BoundMarker(this.minX, this.maxX, this.minY, this.maxY) {
    midX = (minX + maxX) / 2;
    midY = (minY + maxY) / 2;
  }

  bool contains(double x, double y) {
    return minX <= x && x <= maxX && minY <= y && y <= maxY;
  }

  bool containPoint(PointMarker point) {
    return contains(point.x, point.y);
  }

  bool intersects(double minX, double maxX, double minY, double maxY) {
    return minX < this.maxX &&
        this.minX < maxX &&
        minY < this.maxY &&
        this.minY < maxY;
  }

  bool intersectBound(BoundMarker bounds) {
    return intersects(bounds.minX, bounds.maxX, bounds.minY, bounds.maxY);
  }

  bool containsBound(BoundMarker bounds) {
    return bounds.minX >= minX &&
        bounds.maxX <= maxX &&
        bounds.minY >= minY &&
        bounds.maxY <= maxY;
  }
}
