import 'package:flutter/material.dart';
import 'package:maps_core/maps/models/map_objects/map_objects.dart';

class Cluster extends MarkerCover {
  Cluster({
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
    super.bound,
    super.point,
    super.isClustered = false,
    required super.positionMarkerCover,
    required this.markerSet,
  });

  // set marker of cluster
  Set<MarkerCover> markerSet = {};

  @override
  Cluster copyWith({
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
    Set<MarkerCover>? markerSetParam,
  }) {
    return Cluster(
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
      markerSet: markerSetParam ?? markerSet,
    );
  }

  Cluster copyFromCLusterData(ClusterData data) {
    return Cluster(
      id: id,
      alpha: data.alpha ?? alpha,
      anchor: data.anchor ?? anchor,
      draggable: data.draggable ?? draggable,
      flat: data.flat ?? flat,
      icon: data.icon ?? icon,
      infoWindow: data.infoWindow ?? infoWindow,
      position: position,
      rotation: data.rotation ?? rotation,
      visible: visible,
      zIndex: data.zIndex ?? zIndex,
      onTap: () {
        if (data.expandOnTap) {
          onTap?.call();
        }
        data.onTap?.call();
      },
      onDragStart: onDragStart,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
      bound: bound,
      point: point,
      isClustered: isClustered,
      positionMarkerCover: positionMarkerCover,
      markerSet: markerSet,
    );
  }
}
