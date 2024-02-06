import 'package:flutter/material.dart';
import 'package:maps_core/maps/models/map_objects/map_objects.dart';

class ClusterData {
  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double? alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  final Anchor? anchor;

  /// True if the marker is draggable by user touch events.
  final bool? draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool? flat;

  /// A description of the bitmap used to draw the marker icon.
  final MarkerIcon? icon;

  /// A Google Maps InfoWindow.
  ///
  /// The window is displayed when the marker is tapped.
  final InfoWindow? infoWindow;
  /// Rotation of the marker image in degrees clockwise from the [anchor] point.
  final double? rotation;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int? zIndex;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// cluster can expand to marker when tap
  final bool expandOnTap;

  ClusterData({
    this.alpha,
    this.anchor,
    this.draggable,
    this.flat,
    this.icon,
    this.infoWindow,
    this.rotation,
    this.zIndex,
    this.onTap,
    this.expandOnTap = false,
  });
}
