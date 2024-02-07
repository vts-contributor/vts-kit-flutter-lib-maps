import 'package:maps_core/maps.dart';

class MarkerCover extends Marker {
  MarkerCover({
    required super.id,
    super.alpha = 1.0,
    super.anchor = Anchor.bottom,
    super.draggable = false,
    super.flat = false,
    super.icon = MarkerIcon.defaultIcon,
    super.infoWindow,
    required super.position,
    super.rotation = 0.0,
    super.visible = true,
    super.zIndex = 0,
    super.onTap,
    super.onDrag,
    super.onDragStart,
    super.onDragEnd,
    this.bound,
    this.point,
    this.isClustered = false,
    required this.positionMarkerCover,
    super.isCanCluster = true,
  }) {
    setPosition(position);
  }

  /// boundary of marker from point and adjust by zoom
  late BoundMarker? bound;

  /// point (x;y) of marker transfer from position
  late PointMarker? point;

  /// check if marker is clustered
  bool isClustered = false;

  /// Geographical location of the marker.
  late LatLng positionMarkerCover;

  void setPosition(LatLng positionValue) {
    positionMarkerCover = positionValue;
    point = positionMarkerCover.toPoint();
  }
}
