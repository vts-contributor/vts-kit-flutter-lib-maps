import 'package:flutter/material.dart';
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

  @override
  MarkerCover copyWith({
    double? alphaParam,
    Anchor? anchorParam,
    bool? draggableParam,
    bool? flatParam,
    MarkerIcon? iconParam,
    InfoWindow? infoWindowParam,
    LatLng? positionParam,
    double? rotationParam,
    bool? visibleParam,
    int? zIndexParam,
    VoidCallback? onTapParam,
    ValueChanged<LatLng>? onDragStartParam,
    ValueChanged<LatLng>? onDragParam,
    ValueChanged<LatLng>? onDragEndParam,
    BoundMarker? boundParam,
    PointMarker? pointParam,
    bool? isClusteredParam,
    LatLng? positionMarkerCoverParam,
    bool? isCanClusterParam,
  }) {
    return MarkerCover(
      id: id,
      alpha: alphaParam ?? alpha,
      anchor: anchorParam ?? anchor,
      draggable: draggableParam ?? draggable,
      flat: flatParam ?? flat,
      icon: iconParam ?? icon,
      infoWindow: infoWindowParam ?? infoWindow,
      position: positionParam ?? position,
      rotation: rotationParam ?? rotation,
      visible: visibleParam ?? visible,
      zIndex: zIndexParam ?? zIndex,
      onTap: onTapParam ?? onTap,
      onDragStart: onDragStartParam ?? onDragStart,
      onDrag: onDragParam ?? onDrag,
      onDragEnd: onDragEndParam ?? onDragEnd,
      bound: boundParam ?? bound,
      point: pointParam ?? point,
      isClustered: isClusteredParam ?? isClustered,
      positionMarkerCover: positionMarkerCoverParam ?? positionMarkerCover,
      isCanCluster: isCanClusterParam ?? isCanCluster,
    );
  }

  MarkerCover copyFromCluster(Cluster cluster) {
    return MarkerCover(
      id: id,
      alpha: cluster.alpha,
      anchor: cluster.anchor,
      draggable: cluster.draggable,
      flat: cluster.flat,
      icon: cluster.icon,
      infoWindow: cluster.infoWindow,
      position: cluster.position,
      rotation: cluster.rotation,
      visible: cluster.visible,
      zIndex: cluster.zIndex,
      onTap: cluster.onTap,
      onDragStart: cluster.onDragStart,
      onDrag: cluster.onDrag,
      onDragEnd: cluster.onDragEnd,
      bound: cluster.bound,
      point: cluster.point,
      isClustered: false,
      positionMarkerCover: cluster.positionMarkerCover,
      isCanCluster: cluster.isCanCluster,
    );
  }
}
